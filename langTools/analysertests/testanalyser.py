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
        a.disambiguationAnalysis()
        got = a.getDisambiguation()
        want = '"<Muhto>"\n\t"muhto" CC <sme> @CVP \n"<gaskkohagaid>"\n\t"gaskkohagaid" Adv <sme> \n"<,>"\n\t"," CLB \n"<ja>"\n\t"ja" CC <sme> @CNP \n"<erenoamážit>"\n\t"erenoamážit" Adv <sme> \n"<dalle_go>"\n\t"dalle_go" MWE CS <sme> @CVP \n"<lei>"\n\t"leat" V <sme> IV Ind Prt Sg3 @+FMAINV \n"<buolaš>"\n\t"buolaš" Sem/Wthr N <sme> Sg Nom \n"<,>"\n\t"," CLB \n"<de>"\n\t"de" Adv <sme> \n"<aggregáhta>"\n\t"aggregáhta" N <sme> Sg Nom \n"<billánii>"\n\t"billánit" V <sme> IV Ind Prt Sg3 @+FMAINV \n"<.>"\n\t"." CLB \n\n"<¶>"\n\t"¶" CLB \n\n'

        self.assertEqual(got, want.encode('utf8'))

    def testSmeDependencyOutput(self):
        """Check if disambiguation analysis gives the expected output
        """
        a = analyser.Analyser('sme', 'smefile.xml')
        a.dependencyAnalysis()
        got = a.getDependency()
        want = '"<Muhto>"\n\t"muhto" CC @CVP #1->1 \n"<gaskkohagaid>"\n\t"gaskkohagaid" Adv @ADVL> #2->12 \n"<,>"\n\t"," CLB #3->4 \n"<ja>"\n\t"ja" CC @CNP #4->2 \n"<erenoamážit>"\n\t"erenoamážit" Adv @ADVL> #5->12 \n"<dalle_go>"\n\t"dalle_go" CS @CVP #6->7 \n"<lei>"\n\t"leat" V IV Ind Prt Sg3 @FS-ADVL> #7->12 \n"<buolaš>"\n\t"buolaš" N Sg Nom @<SPRED #8->7 \n"<,>"\n\t"," CLB #9->6 \n"<de>"\n\t"de" Adv @ADVL> #10->12 \n"<aggregáhta>"\n\t"aggregáhta" N Sg Nom @SUBJ> #11->12 \n"<billánii>"\n\t"billánit" V IV Ind Prt Sg3 @FS-ADVL> #12->0 \n"<.>"\n\t"." CLB #13->12 \n\n"<¶>"\n\t"¶" CLB #1->1 \n\n'

        self.assertEqual(got, want.encode('utf8'))

    def testAnalysisXml(self):
        """Check if the xml is what it is supposed to be
        """
        a = analyser.Analyser('sme', 'smefile.xml')
        a.dependencyAnalysis()
        got = a.getAnalysisXml()
        want = '''<document xml:lang="sme" id="no_id">
  <header>
    <title>Internáhtta sosiálalaš giliguovddážin</title>
    <genre code="facta"/>
    <author>
      <person firstname="Abba" lastname="Abbamar" sex="m" born="1900" nationality="nor"/>
    </author>
    <translator>
      <person firstname="Ibba" lastname="Ibbamar" sex="unknown" born="" nationality=""/>
    </translator>
    <translated_from xml:lang="nob"/>
    <year>2005</year>
    <publChannel>
      <publication>
        <publisher>Almmuheaddji OS</publisher>
      </publication>
    </publChannel>
    <wordcount>10</wordcount>
    <availability>
      <free/>
    </availability>
    <submitter name="Børre Gaup" email="boerre.gaup@samediggi.no"/>
    <multilingual>
      <language xml:lang="nob"/>
    </multilingual>
    <origFileName>aarseth_s.htm</origFileName>
    <metadata>
      <uncomplete/>
    </metadata>
    <version>XSLtemplate  1.9 ; file-specific xsl  $Revision: 1.3 $; common.xsl  $Revision$; </version>
  </header>
  <body><disambiguation>"&lt;Muhto&gt;"\n\t"muhto" CC &lt;sme&gt; @CVP \n"&lt;gaskkohagaid&gt;"\n\t"gaskkohagaid" Adv &lt;sme&gt; \n"&lt;,&gt;"\n\t"," CLB \n"&lt;ja&gt;"\n\t"ja" CC &lt;sme&gt; @CNP \n"&lt;erenoamážit&gt;"\n\t"erenoamážit" Adv &lt;sme&gt; \n"&lt;dalle_go&gt;"\n\t"dalle_go" MWE CS &lt;sme&gt; @CVP \n"&lt;lei&gt;"\n\t"leat" V &lt;sme&gt; IV Ind Prt Sg3 @+FMAINV \n"&lt;buolaš&gt;"\n\t"buolaš" Sem/Wthr N &lt;sme&gt; Sg Nom \n"&lt;,&gt;"\n\t"," CLB \n"&lt;de&gt;"\n\t"de" Adv &lt;sme&gt; \n"&lt;aggregáhta&gt;"\n\t"aggregáhta" N &lt;sme&gt; Sg Nom \n"&lt;billánii&gt;"\n\t"billánit" V &lt;sme&gt; IV Ind Prt Sg3 @+FMAINV \n"&lt;.&gt;"\n\t"." CLB \n\n"&lt;¶&gt;"\n\t"¶" CLB \n\n</disambiguation><dependency>"&lt;Muhto&gt;"\n\t"muhto" CC @CVP #1-&gt;1 \n"&lt;gaskkohagaid&gt;"\n\t"gaskkohagaid" Adv @ADVL&gt; #2-&gt;12 \n"&lt;,&gt;"\n\t"," CLB #3-&gt;4 \n"&lt;ja&gt;"\n\t"ja" CC @CNP #4-&gt;2 \n"&lt;erenoamážit&gt;"\n\t"erenoamážit" Adv @ADVL&gt; #5-&gt;12 \n"&lt;dalle_go&gt;"\n\t"dalle_go" CS @CVP #6-&gt;7 \n"&lt;lei&gt;"\n\t"leat" V IV Ind Prt Sg3 @FS-ADVL&gt; #7-&gt;12 \n"&lt;buolaš&gt;"\n\t"buolaš" N Sg Nom @&lt;SPRED #8-&gt;7 \n"&lt;,&gt;"\n\t"," CLB #9-&gt;6 \n"&lt;de&gt;"\n\t"de" Adv @ADVL&gt; #10-&gt;12 \n"&lt;aggregáhta&gt;"\n\t"aggregáhta" N Sg Nom @SUBJ&gt; #11-&gt;12 \n"&lt;billánii&gt;"\n\t"billánit" V IV Ind Prt Sg3 @FS-ADVL&gt; #12-&gt;0 \n"&lt;.&gt;"\n\t"." CLB #13-&gt;12 \n\n"&lt;¶&gt;"\n\t"¶" CLB #1-&gt;1 \n\n</dependency></body></document>'''
        self.maxDiff = None
        self.assertEqual(etree.tostring(got, encoding='unicode'), want)

def main():
    unittest.main()

if __name__ == '__main__':
    main()
