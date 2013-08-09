#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This file contains a program to convert corpus files with a
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
import analysisconcatenator

def parse_options():
    parser = argparse.ArgumentParser(description = 'Convert original files to giellatekno xml, using dependency checking.')
    parser.add_argument('lang', help = "lang which should be analysed")
    parser.add_argument('converted_dir', help = "directory where the converted files exist")

    args = parser.parse_args()
    return args

def worker(inTuple):
    (lang, xmlFile) = inTuple
    ana = analyser.Analyser(lang, xmlFile)
    ana.analyse()

if __name__ == '__main__':
    args = parse_options()
    xmlFiles = []
    for root, dirs, files in os.walk(args.converted_dir): # Walk directory tree
        for f in files:
            if args.lang in root and f.endswith('.xml'):
                xmlFiles.append((args.lang, os.path.join(root, f)))

    poolSize = multiprocessing.cpu_count() * 2
    pool = multiprocessing.Pool(processes=poolSize,)
    poolOutputs = pool.map(worker, xmlFiles)
    pool.close() # no more tasks
    pool.join()  # wrap up current tasks

    ac = analyser.AnalysisConcatenator(xmlFiles)
    ac.concatenateAnalysedFiles()
