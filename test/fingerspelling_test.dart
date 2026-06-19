import 'package:signwriting/signwriting.dart';
import 'package:test/test.dart';

void main() {
  // Expected values verified against the Python `signwriting` package.
  group('spell', () {
    test('vertical (single-variant characters)', () {
      expect(
        spell('abcdef', language: 'ase'),
        'M513x578S1f720487x421S14720493x441S16d20491x468S10120492x493S14a20492x528S1ce20491x548',
      );
    });

    test('horizontal', () {
      expect(
        spell('abcdef', language: 'ase', vertical: false),
        'M564x515S1f720435x492S14720460x485S16d20479x487S10120501x477S14a20522x492S1ce20542x477',
      );
    });

    test('is case-insensitive', () {
      expect(
          spell('AbCdEf', language: 'ase'), spell('abcdef', language: 'ase'));
    });

    test('returns null for unmappable input', () {
      expect(spell('ab#', language: 'ase'), isNull);
    });

    test('accepts a hyphenated locale (uses the 3rd part)', () {
      expect(
          spell('a', language: 'en-us-ase-asl'), spell('a', language: 'ase'));
    });

    test('throws without language or chars', () {
      expect(() => spell('a'), throwsArgumentError);
    });
  });

  group('tokenize', () {
    test('splits words, punctuation, and underscores', () {
      expect(tokenize('custom prited circuit board'),
          ['custom', 'prited', 'circuit', 'board']);
      expect(tokenize('a_b, c! 12'), ['a', '_', 'b', ',', 'c', '!', '12']);
    });

    test('is Unicode-aware (matches Python)', () {
      expect(tokenize('한국어 test'), ['한국어', 'test']);
    });
  });

  group('spellText', () {
    test('spells each token and joins with spaces', () {
      expect(
        spellText('ab cd', language: 'ase'),
        'M510x521S1f720487x479S14720493x499 M508x527S16d20491x472S10120492x497',
      );
    });

    test('returns null when a token is unmappable', () {
      expect(spellText('ab #', language: 'ase'), isNull);
    });
  });
}
