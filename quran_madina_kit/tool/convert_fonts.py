"""Convert the quran-madina-html .woff2 fonts to .ttf for Flutter.

woff2 is only a Brotli-compressed sfnt container: clearing `flavor` and re-saving
writes the identical glyph/metric tables back out uncompressed. Nothing is lost,
so the glyph advances the JSON DB's stretch factors were measured against are
preserved exactly.

Run once; commit the .ttf output.

    python3 tool/convert_fonts.py ../../quran-madina-html/assets/fonts assets/fonts
"""

import glob
import os
import sys

from fontTools.ttLib import TTFont


def main(src_dir, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    sources = sorted(glob.glob(os.path.join(src_dir, "*.woff2")))
    if not sources:
        sys.exit(f"no .woff2 files under {src_dir}")
    for src in sources:
        font = TTFont(src)
        font.flavor = None  # drop the woff2 wrapper, keep every table
        out = os.path.join(out_dir, os.path.basename(src).replace(".woff2", ".ttf"))
        font.save(out)
        colr = "COLR" in font
        print(
            f"{os.path.basename(out):28} {os.path.getsize(out):>8} bytes  "
            f"glyphs={font['maxp'].numGlyphs:<5} upem={font['head'].unitsPerEm}  "
            f"colour={colr}"
        )


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(f"usage: {sys.argv[0]} <src-woff2-dir> <out-ttf-dir>")
    main(sys.argv[1], sys.argv[2])
