import 'dart:convert';

import 'package:signwriting/formats.dart';
import 'package:signwriting/src/mouthing_data.g.dart';
import 'package:signwriting/utils.dart';

/// A grapheme-to-IPA transliteration function (e.g. a Dart port of epitran,
/// or any other G2P). Used by [mouth] to turn a written word into IPA.
typedef GraphemeToIpa = String Function(String word);

/// The result of mouthing a word: its IPA, and the SignWriting representation
/// in both FSW and SWU (null when the IPA could not be fully mouthed).
class MouthingResult {
  final String ipa;
  final String? fsw;
  final String? swu;

  const MouthingResult(
      {required this.ipa, required this.fsw, required this.swu});

  @override
  String toString() => 'MouthingResult(ipa: $ipa, fsw: $fsw, swu: $swu)';
}

Map<String, Map<String, dynamic>>? _mouthingsCache;

/// The IPA → mouthing index, with each entry's `alternatives` also keyed to the
/// same record. Mirrors Python `get_mouthings`.
Map<String, Map<String, dynamic>> getMouthings() {
  return _mouthingsCache ??= () {
    final decoded = jsonDecode(mouthingData) as Map<String, dynamic>;
    final mouthings = <String, Map<String, dynamic>>{
      for (final e in decoded.entries)
        e.key: (e.value as Map).cast<String, dynamic>(),
    };
    // Snapshot original values, then alias each alternative to its record.
    for (final info in mouthings.values.toList()) {
      final alternatives = info['alternatives'];
      if (alternatives is List) {
        for (final alt in alternatives) {
          mouthings[alt as String] = info; // shared reference, like Python
        }
      }
    }
    return mouthings;
  }();
}

Map<String, Map<String, dynamic>>? _mouthingsNoAspirationCache;

/// Like [getMouthings] but with the "air blowing out" aspiration mark (S335)
/// stripped and each sign re-boxed. Mirrors Python
/// `get_mouthings_without_aspiration`, including its in-place processing of
/// records shared between a symbol and its alternatives.
Map<String, Map<String, dynamic>> getMouthingsWithoutAspiration() {
  return _mouthingsNoAspirationCache ??= () {
    final source = getMouthings();
    // Deep-copy while preserving shared references (alt + primary -> one copy).
    final memo = <Map<String, dynamic>, Map<String, dynamic>>{};
    final mouthings = <String, Map<String, dynamic>>{};
    source.forEach((key, info) {
      mouthings[key] =
          memo.putIfAbsent(info, () => Map<String, dynamic>.from(info));
    });

    final s335 = RegExp(r'S335..\d{3}x\d{3}');
    // Iterating values yields a shared record once per key, so it is processed
    // as many times as Python's loop does — kept identical on purpose.
    for (final info in mouthings.values) {
      var writing = info['writing'] as String;
      if (writing.contains('S335')) {
        writing = writing.replaceAll(s335, '');
      }
      final sign = fswToSign(writing);
      info['writing'] =
          sign.symbols.isEmpty ? '' : signToFsw(signFromSymbols(sign.symbols));
    }
    return mouthings;
  }();
}

/// Mouths a single IPA [word] into an FSW sign, or returns null if any IPA
/// symbol is unknown. Mirrors Python `mouth_ipa_single`.
String? mouthIpaSingle(String word, {bool aspiration = false}) {
  final mouthings =
      aspiration ? getMouthings() : getMouthingsWithoutAspiration();
  // Match longer IPA symbols first.
  final items = mouthings.entries.toList()
    ..sort((a, b) => b.key.length.compareTo(a.key.length));

  // Remove syllabic consonant markers (combining vertical line below).
  word = word.replaceAll('̩', '');

  final sl = <String>[];
  int caret = 0;
  while (caret < word.length) {
    bool found = false;
    for (final entry in items) {
      final symbol = entry.key;
      final end = caret + symbol.length;
      if (end <= word.length &&
          word.substring(caret, end).toLowerCase() == symbol) {
        sl.add(entry.value['writing'] as String);
        caret = end;
        found = true;
        break;
      }
    }
    if (!found) return null;
  }
  return joinSignsHorizontal(sl, spacing: -10);
}

/// Mouths a space-separated IPA string, mouthing each word and joining them.
/// Returns null if any word cannot be mouthed. Mirrors Python `mouth_ipa`.
String? mouthIpa(String characters, {bool aspiration = false}) {
  final words = [
    for (final word in characters.split(' '))
      mouthIpaSingle(word, aspiration: aspiration)
  ];
  if (words.any((w) => w == null)) return null;
  return joinSignsHorizontal(words.cast<String>(), spacing: 10);
}

/// Mouths a written [word] for a spoken language, using a supplied [g2p]
/// grapheme-to-IPA function (epitran has no Dart port — see EPITRAN_PORT.md).
MouthingResult mouth(String word,
    {required GraphemeToIpa g2p, bool aspiration = false}) {
  final ipa = g2p(word);
  final fsw = mouthIpa(ipa, aspiration: aspiration);
  final swu = fsw != null ? fsw2swu(fsw) : null;
  return MouthingResult(ipa: ipa, fsw: fsw, swu: swu);
}
