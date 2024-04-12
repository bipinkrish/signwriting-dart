# SignWriting

[![pub package](https://img.shields.io/pub/v/signwriting.svg)](https://pub.dev/packages/signwriting)

This is dart implementation of its [python counterpart](https://github.com/sign-language-processing/signwriting). Dart utilities for SignWriting formats, tokenizer, visualizer and utils.

## Features

- ✔️ Formats
- ✔️ Tokenizer
- ❌ Visualizer ([implemented here](https://pub.dev/packages/signwriting_flutter))
- ✔️ Utils

## Usage

### Formats

This module provides utilities for converting between different formats of SignWriting. We include a few examples:

1. To parse an FSW string into a Sign object, representing the sign as a dictionary:

```dart
print(fswToSign("M123x456S1f720487x492"));
// Sign { box: SignSymbol { symbol: 'M', position: [123, 456] }, symbols: [SignSymbol { symbol: 'S1f720', position: [487, 492] }] }
```

2. To convert a SignWriting string in SWU format to FSW format:

```dart
print(swu2fsw('𝠃𝤟𝤩񋛩𝣵𝤐񀀒𝤇𝣤񋚥𝤐𝤆񀀚𝣮𝣭'));
// M525x535S2e748483x510S10011501x466S2e704510x500S10019476x475
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

1. `join_signs` joins a list of signs into a single sign. This is useful for example for fingerspelling words out of individual character signs.

```dart
String charA = 'M507x507S1f720487x492';
String charB = 'M507x507S14720493x485';
String resultSign = joinSigns(fsws: [charA, charB]);
print(resultSign);
// M500x500S1f720487x493S14720493x508
```
