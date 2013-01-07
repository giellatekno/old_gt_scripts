# -*- coding: utf-8 -*-

import os
import unittest

class TestPreconverter(unittest.TestCase):
    def setUp(self):
        self.preconverterInsideOrig = \
        Preconverter('fakecorpus/orig/nob/samediggi-article-16.html', True)
        
        self.preconverterOutsideOrig = \
        Preconverter('parallelize_data/samediggi-article-48.html', False)
        
        self.preconverterInsideFreecorpus = \
        Preconverter(os.path.join(os.getenv('GTFREE'), \
        'orig/sme/admin/sd/samediggi.no/samediggi-article-48.html'), False)
    
    def testGetOrig(self):
        self.assertEqual(self.preconverterInsideOrig.getOrig(), \
        os.path.join(os.getenv('GTHOME'),\
        'gt/script/langTools/fakecorpus/orig/nob/samediggi-article-16.html'))
        
        self.assertEqual(self.preconverterOutsideOrig.getOrig(), \
        os.path.join(os.getenv('GTHOME'), \
        'gt/script/langTools/parallelize_data/samediggi-article-48.html'))
        
        self.assertEqual(self.preconverterInsideFreecorpus.getOrig(), \
        os.path.join(os.getenv('GTFREE'), \
        'orig/sme/admin/sd/samediggi.no/samediggi-article-48.html'))
    
    def testGetXsl(self):
        self.assertEqual(self.preconverterInsideOrig.getXsl(), \
        os.path.join(os.getenv('GTHOME'),\
        'gt/script/langTools/fakecorpus/orig/nob/samediggi-article-16.html.xsl'))
        
        self.assertEqual(self.preconverterOutsideOrig.getXsl(), \
        os.path.join(os.getenv('GTHOME'), \
        'gt/script/langTools/parallelize_data/samediggi-article-48.html.xsl'))
        
        self.assertEqual(self.preconverterInsideFreecorpus.getXsl(), \
        os.path.join(os.getenv('GTFREE'), \
        'orig/sme/admin/sd/samediggi.no/samediggi-article-48.html.xsl'))
    
    def testGetTest(self):
        self.assertEqual(self.preconverterInsideOrig.getTest(), True)
        
        self.assertEqual(self.preconverterOutsideOrig.getTest(), False)
        
        self.assertEqual(self.preconverterInsideFreecorpus.getTest(), False)
    
    def testGetTmpdir(self):
        self.assertEqual(self.preconverterInsideOrig.getTmpdir(), \
        os.path.join(os.getenv('GTHOME'), 'gt/script/langTools/fakecorpus/tmp'))
        
        self.assertEqual(self.preconverterOutsideOrig.getTmpdir(), \
        os.path.join(os.getenv('GTHOME'), 'gt/script/langTools/tmp'))
        
        self.assertEqual(self.preconverterInsideFreecorpus.getTmpdir(), \
        os.path.join(os.getenv('GTFREE'), 'tmp'))
        
    def testGetCorpusdir(self):
        self.assertEqual(self.preconverterInsideOrig.getCorpusdir(), \
        os.path.join(os.getenv('GTHOME'), 'gt/script/langTools/fakecorpus'))
        
        self.assertEqual(self.preconverterOutsideOrig.getCorpusdir(), \
        os.path.join(os.getenv('GTHOME'), 'gt/script/langTools'))
        
        self.assertEqual(self.preconverterInsideFreecorpus.getCorpusdir(), \
        os.getenv('GTFREE'))    
    
class Preconverter:
    """
    Class to take care of data common to all Converter classes
    """
    def __init__(self, filename, test = False):
        self.orig = os.path.abspath(filename)
        self.setCorpusdir()
        self.test = test
        
    def getOrig(self):
        return self.orig
    
    def getXsl(self):
        return self.orig + '.xsl'
    
    def getTest(self):
        return self.test
    
    def getTmpdir(self):
        return os.path.join(self.getCorpusdir(), 'tmp')
    
    def getCorpusdir(self):
        return self.corpusdir
    
    def setCorpusdir(self):
        origPos = self.orig.find('orig/')
        if origPos != -1:
            self.corpusdir = os.path.dirname(self.orig[:origPos])
        else:
            self.corpusdir = os.getcwd()
            
from lxml import etree
from lxml import doctestcompare

class TestAvvirConverter(unittest.TestCase):
    def setUp(self):
        self.avvir = AvvirConverter('fakecorpus/orig/sme/news/Avvir_xml-filer/Avvir_2008_xml-filer/02nr028av.article.xml')
    
    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)
        
    def testConvert2intermediate(self):
        got = self.avvir.convert2intermediate()
        want = etree.parse('parallelize_data/gt-02nr028av.article.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))
        
    
class AvvirConverter(Preconverter):
    """
    Class to convert Ávvir xml files to the giellatekno xml format
    """
    
    def __init__(self, filename, test="False"):
        Preconverter.__init__(self, filename, test)
        self.converterXsl = \
        os.path.join(os.getenv('GTHOME'), 'gt/script/corpus/avvir2corpus.xsl')
        
    def convert2intermediate(self):
        """
        Convert the original document to the giellatekno xml format, with no 
        metadata
        The resulting xml is stored in intermediate
        """
        avvirXsltRoot = etree.parse(self.converterXsl)
        transform = etree.XSLT(avvirXsltRoot)
        doc = etree.parse(self.orig)
        intermediate = transform(doc)
        
        return intermediate