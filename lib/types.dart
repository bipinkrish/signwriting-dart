import "package:tuple/tuple.dart";

/// Represents a symbol within a sign, along with its position.
class SignSymbol {
  final String symbol; // Symbol identifier
  Tuple2<int, int> position; // Position coordinates (x, y)

  /// Constructor for SignSymbol class.
  ///
  /// [symbol]: Symbol identifier.
  /// [position]: Position coordinates as a Tuple2<int, int>.
  SignSymbol({required this.symbol, required this.position});

  /// Returns a string representation of the SignSymbol object.
  @override
  String toString() {
    return "SignSymbol { symbol: '$symbol', position: $position }";
  }
}

/// Represents a sign consisting of a box symbol and a list of symbols.
class Sign {
  final SignSymbol box; // Box symbol
  final List<SignSymbol> symbols; // List of symbols

  /// Constructor for Sign class.
  ///
  /// [box]: SignSymbol representing the box of the sign.
  /// [symbols]: List of SignSymbol representing other symbols in the sign.
  Sign({required this.box, required this.symbols});

  /// Returns a string representation of the Sign object.
  @override
  String toString() {
    return "Sign { box: $box, symbols: $symbols }";
  }
}
