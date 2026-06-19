import 'package:signwriting/formats.dart';
import 'package:signwriting/metrics.dart';
import 'package:signwriting/types.dart';
import 'package:tuple/tuple.dart';

/// Horizontal mirror for SignWriting symbols and signs.
///
/// Port of Python `signwriting.utils.mirror`. The Sutton SignWriting symbol
/// set (ISWA) splits into ranges that mirror differently (hands, contact,
/// movement arrows, and everything else); the bulk of this file is per-base
/// override tables calibrated against human-confirmed mirror pairs, so that
/// `mirrorSymbol(mirrorSymbol(s)) == s` for every existing ISWA symbol.

// Symbols whose horizontal mirror is not representable as another ISWA symbol;
// returned unchanged.
const Set<String> _noMirrorSymbols = {
  'S2ef24',
  'S2ef25',
  'S2f024',
  'S2f025',
};

// One-off per-symbol overrides that don't fit any base-level rule.
const Map<String, String> _specialMirrorOverrides = {
  'S32320': 'S32324',
  'S32630': 'S32630',
  'S32634': 'S32634',
};
// Inverse lookup, excluding self-pairs (already served by the forward dict).
const Map<String, String> _specialMirrorReverse = {
  'S32324': 'S32320',
};

// Shared fill-mirror dicts.
const Map<String, String> _fill01Swap = {'0': '1', '1': '0'};
const Map<String, String> _fill23Swap = {'2': '3', '3': '2'};
const Map<String, String> _fill45Swap = {'4': '5', '5': '4'};
const Map<String, String> _fill0123Swap = {
  '0': '1',
  '1': '0',
  '2': '3',
  '3': '2'
};
const Map<String, String> _fill012345Swap = {
  '0': '1',
  '1': '0',
  '2': '3',
  '3': '2',
  '4': '5',
  '5': '4',
};
const Map<String, String> _fill1234Swap = {
  '1': '2',
  '2': '1',
  '3': '4',
  '4': '3'
};
const Map<String, String> _fill1245Swap = {
  '1': '2',
  '2': '1',
  '4': '5',
  '5': '4'
};
const Map<String, String> _fill34Swap = {'3': '4', '4': '3'};

// ---------------------------------------------------------------------------
// Section dispatch
// ---------------------------------------------------------------------------
String _section(String base) {
  final value = int.parse(base.substring(1), radix: 16);
  if (value >= 0x100 && value <= 0x204) return 'hand';
  if (value >= 0x205 && value <= 0x216) return 'contact';
  if (value >= 0x217 && value <= 0x2f6) return 'movement';
  return 'other';
}

bool _exists(String symbol) => symbolExists(symbol);

// ---------------------------------------------------------------------------
// Hands  (S100-S204)
// ---------------------------------------------------------------------------
Tuple2<String, int> _mirrorHand(String fill, int rotation) {
  return Tuple2(fill, (rotation + 8) % 16);
}

// ---------------------------------------------------------------------------
// Contact  (S205-S216)
// ---------------------------------------------------------------------------
final Map<String, int> _contactCountCache = {};

int _contactRotationCount(String base, String fill) {
  return _contactCountCache.putIfAbsent('$base$fill', () {
    int n = 0;
    for (int r = 0; r < 16; r++) {
      if (_exists('$base$fill${r.toRadixString(16)}')) {
        n = r + 1;
      } else {
        break;
      }
    }
    return n;
  });
}

Tuple2<String, int> _mirrorContact(String base, String fill, int rotation) {
  final n = _contactRotationCount(base, fill);
  if (n == 0) return Tuple2(fill, rotation);
  return Tuple2(fill, (n - rotation) % n);
}

// ---------------------------------------------------------------------------
// Face, head, dynamics, eyes, mouth, ...  (S2f7+ and the "other" range)
// ---------------------------------------------------------------------------
const Map<int, int> _faceRotationMirror = {
  0: 0,
  1: 7,
  2: 6,
  3: 5,
  4: 4,
  5: 3,
  6: 2,
  7: 1
};
const Map<String, String> _faceFillMirror = {'1': '2', '2': '1'};

const Set<String> _other16RotationBases = {
  'S308',
  'S309',
  'S327',
  'S36f',
  'S370',
  'S371',
  'S37e',
};
const Set<String> _limbBases = {
  'S377',
  'S378',
  'S379',
  'S37a',
  'S37b',
  'S37c',
  'S37d',
};

int _mirrorLimbRotation(int rotation) {
  if (rotation == 0 || rotation == 8) return rotation;
  return (rotation + 8) % 16;
}

