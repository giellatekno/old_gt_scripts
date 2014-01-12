#!/usr/bin/env python3
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
import os

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

        self.assertEqual(got, want.encode('utf8'))

    def testSmePreprocessOutput(self):
        """Test if the preprocess output is what we expect it to be
        """
        a = analyser.Analyser('sme', 'smefile.xml')
        got = a.preprocess()
        want = '''Muhto\ngaskkohagaid\n,\nja\nerenoamážit\ndalle go\nlei\nbuolaš\n,\nde\naggregáhta\nbillánii\n.\n¶\n'''

        self.assertEqual(got, want.encode('utf8'))

    def testSmeDisambiguationOutput(self):
        """Check if disambiguation analysis gives the expected output
        """
        a = analyser.Analyser('sme', 'smefile.xml')
        got = a.disambiguationAnalysis()
        want = '"<Muhto>"\n\t"muhto" CC <sme> @CVP \n"<gaskkohagaid>"\n\t"gaskkohagaid" Adv <sme> \n"<,>"\n\t"," CLB \n"<ja>"\n\t"ja" CC <sme> @CNP \n"<erenoamážit>"\n\t"erenoamážit" Adv <sme> \n"<dalle_go>"\n\t"dalle_go" MWE CS <sme> @CVP \n"<lei>"\n\t"leat" V <sme> IV Ind Prt Sg3 @+FMAINV \n"<buolaš>"\n\t"buolaš" Sem/Wthr N <sme> Sg Nom \n"<,>"\n\t"," CLB \n"<de>"\n\t"de" Adv <sme> \n"<aggregáhta>"\n\t"aggregáhta" N <sme> Sg Nom \n"<billánii>"\n\t"billánit" V <sme> IV Ind Prt Sg3 @+FMAINV \n"<.>"\n\t"." CLB \n\n"<¶>"\n\t"¶" CLB \n\n'

        self.assertEqual(got, want.encode('utf8'))

def main():
    unittest.main()

if __name__ == '__main__':
    main()
