#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This is a program to ccat giellatekno xml corpus files by
#   language, genre and translated from attributes
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
import subprocess

sys.path.append(os.getenv('GTHOME') + '/gt/script/langTools')
import analyser

def parse_options():
    parser = argparse.ArgumentParser(description = 'ccat xml files in a given directory by lang/genre/translated_from.')
    parser.add_argument('ccatDir', help='directory where the ccatted files are placed')
    parser.add_argument('lang', help = "lang which should be ccatted")
    parser.add_argument('converted_dir', nargs='+', help = "director(y|ies) where the converted files exist")

    args = parser.parse_args()
    return args

def sanityCheck():
    """Look for programs and files that are needed to do the analysis.
    If they don't exist, quit the program
    """
    for program in ['ccat']:
        if which(program) is False:
            sys.stderr.write(program, " isn't found in path\n")
            sys.exit(2)

def which(name):
        """Get the output of the unix command which.
        Return false if empty, true if non-empty
        """
        if subprocess.check_output(['which', name]) == '':
            return False
        else:
            return True

if __name__ == '__main__':
    args = parse_options()
    sanityCheck()
    ccatFiles = {}

    if not os.path.exists(args.ccatDir):
        os.makedirs(args.ccatDir)

    for cdir in args.converted_dir:
        for root, dirs, files in os.walk(cdir): # Walk directory tree
            for f in files:
                if f.endswith('.xml'):
                    c = analyser.Analyser(args.lang, os.path.join(root, f))
                    ccatFileName = os.path.join(args.ccatDir,
                                                '_'.join([c.getLang(), c.getGenre(), c.getTranslatedfrom()]) + '.ccat')
                    try:
                        ccatFiles[ccatFileName]
                    except KeyError:
                        ccatFiles[ccatFileName] = open(ccatFileName, 'w')
                    finally:
                        ccatFiles[ccatFileName].write(c.ccat())

    for ccatFile in ccatFiles.values():
        ccatFile.close()