const Set<String> _noFillSwapBases = {
  'S302',
  'S304',
  'S305',
  'S306',
  'S307',
  'S308',
  'S309',
  'S321',
  'S322',
  'S323',
  'S324',
  'S325',
  'S326',
  'S327',
  'S328',
  'S329',
  'S361',
  'S368',
  'S369',
  'S36f',
  'S370',
  'S371',
  'S372',
  'S373',
  'S374',
  'S376',
  'S37e',
  'S382',
  'S386',
  'S387',
};
const Map<String, Map<String, String>> _faceFillOverrides = {
  'S30a': _fill1245Swap,
  'S30b': _fill1245Swap,
  'S30c': _fill1245Swap,
  'S30d': _fill1245Swap,
  'S30e': _fill1245Swap,
  'S30f': _fill1245Swap,
  'S310': _fill1245Swap,
  'S335': _fill1245Swap,
  'S336': _fill1245Swap,
  'S356': _fill1245Swap,
  'S317': _fill1234Swap,
  'S32b': _fill1234Swap,
  'S32c': _fill1234Swap,
  'S330': _fill1234Swap,
  'S357': _fill45Swap,
  'S358': _fill45Swap,
  'S365': _fill45Swap,
  'S36b': _fill23Swap,
  'S36c': _fill23Swap,
  'S2f7': _fill0123Swap,
  'S2f9': _fill0123Swap,
  'S2fa': _fill0123Swap,
  'S339': _fill012345Swap,
  'S33a': _fill012345Swap,
};
const Set<String> _otherXor4Bases = {'S328', 'S329', 'S386'};
const Set<String> _otherXor2Bases = {'S304', 'S305', 'S372', 'S373', 'S374'};
const Map<String, Map<int, int>> _otherBaseRotationMaps = {
  'S382': {0: 0, 1: 2, 2: 1, 3: 4, 4: 3, 5: 6, 6: 5, 7: 8, 8: 7},
  'S376': {
    0: 0,
    1: 9,
    2: 10,
    3: 11,
    4: 12,
    5: 14,
    6: 15,
    7: 13,
    8: 8,
    9: 1,
    10: 2,
    11: 3,
    12: 4,
    13: 7,
    14: 5,
    15: 6,
  },
};
const Set<String> _otherXor1Bases = {'S302', 'S306', 'S307'};
const Set<String> _faceWith04SwapBases = {'S326', 'S387'};
const Map<int, int> _faceWith04SwapRotation = {
  0: 4,
  1: 7,
  2: 6,
  3: 5,
  4: 0,
  5: 3,
  6: 2,
  7: 1
};
const Map<String, Map<String, Map<int, int>>> _perFillRotationMaps = {
  'S36e': {
    '0': {0: 0, 1: 5, 2: 4, 3: 3, 4: 2, 5: 1},
    '1': {0: 3, 1: 5, 2: 4, 3: 0, 4: 2, 5: 1},
    '2': {0: 3, 1: 5, 2: 4, 3: 0, 4: 2, 5: 1},
    '3': {0: 3, 1: 5, 2: 4, 3: 0, 4: 2, 5: 1},
    '4': {0: 1, 1: 0, 2: 2, 3: 3, 4: 5, 5: 4},
  },
  'S372': {
    '2': {0: 0, 1: 3, 2: 2, 3: 1},
  },
};

int _faceRotation(String base, int rotation) {
  if (_limbBases.contains(base)) return _mirrorLimbRotation(rotation);
  if (_other16RotationBases.contains(base)) return (rotation + 8) % 16;
  if (_otherXor4Bases.contains(base)) return rotation ^ 4;
  if (_otherXor2Bases.contains(base)) return rotation ^ 2;
  if (_otherXor1Bases.contains(base)) return rotation ^ 1;
  if (_faceWith04SwapBases.contains(base)) {
    return _faceWith04SwapRotation[rotation] ?? rotation;
  }
  return _faceRotationMirror[rotation] ?? rotation;
}

Tuple2<String, int> _mirrorFace(String base, String fill, int rotation) {
  if (_perFillRotationMaps.containsKey(base)) {
    final rotationMap = _perFillRotationMaps[base]![fill];
    if (rotationMap != null) {
      return Tuple2(fill, rotationMap[rotation] ?? rotation);
    }
  }
  if (base == 'S383') return Tuple2(fill, rotation);
  if (_otherBaseRotationMaps.containsKey(base)) {
    final rotationMap = _otherBaseRotationMaps[base]!;
    return Tuple2(fill, rotationMap[rotation] ?? rotation);
  }
  if (base == 'S36d') return _mirrorContact(base, fill, rotation);
  final newRotation = _faceRotation(base, rotation);
  if (_noFillSwapBases.contains(base)) return Tuple2(fill, newRotation);
  final fillMap = _faceFillOverrides[base] ?? _faceFillMirror;
  final swappedFill = fillMap[fill] ?? fill;
  if (swappedFill != fill &&
      _exists('$base$swappedFill${newRotation.toRadixString(16)}')) {
    return Tuple2(swappedFill, newRotation);
  }
  return Tuple2(fill, newRotation);
}

