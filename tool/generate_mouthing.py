"""Embed mouthing.json into a Dart source file (pure-Dart packages can't load
runtime assets).

Usage:
  python tool/generate_mouthing.py path/to/signwriting/mouthing/mouthing.json
"""
import json
import os
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(_HERE, "..", "lib", "src", "mouthing_data.g.dart"))


def dart_string(text: str) -> str:
    return json.dumps(text, ensure_ascii=False).replace("$", r"\$")


def main():
    if len(sys.argv) < 2:
        raise SystemExit("Pass the path to mouthing.json")
    with open(sys.argv[1], "r", encoding="utf-8") as f:
        minified = json.dumps(json.load(f), ensure_ascii=False, separators=(",", ":"))

    dart = (
        "// GENERATED — do not edit by hand.\n"
        "// Source: tool/generate_mouthing.py (signwriting/mouthing/mouthing.json)\n\n"
        f"const String mouthingData = {dart_string(minified)};\n"
    )
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(dart)
    print(f"wrote {OUT}", file=sys.stderr)


if __name__ == "__main__":
    main()
