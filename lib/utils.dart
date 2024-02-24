import 'package:signwriting/formats.dart';
import 'package:signwriting/types.dart';
import 'package:tuple/tuple.dart';

List<int> allYs(Sign sign) {
  return sign.symbols.map((s) => s.position.item2).toList();
}

String joinSigns({required List<String> fsws, int spacing = 0}) {
  List<Sign> signs = fsws.map((fsw) => fswToSign(fsw)).toList();
  Sign newSign = Sign(
    box: SignSymbol(symbol: "M", position: Tuple2<int, int>(500, 500)),
    symbols: [],
  );

  int accumulativeOffset = 0;

  for (Sign sign in signs) {
    int signMinY = allYs(sign).reduce((min, y) => y < min ? y : min);
    int signOffsetY = accumulativeOffset + spacing - signMinY;
    accumulativeOffset += (sign.box.position.item2 - signMinY) + spacing; // * 2

    newSign.symbols.addAll(sign.symbols.map(
      (s) => SignSymbol(
        symbol: s.symbol,
        position:
            Tuple2<int, int>(s.position.item1, s.position.item2 + signOffsetY),
      ),
    ));
  }

  // Recenter around box center
  int signMiddle = allYs(newSign).reduce((max, y) => y > max ? y : max) ~/ 2;

  for (SignSymbol symbol in newSign.symbols) {
    symbol.position = Tuple2<int, int>(
      symbol.position.item1,
      newSign.box.position.item2 - signMiddle + symbol.position.item2,
    );
  }

  return signToFsw(newSign);
}
