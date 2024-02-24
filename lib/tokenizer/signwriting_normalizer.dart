import 'package:signwriting/tokenizer/signwriting_tokenizer.dart';

// Define a class to hold the cached tokenizer instance
class TokenizerCache {
  static SignWritingTokenizer? _cachedTokenizer;

  static SignWritingTokenizer getTokenizer() {
    _cachedTokenizer ??= SignWritingTokenizer();
    return _cachedTokenizer!;
  }
}

// Define the normalizeSignWriting function
String normalizeSignWriting(String fsw) {
  final tokenizer = TokenizerCache.getTokenizer();
  final tokens = tokenizer.textToTokens(fsw, boxPosition: true);
  return tokenizer.tokensToText(tokens);
}
