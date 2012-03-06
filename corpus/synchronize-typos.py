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

class TestTypoline(unittest.TestCase):
    """Class to test the typos synchroniser
    """
    def setUp(self):
        pass
    
    def testGetCount(self):
        tl = Typoline('    196 deatalaš	deaŧalaš')
        self.assertEqual(tl.getCount(), 196)
    
    def testGetTypo(self):
        tl = Typoline('    196 deatalaš	deaŧalaš')
        self.assertEqual(tl.getTypo(), 'deatalaš')
    
        tl = Typoline('      6 deatalaš	deaŧalaš')
        self.assertEqual(tl.getTypo(), 'deatalaš')
    
    def testGetCorrection(self):
        tl = Typoline('    196 deatalaš	deaŧalaš')
        self.assertEqual(tl.getCorrection(), 'deaŧalaš')
    
        tl = Typoline('    196 deatalaš')
        self.assertEqual(tl.getCorrection(), None)

    def testMakeTypoline(self):
        tl = Typoline('    196 deatalaš deaŧalaš')
        self.assertEqual(tl.makeTypoline(), '    196 deatalaš deaŧalaš')
       
    def testSetCorrection(self):
        tl = Typoline('    196 deatalaš deaŧalaš')
        tl.setCorrection('ditalaš')
        self.assertEqual(tl.getCorrection(), 'ditalaš')
        
class Typoline:
    def __init__(self, typoline):
        parts = typoline.split('\t')
        
        firstPart = re.compile("(?P<numpart> +\d+) (?P<typopart>.*)")
        m = re.match(firstPart, parts[0])
        self.count = int(m.group('numpart').strip())
        self.typo = m.group('typopart')
        
        if len(parts) == 2:
            self.correction = parts[1]
        else:
            self.correction = None
        
    def getCount(self):
        return self.count
        
    def getTypo(self):
        return self.typo
        
    def setCorrection(self, correction):
        self.correction = correction
        
    def getCorrection(self):
        return self.correction

    def makeTypoline(self):
        result = '{0:7d} '.format(self.count) + self.typo
        if (self.correction):
            result = result + '\t' + self.correction

        return result
        
class Typos:
    """A class that reads typos from a .typos files and stores them in a dict
    """
    def __init__(self, typosfile):
        """Read typos from typosfile. Insert the typos into self.typos
        """
        self.typos = {}
        typofile = open(typosfile)
        
        for line in typofile:
            if line.strip():
                tl = Typoline(line.rstrip())
                if tl.getCorrection():
                    self.typos[tl.getTypo()] = tl.getCorrection()
        typofile.close()
        
    def getTypos(self):
        """Return the typos dict
        """
        return self.typos
        
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
