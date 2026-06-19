import 'package:signwriting/signwriting.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('getSymbolSize', () {
    test('matches Python get_symbol_size (ink bbox @ size 30)', () {
      // Values produced by the reference PIL implementation.
      expect(getSymbolSize('S10000'), const Tuple2(15, 30));
      expect(getSymbolSize('S10011'), const Tuple2(21, 30));
      expect(getSymbolSize('S10019'), const Tuple2(21, 30));
      expect(getSymbolSize('S2e748'), const Tuple2(16, 26));
    });

    test('returns (0, 0) for symbols with no ISWA glyph', () {
      // S20544's line glyph is absent from the font.
      expect(getSymbolSize('S20544'), const Tuple2(0, 0));
    });
  });

  group('symbolExists', () {
    test('true for real glyphs, false otherwise', () {
      expect(symbolExists('S10000'), isTrue);
      expect(symbolExists('S2e748'), isTrue);
      expect(symbolExists('S20544'), isFalse);
    });
  });

  group('signwritingBox', () {
    test('recomputes the tight bottom-right corner from symbol sizes', () {
      final sign = fswToSign('M525x535S2e748483x510S10011501x466S10019476x475');
      final box = signwritingBox(sign);
      // max over symbols of (x + width, y + height).
      // S2e748@(483,510)->(16,26): (499,536); S10011@(501,466)->(21,30):(522,496);
      // S10019@(476,475)->(21,30):(497,505). => (522, 536)
      expect(box, const Tuple2(522, 536));
    });
  });
}
