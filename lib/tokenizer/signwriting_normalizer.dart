import 'package:signwriting/tokenizer/signwriting_tokenizer.dart';

// Define a class to hold the cached tokenizer instance
class TokenizerCache {
  static SignWritingTokenizer?
      _cachedTokenizer; // Cached instance of SignWritingTokenizer

  // Method to get the tokenizer instance
  static SignWritingTokenizer getTokenizer() {
    // If the tokenizer instance is not cached, create a new instance and cache it
    _cachedTokenizer ??= SignWritingTokenizer();
    return _cachedTokenizer!;
  }
}

// Define the normalizeSignWriting function
String normalizeSignWriting(String fsw) {
  final tokenizer = TokenizerCache
      .getTokenizer(); // Getting the tokenizer instance from the cache
  final tokens = tokenizer.textToTokens(fsw,
      boxPosition: true); // Tokenizing the FSW string with box position
  return tokenizer.tokensToText(tokens); // Converting tokens back to text
}
