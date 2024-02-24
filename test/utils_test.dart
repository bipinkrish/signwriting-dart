import 'package:signwriting/utils.dart';
import 'package:test/test.dart';

void main() {
  group('Join Signs Test', () {
    test('Join Two Characters', () {
      String charA = 'M507x507S1f720487x492';
      String charB = 'M507x507S14720493x485';
      String resultSign = joinSigns(fsws: [charA, charB]);
      expect(resultSign, 'M500x500S1f720487x493S14720493x508');
    });

    test('Join Alphabet Characters', () {
      List<String> chars = [
        "M510x508S1f720490x493", "M507x511S14720493x489", "M509x510S16d20492x490", "M508x515S10120492x485",
        "M508x508S14a20493x493", "M511x515S1ce20489x485", "M515x508S1f000486x493", "M515x508S11502485x493",
        "M511x510S19220490x491", "M519x518S19220498x499S2a20c482x483"
      ];
      String resultSign = joinSigns(fsws: chars, spacing: 10);
      // You can add a long string representation of the expected result here.
      // For readability, we use multiple lines and concatenation.
      expect(
        resultSign,
        'M500x500S1f720490x362S14720493x387S16d20492x419S10120492x449S14a20493x489S1ce20489x514S1f000486x554S11502485x579S19220490x604S19220498x649S2a20c482x633',
      );
    });
  });
}
