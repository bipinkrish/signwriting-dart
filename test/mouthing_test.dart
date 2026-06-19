import 'package:signwriting/signwriting.dart';
import 'package:test/test.dart';

void main() {
  // Expected values verified against the Python `signwriting` package
  // (mouth_ipa with epitran stubbed out — epitran is not needed for IPA input).
  group('mouthIpaSingle', () {
    test('without aspiration (default)', () {
      expect(mouthIpaSingle('ɑː'), 'M518x518S34c00482x482');
    });

    test('with aspiration', () {
      expect(mouthIpaSingle('ɑː', aspiration: true), 'M518x518S34c00482x483');
    });

    test('strips syllabic consonant markers', () {
      expect(mouthIpaSingle('ɛ̩'), mouthIpaSingle('ɛ'));
    });
  });

  group('mouthIpa', () {
    test('joins concatenated symbols', () {
      expect(mouthIpa('ɑːɛ'), 'M531x518S34c00469x482S34a00495x482');
    });

    test('joins space-separated words', () {
      expect(mouthIpa('ɑː ɛ'), 'M541x518S34c00459x482S34a00505x482');
    });

    test('returns null for unmappable IPA', () {
      expect(mouthIpa('#'), isNull);
      expect(mouthIpa('qqq'), isNull);
    });
  });

  group('mouth', () {
    test('uses the supplied g2p and fills in fsw + swu', () {
      final result = mouth('whatever', g2p: (word) => 'ɑː');
      expect(result.ipa, 'ɑː');
      expect(result.fsw, 'M518x518S34c00482x482');
      expect(result.swu, '𝠃𝤘𝤘񍲁𝣴𝣴');
    });

    test('fsw and swu are null when IPA is unmappable', () {
      final result = mouth('whatever', g2p: (word) => '#');
      expect(result.ipa, '#');
      expect(result.fsw, isNull);
      expect(result.swu, isNull);
    });
  });
}
