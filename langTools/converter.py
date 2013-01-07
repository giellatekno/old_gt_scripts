# -*- coding: utf-8 -*-

#
#   This file contains routines to convert files to the giellatekno xml
#   format.
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

import os
import sys
import unittest

class TestConverter(unittest.TestCase):
    def setUp(self):
        self.converterInsideOrig = \
        Converter('fakecorpus/orig/nob/samediggi-article-16.html', True)
        
        self.converterOutsideOrig = \
        Converter('parallelize_data/samediggi-article-48.html', False)
        
        self.converterInsideFreecorpus = \
        Converter(os.path.join(os.getenv('GTFREE'), \
        'orig/sme/admin/sd/samediggi.no/samediggi-article-48.html'), False)
    
    def testGetOrig(self):
        self.assertEqual(self.converterInsideOrig.getOrig(), \
        os.path.join(os.getenv('GTHOME'),\
        'gt/script/langTools/fakecorpus/orig/nob/samediggi-article-16.html'))
        
        self.assertEqual(self.converterOutsideOrig.getOrig(), \
        os.path.join(os.getenv('GTHOME'), \
        'gt/script/langTools/parallelize_data/samediggi-article-48.html'))
        
        self.assertEqual(self.converterInsideFreecorpus.getOrig(), \
        os.path.join(os.getenv('GTFREE'), \
        'orig/sme/admin/sd/samediggi.no/samediggi-article-48.html'))
    
    def testGetXsl(self):
        self.assertEqual(self.converterInsideOrig.getXsl(), \
        os.path.join(os.getenv('GTHOME'),\
        'gt/script/langTools/fakecorpus/orig/nob/samediggi-article-16.html.xsl'))
        
        self.assertEqual(self.converterOutsideOrig.getXsl(), \
        os.path.join(os.getenv('GTHOME'), \
        'gt/script/langTools/parallelize_data/samediggi-article-48.html.xsl'))
        
        self.assertEqual(self.converterInsideFreecorpus.getXsl(), \
        os.path.join(os.getenv('GTFREE'), \
        'orig/sme/admin/sd/samediggi.no/samediggi-article-48.html.xsl'))
    
    def testGetTest(self):
        self.assertEqual(self.converterInsideOrig.getTest(), True)
        
        self.assertEqual(self.converterOutsideOrig.getTest(), False)
        
        self.assertEqual(self.converterInsideFreecorpus.getTest(), False)
    
    def testGetTmpdir(self):
        self.assertEqual(self.converterInsideOrig.getTmpdir(), \
        os.path.join(os.getenv('GTHOME'), 'gt/script/langTools/fakecorpus/tmp'))
        
        self.assertEqual(self.converterOutsideOrig.getTmpdir(), \
        os.path.join(os.getenv('GTHOME'), 'gt/script/langTools/tmp'))
        
        self.assertEqual(self.converterInsideFreecorpus.getTmpdir(), \
        os.path.join(os.getenv('GTFREE'), 'tmp'))
        
    def testGetCorpusdir(self):
        self.assertEqual(self.converterInsideOrig.getCorpusdir(), \
        os.path.join(os.getenv('GTHOME'), 'gt/script/langTools/fakecorpus'))
        
        self.assertEqual(self.converterOutsideOrig.getCorpusdir(), \
        os.path.join(os.getenv('GTHOME'), 'gt/script/langTools'))
        
        self.assertEqual(self.converterInsideFreecorpus.getCorpusdir(), \
        os.getenv('GTFREE'))    

class Converter:
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
    
import doctest
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
        
class AvvirConverter:
    """
    Class to convert Ávvir xml files to the giellatekno xml format
    """
    
    def __init__(self, filename):
        self.orig = filename
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

import chardet
import re
import codecs

