#!/usr/bin/env python
# -*- coding: utf-8 -*-
import unittest
import lxml.doctestcompare
import lxml.etree
import doctest
import os
import sys
import argparse

import parallelize

class TestParallelFile(unittest.TestCase):
    """
    A test class for the ParallelFile class
    """
    def setUp(self):
        self.pfile = parallelize.ParallelFile()
        
    def testName(self):
        self.pfile.setName("/home/test/filename.html")
        self.assertEqual(self.pfile.getName(), "filename.html")
        
    def testDirname(self):
        self.pfile.setName("/home/test/filename.html")
        self.assertEqual(self.pfile.getDirname(), "/home/test")
        
    def testLang(self):
        self.pfile.setLang("sme")
        self.assertEqual(self.pfile.getLang(), "sme")

        
class TestTmx(unittest.TestCase):
    """
    A test class for the Tmx class
    """
    def setUp(self):
        """
        Hand the data from the Parallelize class to the tmx class
        """
        para = parallelize.Parallelize(os.environ['GTFREE'] + "/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml", "nob")

        self.tmx = parallelize.Tmx(para.getFilelist())
    
    def assertXmlEqual(self, got, want):
        """
        Check if two xml snippets are equal
        """
        string_got = lxml.etree.tostring(got, pretty_print = True)
        string_want = lxml.etree.tostring(want, pretty_print = True)
        
        checker = lxml.doctestcompare.LXMLOutputChecker()
        if not checker.check_output(string_got, string_want, 0):
            message = checker.output_difference(doctest.Example("", string_got), string_want, 0).encode('utf-8')
            raise AssertionError('xmls not equal')
        
    def testMakeTu(self):
        line1 = '<s id="1">ubba gubba.</s> <s id="2">ibba gibba.</s>'
        line2 = '<s id="1">abba gabba.</s> <s id="2">ebba gebba.</s>'
        
        gotTu = self.tmx.makeTu(line1, line2)

        wantTu = lxml.etree.XML('<tu><tuv xml:lang="sme"><seg>ubba gubba. ibba gibba.</seg></tuv><tuv xml:lang="nob"><seg>abba gabba. ebba gebba.</seg></tuv></tu>')
        
        self.assertXmlEqual(gotTu, wantTu)

    def testMakeTuv(self):
        line =  '<s id="1">ubba gubba.</s> <s id="2">ibba gibba.</s>'
        lang = 'smi'
        gotTuv = self.tmx.makeTuv(line, lang)
        
        wantTuv = lxml.etree.XML('<tuv xml:lang="smi"><seg>ubba gubba. ibba gibba.</seg></tuv>')
        
        self.assertXmlEqual(gotTuv, wantTuv)
        
    def testMakeTmxHeader(self):
        lang = 'smi'
        gotTuv = self.tmx.makeTmxHeader(lang)
        
        wantTuv = lxml.etree.XML('<header segtype="sentence" o-tmf="OmegaT TMX" adminlang="en-US" srclang="smi" datatype="plaintext"/>')
        
        self.assertXmlEqual(gotTuv, wantTuv)
        
    def testRemoveSTag(self):
        got = self.tmx.removeSTag('<s id="1">ubba gubba.</s> <s id="2">ibba gibba.</s>')
        want =  'ubba gubba. ibba gibba.'
        
        self.assertEqual(got, want)
        
    def testGetOutfileName(self):
        self.assertEqual(self.tmx.getOutfileName(), os.path.join(os.environ['GTFREE'], 'prestable/tmx/sme2nob/facta/skuvlahistorja2/aarseth2-s.htm.tmx'))
    
    def testPrintTmxFile(self):
        want = lxml.etree.parse("aarseth2-s.htm.tmx")
        self.tmx.printTmxFile()
        got = lxml.etree.parse(self.tmx.getOutfileName())
        
        self.assertXmlEqual(want, got)

    def testTuToString(self):
        tu = lxml.etree.XML('<tu><tuv xml:lang="sme"><seg>Sámegiella</seg></tuv><tuv xml:lang="nob"><seg>Samisk</seg></tuv></tu>')
        
        self.assertEqual(self.tmx.tuToString(tu), "Sámegiella\tSamisk\n")
        
    def testTmxToStringlist(self):
        f = open('aarseth2-s.htm.tmx.as.txt', 'r')
        wantList = f.readlines()
        f.close()
        #self.maxDiff = None
        self.assertEqual(self.tmx.tmxToStringlist(), wantList)

