# -*- coding: utf-8 -*-
import unittest
import parallelize
import lxml.doctestcompare
import lxml.etree
import doctest

class TestParallelFile(unittest.TestCase):
    """
    A test class for the ParallelFile class
    """
    def setUp(self):
        self.pfile = parallelize.ParallelFile()
        
    def testName(self):
        self.pfile.setName("test")
        self.assertEqual(self.pfile.getName(), "test")
        
    def testLang(self):
        self.pfile.setLang("sme")
        self.assertEqual(self.pfile.getLang(), "sme")
        
class TestParallelize(unittest.TestCase):
    """
    A test class for the Parallelize module
    """
    def setUp(self):
        self.parallelize = parallelize.Parallelize("/home/boerre/Dokumenter/corpus/freecorpus/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml", "nob")
        
    def assertXmlEqual(self, got, want):
        """
        Check if two stringified xml snippets are equal
        """
        checker = lxml.doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)
        
    def testFindParallelFilename(self):
        self.assertEqual(self.parallelize.findParallelFilename(), 'aarseth2-n.htm')
        
    def testOrigPath(self):
        self.assertEqual(self.parallelize.getorigfile1(), "/home/boerre/Dokumenter/corpus/freecorpus/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml")
        
    def testParallelPath(self):
        self.assertEqual(self.parallelize.getorigfile2(), "/home/boerre/Dokumenter/corpus/freecorpus/prestable/converted/nob/facta/skuvlahistorja2/aarseth2-n.htm.xml")
        
    def testLang1(self):
        self.assertEqual(self.parallelize.getlang1(), "sme")
        
    def testLang2(self):
        self.assertEqual(self.parallelize.getlang2(), "nob")
        
    def testGetSentFilename(self):
        self.assertEqual(self.parallelize.getSentFilename(self.parallelize.getorigfile1()), "/home/boerre/Dokumenter/corpus/freecorpus/tmp/aarseth2-s.htm_sent.xml")
        
    def testMakeTu(self):
        line1 = '<s id="1">ubba gubba.</s> <s id="2">ibba gibba.</s>'
        line2 = '<s id="1">abba gabba.</s> <s id="2">ebba gebba.</s>'
        
        gotTu = lxml.etree.tostring(self.parallelize.makeTu(line1, line2), pretty_print = True)

        wantTu = lxml.etree.tostring(lxml.etree.XML('<tu><tuv xml:lang="sme"><seg>ubba gubba. ibba gibba.</seg></tuv><tuv xml:lang="nob"><seg>abba gabba. ebba gebba.</seg></tuv></tu>'), pretty_print = True)
        
        self.assertXmlEqual(gotTu, wantTu)

    def testMakeTuv(self):
        line =  '<s id="1">ubba gubba.</s> <s id="2">ibba gibba.</s>'
        lang = 'smi'
        gotTuv = lxml.etree.tostring(self.parallelize.makeTuv(line, lang))
        
        wantTuv = lxml.etree.tostring(lxml.etree.XML('<tuv xml:lang="smi"><seg>ubba gubba. ibba gibba.</seg></tuv>'))
        
        self.assertXmlEqual(gotTuv, wantTuv)
        
    def testMakeTmxHeader(self):
        lang = 'smi'
        gotTuv = lxml.etree.tostring(self.parallelize.makeTmxHeader(lang))
        
        wantTuv = lxml.etree.tostring(lxml.etree.XML('<header segtype="sentence" o-tmf="OmegaT TMX" adminlang="en-US" srclang="smi" datatype="plaintext"/>'))
        
        self.assertXmlEqual(gotTuv, wantTuv)
        
    def testRemoveSTag(self):
        got = self.parallelize.removeSTag('<s id="1">ubba gubba.</s> <s id="2">ibba gibba.</s>')
        want =  'ubba gubba. ibba gibba.'
        
        self.assertEqual(got, want)
        
    def testDividePIntoSentences(self):
        self.assertEqual(self.parallelize.dividePIntoSentences(), 0)

    def testParallizeFiles(self):
        self.assertEqual(self.parallelize.parallelizeFiles(), 0)
        
    def testPrintTmxFile(self):
        got = lxml.etree.tostring(lxml.etree.parse("aarseth2-s.htm.tmx"))
        want = lxml.etree.tostring(lxml.etree.parse(self.parallelize.printTmxFile(self.parallelize.makeTmx())))
        self.assertXmlEqual(got, want)
        

def lightTests():
    independentSuite = unittest.TestSuite()
    independentSuite.addTest(TestParallelize("testRemoveSTag"))
    independentSuite.addTest(TestParallelize("testMakeTmxHeader"))
    independentSuite.addTest(TestParallelize("testMakeTuv"))
    independentSuite.addTest(TestParallelize("testMakeTu"))
    independentSuite.addTest(TestParallelize("testGetSentFilename"))
    independentSuite.addTest(TestParallelize("testLang1"))
    independentSuite.addTest(TestParallelize("testLang2"))
    independentSuite.addTest(TestParallelize("testParallelPath"))
    independentSuite.addTest(TestParallelize("testOrigPath"))
    independentSuite.addTest(TestParallelize("testFindParallelFilename"))
    
    return independentSuite
    
def defaultChainTest():
    chainTestSuite = unittest.TestSuite()
    chainTestSuite.addTest(TestParallelize("testDividePIntoSentences"))
    chainTestSuite.addTest(TestParallelize("testParallizeFiles"))
    chainTestSuite.addTest(TestParallelize("testPrintTmxFile"))
    
    return chainTestSuite
    
def customChainTest(pfile, lang, wantFile):
    test = TestParallelize()
    test.self.parallelize = parallelize.Parallelize(pfile, lang)
    


if __name__ == '__main__':
    unittest.TextTestRunner().run(lightTests())
    unittest.TextTestRunner().run(defaultChainTest())