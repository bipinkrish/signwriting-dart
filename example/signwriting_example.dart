import 'package:signwriting/signwriting.dart';

void main() {
  print(fswToSign("M123x456S1f720487x492"));
  // Sign { box: SignSymbol { symbol: 'M', position: [123, 456] }, symbols: [SignSymbol { symbol: 'S1f720', position: [487, 492] }] }

  print(swu2fsw('𝠃𝤟𝤩񋛩𝣵𝤐񀀒𝤇𝣤񋚥𝤐𝤆񀀚𝣮𝣭'));
  // M525x535S2e748483x510S10011501x466S2e704510x500S10019476x475

  SignWritingTokenizer tokenizer = SignWritingTokenizer();
  String fsw = 'M123x456S1f720487x492S1f720487x492';
  List<String> tokens = tokenizer.textToTokens(fsw, boxPosition: true);
  print(tokens);
  // [M, p123, p456, S1f7, c2, r0, p487, p492, S1f7, c2, r0, p487, p492]

  print(tokenizer.tokensToText(tokens));
  // M123x456S1f720487x492S1f720487x492

  print(tokenizer.tokenize(fsw, bos: false, eos: false));
  // [6, 932, 932, 255, 678, 660, 919, 924, 255, 678, 660, 919, 924]

  print(normalizeSignWriting(fsw));
  // M123x456S1f720487x492S1f720487x492

  // // Not implemented yet
  // String fsw =
  //     "AS10011S10019S2e704S2e748M525x535S2e748483x510S10011501x466S20544510x500S10019476x475";
  // signwritingToImage(fsw);

  String charA = 'M507x507S1f720487x492';
  String charB = 'M507x507S14720493x485';
  String resultSign = joinSigns(fsws: [charA, charB]);
  print(resultSign);
  // M500x500S1f720487x493S14720493x508
}
