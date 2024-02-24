import 'dart:core';
import 'package:signwriting/formats.dart';
import 'package:signwriting/tokenizer/base_tokenizer.dart';
import 'package:signwriting/types.dart';

class SignWritingTokenizer extends BaseTokenizer {
  SignWritingTokenizer({int? startingIndex})
      : super(
          SignWritingTokenizer.tokens(),
          startingIndex: startingIndex,
        );

  static List<String> tokens() {
    List<String> boxSymbols = ["B", "L", "M", "R"];

    List<String> baseSymbols = [];
    for (int i = 0x10; i <= 0x38; i++) {
      for (int j = 0x0; j <= 0xf; j++) {
        String baseSymbol = "S${i.toRadixString(16)}${j.toRadixString(16)}";
        if (baseSymbol != "S38c" &&
            baseSymbol != "S38d" &&
            baseSymbol != "S38e" &&
            baseSymbol != "S38f") {
          baseSymbols.add(baseSymbol);
        }
      }
    }

    List<String> rows = [];
    for (int j = 0x0; j <= 0xf; j++) {
      rows.add("r${j.toRadixString(16)}");
    }

    List<String> cols = ["c0", "c1", "c2", "c3", "c4", "c5"];

    List<String> positions = [];
    for (int p = 250; p <= 750; p++) {
      positions.add("p$p");
    }

    return [boxSymbols, baseSymbols, rows, cols, positions]
        .expand((element) => element)
        .toList();
  }

  static List<String> tokenizeSymbol(SignSymbol symbol,
      {bool boxPosition = false}) {
    if (['B', 'L', 'M', 'R'].contains(symbol.symbol)) {
      List<String> tokens = [symbol.symbol];

      if (boxPosition) {
        tokens.add("p${symbol.position.item1}");
        tokens.add("p${symbol.position.item2}");
      } else {
        // We position all boxes at 500x500, since the position can be inferred from the other symbols
        tokens.add("p500");
        tokens.add("p500");
      }

      return tokens;
    } else {
      List<String> tokens = [
        symbol.symbol.substring(0, 4)
      ]; // Break symbol down
      int num = int.parse(symbol.symbol.substring(4), radix: 16);
      tokens.add("c${(num ~/ 0x10).toRadixString(16)}");
      tokens.add("r${(num % 0x10).toRadixString(16)}");
      tokens.add("p${symbol.position.item1}");
      tokens.add("p${symbol.position.item2}");

      return tokens;
    }
  }

  @override
  List<String> textToTokens(String text, {bool boxPosition = false}) {
    text = text.replaceAllMapped(
        RegExp(r'([MLBR])'), (match) => ' ${match.group(0)}'); // add spaces
    text = text.replaceAll(RegExp(r'\bA\w*\b'), ''); // remove sign prefix
    text = text.replaceAll(RegExp(r' +'), ' '); // remove consecutive spaces
    text = text.trim();

    List<Sign> signs = [for (String f in text.split(" ")) fswToSign(f)];
    List<String> tokens = [];

    for (Sign sign in signs) {
      tokens.addAll(tokenizeSymbol(sign.box, boxPosition: boxPosition));
      for (SignSymbol symbol in sign.symbols) {
        tokens.addAll(tokenizeSymbol(symbol));
      }
    }
    return tokens;
  }

  @override
  String tokensToText(List<String> tokens) {
    String tokenized = tokens.join(' ');

    tokenized = tokenized.replaceAllMapped(RegExp(r'p(\d*) p(\d*)'),
        (match) => '${match.group(1)}x${match.group(2)}');
    tokenized = tokenized.replaceAllMapped(RegExp(r'c(\d)\d? r(.)'),
        (match) => '${match.group(1)}${match.group(2)}');

    tokenized = tokenized.replaceAllMapped(
        RegExp(r'c(\d)\d?'), (match) => '${match.group(1)} 0');
    tokenized = tokenized.replaceAllMapped(
        RegExp(r'r(.)'), (match) => '0${match.group(1)}');

    tokenized = tokenized.replaceAll(' ', '');
    tokenized = tokenized.replaceAllMapped(RegExp(r'(\d)([MBLR])'),
        (match) => '${match.group(1)} ${match.group(2)}');

    return tokenized;
  }
}