// ---------------------------------------------------------------------------
// Movement arrows  (S217-S2f6)
// ---------------------------------------------------------------------------
const Set<String> _xorPairedBases = {
  'S2a6',
  'S2a7',
  'S2a8',
  'S2a9',
  'S2aa',
  'S2ab',
  'S2ad',
  'S2ae',
  'S2af',
  'S2b0',
  'S2b1',
  'S2b2',
  'S2ba',
  'S2bc',
  'S2bd',
  'S2be',
  'S2bf',
  'S2c0',
  'S2c1',
  'S2c2',
};
const Set<String> _alternatingRotationBases = {'S2ac', 'S2b3'};
const Map<int, int> _axisFoldRotation = {
  0: 1,
  1: 0,
  2: 7,
  3: 6,
  4: 5,
  5: 4,
  6: 3,
  7: 2
};
const Set<String> _ceilingHitsBases = {
  'S2b7',
  'S2b8',
  'S2c3',
  'S2c4',
  'S2c5',
  'S2c6',
  'S2c7',
  'S2d2',
  'S2d3',
};
const Map<int, int> _s2d4Rotation = {
  0: 4,
  4: 0,
  1: 5,
  5: 1,
  2: 7,
  7: 2,
  3: 6,
  6: 3
};
const Set<String> _plus8RotationBases = {
  'S2a2',
  'S2a3',
  'S2a4',
  'S2df',
  'S2e0',
  'S2e1',
  'S2e7',
  'S2e8',
  'S2e9',
  'S2ea',
  'S2eb',
  'S2ec',
};

const int _movementFillRangeStart = 0x22a;
const Set<String> _movementKeepAllFillBases = {'S2f5', 'S2f6'};

final Map<String, int> _movementFillCountCache = {};

int _movementFillCount(String base) {
  return _movementFillCountCache.putIfAbsent(base, () {
    int n = 0;
    for (int f = 0; f < 6; f++) {
      if (_exists('$base${f}0')) {
        n = f + 1;
      } else {
        break;
      }
    }
    return n;
  });
}

String _movementFill(String base, String fill) {
  if (int.parse(base.substring(1), radix: 16) < _movementFillRangeStart) {
    return fill;
  }
  if (_movementKeepAllFillBases.contains(base)) return fill;
  final count = _movementFillCount(base);
  if (count < 3) return fill;
  if (_fill01Swap.containsKey(fill)) return _fill01Swap[fill]!;
  if (count == 6) return _fill34Swap[fill] ?? fill;
  return fill;
}

const Set<String> _fill01PairedBases = {'S2ef', 'S2f0'};
const Set<String> _diagonalAndFloorStraightBases = {
  'S255',
  'S256',
  'S257',
  'S258',
  'S259',
  'S25a',
  'S25b',
  'S25c',
  'S25d',
  'S25e',
  'S25f',
  'S260',
  'S261',
  'S262',
  'S263',
  'S264',
  'S265',
  'S266',
  'S267',
  'S268',
  'S269',
  'S26a',
  'S26b',
};
const Set<String> _floorHitsBases = {
  'S2b9',
  'S2bb',
  'S2c8',
  'S2c9',
  'S2ca',
  'S2cb',
  'S2cc',
  'S2cd',
  'S2ce',
  'S2cf',
  'S2d0',
  'S2d1',
};
const Set<String> _fingerCirclesBases = {'S2f3', 'S2f4'};
const Map<int, int> _fingerCirclesRotation = {
  0: 2,
  2: 0,
  1: 3,
  3: 1,
  4: 5,
  5: 4,
  6: 7,
  7: 6
};

final Map<String, bool> _movement16Cache = {};

bool _movementHas16Rotations(String base) {
  return _movement16Cache.putIfAbsent(
      base, () => _exists('${base}08') || _exists('${base}18'));
}

