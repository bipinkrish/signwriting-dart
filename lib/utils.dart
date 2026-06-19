import 'dart:math';

import 'package:signwriting/formats.dart';
import 'package:signwriting/metrics.dart';
import 'package:signwriting/types.dart';
import 'package:tuple/tuple.dart';

// Extracts all coordinate values along an axis ("x" or "y") from a sign's symbols.
List<int> _allAxis(Sign sign, String axis) {
  return sign.symbols
      .map((s) => axis == 'x' ? s.position.item1 : s.position.item2)
      .toList();
}

// Converts FSW strings to signs, dropping any that have no symbols.
List<Sign> _initJoin(List<String> fsws) {
  return [for (final fsw in fsws) fswToSign(fsw)]
      .where((sign) => sign.symbols.isNotEmpty)
      .toList();
}

/// Builds a [Sign] from a list of symbols, computing a tight box centered on
/// (500, 500) from the symbols' rendered sizes and repositioning the symbols
/// into that reference frame.
///
/// When [fixX] / [fixY] is false the corresponding axis is left untouched
/// (used by the directional joins, which fix only the joining axis).
///
/// Mirrors Python `signwriting.utils.join_signs.sign_from_symbols`.
Sign signFromSymbols(List<SignSymbol> symbols,
    {bool fixX = true, bool fixY = true}) {
  int minX = 999;
  int minY = 999;
  int maxX = 0;
  int maxY = 0;
  for (final symbol in symbols) {
    minX = min(minX, symbol.position.item1);
    minY = min(minY, symbol.position.item2);
    final size = getSymbolSize(symbol.symbol);
    maxX = max(maxX, symbol.position.item1 + size.item1);
    maxY = max(maxY, symbol.position.item2 + size.item2);
  }

  final boxX = 500 + (maxX - minX) ~/ 2;
  final boxY = 500 + (maxY - minY) ~/ 2;
  final sizeX = maxX - minX;
  final sizeY = maxY - minY;

  final newSymbols = <SignSymbol>[];
  for (final symbol in symbols) {
    int x = symbol.position.item1;
    int y = symbol.position.item2;
    if (fixX) x += boxX - minX - sizeX;
    if (fixY) y += boxY - minY - sizeY;
    newSymbols.add(SignSymbol(symbol: symbol.symbol, position: Tuple2(x, y)));
  }

  return Sign(
    box: SignSymbol(symbol: 'M', position: Tuple2(boxX, boxY)),
    symbols: newSymbols,
  );
}

/// Stacks signs vertically (top to bottom), with optional [spacing] between them.
///
/// Mirrors Python `signwriting.utils.join_signs.join_signs_vertical`.
String joinSignsVertical(List<String> fsws, {int spacing = 0}) {
  final signs = _initJoin(fsws);
  final symbols = <SignSymbol>[];
  int accumulativeOffset = 0;

  for (final sign in signs) {
    final signMinY = _allAxis(sign, 'y').reduce(min);
    final signOffsetY = accumulativeOffset + spacing - signMinY;
    accumulativeOffset += (sign.box.position.item2 - signMinY) + spacing;

    for (final symbol in sign.symbols) {
      symbols.add(SignSymbol(
        symbol: symbol.symbol,
        position:
            Tuple2(symbol.position.item1, symbol.position.item2 + signOffsetY),
      ));
    }
  }

  if (symbols.isEmpty) return 'M500x500';
  return signToFsw(signFromSymbols(symbols, fixX: false));
}

/// Arranges signs horizontally (left to right), with optional [spacing] between them.
///
/// Mirrors Python `signwriting.utils.join_signs.join_signs_horizontal`.
String joinSignsHorizontal(List<String> fsws, {int spacing = 0}) {
  final signs = _initJoin(fsws);
  final symbols = <SignSymbol>[];
  int accumulativeOffset = 0;

  for (final sign in signs) {
    final signMinX = _allAxis(sign, 'x').reduce(min);
    final signOffsetX = accumulativeOffset + spacing - signMinX;
    accumulativeOffset += (sign.box.position.item1 - signMinX) + spacing;

    for (final symbol in sign.symbols) {
      symbols.add(SignSymbol(
        symbol: symbol.symbol,
        position:
            Tuple2(symbol.position.item1 + signOffsetX, symbol.position.item2),
      ));
    }
  }

  if (symbols.isEmpty) return 'M500x500';
  return signToFsw(signFromSymbols(symbols, fixY: false));
}

/// Joins signs vertically. Kept for backwards compatibility.
@Deprecated('Use joinSignsVertical instead')
String joinSigns({required List<String> fsws, int spacing = 0}) {
  return joinSignsVertical(fsws, spacing: spacing);
}
