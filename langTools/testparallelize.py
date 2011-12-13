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
        
    def testBasename(self):
        self.pfile.setName("/home/test/filename.html")
        self.assertEqual(self.pfile.getBasename(), "filename.html")
        
    def testDirname(self):
        self.pfile.setName("/home/test/filename.html")
        self.assertEqual(self.pfile.getDirname(), "/home/test")
        
    def testName(self):
        self.pfile.setName("/home/test/filename.html")
        self.assertEqual(self.pfile.getName(), "/home/test/filename.html")
        
    def testLang(self):
        self.pfile.setLang("sme")
        self.assertEqual(self.pfile.getLang(), "sme")

class TestParallelize(unittest.TestCase):
    """
    A test class for the Parallelize class
    """
    def setUp(self):
        self.parallelize = parallelize.Parallelize(os.environ['GTFREE'] + "/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml", "nob")
    
    def testFindParallelFilename(self):
        self.assertEqual(self.parallelize.findParallelFilename(), 'aarseth2-n.htm')
        
    def testOrigPath(self):
        self.assertEqual(self.parallelize.getorigfile1(), os.environ['GTFREE'] + "/prestable/converted/nob/facta/skuvlahistorja2/aarseth2-n.htm.xml")
        
    def testParallelPath(self):
        self.assertEqual(self.parallelize.getorigfile2(), os.environ['GTFREE'] + "/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml")
        
    def testLang1(self):
        self.assertEqual(self.parallelize.getlang1(), "nob")
        
    def testLang2(self):
        self.assertEqual(self.parallelize.getlang2(), "sme")
        
    def testGetSentFilename(self):
        self.assertEqual(self.parallelize.getSentFilename(self.parallelize.getFilelist()[0]), os.environ['GTFREE'] + "/tmp/aarseth2-n.htmnob_sent.xml")
        
    def testDividePIntoSentences(self):
        self.assertEqual(self.parallelize.dividePIntoSentences(), 0)

    def testParallizeFiles(self):
        self.assertEqual(self.parallelize.parallelizeFiles(), 0)
        
    def testGenerateAnchorFile(self):
        self.assertEqual(self.parallelize.generateAnchorFile(), os.path.join(os.environ['GTFREE'], 'anchor-nobsme.txt'))
        
class TestTmx(unittest.TestCase):
    """
    A test class for the Tmx class
    """
    def setUp(self):
        self.tmx = parallelize.Tmx(lxml.etree.parse('aarseth2-n.htm.tmx'))
        
    def assertXmlEqual(self, got, want):
        """
        Check if two xml snippets are equal
        """
        string_got = lxml.etree.tostring(got, pretty_print = True)
        string_want = lxml.etree.tostring(want, pretty_print = True)
        
        checker = lxml.doctestcompare.LXMLOutputChecker()
        if not checker.check_output(string_got, string_want, 0):
            message = checker.output_difference(doctest.Example("", string_got), string_want, 0).encode('utf-8')
            raise AssertionError(message)
        
    def testTuToString(self):
        tu = lxml.etree.XML('<tu><tuv xml:lang="sme"><seg>Sámegiella</seg></tuv><tuv xml:lang="nob"><seg>Samisk</seg></tuv></tu>')
        
        self.assertEqual(self.tmx.tuToString(tu), "Sámegiella\tSamisk\n")

    def testTuvToString(self):
        tuv = lxml.etree.XML('<tuv xml:lang="sme"><seg>Sámegiella</seg></tuv>')
        
        self.assertEqual(self.tmx.tuvToString(tuv), "Sámegiella")
        
    def testLangToStringList(self):
        f = open('aarseth2-n.htm.tmx.as.txt', 'r')
        stringList = f.readlines()
        
        nobList = []
        smeList = []
        for string in stringList:
            pairList = string.split('\t')
            nobList.append(pairList[0])
            smeList.append(pairList[1].strip())
            
        self.assertEqual(self.tmx.langToStringlist('nob'), nobList)
        self.assertEqual(self.tmx.langToStringlist('sme'), smeList)
    
    def testTmxToStringlist(self):
        f = open('aarseth2-n.htm.tmx.as.txt', 'r')
        wantList = f.readlines()
        f.close()
        #self.maxDiff = None
        self.assertEqual(self.tmx.tmxToStringlist(), wantList)
    
    def testPrettifySegs(self):
        wantXml = lxml.etree.XML('<tu><tuv xml:lang="nob"><seg>ubba gubba. ibba gibba.</seg></tuv><tuv xml:lang="sme"><seg>abba gabba. ebba gebba.</seg></tuv></tu>')
        gotXml = lxml.etree.XML('<tu><tuv xml:lang="nob"><seg>ubba gubba. ibba gibba.\n</seg></tuv><tuv xml:lang="sme"><seg>abba gabba. ebba gebba.\n</seg></tuv></tu>')
        self.assertXmlEqual(self.tmx.prettifySegs(gotXml), wantXml)
        
