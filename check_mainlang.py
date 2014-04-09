#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Written by Børre Gaup <borre.gaup@uit.no>

"""If a metadata file does not have the exptected language,
open it and the main file. Move it to the correct language dir
if needed.
"""

import sys
import os
import lxml.etree as etree
import subprocess

def check_mainlang(file_):
    try:
        tree = etree.parse(file_)
        root = tree.getroot()
        mainlang = root.find('{http://www.w3.org/1999/XSL/Transform}variable[@name="mainlang"]')

        ml = mainlang.get('select').replace("'", "")
        if ml != sys.argv[2] and ml != "mixed":
            subprocess.call(['kde-open', file_])
            subprocess.call(['kde-open',
                             file_.replace('.xsl', '')])
            answer = raw_input("Move " + file_ + "? ")
            if answer == 'y':
                new = file_.replace(
                    'orig/' + sys.argv[2],
                    'orig/' + ml)

                try:
                    os.makedirs(new)
                except OSError:
                    pass

                subprocess.call(['git', 'mv', '-f', file_, new])
                subprocess.call(['git', 'mv', '-f',
                           file_.replace('.xsl', ''),
                           new.replace('xsl', '')])

                print 'Moved', file_, ' -> ', new

    except etree.XMLSyntaxError:
        print >>sys.stderr, "Could not parse", file_

def collect_files(dir_):
    for root, dirs, files in os.walk(dir_):
        for f in files:
            if f.endswith('.xsl'):
                check_mainlang(os.path.join(root, f))

collect_files(sys.argv[1])
