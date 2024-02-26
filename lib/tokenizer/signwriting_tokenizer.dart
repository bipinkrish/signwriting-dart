import 'dart:core';
import 'package:signwriting/formats.dart';
import 'package:signwriting/tokenizer/base_tokenizer.dart';
import 'package:signwriting/types.dart';

/// SignWritingTokenizer class extends BaseTokenizer for tokenization and detokenization of SignWriting symbols.
class SignWritingTokenizer extends BaseTokenizer {
  /// Constructor for SignWritingTokenizer.
  ///
  /// [startingIndex]: Starting index for token IDs.
  SignWritingTokenizer({int? startingIndex})
      : super(
          SignWritingTokenizer.tokens(),
          startingIndex: startingIndex,
        );

  /// Method to generate the list of tokens for SignWriting symbols.
  static List<String> tokens() {
    List<String> boxSymbols = ["B", "L", "M", "R"]; // Box symbols

    List<String> baseSymbols = [];
    // Generating base symbols using hexadecimal values
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
    // Generating row symbols using hexadecimal values
    for (int j = 0x0; j <= 0xf; j++) {
      rows.add("r${j.toRadixString(16)}");
    }

    List<String> cols = ["c0", "c1", "c2", "c3", "c4", "c5"]; // Column symbols

    List<String> positions = [];
    // Generating position symbols from 250 to 750
    for (int p = 250; p <= 750; p++) {
      positions.add("p$p");
    }

    // Combining all token categories and returning a flattened list
    return [boxSymbols, baseSymbols, rows, cols, positions]
        .expand((element) => element)
        .toList();
  }

  /// Method to tokenize a SignSymbol into a list of tokens.
  static List<String> tokenizeSymbol(SignSymbol symbol,
      {bool boxPosition = false}) {
    if (['B', 'L', 'M', 'R'].contains(symbol.symbol)) {
      // If the symbol is a box symbol
      List<String> tokens = [symbol.symbol]; // Adding box symbol
      if (boxPosition) {
        tokens.add("p${symbol.position.item1}"); // Adding x-coordinate
        tokens.add("p${symbol.position.item2}"); // Adding y-coordinate
      } else {
        tokens.add("p500"); // Assuming default position of 500x500
        tokens.add("p500"); // Assuming default position of 500x500
      }
      return tokens;
    } else {
      // If the symbol is a base symbol
      List<String> tokens = [
        symbol.symbol.substring(0, 4)
      ]; // Adding base symbol
      int num = int.parse(symbol.symbol.substring(4),
          radix: 16); // Parsing symbol number
      tokens.add("c${(num ~/ 0x10).toRadixString(16)}"); // Adding column
      tokens.add("r${(num % 0x10).toRadixString(16)}"); // Adding row
      tokens.add("p${symbol.position.item1}"); // Adding x-coordinate
      tokens.add("p${symbol.position.item2}"); // Adding y-coordinate
      return tokens;
    }
  }

  @override
  List<String> textToTokens(String text, {bool boxPosition = false}) {
    // Preprocessing text
    text = text.replaceAllMapped(
        RegExp(r'([MLBR])'), (match) => ' ${match.group(0)}'); // Add spaces
    text = text.replaceAll(RegExp(r'\bA\w*\b'), ''); // Remove sign prefix
    text = text.replaceAll(RegExp(r' +'), ' '); // Remove consecutive spaces
    text = text.trim();

    List<Sign> signs = [
      for (String f in text.split(" ")) fswToSign(f)
    ]; // Splitting text into FSW signs and converting them to Sign objects
    List<String> tokens = [];

    // Tokenizing each sign
    for (Sign sign in signs) {
      tokens.addAll(tokenizeSymbol(sign.box,
          boxPosition: boxPosition)); // Tokenizing box symbol
      for (SignSymbol symbol in sign.symbols) {
        tokens.addAll(tokenizeSymbol(symbol)); // Tokenizing other symbols
      }
    }
    return tokens;
  }

  @override
  String tokensToText(List<String> tokens) {
    String tokenized = tokens.join(' '); // Joining tokens into a single string

    // Replacing position tokens with 'x' separator
    tokenized = tokenized.replaceAllMapped(RegExp(r'p(\d*) p(\d*)'),
        (match) => '${match.group(1)}x${match.group(2)}');
    // Replacing column and row tokens with simplified format
    tokenized = tokenized.replaceAllMapped(RegExp(r'c(\d)\d? r(.)'),
        (match) => '${match.group(1)}${match.group(2)}');
    // Replacing single-digit columns with two-digit format
    tokenized = tokenized.replaceAllMapped(
        RegExp(r'c(\d)\d?'), (match) => '${match.group(1)} 0');
    // Replacing single-digit rows with two-digit format
    tokenized = tokenized.replaceAllMapped(
        RegExp(r'r(.)'), (match) => '0${match.group(1)}');
    // Removing spaces between digits and box symbols
    tokenized = tokenized.replaceAll(' ', '');
    tokenized = tokenized.replaceAllMapped(
        RegExp(r'(\d)([MBLR])'),
        (match) =>
            '${match.group(1)} ${match.group(2)}'); // Adding space between digit and box symbol

    return tokenized; // Returning the detokenized FSW string
  }
}
