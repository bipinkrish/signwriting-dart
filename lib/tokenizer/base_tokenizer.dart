/// BaseTokenizer class for tokenization and detokenization.
class BaseTokenizer {
  Map<int, String> i2s = {}; // Map to store index to string mapping
  Map<String, int> s2i = {}; // Map to store string to index mapping
  late String padToken; // Padding token
  late String bosToken; // Beginning of sequence token
  late String eosToken; // End of sequence token
  late String unkToken; // Unknown token

  /// Constructor for BaseTokenizer.
  ///
  /// [tokens]: List of tokens.
  /// [startingIndex]: Starting index for token IDs.
  /// [initToken]: Initial token for beginning of sequence.
  /// [eosToken]: Token for end of sequence.
  /// [padToken]: Token for padding.
  /// [unkToken]: Token for unknown elements.
  BaseTokenizer(List<String> tokens,
      {int? startingIndex,
      String initToken = "[CLS]",
      String eosToken = "[SEP]",
      String padToken = "[PAD]",
      String unkToken = "[UNK]"}) {
    startingIndex ??= 4;

    padToken = padToken;
    bosToken = initToken;
    eosToken = eosToken;
    unkToken = unkToken;

    // Mapping tokens to their corresponding indices
    for (int i = 0; i < tokens.length; i++) {
      i2s[i + startingIndex] = tokens[i];
    }

    // Following the same ID scheme as JoeyNMT
    i2s[0] = unkToken;
    i2s[1] = padToken;
    i2s[2] = bosToken;
    i2s[3] = eosToken;

    // Mapping strings to their corresponding indices
    for (int i in i2s.keys) {
      s2i[i2s[i]!] = i;
    }

    // Setting token IDs
    padTokenId = s2i[padToken]!;
    bosTokenId = s2i[bosToken]!;
    eosTokenId = s2i[eosToken]!;
    unkTokenId = s2i[unkToken]!;
  }

  // Token IDs
  int padTokenId = -1;
  int bosTokenId = -1;
  int eosTokenId = -1;
  int unkTokenId = -1;

  // Length of tokenizer vocabulary
  int get length => i2s.length;

  /// Returns the vocabulary tokens.
  List<String> vocab() {
    return i2s.values.toList();
  }

  /// Converts text to tokens.
  List<String> textToTokens(String text) {
    throw UnimplementedError();
  }

  /// Converts tokens to text.
  String tokensToText(List<String> tokens) {
    throw UnimplementedError();
  }

  /// Tokenizes the text.
  List<int> tokenize(String text, {bool bos = false, bool eos = false}) {
    List<int> tokenIds =
        textToTokens(text).map((token) => s2i[token]!).toList();
    if (bos) tokenIds.insert(0, bosTokenId);
    if (eos) tokenIds.add(eosTokenId);
    return tokenIds;
  }

  /// Detokenizes the tokens.
  String detokenize(List<int> tokens) {
    if (tokens.isEmpty) return "";
    if (tokens[0] == bosTokenId) tokens = tokens.sublist(1);
    if (tokens.isNotEmpty && tokens.last == eosTokenId) {
      tokens = tokens.sublist(0, tokens.length - 1);
    }

    try {
      int paddingIndex = tokens.indexWhere((element) => element == padTokenId);
      if (paddingIndex != -1) tokens = tokens.sublist(0, paddingIndex);
    } catch (e) {
      // Ignore errors if pad token not found
    }

    List<String> detokenizedTokens =
        tokens.map((token) => i2s[token]!).toList();
    return tokensToText(detokenizedTokens);
  }
}
