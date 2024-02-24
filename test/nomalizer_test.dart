import 'package:test/test.dart';
import 'package:signwriting/tokenizer/signwriting_normalizer.dart';

void main() {
  group('Normalize', () {
    test('Normalizer same sign', () {
      final fsw = 'M123x456S1f720487x492S1f720487x492';
      final normalized = normalizeSignWriting(fsw);
      expect(fsw, equals(normalized));
    });

    test('Normalizer removes a', () {
      final aInfo = 'AS16d10S22b03S20500S15a28S31400';
      final mInfo = 'M536x550S15a28485x523S16d10519x484S22b03507x508S20500498x532S31400482x482';
      final normalized = normalizeSignWriting(aInfo + mInfo);
      expect(mInfo, equals(normalized));
    });

    test('Normalizer creates space', () {
      final fsw1 = 'M536x550S15a28485x523S16d10519x484S22b03507x508S20500498x532S31400482x482';
      final fsw2 = 'M123x456S15a28485x523S16d10519x484S22b03507x508S20500498x532S31400482x482';

      final normalized = normalizeSignWriting(fsw1 + fsw2);
      expect("$fsw1 $fsw2", equals(normalized));
    });
  });
}
