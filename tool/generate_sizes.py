"""Generate the SignWriting symbol-size table for the pure-Dart package.

Faithful to Python signwriting.visualizer.visualize.get_symbol_size:
  size = SuttonSignWritingLine font @ size 30, ink bbox (right-left, bottom-top).

Output: a Dart source file embedding a base64 of a flat Uint8 array indexed by
key2id, so getSymbolSize is an O(1) array read with no runtime asset loading.

Prerequisites:
  pip install pillow fonttools

Usage:
  python tool/generate_sizes.py [path/to/SuttonSignWritingLine.ttf]

The font ships with the sibling `signwriting_flutter` package
(assets/fonts/SuttonSignWritingLine.ttf); by default we look for it there.
"""
import base64
import os
import sys
from fontTools.ttLib import TTFont
from PIL import ImageFont

_HERE = os.path.dirname(os.path.abspath(__file__))
_DEFAULT_LINE = os.path.normpath(os.path.join(
    _HERE, "..", "..", "signwriting-flutter", "assets", "fonts",
    "SuttonSignWritingLine.ttf"))

LINE = sys.argv[1] if len(sys.argv) > 1 else _DEFAULT_LINE
OUT = os.path.normpath(os.path.join(_HERE, "..", "lib", "src", "symbol_sizes.g.dart"))
FONT_SIZE = 30
LINE_OFFSET = 0xF0000  # symbol_line(id) = chr(id + 0xF0000)


def main():
    tt = TTFont(LINE)
    cmap = tt.getBestCmap()
    font = ImageFont.truetype(LINE, FONT_SIZE)

    # Existing line glyphs live at LINE_OFFSET + id; recover id from codepoint.
    ids = sorted(cp - LINE_OFFSET for cp in cmap if LINE_OFFSET < cp < LINE_OFFSET + 0x10000)
    max_id = ids[-1]

    sizes = {}  # id -> (w, h)
    max_w = max_h = 0
    for sid in ids:
        bbox = font.getbbox(chr(sid + LINE_OFFSET))
        if not bbox:
            continue
        w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
        if w <= 0 or h <= 0:
            continue  # matches _symbol_exists: width>0 and height>0
        sizes[sid] = (w, h)
        max_w, max_h = max(max_w, w), max(max_h, h)

    print(f"glyphs in cmap: {len(ids)}  existing (w>0,h>0): {len(sizes)}", file=sys.stderr)
    print(f"max_id: {max_id}  max_w: {max_w}  max_h: {max_h}", file=sys.stderr)

    if max_w > 255 or max_h > 255:
        print("ERROR: dimensions exceed uint8; encoding must change", file=sys.stderr)
        sys.exit(1)

    # Flat Uint8 array indexed by id: [w0,h0, w1,h1, ...]. id 0 unused.
    buf = bytearray((max_id + 1) * 2)
    for sid, (w, h) in sizes.items():
        buf[sid * 2] = w
        buf[sid * 2 + 1] = h

    b64 = base64.b64encode(bytes(buf)).decode("ascii")
    print(f"binary bytes: {len(buf)}  base64 chars: {len(b64)}", file=sys.stderr)

    # Chunk the string literal to keep the Dart analyzer/compiler happy.
    chunk = 120
    lines = [b64[i:i + chunk] for i in range(0, len(b64), chunk)]
    joined = "\n    '" + "'\n    '".join(lines) + "'"

    dart = f"""// GENERATED — do not edit by hand.
// Source: tool/generate_sizes.py (SuttonSignWritingLine @ {FONT_SIZE}, ink bbox).
// Flat Uint8 table indexed by key2id: bytes[id*2] = width, bytes[id*2+1] = height.
// 0 means the symbol does not exist in ISWA (width>0 && height>0 == exists).

const int maxSymbolId = {max_id};

const String packedSymbolSizes ={joined};
"""
    with open(OUT, "w") as f:
        f.write(dart)
    print(f"wrote {OUT}", file=sys.stderr)


if __name__ == "__main__":
    main()
