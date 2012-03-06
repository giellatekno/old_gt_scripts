#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This file synchronises the .typos files in $GTFREE
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
#   along with this file. If not, see <http://www.gnu.org/licenses/>.
#
#   Copyright 2012 Børre Gaup <borre.gaup@uit.no>
#

import unittest
import re
import subprocess
import os
import fileinput

def findTyposFiles():
    """
    Find the typos files in dirname, return them as a list
    """
    subp = subprocess.Popen(['find', os.path.join(os.environ['GTFREE'], 'prestable/converted'), '-name', '*.typos', '-print' ], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
    (output, error) = subp.communicate()

    if subp.returncode != 0:
        print >>sys.stderr, 'Error when searching for typos docs'
        print >>sys.stderr, error
        sys.exit(1)
    else:
        files = output.split('\n')
        return files[:-1]

def main():
    files = findTyposFiles()
    typos = {}
    
    for typoname in files:
        # Read typos from a .typos file
        typosInstance = Typos(typoname)
        # Add the typos found to a the typos dict
        typos.update(typosInstance.getTypos())
        
    for typoname in files:
        for line in fileinput.FileInput(typoname, inplace = 1):
            line = line.rstrip()
            if line:
                tl = Typoline(line)
                if tl.getCorrection() == None and tl.getTypo() in typos:
                    tl.setCorrection(typos[tl.getTypo()])
                    line = tl.makeTypoline()
                
            print line
    
if __name__ == '__main__':
    main()
    #for test in [TestTypoline]:
        #testSuite = unittest.TestSuite()
        #testSuite.addTest(unittest.makeSuite(test))
        #unittest.TextTestRunner().run(testSuite)
