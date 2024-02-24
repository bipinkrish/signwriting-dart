// import 'dart:collection';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:image/image.dart';
// import 'package:path/path.dart';

// Image? _cachedFont;
// final _fontCache = HashMap<String, Image>();


// Image _getFont(String fontName) {
//   if (_cachedFont != null) return _cachedFont!;

//   final fontPath = File('${dirname(Platform.script.path)}/$fontName.ttf');
//   final fontData = fontPath.readAsBytesSync();
//   _cachedFont = decodeFontFromBytes(Uint8List.fromList(fontData))!;
//   return _cachedFont!;
// }

// List<int> _getSymbolSize(String symbol) {
//   final font = _getFont('SuttonSignWritingLine');
//   final lineId = _symbolLine(_key2Id(symbol));
//   final bbox = font.getStringMetrics(lineId);
//   final width = (bbox.xmax - bbox.xmin).toInt();
//   final height = (bbox.ymax - bbox.ymin).toInt();
//   return [width, height];
// }

// final _symbolCache = HashMap<String, String>();

// String _symbolFill(String symbolId) {
//   if (_symbolCache.containsKey(symbolId)) {
//     return _symbolCache[symbolId]!;
//   }
//   final fill = symbol_fill(symbolId);
//   _symbolCache[symbolId] = fill;
//   return fill;
// }

// String _symbolLine(String symbolId) {
//   if (_symbolCache.containsKey(symbolId)) {
//     return _symbolCache[symbolId]!;
//   }
//   final line = symbol_line(symbolId);
//   _symbolCache[symbolId] = line;
//   return line;
// }

// Image signwritingToImage(String fsw, {bool antialiasing = true, bool trustBox = true}) {
//   final sign = fswToSign(fsw);
//   if (sign['symbols'].isEmpty) {
//     return Image(1, 1);
//   }

//   final positions = sign['symbols'].map((s) => s['position'] as List<int>).toList();
//   final minX = positions.map((p) => p[0]).reduce((a, b) => a < b ? a : b);
//   final minY = positions.map((p) => p[1]).reduce((a, b) => a < b ? a : b);

//   var maxX = sign['box']['position'][0] as int;
//   var maxY = sign['box']['position'][1] as int;

//   if (!trustBox) {
//     maxX = 0;
//     maxY = 0;
//     for (final symbol in sign['symbols']) {
//       final symbolX = symbol['position'][0] as int;
//       final symbolY = symbol['position'][1] as int;
//       final symbolSize = _getSymbolSize(symbol['symbol']);
//       maxX = maxX > symbolX + symbolSize[0] ? maxX : symbolX + symbolSize[0];
//       maxY = maxY > symbolY + symbolSize[1] ? maxY : symbolY + symbolSize[1];
//     }
//   }

//   final image = Image(maxX - minX, maxY - minY, channels: img.Channels.rgba);
//   final fillFont = _getFont('SuttonSignWritingFill');
//   final lineFont = _getFont('SuttonSignWritingLine');

//   for (final symbol in sign['symbols']) {
//     final x = symbol['position'][0] as int - minX;
//     final y = symbol['position'][1] as int - minY;
//     final symbolId = _key2Id(symbol['symbol']);
//     final symbolFill = _symbolFill(symbolId);
//     final symbolLine = _symbolLine(symbolId);
//     final draw = DrawOptions(font: fillFont);
//     drawString(symbolFill, x, y, draw);
    
//     if (!antialiasing) {
//       final lineDraw = DrawOptions(font: lineFont, antialias: false);
//       drawString(symbolLine, x, y, lineDraw);
//     } else {
//       final lineDraw = DrawOptions(font: lineFont);
//       drawString(symbolLine, x, y, lineDraw);
//     }
  
//   }

//   return image;
// }