class TestTmxFromTca2(unittest.TestCase):
    """
    A test class for the TmxFromTca2 class
    """
    def setUp(self):
        """
        Hand the data from the Parallelize class to the tmx class
        """
        para = parallelize.Parallelize(os.environ['GTFREE'] + "/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml", "nob")

        self.tmx = parallelize.TmxFromTca2(para.getFilelist())
    
    def assertXmlEqual(self, got, want):
        """
        Check if two xml snippets are equal
        """
        string_got = lxml.etree.tostring(got, pretty_print = True)
        string_want = lxml.etree.tostring(want, pretty_print = True)
        
        checker = lxml.doctestcompare.LXMLOutputChecker()
        if not checker.check_output(string_got, string_want, 0):
            message = checker.output_difference(doctest.Example("", string_got), string_want, 0).encode('utf-8')
            raise AssertionError(message)
        
    def testMakeTu(self):
        line1 = '<s id="1">ubba gubba.</s> <s id="2">ibba gibba.</s>'
        line2 = '<s id="1">abba gabba.</s> <s id="2">ebba gebba.</s>'
        
        gotTu = self.tmx.makeTu(line1, line2)

        wantTu = lxml.etree.XML('<tu><tuv xml:lang="nob"><seg>ubba gubba. ibba gibba.</seg></tuv><tuv xml:lang="sme"><seg>abba gabba. ebba gebba.</seg></tuv></tu>')
        
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
        self.assertEqual(self.tmx.getOutfileName(), os.path.join(os.environ['GTFREE'], 'prestable/tmx/nob2sme/facta/skuvlahistorja2/aarseth2-n.htm.tmx'))
    
    def testPrintTmxFile(self):
        want = lxml.etree.parse("aarseth2-n.htm.tmx")
        self.tmx.printTmxFile()
        got = lxml.etree.parse(self.tmx.getOutfileName())
        
        self.assertXmlEqual(got, want)

class TestTmxComparator(unittest.TestCase):
    """
    A test class for the TmxComparator class
    """
    def testEqualTmxes(self):
        comp = parallelize.TmxComparator(parallelize.Tmx(lxml.etree.parse('aarseth2-n.htm.tmx')), parallelize.Tmx(lxml.etree.parse('aarseth2-n.htm.tmx')))
        
        self.assertEqual(comp.getNumberOfDifferingLines(), -1)
        self.assertEqual(comp.getLinesInWantedfile(), 274)
        self.assertEqual(len(comp.getDiffAsText()), 0)
        
    #def testUnEqualTmxes(self):
        #gotFile = os.path.join(os.environ['GTFREE'], 'prestable/tmx/nob2sme/laws/other_files/finnmarksloven.pdf.tmx')
        #wantFile = os.path.join(os.environ['GTFREE'], 'prestable/tmx/goldstandard/nob2sme/laws/other_files/finnmarksloven.pdf.tmx')
        #comp = parallelize.TmxComparator(parallelize.Tmx(lxml.etree.parse(wantFile)), parallelize.Tmx(lxml.etree.parse(gotFile)))

        #self.assertEqual(comp.getNumberOfDifferingLines(), 7)
        #self.assertEqual(comp.getLinesInWantedfile(), 632)
        #self.assertEqual(len(comp.getDiffAsText()), 28)

    #def testReversedlang(self):
        #wantFile = parallelize.Tmx(lxml.etree.parse('aarseth2-n.htm.tmx'))
        #gotFile = parallelize.Tmx(lxml.etree.parse('aarseth2-s.htm.tmx'))
        #gotFile.reverseLangs()
        
        #comp = parallelize.TmxComparator(wantFile, gotFile)
        
        #print comp.getDiffAsText()
        #self.assertEqual(comp.getNumberOfDifferingLines(), -1)
        #self.assertEqual(comp.getLinesInWantedfile(), 274)
        #self.assertEqual(len(comp.getDiffAsText()), 0)
        
