class BaseTokenizer {
  Map<int, String> i2s = {};
  Map<String, int> s2i = {};
  late String padToken;
  late String bosToken;
  late String eosToken;
  late String unkToken;

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

    for (int i = 0; i < tokens.length; i++) {
      i2s[i + startingIndex] = tokens[i];
    }

    // Following the same ID scheme as JoeyNMT
    i2s[0] = unkToken;
    i2s[1] = padToken;
    i2s[2] = bosToken;
    i2s[3] = eosToken;

    for (int i in i2s.keys) {
      s2i[i2s[i]!] = i;
    }

    padTokenId = s2i[padToken]!;
    bosTokenId = s2i[bosToken]!;
    eosTokenId = s2i[eosToken]!;
    unkTokenId = s2i[unkToken]!;
  }

  int padTokenId = -1;
  int bosTokenId = -1;
  int eosTokenId = -1;
  int unkTokenId = -1;

  int get length => i2s.length;

  List<String> vocab() {
    return i2s.values.toList();
  }

  List<String> textToTokens(String text) {
    throw UnimplementedError();
  }

  String tokensToText(List<String> tokens) {
    throw UnimplementedError();
  }

  List<int> tokenize(String text, {bool bos = false, bool eos = false}) {
    List<int> tokenIds =
        textToTokens(text).map((token) => s2i[token]!).toList();
    if (bos) tokenIds.insert(0, bosTokenId);
    if (eos) tokenIds.add(eosTokenId);
    return tokenIds;
  }

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
