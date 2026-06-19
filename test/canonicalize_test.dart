import 'package:signwriting/signwriting.dart';
import 'package:test/test.dart';

void main() {
  group('canonicalize', () {
    // Values verified against the Python `signwriting` package. These signs
    // have no overlapping symbols, so the pure result equals Python exactly.
    test('reorders, centers, and tightens the box', () {
      expect(
        canonicalize(
            'M525x535S2e748483x510S10011501x466S2e704510x500S10019476x475'),
        'M525x535S10011501x465S10019476x474S2e704510x499S2e748483x509',
      );
      expect(canonicalize('M518x529S14c20480x471S27106503x489'),
          'M519x529S14c20481x471S27106504x489');
    });

    test('single symbol', () {
      expect(canonicalize('M507x507S1f720487x492'), 'M510x508S1f720490x493');
    });

    test('canonicalizes each whitespace-separated sign independently', () {
      expect(
        canonicalize('M507x507S1f720487x492 M507x507S14720493x485'),
        'M510x508S1f720490x493 M507x511S14720493x489',
      );
    });

    test('empty input returns empty', () {
      expect(canonicalize(''), '');
    });

    test('rejects non-ASCII (SWU) input', () {
      expect(() => canonicalize('𝠃𝤟𝤩'), throwsArgumentError);
    });

    test('is idempotent', () {
      const fsw =
          'M525x535S2e748483x510S10011501x466S2e704510x500S10019476x475';
      final once = canonicalize(fsw);
      expect(canonicalize(once), once);
    });
  });
}
