#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This file contains a class to analyse text in giellatekno xml format
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
#   Copyright 2013-2014 Børre Gaup <borre.gaup@uit.no>
#

import unittest
import doctest
from lxml import etree
from lxml import doctestcompare

import sys
import os

sys.path.append(os.getenv('GTHOME') + '/gt/script/langTools')
import analyser

class TestAnalyser(unittest.TestCase):
    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)

    def testSmeCcatOutput(self):
        """Test if the ccat output is what we expect it to be
        """
        a = analyser.Analyser('sme', 'smefile.xml')
        got = a.ccat()
        want = '''Muhto gaskkohagaid, ja erenoamážit dalle go lei buolaš, de aggregáhta billánii. ¶\n'''

        self.assertEqual(got, want)

    def testSmeDisambiguationOutput(self):
        """Check if disambiguation analysis gives the expected output
        """
        pass
        #a = analyser.Analyser('sme', 'smefile.xml')
        #got = a.disambiguationAnalysis()
        #want = '''"<Muhto>"
        #"muhto" CC <sme> @CVP
#"<gaskkohagaid>"
        #"gaskkohagaid" Adv <sme>
#"<,>"
        #"," CLB
#"<ja>"
        #"ja" CC <sme> @CNP
#"<erenoamážit>"
        #"erenoamážit" Adv <sme>
#"<dalle>"
        #"dalle" Adv <sme> Sem/Time
#"<go>"
        #"go" CS <sme> @CVP
#"<lei>"
        #"leat" V <sme> IV Ind Prt Sg3 @+FMAINV
#"<buolaš>"
        #"buolaš" Sem/Wthr N <sme> Sg Nom
#"<,>"
        #"," CLB
#"<de>"
        #"de" Adv <sme>
#"<aggregáhta>"
        #"aggregáhta" N <sme> Sg Nom
#"<billánii>"
        #"billánit" V <sme> IV Ind Prt Sg3 @+FMAINV
#"<.>"
        #"." CLB

#"<¶>"
        #"¶" CLB
#'''

        #self.assertEqual(got, want)

def main():
    unittest.main()

if __name__ == '__main__':
    main()
