import 'package:test/test.dart';
import 'package:signwriting/types.dart';
import 'package:signwriting/formats.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('Parse Sign Test', () {
    test('Get Box', () {
      String fsw = 'M123x456S1f720487x492';
      Sign sign = fswToSign(fsw);
      expect(sign.box.symbol, 'M');
      expect(sign.box.position, Tuple2<int, int>.fromList([123, 456]));
    });
  });

  group('SWU to FSW Test', () {
    test('Conversion', () {
      String swu = '𝠀񀀒񀀚񋚥񋛩𝠃𝤟𝤩񋛩𝣵𝤐񀀒𝤇𝣤񋚥𝤐𝤆񀀚𝣮𝣭';
      String fsw = swu2fsw(swu);
      expect(fsw,
          'AS10011S10019S2e704S2e748M525x535S2e748483x510S10011501x466S2e704510x500S10019476x475');
    });
  });

  group('FSW to SWU Test', () {
    const swu = '𝠀񀀒񀀚񋚥񋛩𝠃𝤟𝤩񋛩𝣵𝤐񀀒𝤇𝣤񋚥𝤐𝤆񀀚𝣮𝣭';
    const fsw =
        'AS10011S10019S2e704S2e748M525x535S2e748483x510S10011501x466S2e704510x500S10019476x475';

    test('Conversion', () {
      expect(fsw2swu(fsw), swu);
    });

    test('Empty input', () {
      expect(fsw2swu(''), '');
    });

    test('Round trip FSW -> SWU -> FSW', () {
      expect(swu2fsw(fsw2swu(fsw)), fsw);
    });

    test('Round trip SWU -> FSW -> SWU', () {
      expect(fsw2swu(swu2fsw(swu)), swu);
    });

    test('Helpers invert their SWU counterparts', () {
      expect(mark2swu('M'), String.fromCharCode(0x1D803));
      expect(swu2num(num2swu(500)), 500);
      expect(swu2coord(position2swu(483, 510)), [483, 510]);
    });
  });
}
