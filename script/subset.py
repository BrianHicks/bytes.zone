#!/usr/bin/env python3
from __future__ import print_function
import json
import os
import os.path
import subprocess

FONTS = {
    ("Exo 2", "700", "italic"): "./dist/fonts/Exo2-BoldItalic.woff2",
    ("Exo 2", "700", "normal"): "./dist/fonts/Exo2-Bold.woff2",
    ("Exo 2", "400", "normal"): "./dist/fonts/Exo2-Regular.woff2",
    ("Open Sans", "400", "normal"): "./dist/fonts/OpenSans.woff2",
    ("Open Sans", "400", "italic"): "./dist/fonts/OpenSans-Italic.woff2",
    ("Open Sans", "700", "normal"): "./dist/fonts/OpenSans-Bold.woff2",
    ("Open Sans", "700", "italic"): "./dist/fonts/OpenSans-BoldItalic.woff2",
    ("Jetbrains Mono", "400", "normal"): "./dist/fonts/Jetbrains-Mono.woff2",
}
OUTPUT_DIR = "./dist"


def codepoint(char):
    return hex(ord(char))[2:]


def main():
    files = [
        os.path.abspath(f)
        for f in subprocess.check_output(["find", OUTPUT_DIR, "-name", "*.html"])
        .decode("utf-8")
        .strip()
        .split("\n")
    ]
    print("Finding subsets of %d fonts on %d pages" % (len(FONTS), len(files)))

    faces_output = subprocess.check_output(
        ["node", "./script/faces.js"] + files
    ).decode("utf-8")
    faces = json.loads(faces_output)

    for font_and_chars in faces:
        font = font_and_chars["font"]
        filename = FONTS.get((font["face"], font["weight"], font["style"]), None)
        if filename is None:
            # not a problem, we just don't care about this face. Stuff like
            # "sans-serif" and "monospace" shows up here.
            continue

        unicodes = ",".join(codepoint(char) for char in font_and_chars["chars"])

        out_filename = filename + ".subset"
        subprocess.check_call(
            [
                "pyftsubset",
                filename,
                "--unicodes=%s" % unicodes,
                "--drop-tables=BASE,JSTF,DSIG,EBDT,EBLC,EBSC,SVG,PCLT,LTSH,Feat,Glat,Gloc,Silf,Sill,CBLC,CBDT,sbix,FFTM",
                "--flavor=woff2",
                "--output-file=%s" % out_filename,
            ]
        )

        before_size = os.path.getsize(filename)
        after_size = os.path.getsize(out_filename)

        print(
            "Subset %s from %d to %d bytes (%.2f%% of original size, %d glyphs)"
            % (
                filename,
                before_size,
                after_size,
                (float(after_size) / float(before_size)) * 100,
                len(font_and_chars["chars"]),
            )
        )

        os.rename(out_filename, filename)


if __name__ == "__main__":
    main()
