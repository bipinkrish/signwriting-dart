import 'package:test/test.dart';
import 'package:signwriting/tokenizer/signwriting_tokenizer.dart';

void main() {
  group('Tokenize', () {
    test('Tokenization single sign', () {
      final tokenizer = SignWritingTokenizer();
      final fsw = 'M123x456S1f720487x492S1f720487x492';
      final tokens = tokenizer.textToTokens(fsw, boxPosition: true);
      expect(
          tokens,
          equals([
            'M',
            'p123',
            'p456',
            'S1f7',
            'c2',
            'r0',
            'p487',
            'p492',
            'S1f7',
            'c2',
            'r0',
            'p487',
            'p492'
          ]));
    });

    test('Tokenization no box', () {
      final tokenizer = SignWritingTokenizer();
      final fsw = 'S38800464x496';
      final tokens = tokenizer.textToTokens(fsw);
      expect(tokens,
          equals(['M', 'p500', 'p500', 'S388', 'c0', 'r0', 'p464', 'p496']));
    });

    test('Tokenization multiple signs', () {
      final tokenizer = SignWritingTokenizer();
      final fsw = 'M123x456S1f720487x492 M124x456S1f210488x493';
      final tokens = tokenizer.textToTokens(fsw, boxPosition: true);
      expect(
          tokens,
          equals([
            'M',
            'p123',
            'p456',
            'S1f7',
            'c2',
            'r0',
            'p487',
            'p492',
            'M',
            'p124',
            'p456',
            'S1f2',
            'c1',
            'r0',
            'p488',
            'p493'
          ]));
    });

    test('Tokenization multiple signs no space', () {
      final tokenizer = SignWritingTokenizer();
      final fsw = 'M123x456S1f720487x492M124x456S1f210488x493';
      final tokens = tokenizer.textToTokens(fsw, boxPosition: true);
      expect(
          tokens,
          equals([
            'M',
            'p123',
            'p456',
            'S1f7',
            'c2',
            'r0',
            'p487',
            'p492',
            'M',
            'p124',
            'p456',
            'S1f2',
            'c1',
            'r0',
            'p488',
            'p493'
          ]));
    });

    test('Tokenization with a', () {
      final tokenizer = SignWritingTokenizer();
      final fsw = "AS1f720M123x456S1f720487x492";
      final tokens = tokenizer.textToTokens(fsw, boxPosition: true);
      expect(
          tokens,
          equals([
            'M',
            'p123',
            'p456',
            'S1f7',
            'c2',
            'r0',
            'p487',
            'p492',
          ]));
    });

    test('Not failing for r box', () {
      final tokenizer = SignWritingTokenizer();
      final fsw =
          'M528x518S15a37473x494S1f010488x503S26507515x483 M524x515S1dc20476x485S18720506x486 S38800464x496 M521x576S10021478x555S10029457x555S22a07495x535S22a11461x535S30a00480x483S36d01479x516 M511x590S1f720489x410S1fb20494x554S10120494x429S10e20494x461S17620494x494S16d20494x513S1f720489x536S14a20494x575 M527x561S20302486x439S20300491x456S2890f491x474S22a14473x546S15a40513x514S15a48473x514S22a04514x546 S38700463x496 R521x536S11541471x509S1150a449x511S22a04472x488S36d01479x465 R518x542S1d441493x482S1d437493x517S22a00499x459S22105483x493 R519x515S1ce18481x485S1ce10497x485S2fb06498x500 R518x612S2ff00482x483S10010487x512S15a30485x565S11541487x585S26500503x569 S38700463x496 M562x527S36d01480x516S32107478x483S15a37539x488S15a37517x488 M521x516S20500480x505S10043491x484 M562x518S15a56522x485S18221537x467S26501517x451S22101535x468S2ff00482x483 M525x527S10041504x497S2d60e476x474 M533x518S2b700514x459S15a10521x486S2ff00482x483 S38800464x496 M562x527S36d01480x516S32107478x483S15a37539x488S15a37517x488 M533x518S2ff00482x483S15a10521x484S2b700514x454 M568x528S10149521x459S10142538x447S2be14526x490S2be04548x477S32107482x483 M517x517S10018483x487S10002487x484 M525x527S10041504x497S2d60e476x474 M526x522S10018475x483S26505513x509S10641490x479 M560x518S1f721516x469S1f70f471x468S2ff00482x483S22a17489x460S22a07534x460S14c10537x427S14c18500x432S32107482x483 S38900464x493 M562x527S36d01480x516S32107478x483S15a37539x488S15a37517x488 M533x518S2ff00482x483S15a10521x484S2b700514x454 M518x642S2ff00482x483S10000487x512S15a20494x570S15a56490x630S37800499x596 M522x516S15a37498x489S15a31499x488S2e800479x484 M530x516S10012500x485S18518470x490S2e734494x491 M520x517S20500480x506S10043490x484 S38800464x496'; // noqa: E501
      expect(tokenizer.tokenize(fsw), isList);
    });

    test('Tokenization into IDs', () {
      final tokenizer = SignWritingTokenizer();
      final tokens = ['M', 'p251', 'p456', 'S1f7', 'c2', 'r0', 'p487', 'p492'];
      final ids = tokens.map((t) => tokenizer.s2i[t]).toList();
      expect(ids, equals([6, 683, 888, 255, 678, 660, 919, 924]));
    });
  });

  group('Detokenize', () {
    test('Detokenization single sign', () {
      final tokenizer = SignWritingTokenizer();
      final tokens = [
        'M',
        'p251',
        'p456',
        'S1f7',
        'c2',
        'r0',
        'p487',
        'p492',
        'S1f7',
        'c2',
        'r0',
        'p487',
        'p492'
      ];
      final fsw = tokenizer.tokensToText(tokens);
      expect(fsw, equals('M251x456S1f720487x492S1f720487x492'));
    });

    test('Detokenization multiple signs', () {
      final tokenizer = SignWritingTokenizer();
      final tokens = [
        'M',
        'p251',
        'p456',
        'S1f7',
        'c2',
        'r0',
        'p487',
        'p492',
        'M',
        'p124',
        'p456',
        'S1f2',
        'c1',
        'r0',
        'p488',
        'p493'
      ];
      final fsw = tokenizer.tokensToText(tokens);
      expect(fsw, equals('M251x456S1f720487x492 M124x456S1f210488x493'));
    });
  });
}