class TestTmxComparator(unittest.TestCase):
    """
    A test class for the TmxComparator class
    """
    
    
class TestParallelize(unittest.TestCase):
    """
    A test class for the Parallelize class
    """
    def setUp(self):
        self.parallelize = parallelize.Parallelize(os.environ['GTFREE'] + "/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml", "nob")
    
    def testFindParallelFilename(self):
        self.assertEqual(self.parallelize.findParallelFilename(), 'aarseth2-n.htm')
        
    def testOrigPath(self):
        self.assertEqual(self.parallelize.getorigfile1(), os.environ['GTFREE'] + "/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml")
        
    def testParallelPath(self):
        self.assertEqual(self.parallelize.getorigfile2(), os.environ['GTFREE'] + "/prestable/converted/nob/facta/skuvlahistorja2/aarseth2-n.htm.xml")
        
    def testLang1(self):
        self.assertEqual(self.parallelize.getlang1(), "sme")
        
    def testLang2(self):
        self.assertEqual(self.parallelize.getlang2(), "nob")
        
    def testGetSentFilename(self):
        self.assertEqual(self.parallelize.getSentFilename(self.parallelize.getorigfile1()), os.environ['GTFREE'] + "/tmp/aarseth2-s.htm_sent.xml")
        
    def testDividePIntoSentences(self):
        self.assertEqual(self.parallelize.dividePIntoSentences(), 0)

    def testParallizeFiles(self):
        self.assertEqual(self.parallelize.parallelizeFiles(), 0)
        
    #def testGoldstandard(self):
        #goldstandard = {}
        #goldstandard['/prestable/tmx/goldstandard/nob2sme/samisk_strategiplan_samisk.doc.tmx'] = '/prestable/converted/sme/admin/others/samisk_strategiplan_samisk.doc.xml'
        #goldstandard['/prestable/tmx/goldstandard/nob2sme/dc_05_1.doc.tmx'] = 'prestable/converted/sme/admin/sd/other_files/dc_05_1.doc.xml'
        #goldstandard['/prestable/tmx/goldstandard/nob2sme/finnmarkkulahka_web_lettere.pdf.tmx'] = 'prestable/converted/sme/laws/other_files/finnmarkkulahka_web_lettere.pdf.xml'
        
        #for tmxFile, xmlFile in goldstandard.items():
            #self.parallelize = parallelize.Parallelize(os.environ['GTFREE'] + "/" + xmlFile, 'nob')
            #self.parallelize.dividePIntoSentences()
            #self.parallelize.parallelizeFiles()
            #got = lxml.etree.parse(self.parallelize.printTmxFile(self.parallelize.makeTmx()))
            #want = lxml.etree.parse(os.environ['GTFREE'] + "/" + tmxFile)
            
            #self.assertXmlEqual(got, want)

if __name__ == '__main__':
    for test in [TestParallelFile, TestParallelize, TestTmx]:
        testSuite = unittest.TestSuite()
        testSuite.addTest(unittest.makeSuite(test))
        unittest.TextTestRunner().run(testSuite)
        
    #parser = argparse.ArgumentParser(description = 'Test various parts of the alignment process')
    #parser.add_argument('-g', '--goldstandard', dest = 'goldstandard', help = 'Check if the current aligner pipeline agrees with the goldstandard docs', action = 'store_true')
    #args = parser.parse_args()
    
    #if args.goldstandard:
        #unittest.TextTestRunner().run(customChainTest())
    #else:
        #unittest.TextTestRunner().run(lightTests())
        #unittest.TextTestRunner().run(defaultChainTest())
