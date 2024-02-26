import 'dart:core';
import 'package:signwriting/types.dart';
import 'package:tuple/tuple.dart';

// FSW 2 Sign

Sign fswToSign(String fsw) {
  RegExp boxesRegex = RegExp(r'([BLMR])(\d{3})x(\d{3})');
  Iterable<Match> boxes = boxesRegex.allMatches(fsw);
  Match? box = boxes.isNotEmpty ? boxes.first : null;

  String boxSymbol = box != null ? box.group(1)! : "M";
  String x = box != null ? box.group(2)! : "500";
  String y = box != null ? box.group(3)! : "500";

  RegExp symbolsRegex =
      RegExp(r'(S[123][0-9a-f]{2}[0-5][0-9a-f])(\d{3})x(\d{3})');
  Iterable<Match> symbols = symbolsRegex.allMatches(fsw);

  List<SignSymbol> parsedSymbols = [];
  for (Match s in symbols) {
    String symbol = s.group(1)!;
    String posX = s.group(2)!;
    String posY = s.group(3)!;
    parsedSymbols.add(
      SignSymbol(
          symbol: symbol,
          position:
              Tuple2<int, int>.fromList([int.parse(posX), int.parse(posY)])),
    );
  }

  return Sign(
    box: SignSymbol(
        symbol: boxSymbol,
        position: Tuple2<int, int>.fromList([int.parse(x), int.parse(y)])),
    symbols: parsedSymbols,
  );
}

// FSW 2 SWU

String key2swu(String key) {
  return String.fromCharCode(key2id(key) + 0x40000);
}

int key2id(String key) {
  int base = int.parse(key.substring(1, 4), radix: 16);
  int fill = int.parse(key[4], radix: 16);
  int rotation = int.parse(key[5], radix: 16);
  return ((base - 0x100) * 96) + (fill * 16) + rotation + 1;
}

String symbolLine(int symbolId) {
  return String.fromCharCode(symbolId + 0xF0000);
}

String symbolFill(int symbolId) {
  return String.fromCharCode(symbolId + 0x100000);
}

// Sign 2 FSW

String signToFsw(Sign sign) {
  List<SignSymbol> symbols = [sign.box, ...sign.symbols];
  List<String> symbolsStr = symbols
      .map((s) => '${s.symbol}${s.position.item1}x${s.position.item2}')
      .toList();
  return symbolsStr.join('');
}

// SWU 2 FSW

class ReSwu {
  static const String symbol = r'[\u{40001}-\u{4FFFF}]';
  static const String coord = r'[\u{1D80C}-\u{1DFFF}]{2}';
}

String swu2fsw(String swuText) {
  if (swuText.isEmpty) {
    return '';
  }

  // Initial replacements
  String fsw = swuText
      .replaceAll("𝠀", "A")
      .replaceAll("𝠁", "B")
      .replaceAll("𝠂", "L")
      .replaceAll("𝠃", "M")
      .replaceAll("𝠄", "R");

  // SWU symbols to FSW keys
  RegExp symbolRegex = RegExp(ReSwu.symbol, unicode: true);
  Iterable<RegExpMatch> symbols = symbolRegex.allMatches(fsw);
  if (symbols.isNotEmpty) {
    for (RegExpMatch sym in symbols) {
      fsw = fsw.replaceAll(sym.group(0)!, swu2key(sym.group(0)!));
    }
  }

  // SWU coordinates to FSW coordinates
  RegExp coordRegex = RegExp(ReSwu.coord, unicode: true);
  Iterable<RegExpMatch> coords = coordRegex.allMatches(fsw);
  if (coords.isNotEmpty) {
    for (RegExpMatch coord in coords) {
      fsw = fsw.replaceAll(
        coord.group(0)!,
        swu2coord(coord.group(0)!).join('x'),
      );
    }
  }

  return fsw;
}

String swu2key(String swuSym) {
  int symcode = swuSym.runes.first - 0x40001;
  int base = symcode ~/ 96;
  int fill = (symcode - (base * 96)) ~/ 16;
  int rotation = symcode - (base * 96) - (fill * 16);
  return 'S${(base + 0x100).toRadixString(16)}${fill.toRadixString(16)}${rotation.toRadixString(16)}';
}

int swu2num(String swuNum) {
  return swuNum.runes.first - 0x1D80C + 250;
}

List<int> swu2coord(String swuCoord) {
  return [swu2num(swuCoord.substring(0, 2)), swu2num(swuCoord.substring(2, 4))];
}
