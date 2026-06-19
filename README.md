# SignWriting

[![pub package](https://img.shields.io/pub/v/signwriting.svg)](https://pub.dev/packages/signwriting)

This is dart implementation of its [python counterpart](https://github.com/sign-language-processing/signwriting). Dart utilities for SignWriting formats, tokenizer, visualizer and utils.

## Features

- ✔️ Formats
- ✔️ Tokenizer
- ❌ Visualizer ([implemented here](https://pub.dev/packages/signwriting_flutter))
- ✔️ Utils (join, metrics, mirror)
- ✔️ Fingerspelling
- ✔️ Mouthing (IPA → SignWriting)

## Usage

### Formats

This module provides utilities for converting between different formats of SignWriting. We include a few examples:

1. To parse an FSW string into a Sign object, representing the sign as a dictionary:

```dart
print(fswToSign("M123x456S1f720487x492"));
// Sign { box: SignSymbol { symbol: 'M', position: [123, 456] }, symbols: [SignSymbol { symbol: 'S1f720', position: [487, 492] }] }
```

2. To convert a SignWriting string between SWU and FSW formats (both directions):

```dart
print(swu2fsw('𝠃𝤟𝤩񋛩𝣵𝤐񀀒𝤇𝣤񋚥𝤐𝤆񀀚𝣮𝣭'));
// M525x535S2e748483x510S10011501x466S2e704510x500S10019476x475

print(fsw2swu('M525x535S2e748483x510S10011501x466S2e704510x500S10019476x475'));
// 𝠃𝤟𝤩񋛩𝣵𝤐񀀒𝤇𝣤񋚥𝤐𝤆񀀚𝣮𝣭
```

### Tokenizer

This module provides utilities for tokenizing SignWriting strings for use in NLP tasks1. We include a few usage non-exhaustive examples:

1. To tokenize a SignWriting string into a list of tokens:

```dart
SignWritingTokenizer tokenizer = SignWritingTokenizer();
String fsw = 'M123x456S1f720487x492S1f720487x492';
List<String> tokens = tokenizer.textToTokens(fsw, boxPosition: true);
print(tokens);
// [M, p123, p456, S1f7, c2, r0, p487, p492, S1f7, c2, r0, p487, p492]
```

2. To convert a list of tokens back to a SignWriting string:

```dart
print(tokenizer.tokensToText(tokens));
// M123x456S1f720487x492S1f720487x492
```

3. For machine learning purposes, we can convert the tokens to a list of integers:

```dart
print(tokenizer.tokenize(fsw, bos: false, eos: false));
// [6, 932, 932, 255, 678, 660, 919, 924, 255, 678, 660, 919, 924]
```

4. Or to remove 'A' information, and separate signs by spaces, we can use:

```dart
print(normalizeSignWriting(fsw));
// M123x456S1f720487x492S1f720487x492
```

### Visualizer

([implemented here](https://pub.dev/packages/signwriting_flutter))

This module is used to visualize SignWriting strings as images. Unlike [sutton-signwriting/font-db](https://github.com/sutton-signwriting/font-db/) which it is based on, this module does not support custom styling. Benchmarks show that this module is ~5000x faster than the original implementation.

```dart
String fsw = "AS10011S10019S2e704S2e748M525x535S2e748483x510S10011501x466S20544510x500S10019476x475";
signwritingToImage(fsw);
```

### Utils

This module includes general utilities that were not covered in the other modules.

1. `joinSignsVertical` / `joinSignsHorizontal` join a list of signs into a single sign. This is useful for example for fingerspelling words out of individual character signs.

```dart
String charA = 'M507x507S1f720487x492';
String charB = 'M507x507S14720493x485';

print(joinSignsVertical([charA, charB]));
// M510x518S1f720487x481S14720493x496

print(joinSignsHorizontal([charA, charB]));
// M517x511S1f720483x492S14720503x485
```

2. `signFromSymbols` builds a tightly-boxed sign (centered on 500x500) from a list of symbols.

3. `getSymbolSize` returns the rendered size of a symbol, and `signwritingBox` recomputes a sign's tight bounding box — both without needing a font renderer.

```dart
print(getSymbolSize('S2e748'));
// [16, 26]
```

### Mirror

`mirrorSymbol` and `mirrorSign` produce the horizontal mirror of a symbol or a full FSW sign.

```dart
print(mirrorSymbol('S10000'));
// S10008

print(mirrorSign('M507x507S1f720487x492'));
// M513x507S1f728493x492
```

### Fingerspelling

Spell words letter-by-letter as SignWriting, for 23 signed languages. `spell` handles a single word; `spellText` handles full text (returns `null` if any character is unmappable).

```dart
print(spell('abc', language: 'ase'));
// M510x533S1f720487x466S14720493x486S16d20491x513

print(spellText('a b', language: 'ase'));
// M510x507S1f720487x492 M507x511S14720493x489
```

### Mouthing

Convert IPA (mouth shapes / Mundbildschrift) to SignWriting.

```dart
print(mouthIpa('ɑː ɛ'));
// M541x518S34c00459x482S34a00505x482
```

To mouth a written word, supply your own grapheme-to-IPA function (Python's `epitran` has no Dart port)

```dart
final result = mouth('hello', g2p: (word) => myG2p(word));
print(result.fsw);
```
