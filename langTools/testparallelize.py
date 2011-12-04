# -*- coding: utf-8 -*-
import unittest
import parallelize

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
        
    def testDividePIntoSentences(self):
        self.assertEqual(self.parallelize.dividePIntoSentences(), 0)

    def testParallizeFiles(self):
        self.assertEqual(self.parallelize.parallelizeFiles(), 0)

if __name__ == '__main__':
    unittest.main()
    