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
}