class TestPlaintextConverter(unittest.TestCase):
    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)
        
    def testToUnicode(self):
        converter = PlaintextConverter('parallelize_data/winsami2-test-ws2.txt')
        got  = converter.toUnicode()
        
        # Ensure that the data in want is unicode
        f = codecs.open('parallelize_data/winsami2-test-utf8.txt', encoding = 'utf8')
        want = f.read()
        f.close()
        
        self.assertEqual(got, want)
        
    def testPlaintext(self):
        plaintext = PlaintextConverter('parallelize_data/plaintext.txt')
        got = plaintext.convert2intermediate()
        want = etree.parse('parallelize_data/plaintext.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testNewstext(self):
        newstext = PlaintextConverter('parallelize_data/newstext.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/newstext.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testAssu97(self):
        newstext = PlaintextConverter('parallelize_data/assu97.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/assu97.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testBilde(self):
        newstext = PlaintextConverter('parallelize_data/bilde.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/bilde.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testIngress(self):
        newstext = PlaintextConverter('parallelize_data/ingress.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/ingress.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testMtitt(self):
        newstext = PlaintextConverter('parallelize_data/mtitt.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/mtitt.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testTekst(self):
        newstext = PlaintextConverter('parallelize_data/tekst.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/tekst.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testNBSP(self):
        newstext = PlaintextConverter('parallelize_data/nbsp.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/nbsp.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testTittel(self):
        newstext = PlaintextConverter('parallelize_data/tittel.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/tittel.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testByline(self):
        newstext = PlaintextConverter('parallelize_data/byline.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/byline.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

import io

class PlaintextConverter:
    """
    A class to convert plain text files containing "news" tags to the 
    giellatekno xml format
    """
    
    def __init__(self, filename):
        self.orig = filename
        
    def toUnicode(self):
        """
        Read a file into a string of type str
        If the content of the file is not utf-8, convert it to utf-8,
        pretending the encoding is latin1. The real encoding will be
        detected later.
        
        Return a python unicode string
        """
        f = open(self.orig)
        content = f.read()
        f.close()
        
        encoding = chardet.detect(content)['encoding']
        if encoding != 'utf-8':
            content = content.decode('latin1', 'replace').encode('utf-8')
        
        content = unicode(content, encoding='utf-8')
        content = content.replace(u'  ', '\n\n')
        content = content.replace(u'–<\!q>', u'– ')
        content = content.replace('\x0d', '\x0a')
        
        return content

    def convert2intermediate(self):
        document = etree.Element('document')
        
        content = io.StringIO(self.toUnicode())
        header = etree.Element('header')
        body = etree.Element('body')
        ptext = ''
        
        bilde = re.compile(r'BILDE(\s\d)*:(.*)')
        
        for line in content:
            if line.startswith('@bilde:'):
                p = etree.Element('p')
                p.text = line.replace('@bilde:', '')
                body.append(p)
                ptext = ''
            elif bilde.match(line):
                m = bilde.match(line)
                p = etree.Element('p')
                p.text = m.group(2)
                body.append(p)
                ptext = ''
            elif line.startswith('@bold:'):
                em = etree.Element('em', type = "bold")
                em.text = line.replace('@bold:', '')
                p = etree.Element('p')
                p.append(em)
                body.append(p)
                ptext = ''
            elif line.startswith('@ingress:'):
                p = etree.Element('p')
                p.text = line.replace('@ingress:', '').decode('utf-8')
                body.append(p)
                ptext = ''
            elif line.startswith('LOGO:'):
                p = etree.Element('p')
                p.text = line.replace('LOGO:', '').strip()
                body.append(p)
                ptext = ''
            elif line.startswith('@tekst:') or line.startswith('TEKST:') or line.startswith('@stikk:') or line.startswith('@foto'):
                p = etree.Element('p')
                line = line.replace('@tekst:', '')
                line = line.replace('@stikk:', '')
                line = line.replace('TEKST:', '')
                line = line.replace('@foto:', '')
                p.text = line
                body.append(p)
                ptext = ''
            elif line.startswith('@m.titt:') or line.startswith('M:TITT:'):
                p = etree.Element('p', type="title")
                line = line.replace('@m.titt:', '')
                line = line.replace('M:TITT:', '')
                p.text = line
                body.append(p)
                ptext = ''
            elif line.startswith(u'  '):
                p = etree.Element('p')
                p.text = line #.replace(u'  ', '')
                body.append(p)
                ptext = ''
            elif line.startswith('@tittel:') or line.startswith('TITT'):
                title = etree.Element('title')
                line = line.replace('@tittel:', '')
                line = line.replace('TITT:', '')
                title.text = line
                header.append(title)
            elif line.startswith('@byline:'):
                person = etree.Element('person')
                
                line = line.replace('@byline:', '').strip()
                names = line.split(' ')
                person.set('lastname', names[-1])
                person.set('firstname', ' '.join(names[:-1]))
                
                author = etree.Element('author')
                author.append(person)
                header.append(author)
                
            elif line == '\n' and ptext != '':
                p = etree.Element('p')
                p.text = ptext
                body.append(p)
                ptext = ''
            else:
                ptext = ptext.strip() + line.strip()
                
        if ptext != '':
            p = etree.Element('p')
            p.text = ptext
            body.append(p)
        
        document.append(header)
        document.append(body)
        
        return document

from pdfminer.pdfparser import PDFDocument, PDFParser
from pdfminer.pdfinterp import PDFResourceManager, PDFPageInterpreter, process_pdf
from pdfminer.pdfdevice import PDFDevice, TagExtractor
from pdfminer.converter import TextConverter
from pdfminer.cmapdb import CMapDB
from pdfminer.layout import LAParams

import cStringIO

class TestPDFConverter(unittest.TestCase):
    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)
        
    def testPDFConverter(self):
        pdfdocument = PDFConverter('parallelize_data/pdf-test.pdf')
        got = pdfdocument.convert2intermediate(pdfdocument.extractText())
        want = etree.parse('parallelize_data/pdf-test.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

class PDFConverter:
    def __init__(self, filename):
        self.orig = filename
        
    def extractText(self):
        # debug option
        debug = 0
        # input option
        pagenos = set()
        maxpages = 0
        # output option
        codec = 'utf-8'
        caching = True
        laparams = LAParams()

        PDFDocument.debug = debug
        PDFParser.debug = debug
        CMapDB.debug = debug
        PDFResourceManager.debug = debug
        PDFPageInterpreter.debug = debug
        PDFDevice.debug = debug
        #
        rsrcmgr = PDFResourceManager(caching=caching)

        outfp = cStringIO.StringIO()
            
        device = TextConverter(rsrcmgr, outfp, codec=codec, laparams=laparams)

        fp = file(self.orig, 'rb')
        process_pdf(rsrcmgr, device, fp, pagenos, maxpages=maxpages, 
                    caching=caching, check_extractable=True)
        fp.close()
        
        device.close()
        text = outfp.getvalue()
        outfp.close()
        
        return text

    def convert2intermediate(self, text):
        document = etree.Element('document')
        header = etree.Element('header')
        body = etree.Element('body')
        
        content = io.StringIO(unicode(text, encoding='utf-8'))
        ptext = ''
        
        for line in content:
            line = line.replace('\x0c', '')
            #print 'line', line
            if line == '\n':
                p = etree.Element('p')
                p.text = ptext
                body.append(p)
                ptext = ''
            else:
                ptext = ptext + line
        
        if ptext != '':
            p = etree.Element('p')
            p.text = ptext.replace('\x0c', '')
            body.append(p)
        
        document.append(header)
        document.append(body)
        
        return document

import subprocess
class TestDocConverter(unittest.TestCase):
    def setUp(self):
        self.testdoc = DocConverter('parallelize_data/doc-test.doc')
    
    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)
        
    def testConvert2intermediate(self):
        docbook = self.testdoc.extractText()
        got = self.testdoc.convert2intermediate(docbook)
        want = etree.parse('parallelize_data/doc-test.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))
        
class DocConverter:
    """
    Class to convert Microsoft Word documents to the giellatekno xml format
    """
    def __init__(self, filename):
        self.orig = filename
        self.converterXsl = \
        os.path.join(os.getenv('GTHOME'), 'gt/script/corpus/docbook2corpus2.xsl')
    
    def extractText(self):
        """
        Extract the text from the doc file using antiword
        output contains the docbook xml output by antiword, 
        and is a utf-8 string
        """
        subp = subprocess.Popen(['antiword', '-x',  'db', self.orig], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate()
        
        if subp.returncode != 0:
            print >>sys.stderr, 'Could not process', self.orig
            print >>sys.stderr, output
            print >>sys.stderr, error
            return subp.returncode

        return output
    
    def convert2intermediate(self, docbook):
        """
        Convert the original document to the giellatekno xml format, with no 
        metadata
        The resulting xml is stored in intermediate
        """
        docbookXsltRoot = etree.parse(self.converterXsl)
        transform = etree.XSLT(docbookXsltRoot)
        doc = etree.fromstring(docbook)
        intermediate = transform(doc)
        
        return intermediate
    
class TestHTMLConverter(unittest.TestCase):
    def setUp(self):
        self.testhtml = HTMLConverter('parallelize_data/samediggi-article-48s.html')
    
    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)
        
    def testConvert2intermediate(self):
        docbook = self.testhtml.tidy()
        got = self.testhtml.convert2intermediate(docbook)
        want = etree.parse('parallelize_data/samediggi-article-48s.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

import BeautifulSoup

class HTMLConverter:
    """
    Class to convert html documents to the giellatekno xml format
    """
    def __init__(self, filename):
        self.orig = filename
        self.converterXsl = \
        os.path.join(os.getenv('GTHOME'), 'gt/script/corpus/xhtml2corpus.xsl')
    
    def tidy(self):
        """
        Run html through tidy
        """
        tidycommand = ['tidy', '-config', os.path.join(os.getenv('GTHOME'), 'gt/script/tidy-config.txt'), '-utf8', '-asxml', '-quiet', self.orig]
        subp = subprocess.Popen(tidycommand, stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate()
        
        if subp.returncode == 512:
            print >>sys.stderr, 'Could not process', self.orig
            print >>sys.stderr, output
            print >>sys.stderr, error
            return subp.returncode

        try:
                soup = BeautifulSoup.BeautifulSoup(output, fromEncoding="utf-8", convertEntities=BeautifulSoup.BeautifulStoneSoup.HTML_ENTITIES)
        except HTMLParseError, e:
                print 'Cannot parse', sys.argv[1]
                print 'Reason', e
                sys.exit(4)

        comments = soup.findAll(text=lambda text:isinstance(text, BeautifulSoup.Comment))
        [comment.extract() for comment in comments]

        [item.extract() for item in soup.findAll(text = lambda text:isinstance(text, BeautifulSoup.ProcessingInstruction ))]
        [item.extract() for item in soup.findAll(text = lambda text:isinstance(text, BeautifulSoup.Declaration ))]
            
        remove_tags = ['noscript', 'script', 'input', 'img', 'v:shapetype', 'v:shape', 'textarea', 'label', 'o:p', 'st1:metricconverter', 'st1:placename', 'st1:place', 'meta']
        for remove_tag in remove_tags:
                removes = soup.findAll(remove_tag)
                for remove in removes:
                        remove.extract()

        try:
                if not ("xmlns", "http://www.w3.org/1999/xhtml") in soup.html.attrs:
                        soup.html.attrs.append(("xmlns", "http://www.w3.org/1999/xhtml"))
        except AttributeError:
                pass

        return soup.prettify()
    
    def convert2intermediate(self, html):
        """
        Convert the original document to the giellatekno xml format, with no 
        metadata
        The resulting xml is stored in intermediate
        """
        #print docbook
        htmlXsltRoot = etree.parse(self.converterXsl)
        transform = etree.XSLT(htmlXsltRoot)
        doc = etree.fromstring(html)
        intermediate = transform(doc)
        
        return intermediate
    
import decode

class TestEncodingFixer:
    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)
        
    def testFixBodyEncoding(self):
        newstext = PlaintextConverter('parallelize_data/assu97-mac-sami.txt')
        eg = EncodingFixer(newstext.convert2intermediate())

        got = eg.fixBodyEncoding()
        
        want = etree.parse('parallelize_data/assu97.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))
        
    
class EncodingFixer:
    """
    Receive an etree from one of the raw converters, fix the encoding, return 
    an etree with correct characters
    """
    def __init__(self, etree):
        self.etree = etree

    def fixBodyEncoding(self):
        """
        Send a stringified version of the body into the EncodingGuesser class.
        It returns the same version, but with fixed characters.
        Parse the returned string, insert it into the document
        """
        document = self.etree
        body = document.find('body')
        
        eg = decode.EncodingGuesser()
        
        bodyString = etree.tostring(body, encoding='utf-8')
        
        body.getparent().remove(body)
        
        encoding = eg.guessBodyEncoding(bodyString)
        body = etree.fromstring(eg.decodePara(encoding, bodyString))
        
        document.append(body)
        return document
