import "package:tuple/tuple.dart";

class SignSymbol {
  final String symbol;
  Tuple2<int, int> position;

  SignSymbol({required this.symbol, required this.position});

  @override
  String toString() {
    return "SignSymbol { symbol: '$symbol', position: $position }";
  }
}

class Sign {
  final SignSymbol box;
  final List<SignSymbol> symbols;

  Sign({required this.box, required this.symbols});

  @override
  String toString() {
    return "Sign { box: $box, symbols: $symbols }";
  }
}
