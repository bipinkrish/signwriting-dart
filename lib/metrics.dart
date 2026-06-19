import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:signwriting/formats.dart';
import 'package:signwriting/src/symbol_sizes.g.dart';
import 'package:signwriting/types.dart';
import 'package:tuple/tuple.dart';

// Lazily decoded flat table: bytes[id*2] = width, bytes[id*2+1] = height,
// indexed by key2id. Decoded once on first use.
Uint8List? _sizesCache;
Uint8List get _sizes => _sizesCache ??= base64.decode(packedSymbolSizes);

/// Returns the rendered ink size `(width, height)` of an FSW symbol key
/// (e.g. `S2e748`), measured in the Sutton SignWriting Line font at size 30.
///
/// Mirrors Python `signwriting.visualizer.visualize.get_symbol_size`. Sizes
/// are precomputed (see `tool/generate_sizes.py`) so this works without a font
/// renderer. Returns `(0, 0)` for keys that have no existing ISWA glyph.
Tuple2<int, int> getSymbolSize(String symbol) {
  final id = key2id(symbol);
  final i = id * 2;
  if (id < 0 || i + 1 >= _sizes.length) return const Tuple2(0, 0);
  return Tuple2(_sizes[i], _sizes[i + 1]);
}

/// Whether an FSW symbol key corresponds to an existing ISWA glyph
/// (`width > 0 && height > 0`). Malformed keys return `false`.
///
/// Mirrors the `_symbol_exists` helper used by Python's mirror module.
bool symbolExists(String symbol) {
  try {
    final size = getSymbolSize(symbol);
    return size.item1 > 0 && size.item2 > 0;
  } on FormatException {
    return false;
  }
}

/// Recomputes a sign's bottom-right box corner `(maxX, maxY)` from its symbols'
/// rendered sizes — the tight box used when `trustBox` is off.
///
/// Mirrors Python `signwriting.visualizer.visualize.signwriting_box`.
Tuple2<int, int> signwritingBox(Sign sign) {
  int maxX = 0;
  int maxY = 0;
  for (final symbol in sign.symbols) {
    final size = getSymbolSize(symbol.symbol);
    maxX = max(maxX, symbol.position.item1 + size.item1);
    maxY = max(maxY, symbol.position.item2 + size.item2);
  }
  return Tuple2(maxX, maxY);
}
