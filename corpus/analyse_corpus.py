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

sys.path.append(os.getenv('GTHOME') + '/gt/script/langTools')
import analyser

def worker(inTuple):
    (lang, xmlFile, old) = inTuple
    ana = analyser.Analyser(lang, xmlFile, old)

    ana.analyse()

def sanityCheck(lang):
    """Look for programs and files that are needed to do the analysis.
    If they don't exist, quit the program
    """
    for program in ['ccat', 'preprocess', 'lookup2cg', 'lookup', 'vislcg3']:
        if which(program) is False:
            sys.stderr.write(program, " isn't found in path\n")
            sys.exit(2)

    if lang == 'sme':
        for file in [os.path.join(os.environ['GTHOME'], 'gt/sme/bin/abbr.txt'),
                        os.path.join(os.environ['GTHOME'], 'gt/sme/bin/corr.txt'),
                        os.path.join(os.getenv('GTHOME'), 'gt/' + lang +
                                '/bin/' + lang + '.fst'),
                        os.path.join(os.getenv('GTHOME'), 'gt/' + lang + '/src/Old' + lang + '-dis.rle'),
                        os.path.join(os.getenv('GTHOME'), 'gt/sme/src/sme-dis.rle'),
                        os.path.join( os.getenv('GTHOME'), 'gt/smi/src/smi-dep.rle')]:
            if os.path.isfile(file) is False:
                sys.stderr.write(file)
                sys.stderr.write(" doesn't exist\n")
                sys.stderr.write("Run make GTLANG=sme in ")
                sys.stderr.write(os.path.join(os.getenv('GTHOME'), 'gt'))
                sys.stderr.write('\n')
                sys.exit(2)
    else:
        for file in [os.path.join(os.getenv('GTHOME'),
                                'langs/' + lang + '/src/analyser-gt-desc.xfst'),
                    os.path.join(os.getenv('GTHOME'), 'langs/' +
                                            lang + '/src/syntax/disambiguation.cg3'),
                    os.path.join( os.getenv('GTHOME'), 'gt/smi/src/smi-dep.rle')]:
            if os.path.isfile(file) is False:
                sys.stderr.write(file)
                sys.stderr.write(" doesn't exist\n")
                sys.stderr.write("Run make in")
                sys.stderr.write(os.path.join(os.getenv('GTHOME'), 'langs/' + lang ))
                sys.stderr.write('\n')
                sys.exit(2)

def which(name):
        """Get the output of the unix command which.
        Return false if empty, true if non-empty
        """
        if subprocess.check_output(['which', name]) == '':
            return False
        else:
            return True

def parse_options():
    parser = argparse.ArgumentParser(description = 'Analyse files found in the given directories for the given language using multiple parallel processes.')
    parser.add_argument('-l', '--lang', help = "lang which should be analysed")
    parser.add_argument('-a', '--analysisdir', help='directory where the analysed files are placed')
    parser.add_argument('-o', '--old', help='When using this sme texts are analysed using the old disambiguation grammars', action="store_true")
    parser.add_argument('--debug', help="use this for debugging the analysis process. When this argument is used files will be analysed one by one.", action="store_true")
    parser.add_argument('converted_dir', nargs='+', help = "director(y|ies) where the converted files exist")

    args = parser.parse_args()
    return args

if __name__ == '__main__':
    args = parse_options()
    sanityCheck(args.lang)
    xmlFiles = []
    for cdir in args.converted_dir:
        for root, dirs, files in os.walk(cdir): # Walk directory tree
            for f in files:
                if args.lang in root and f.endswith('.xml'):
                    xmlFiles.append((args.lang, os.path.join(root, f), args.old))


    if args.debug is False:
        poolSize = multiprocessing.cpu_count() * 2
        pool = multiprocessing.Pool(processes=poolSize,)
        poolOutputs = pool.map(worker, xmlFiles)
        pool.close() # no more tasks
        pool.join()  # wrap up current tasks

    else:
        for xmlTuple in xmlFiles:
            print >> sys.stderr, "Analysing", xmlTuple[1]
            worker(xmlTuple)

    ac = analyser.AnalysisConcatenator(args.analysisdir, xmlFiles, args.old)
    ac.concatenateAnalysedFiles()
