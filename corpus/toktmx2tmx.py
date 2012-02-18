#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This program converts toktmx files to tmx files useful for e.g. 
#   Autshumato ITE
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with program. If not, see <http://www.gnu.org/licenses/>.
#
#   Copyright 2011 Børre Gaup <borre.gaup@uit.no>
#

import os
import sys
import argparse
import lxml.etree

sys.path.append(os.environ['GTHOME'] + '/gt/script/langTools')
import parallelize

def parse_options():
    """
    Parse the command line. No arguments expected.
    """
    parser = argparse.ArgumentParser(description = 'Run this script to generate tmx files for use in e.g. Autshumato ITE. It depends on toktmx files to exist in $GTFREE/prestable/toktmx.')
    
    args = parser.parse_args()
    return args

def main():
    args = parse_options()

    toktmx2tmx = parallelize.Toktmx2Tmx()
    for dirname in ['nob2sme', 'sme2nob']:
        for filename in toktmx2tmx.findToktmxFiles(dirname):
            toktmx2tmx.readToktmxFile(filename)
            toktmx2tmx.cleanToktmx()
            toktmx2tmx.writeCleanedupTmx()
    
if __name__ == '__main__':
    main()
