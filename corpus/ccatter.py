#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This is a program to print analysed elements to specific files
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this file. If not, see <http://www.gnu.org/licenses/>.
#
#   Copyright 2013 Børre Gaup <borre.gaup@uit.no>
#

import os
import sys
import argparse

from corpustools import ccat

def parse_options():
    parser = argparse.ArgumentParser(description = 'ccat xml files in a given directory by lang/genre/translated_from.')
    parser.add_argument('ccatDir', help='directory where the ccatted files are placed')
    parser.add_argument('analysed_dir', nargs='+', help = "director(y|ies) where the converted files exist")

    args = parser.parse_args()
    return args


def print_file(element_type, file_, ccatFiles, ccatDir):
    if element_type == 'disambiguation':
        c = ccat.XMLPrinter(disambiguation=True)
    else:
        c = ccat.XMLPrinter(dependency=True)

    c.parse_file(file_)
    ccatFileName = os.path.join(
        ccatDir, '_'.join([c.get_lang(), c.get_genre(),
                           c.get_translatedfrom()]) + element_type)
    try:
        ccatFiles[ccatFileName]
    except KeyError:
        ccatFiles[ccatFileName] = open(ccatFileName, 'w')
    finally:
        ccatFiles[ccatFileName].write(c.process_file().getvalue())


def main():
    args = parse_options()
    ccatFiles = {}

    if not os.path.exists(args.ccatDir):
        os.makedirs(args.ccatDir)

    for cdir in args.analysed_dir:
        for root, dirs, files in os.walk(cdir): # Walk directory tree
            for f in files:
                if f.endswith('.xml'):
                    for type_ in ['disambiguation', 'dependency']:
                        print_file(type_, os.path.join(root, f), ccatFiles,
                                   args.ccatDir)

    for ccatFile in ccatFiles.values():
        ccatFile.close()

if __name__ == '__main__':
    main()
