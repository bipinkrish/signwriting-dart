## 1.3.0

- Add FSW → SWU conversion (`fsw2swu`, `mark2swu`, `num2swu`, `position2swu`), completing the FSW ↔ SWU round-trip
- Add symbol metrics (`getSymbolSize`, `signwritingBox`, `symbolExists`) backed by an embedded size table — no font renderer required
- Add `joinSignsHorizontal` and `signFromSymbols`
- Add `mirror` (`mirrorSymbol`, `mirrorSign`) — verified identical to the Python package across all 37,811 symbols
- Add `fingerspelling` (`spell`, `spellText`) with data for 23 signed languages
- Add `mouthing` (`mouthIpa`, `mouth`) for IPA → SignWriting
- **Changed:** `joinSigns` now produces the same output as the Python reference (font-metric based) and is **deprecated** in favor of `joinSignsVertical`

## 1.2.1

- Minor fix

## 1.2.0

- Remove assets

## 1.1.0

- SWU to FSW
- Documentation

## 1.0.0

- Initial version
- Everything except `visualizer`