int _movementRotation(String base, String fill, int rotation) {
  if (_floorHitsBases.contains(base) || _ceilingHitsBases.contains(base)) {
    return _axisFoldRotation[rotation] ?? rotation;
  }
  if (base == 'S2d4') return _s2d4Rotation[rotation] ?? rotation;
  if (_plus8RotationBases.contains(base)) return (rotation + 8) % 16;
  if (base == 'S2f2') return rotation ^ 4;
  if (_alternatingRotationBases.contains(base)) return 3 - rotation;
  if (_xorPairedBases.contains(base)) return rotation ^ 1;
  if (_fill01PairedBases.contains(base)) {
    return _fill01Swap.containsKey(fill) ? rotation : rotation ^ 1;
  }
  if (_fingerCirclesBases.contains(base)) {
    return _fingerCirclesRotation[rotation] ?? rotation;
  }
  if (_diagonalAndFloorStraightBases.contains(base)) {
    return _faceRotationMirror[rotation] ?? rotation;
  }
  if (_movementHas16Rotations(base)) return (rotation + 8) % 16;
  return _mirrorContact(base, fill, rotation).item2;
}

Tuple2<String, int> _mirrorMovement(String base, String fill, int rotation) {
  return Tuple2(
      _movementFill(base, fill), _movementRotation(base, fill, rotation));
}

// ---------------------------------------------------------------------------
// Symbol mirror
// ---------------------------------------------------------------------------
/// Returns the horizontal mirror of an FSW symbol key (e.g. `S2e748`).
///
/// Symbols that don't exist in the font — and the handful with no
/// representable ISWA mirror — pass through unchanged.
String mirrorSymbol(String symbol) {
  final override = _specialMirrorOverrides[symbol];
  if (override != null) return override;
  final reverse = _specialMirrorReverse[symbol];
  if (reverse != null) return reverse;
  if (_noMirrorSymbols.contains(symbol)) return symbol;
  if (!_exists(symbol)) return symbol;

  final base = symbol.substring(0, 4);
  final fill = symbol[4];
  final rotation = int.parse(symbol[5], radix: 16);
  final section = _section(base);

  final Tuple2<String, int> mirrored;
  switch (section) {
    case 'hand':
      mirrored = _mirrorHand(fill, rotation);
      break;
    case 'contact':
      mirrored = _mirrorContact(base, fill, rotation);
      break;
    case 'movement':
      mirrored = _mirrorMovement(base, fill, rotation);
      break;
    default:
      mirrored = _mirrorFace(base, fill, rotation);
  }

  final candidate = '$base${mirrored.item1}${mirrored.item2.toRadixString(16)}';
  return _exists(candidate) ? candidate : symbol;
}

// ---------------------------------------------------------------------------
// Position flip
// ---------------------------------------------------------------------------
const int _axis = 1000;
const Map<String, String> _boxMirror = {'L': 'R', 'R': 'L'};

// Python's round() uses banker's rounding (half to even); replicate it so
// mirrored positions match the reference byte-for-byte.
int _pythonRound(double value) {
  final floor = value.floor();
  final diff = value - floor;
  if (diff < 0.5) return floor;
  if (diff > 0.5) return floor + 1;
  return floor.isEven ? floor : floor + 1;
}

int _mirrorX(int x, int origWidth, int newWidth) {
  final center = x + origWidth / 2;
  return _pythonRound(_axis - center - newWidth / 2);
}

bool _isAscii(String s) => s.codeUnits.every((c) => c < 128);

/// Returns the horizontal mirror of an FSW sign.
///
/// [fsw] must be ASCII Formal SignWriting. For SWU input, convert with
/// [swu2fsw] first.
String mirrorSign(String fsw) {
  if (!_isAscii(fsw)) {
    throw ArgumentError(
        'mirrorSign expects ASCII FSW; convert SWU input via swu2fsw first');
  }

  final sign = fswToSign(fsw);
  if (sign.symbols.isEmpty) return fsw;

  final boxMarker = _boxMirror[sign.box.symbol] ?? sign.box.symbol;
  final boxY = sign.box.position.item2;
  final origMinX =
      sign.symbols.map((s) => s.position.item1).reduce((a, b) => a < b ? a : b);

  final mirroredSymbols = <SignSymbol>[];
  for (final entry in sign.symbols) {
    final original = entry.symbol;
    final mirrored = mirrorSymbol(original);
    final origWidth = getSymbolSize(original).item1;
    final newWidth = getSymbolSize(mirrored).item1;
    mirroredSymbols.add(SignSymbol(
      symbol: mirrored,
      position: Tuple2(_mirrorX(entry.position.item1, origWidth, newWidth),
          entry.position.item2),
    ));
  }

  final mirroredSign = Sign(
    box:
        SignSymbol(symbol: boxMarker, position: Tuple2(_axis - origMinX, boxY)),
    symbols: mirroredSymbols,
  );
  return signToFsw(mirroredSign);
}
