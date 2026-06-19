import 'dart:math';

import 'package:signwriting/formats.dart';
import 'package:signwriting/metrics.dart';
import 'package:signwriting/types.dart';
import 'package:tuple/tuple.dart';

/// Rewrites each FSW sign with its symbols in a canonical order, centered on
/// (500, 500), with a tight box.
///
/// Port of Python `signwriting.utils.canonicalize` **without** the
/// rasterization-based step that preserves the relative draw order of
/// *overlapping* symbols (that requires a font renderer; see
/// `signwriting_flutter`). For signs whose symbols don't overlap — the common
/// case — the result is identical to the Python package. For heavily
/// overlapping symbols the box, positions and centering still match; only the
/// order of the overlapping symbols (and thus which renders on top) may differ.
///
/// Symbols are ordered by category (faces, other, hands, contact, movement),
/// then top-to-bottom, then left-to-right. [fsw] must be ASCII Formal
/// SignWriting (convert SWU input with [swu2fsw] first); it may hold multiple
/// whitespace-separated signs, each canonicalized independently.

int _categoryRank(String symbol) {
  final base = int.parse(symbol.substring(1, 4), radix: 16);
  // faces
  if (base >= 0x2ff && base <= 0x36c) return 0;
  // other: head, trunk, limbs, location, punctuation
  if (base >= 0x36d) return 1;
  // hands
  if (base <= 0x204) return 2;
  // contact
  if (base <= 0x220) return 3;
  // movement (0x221-0x2fe)
  return 4;
}

// Bounding box (left, top, right, bottom) from symbols' rendered sizes.
// Assumes a non-empty list.
Tuple2<Tuple2<int, int>, Tuple2<int, int>> _bbox(List<SignSymbol> symbols) {
  int left = symbols.first.position.item1;
  int top = symbols.first.position.item2;
  int right = 0;
  int bottom = 0;
  bool first = true;
  for (final s in symbols) {
    final size = getSymbolSize(s.symbol);
    left = min(left, s.position.item1);
    top = min(top, s.position.item2);
    final r = s.position.item1 + size.item1;
    final b = s.position.item2 + size.item2;
    right = first ? r : max(right, r);
    bottom = first ? b : max(bottom, b);
    first = false;
  }
  return Tuple2(Tuple2(left, top), Tuple2(right, bottom));
}

bool _inRange(String symbol, int lo, int hi) {
  final base = int.parse(symbol.substring(1, 4), radix: 16);
  return base >= lo && base <= hi;
}

Tuple2<int, int> _centerOffset(List<SignSymbol> symbols) {
  final box = _bbox(symbols);
  int left = box.item1.item1;
  int top = box.item1.item2;
  int right = box.item2.item1;
  int bottom = box.item2.item2;

  final faces = symbols.where((s) => _inRange(s.symbol, 0x2ff, 0x36c)).toList();
  if (faces.isNotEmpty) {
    final fb = _bbox(faces);
    left = fb.item1.item1;
    right = fb.item2.item1;
  }
  final bodies =
      symbols.where((s) => _inRange(s.symbol, 0x2ff, 0x375)).toList();
  if (bodies.isNotEmpty) {
    final bb = _bbox(bodies);
    top = bb.item1.item2;
    bottom = bb.item2.item2;
  }
  return Tuple2(((left + right) ~/ 2) - 500, ((top + bottom) ~/ 2) - 500);
}

// Order by (categoryRank, y, x), stable on original index. (The Python
// topological sort reduces to exactly this when no overlap constraints apply.)
List<SignSymbol> _canonicalOrder(List<SignSymbol> symbols) {
  final indexed = symbols.asMap().entries.toList();
  indexed.sort((a, b) {
    final sa = a.value;
    final sb = b.value;
    int cmp = _categoryRank(sa.symbol).compareTo(_categoryRank(sb.symbol));
    if (cmp != 0) return cmp;
    cmp = sa.position.item2.compareTo(sb.position.item2); // y
    if (cmp != 0) return cmp;
    cmp = sa.position.item1.compareTo(sb.position.item1); // x
    if (cmp != 0) return cmp;
    return a.key.compareTo(b.key); // stable
  });
  return [for (final e in indexed) e.value];
}

String _canonicalizeSign(String fsw) {
  final sign = fswToSign(fsw);
  if (sign.symbols.isEmpty) return fsw;

  final ordered = _canonicalOrder(sign.symbols);
  final box = signwritingBox(sign);
  final offset = _centerOffset(ordered);

  final canonical = Sign(
    box: SignSymbol(
      symbol: sign.box.symbol,
      position: Tuple2(box.item1 - offset.item1, box.item2 - offset.item2),
    ),
    symbols: [
      for (final s in ordered)
        SignSymbol(
          symbol: s.symbol,
          position: Tuple2(
              s.position.item1 - offset.item1, s.position.item2 - offset.item2),
        ),
    ],
  );
  return signToFsw(canonical);
}

bool _isAscii(String s) => s.codeUnits.every((c) => c < 128);

/// See the library-level note above. Canonicalizes each whitespace-separated
/// sign in [fsw] independently.
String canonicalize(String fsw) {
  if (!_isAscii(fsw)) {
    throw ArgumentError(
        'canonicalize expects ASCII FSW; convert SWU input via swu2fsw first');
  }
  return fsw
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .map(_canonicalizeSign)
      .join(' ');
}
