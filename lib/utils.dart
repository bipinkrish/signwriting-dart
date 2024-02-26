import 'package:signwriting/formats.dart';
import 'package:signwriting/types.dart';
import 'package:tuple/tuple.dart';

// Function to extract all y-coordinates from the symbols of a sign
List<int> allYs(Sign sign) {
  // Mapping each symbol to its y-coordinate and converting it to a list
  return sign.symbols.map((s) => s.position.item2).toList();
}

// Function to join multiple signs together with an optional spacing between them
String joinSigns({required List<String> fsws, int spacing = 0}) {
  // Converting FSW strings to Sign objects
  List<Sign> signs = fsws.map((fsw) => fswToSign(fsw)).toList();

  // Creating a new sign with an initial position
  Sign newSign = Sign(
    box: SignSymbol(symbol: "M", position: Tuple2<int, int>(500, 500)),
    symbols: [],
  );

  int accumulativeOffset =
      0; // Accumulated offset to manage spacing between signs

  // Looping through each sign and adjusting its position
  for (Sign sign in signs) {
    int signMinY = allYs(sign).reduce((min, y) => y < min
        ? y
        : min); // Finding the minimum y-coordinate of symbols in the sign
    int signOffsetY = accumulativeOffset +
        spacing -
        signMinY; // Calculating the vertical offset for the sign
    // Updating the accumulated offset
    accumulativeOffset += (sign.box.position.item2 - signMinY) + spacing; // * 2

    // Adding symbols of the sign to the new sign with adjusted positions
    newSign.symbols.addAll(sign.symbols.map(
      (s) => SignSymbol(
        symbol: s.symbol,
        position: Tuple2<int, int>(
            s.position.item1,
            s.position.item2 +
                signOffsetY), // Adding the offset to y-coordinate
      ),
    ));
  }

  // Recentering the new sign around the center of its box symbol
  int signMiddle = allYs(newSign).reduce((max, y) => y > max ? y : max) ~/
      2; // Calculating the middle position based on the maximum y-coordinate

  // Adjusting the positions of symbols in the new sign to recenter around the box symbol
  for (SignSymbol symbol in newSign.symbols) {
    symbol.position = Tuple2<int, int>(
      symbol.position.item1,
      newSign.box.position.item2 -
          signMiddle +
          symbol.position.item2, // Adjusting the y-coordinate to recenter
    );
  }

  // Converting the new sign to FSW string and returning it
  return signToFsw(newSign);
}
