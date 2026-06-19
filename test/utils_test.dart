import 'package:signwriting/utils.dart';
import 'package:test/test.dart';

void main() {
  // Expected values verified against the Python `signwriting` package.
  const charA = 'M507x507S1f720487x492';
  const charB = 'M507x507S14720493x485';

  const alphabet = [
    'M510x508S1f720490x493',
    'M507x511S14720493x489',
    'M509x510S16d20492x490',
    'M508x515S10120492x485',
    'M508x508S14a20493x493',
    'M511x515S1ce20489x485',
    'M515x508S1f000486x493',
    'M515x508S11502485x493',
    'M511x510S19220490x491',
    'M519x518S19220498x499S2a20c482x483',
  ];

  group('joinSignsVertical', () {
    test('two characters', () {
      expect(joinSignsVertical([charA, charB]),
          'M510x518S1f720487x481S14720493x496');
    });

    test('alphabet with spacing', () {
      expect(
        joinSignsVertical(alphabet, spacing: 10),
        'M518x653S1f720490x347S14720493x372S16d20492x404S10120492x434S14a20493x474S1ce20489x499S1f000486x539S11502485x564S19220490x589S19220498x634S2a20c482x618',
      );
    });

    test('empty input', () {
      expect(joinSignsVertical([]), 'M500x500');
    });
  });

  group('joinSignsHorizontal', () {
    test('two characters', () {
      expect(joinSignsHorizontal([charA, charB]),
          'M517x511S1f720483x492S14720503x485');
    });

    test('alphabet with spacing', () {
      expect(
        joinSignsHorizontal(alphabet, spacing: 10),
        'M655x517S1f720344x493S14720374x489S16d20398x490S10120425x485S14a20451x493S1ce20476x485S1f000508x493S11502547x493S19220587x491S19220634x499S2a20c618x483',
      );
    });

    test('empty input', () {
      expect(joinSignsHorizontal([]), 'M500x500');
    });
  });
}
