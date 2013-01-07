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

import chardet
import re

class TestNewstextConverter(unittest.TestCase):
    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)
        
    def testToUnicode(self):
        converter = NewstextConverter('parallelize_data/winsami2-test-ws2.txt')
        got  = converter.toUnicode()
        
        f = open('parallelize_data/winsami2-test-utf8.txt')
        want = f.read()
        f.close()
        
        self.assertEqual(got, want)
        
    def testPlaintext(self):
        plaintext = NewstextConverter('parallelize_data/plaintext.txt')
        got = plaintext.convert2intermediate()
        want = etree.parse('parallelize_data/plaintext.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testNewstext(self):
        newstext = NewstextConverter('parallelize_data/newstext.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/newstext.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testAssu97(self):
        newstext = NewstextConverter('parallelize_data/assu97.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/assu97.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testBilde(self):
        newstext = NewstextConverter('parallelize_data/bilde.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/bilde.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testIngress(self):
        newstext = NewstextConverter('parallelize_data/ingress.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/ingress.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testMtitt(self):
        newstext = NewstextConverter('parallelize_data/mtitt.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/mtitt.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testTekst(self):
        newstext = NewstextConverter('parallelize_data/tekst.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/tekst.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testNBSP(self):
        newstext = NewstextConverter('parallelize_data/nbsp.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/nbsp.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testTittel(self):
        newstext = NewstextConverter('parallelize_data/tittel.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/tittel.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

    def testByline(self):
        newstext = NewstextConverter('parallelize_data/byline.txt')
        got = newstext.convert2intermediate()
        want = etree.parse('parallelize_data/byline.xml')
        
        self.assertXmlEqual(etree.tostring(got), etree.tostring(want))

class NewstextConverter(Preconverter):
    """
    A class to convert plain text files containing "news" tags to the 
    giellatekno xml format
    """
    
    def __init__(self, filename, test="False"):
        Preconverter.__init__(self, filename, test)
        
    def toUnicode(self):
        """
        Convert anything not utf-8 to utf-8, using the latin1 encoding
        """
        f = open(self.orig)
        content = f.read()
        f.close()
        
        encoding = chardet.detect(content)['encoding']
        if encoding != 'utf-8':
            content = content.decode('latin1', 'replace').encode('utf-8')
        
        content = content.replace('  ', '\n\n')
        content = content.replace('–<\!q>', '– ')
        content = content.replace('\x0d', '\x0a')
        
        return content

    def handleContent(self):
        document = etree.Element('document')
        import io
        
        content = io.StringIO(self.toUnicode().decode('utf-8'))
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
        
    def convert2intermediate(self):
        return self.handleContent()

