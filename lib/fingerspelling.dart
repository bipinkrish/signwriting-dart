import 'dart:convert';
import 'dart:math';

import 'package:signwriting/src/fingerspelling_data.g.dart';
import 'package:signwriting/utils.dart';

// Parsed, lowercase-keyed character maps, cached per language.
final Map<String, Map<String, dynamic>> _charsCache = {};

/// Loads the fingerspelling character map for [language].
///
/// [language] is either a signed-language code (e.g. `ase`) or a hyphenated
/// locale whose third part is that code (e.g. `en-us-ase-asl`). Keys are
/// lowercased. Throws [ArgumentError] for an unknown language.
Map<String, dynamic> getChars(String language) {
  if (language.contains('-')) {
    language = language.split('-')[2];
  }
  return _charsCache.putIfAbsent(language, () {
    final raw = fingerspellingData[language];
    if (raw == null) {
      throw ArgumentError('No fingerspelling data for language "$language"');
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final entry in decoded.entries) entry.key.toLowerCase(): entry.value,
    };
  });
}

/// Resolves the list of FSW sign variants for a character entry.
///
/// An entry is either a list of signs, or a map with a `default` list and a
/// `variations` map; the first requested [variants] key that exists wins,
/// otherwise the default is returned.
List<String> variantSigns(dynamic charVariants, {List<String>? variants}) {
  if (charVariants is Map) {
    final variations = charVariants['variations'] as Map;
    for (final variation in variants ?? const <String>[]) {
      if (variations.containsKey(variation)) {
        return List<String>.from(variations[variation] as List);
      }
    }
    return List<String>.from(charVariants['default'] as List);
  }
  return List<String>.from(charVariants as List);
}

/// Spells a single [word] as a SignWriting sign by joining its characters'
/// signs (vertically by default), or returns `null` if any character is
/// unmappable.
///
/// Provide either [language] or a pre-loaded [chars] map. When a character has
/// multiple variants, one is chosen using [rng] (or a [seed]). NOTE: Dart's RNG
/// does not match Python's, so seeded multi-variant output differs from the
/// Python package; single-variant spellings are identical.
String? spell(
  String word, {
  String? language,
  Map<String, dynamic>? chars,
  bool vertical = true,
  List<String>? variants,
  int? seed,
  Random? rng,
}) {
  if (chars == null) {
    if (language == null) {
      throw ArgumentError('Either language or chars must be provided');
    }
    chars = getChars(language);
  }
  rng ??= seed != null ? Random(seed) : Random();

  final sl = <String>[];
  int caret = 0;
  while (caret < word.length) {
    bool found = false;
    for (final entry in chars.entries) {
      final c = entry.key;
      final end = caret + c.length;
      if (end <= word.length && word.substring(caret, end).toLowerCase() == c) {
        final signs = variantSigns(entry.value, variants: variants);
        // Only draw from the rng when there is an actual choice to make.
        sl.add(signs.length == 1 ? signs[0] : signs[rng.nextInt(signs.length)]);
        caret = end;
        found = true;
        break;
      }
    }
    if (!found) return null;
  }

  return vertical
      ? joinSignsVertical(sl, spacing: 5)
      : joinSignsHorizontal(sl, spacing: 5);
}

// Word tokens, single punctuation marks, or underscores. Uses Unicode property
// escapes so non-Latin scripts tokenize like Python's Unicode-aware `\w`.
final RegExp _tokenRe =
    RegExp(r'[\p{L}\p{N}]+|[^\p{L}\p{N}_\s]|_', unicode: true);

/// Splits [text] into word tokens, individual punctuation marks, and underscores.
List<String> tokenize(String text) {
  return _tokenRe.allMatches(text).map((m) => m.group(0)!).toList();
}

/// Spells full [text], spelling each token and joining results with spaces.
/// Returns `null` if any token cannot be spelled.
///
/// A single seeded [rng] is shared across tokens so the whole text spells
/// deterministically.
String? spellText(
  String text, {
  String? language,
  bool vertical = true,
  List<String>? variants,
  int? seed,
}) {
  final rng = seed != null ? Random(seed) : null;
  final spellings = [
    for (final token in tokenize(text))
      spell(token,
          language: language, vertical: vertical, variants: variants, rng: rng)
  ];
  if (spellings.any((s) => s == null)) return null;
  return spellings.join(' ');
}
