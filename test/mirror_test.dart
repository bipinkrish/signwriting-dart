import 'package:signwriting/signwriting.dart';
import 'package:test/test.dart';

void main() {
  group('mirrorSymbol', () {
    test('matches the Python reference across sections', () {
      // Verified against the Python `signwriting` package.
      expect(mirrorSymbol('S10000'), 'S10008'); // hand
      expect(mirrorSymbol('S10018'), 'S10010'); // hand
      expect(mirrorSymbol('S20500'), 'S20500'); // contact (self)
      expect(mirrorSymbol('S2a600'), 'S2a611'); // movement (xor-paired)
      expect(mirrorSymbol('S2f300'), 'S2f302'); // movement (finger circles)
      expect(mirrorSymbol('S30a10'), 'S30a20'); // face (fill 1<->2 swap)
      expect(mirrorSymbol('S32320'), 'S32324'); // special override
      expect(mirrorSymbol('S2ef24'), 'S2ef24'); // no representable mirror
      expect(mirrorSymbol('S38b00'), 'S38b00'); // other (self)
    });

    test('non-existent symbols pass through unchanged', () {
      expect(mirrorSymbol('S20544'), 'S20544');
    });

    test('is an involution for every existing ISWA symbol', () {
      int checked = 0;
      for (int base = 0x100; base <= 0x38b; base++) {
        final baseStr = 'S${base.toRadixString(16).padLeft(3, '0')}';
        for (int fill = 0; fill <= 5; fill++) {
          for (int rot = 0; rot <= 15; rot++) {
            final key = '$baseStr$fill${rot.toRadixString(16)}';
            if (symbolExists(key)) {
              checked++;
              expect(mirrorSymbol(mirrorSymbol(key)), key,
                  reason: 'mirror(mirror($key)) should equal $key');
            }
          }
        }
      }
      expect(checked, 37811);
    });
  });

  group('mirrorSign', () {
    test('matches the Python reference', () {
      expect(mirrorSign('M507x507S1f720487x492'), 'M513x507S1f728493x492');
      expect(
        mirrorSign(
            'M525x535S2e748483x510S10011501x466S2e704510x500S10019476x475'),
        'M524x535S2e730500x510S10019478x466S2e71c475x500S10011503x475',
      );
      expect(mirrorSign('M518x529S14c20480x471S27106503x489'),
          'M520x529S14c28497x471S2711e482x489');
    });

    test('drops a coordinate-less prefix like Python (rebuilds from symbols)',
        () {
      expect(mirrorSign('AS14c20S27106M518x529S14c20480x471S27106503x489'),
          'M520x529S14c28497x471S2711e482x489');
    });

    test('rejects non-ASCII (SWU) input', () {
      expect(() => mirrorSign('𝠃𝤟𝤩'), throwsArgumentError);
    });
  });
}
