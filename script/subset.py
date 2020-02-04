#!/usr/bin/env python3
from __future__ import print_function
import json
import os
import os.path
import subprocess

FONTS = {
    'Exo 2': './dist/fonts/Exo2-Regular.woff',
    'Open Sans': './dist/fonts/OpenSans.woff',
    'Jetbrains Mono': './dist/fonts/Jetbrains-Mono.woff',
}
OUTPUT_DIR = './dist'

def glyphhanger(args):
    args = ['./node_modules/.bin/glyphhanger'] + list(args)
    return subprocess.check_output(args)

def main():
    files = subprocess.check_output(['find', OUTPUT_DIR, '-name', '*.html']).decode('utf-8').strip().split('\n')
    print('Finding subsets of %d fonts on %d pages' % (len(FONTS), len(files)))
    glyphhanger_output = glyphhanger(files + ['--onlyVisible', '--json', '--family="%s"' % ','.join(FONTS)]).decode('utf-8')
    ranges = json.loads(glyphhanger_output)

    for (font, filename) in FONTS.items():
        unicodes = ranges.get(font, None)
        if unicodes is None:
            print("There weren't any usages of %s according to glyphhanger, skipping." % font)
            continue

        out_filename = filename + '.subset'
        subprocess.check_call([
            'pyftsubset',
            filename,
            '--unicodes=%s' % unicodes,
            '--drop-tables=BASE,JSTF,DSIG,EBDT,EBLC,EBSC,SVG,PCLT,LTSH,Feat,Glat,Gloc,Silf,Sill,CBLC,CBDT,sbix,FFTM',
            '--flavor=woff',
            '--output-file=%s' % out_filename,
        ])
        
        before_size = os.path.getsize(filename)
        after_size = os.path.getsize(out_filename)

        print(before_size, after_size)

        os.rename(out_filename, filename)

if __name__ == '__main__':
    main()
