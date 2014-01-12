#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This is a program to convert corpus files with a
#   make like function
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
import subprocess
import argparse
import multiprocessing
import time
from distutils.dep_util import newer_group

sys.path.append(os.getenv(u'GTHOME') + u'/gt/script/langTools')
import analyser

def worker(inTuple):
    (lang, xmlFile, old) = inTuple
    ana = analyser.Analyser(lang, xmlFile, old)

    ana.analyse()

def sanityCheck(lang):
    u"""Look for programs and files that are needed to do the analysis.
    If they don't exist, quit the program
    """
    for program in [u'ccat', u'preprocess', u'lookup2cg', u'lookup', u'vislcg3']:
        if which(program) is False:
            sys.stderr.write(program, u" isn't found in path\n")
            sys.exit(2)

def which(name):
        u"""Get the output of the unix command which.
        Return false if empty, true if non-empty
        """
        if subprocess.check_output([u'which', name]) == u'':
            return False
        else:
            return True

def parse_options():
    parser = argparse.ArgumentParser(description = u'Analyse files found in the given directories for the given language using multiple parallel processes.')
    parser.add_argument(u'-l', u'--lang', help = u"lang which should be analysed")
    #parser.add_argument('-a', '--analysisdir', help='directory where the analysed files are placed')
    parser.add_argument(u'-o', u'--old', help=u'When using this sme texts are analysed using the old disambiguation grammars', action=u"store_true")
    parser.add_argument(u'--debug', help=u"use this for debugging the analysis process. When this argument is used files will be analysed one by one.", action=u"store_true")
    parser.add_argument(u'converted_dir', nargs=u'+', help = u"director(y|ies) where the converted files exist")

    args = parser.parse_args()
    return args

if __name__ == u'__main__':
    args = parse_options()
    sanityCheck(args.lang)
    xmlFiles = []
    for cdir in args.converted_dir:
        for root, dirs, files in os.walk(cdir): # Walk directory tree
            for f in files:
                if args.lang in root and f.endswith(u'.xml'):
                    xmlFiles.append((args.lang, os.path.join(root, f), args.old))


    if args.debug is False:
        poolSize = multiprocessing.cpu_count() * 2
        pool = multiprocessing.Pool(processes=poolSize,)
        poolOutputs = pool.map(worker, xmlFiles)
        pool.close() # no more tasks
        pool.join()  # wrap up current tasks

    else:
        for xmlTuple in xmlFiles:
            print >>sys.stderr, u"Analysing", xmlTuple[1]
            worker(xmlTuple)

    #ac = analyser.AnalysisConcatenator(args.analysisdir, xmlFiles, args.old)
    #ac.concatenateAnalysedFiles()