class TestTmxTestDataWriter(unittest.TestCase):
    """
    A class to test TmxTestDataWriter
    """
    def setUp(self):
        self.writer = parallelize.TmxTestDataWriter("testfilename")
        
    def assertXmlEqual(self, got, want):
        """
        Check if two xml snippets are equal
        """
        string_got = lxml.etree.tostring(got, pretty_print = True)
        string_want = lxml.etree.tostring(want, pretty_print = True)
        
        checker = lxml.doctestcompare.LXMLOutputChecker()
        if not checker.check_output(string_got, string_want, 0):
            message = checker.output_difference(doctest.Example("", string_got), string_want, 0).encode('utf-8')
            raise AssertionError(message)
        
    def testMakeFileElement(self):
        wantElement = lxml.etree.XML('<file name="abc" gspairs="634" diffpairs="84"/>')
        gotElement = self.writer.makeFileElement("abc", "634", "84")
        
        self.assertXmlEqual(wantElement, gotElement)
    
    def testMakeTestrunElement(self):
        wantElement = lxml.etree.XML('<testrun datetime="20111208-1234"><file name="abc" gspairs="634" diffpairs="84"/></testrun>')
        gotElement = self.writer.makeTestrunElement("20111208-1234")
        fileElement = self.writer.makeFileElement("abc", "634", "84")
        gotElement.append(fileElement)
        
        self.assertXmlEqual(wantElement, gotElement)
    
    def testMakeParagstestingElement(self):
        wantElement = lxml.etree.XML('<paragstesting><testrun datetime="20111208-1234"><file name="abc" gspairs="634" diffpairs="84"/></testrun></paragstesting>')
        gotElement = self.writer.makeParagstestingElement()
        testrunElement = self.writer.makeTestrunElement("20111208-1234")
        fileElement = self.writer.makeFileElement("abc", "634", "84")
        testrunElement.append(fileElement)
        gotElement.append(testrunElement)
        
        self.assertXmlEqual(wantElement, gotElement)
    
    def testInsertTestrunElement(self):
        wantElement = lxml.etree.XML('<paragstesting><testrun datetime="20111208-2345"><file name="abc" gspairs="634" diffpairs="84"/></testrun><testrun datetime="20111208-1234"><file name="abc" gspairs="634" diffpairs="84"/></testrun></paragstesting>')
        
        gotElement = self.writer.makeParagstestingElement()
        self.writer.setParagsTestingElement(gotElement)
        testrunElement = self.writer.makeTestrunElement("20111208-1234")
        fileElement = self.writer.makeFileElement("abc", "634", "84")
        testrunElement.append(fileElement)
        gotElement.append(testrunElement)

        testrunElement = self.writer.makeTestrunElement("20111208-2345")
        fileElement = self.writer.makeFileElement("abc", "634", "84")
        testrunElement.append(fileElement)
        
        self.writer.insertTestrunElement(testrunElement)
        
        self.assertXmlEqual(wantElement, gotElement)
        
    def testWriteParagstestingData(self):
        want = lxml.etree.XML('<paragstesting><testrun datetime="20111208-1234"><file name="abc" gspairs="634" diffpairs="84"/></testrun></paragstesting>')
        
        gotElement = self.writer.makeParagstestingElement()
        self.writer.setParagsTestingElement(gotElement)
        testrunElement = self.writer.makeTestrunElement("20111208-1234")
        fileElement = self.writer.makeFileElement("abc", "634", "84")
        testrunElement.append(fileElement)
        gotElement.append(testrunElement)

        
        self.writer.writeParagstestingData()
        got = lxml.etree.parse(self.writer.filename)
        
        self.assertXmlEqual(got, want)
        
if __name__ == '__main__':
    for test in [TestParallelFile, TestParallelize, TestTmx, TestTmxFromTca2, TestTmxComparator, TestTmxTestDataWriter]:
        testSuite = unittest.TestSuite()
        testSuite.addTest(unittest.makeSuite(test))
        unittest.TextTestRunner().run(testSuite)
