"""Embed the fingerspelling language data into a Dart source file.

Pure-Dart packages cannot load runtime assets, so each language's JSON is
minified and embedded as a string constant, parsed lazily at runtime.

Usage:
  python tool/generate_fingerspelling.py [path/to/fingerspelling/data]
"""
import glob
import json
import os
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
_DEFAULT_DATA = os.path.normpath(os.path.join(
    _HERE, "..", "..", "signwriting-flutter"))  # fallback only; usually pass explicitly
OUT = os.path.normpath(os.path.join(
    _HERE, "..", "lib", "src", "fingerspelling_data.g.dart"))


def dart_string(text: str) -> str:
    # A JSON-encoded string is a valid Dart double-quoted literal; also escape
    # '$' so Dart does not treat it as interpolation.
    return json.dumps(text, ensure_ascii=False).replace("$", r"\$")


def main():
    data_dir = sys.argv[1] if len(sys.argv) > 1 else None
    if not data_dir:
        raise SystemExit("Pass the path to signwriting/fingerspelling/data")

    entries = []
    for path in sorted(glob.glob(os.path.join(data_dir, "*.json"))):
        lang = os.path.splitext(os.path.basename(path))[0]
        with open(path, "r", encoding="utf-8") as f:
            minified = json.dumps(json.load(f), ensure_ascii=False, separators=(",", ":"))
        entries.append(f"  '{lang}': {dart_string(minified)},")

    body = "\n".join(entries)
    dart = (
        "// GENERATED — do not edit by hand.\n"
        "// Source: tool/generate_fingerspelling.py\n"
        "// Minified per-language fingerspelling JSON, parsed lazily at runtime.\n\n"
        "const Map<String, String> fingerspellingData = {\n"
        f"{body}\n"
        "};\n"
    )
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(dart)
    print(f"wrote {OUT} ({len(entries)} languages)", file=sys.stderr)


if __name__ == "__main__":
    main()
