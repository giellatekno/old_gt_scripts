#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This file contains routines to sentence align two files 
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
#   Copyright 2011 Børre Gaup <borre.gaup@uit.no>
#

import os
import re
import sys
import subprocess
import difflib
import doctest
from lxml import etree
from lxml import doctestcompare

import unittest

class ParallelFile:
    """
    A class that contains the info on a file to be parallellized, name and language
    """
    
    def __init__(self, name, paralang):
        self.name = name
        self.paralang = paralang
        self.setLang()
        
    def getName(self):
        """
        Return the absolute path of the file
        """
        return self.name
        
    def getDirname(self):
        """
        Return the dirname of the file
        """
        return os.path.dirname(self.name)
        
    def getBasename(self):
        """
        Return the basename of the file
        """
        return os.path.basename(self.name)
        
    def setLang(self):
        """
        Set the lang of the file
        """
        origfile1Tree = etree.parse(self.getName())
        self.lang = origfile1Tree.getroot().attrib['{http://www.w3.org/XML/1998/namespace}lang']
        
    def getLang(self):
        """
        Get the lang of the file
        """
        return self.lang
        
    def getParallelBasename(self):
        """
        Get the basename of the parallel file
        Input is the lang of the parallel file
        """
        origfile1Tree = etree.parse(self.getName())
        root = origfile1Tree.getroot()
        parallelFiles = root.findall(".//parallel_text")
        for p in parallelFiles:
            if p.attrib['{http://www.w3.org/XML/1998/namespace}lang'] == self.paralang:
                return p.attrib['location']
        
    def getParallelFilename(self):
        """
        Infer the absolute path of the parallel file
        """
        parallelDirname = self.getDirname().replace(self.getLang(), self.paralang)
        parallelBasename = self.getParallelBasename() + '.xml'
        
        return os.path.join(parallelDirname, parallelBasename)

class TestParallelFile(unittest.TestCase):
    """
    A test class for the ParallelFile class
    """
    def setUp(self):
        self.pfile = ParallelFile(os.environ['GTFREE'] + "/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml", "nob")
        
    def testBasename(self):
        self.assertEqual(self.pfile.getBasename(), "aarseth2-s.htm.xml")
        
    def testDirname(self):
        self.assertEqual(self.pfile.getDirname(), os.path.join(os.environ['GTFREE'] + "/prestable/converted/sme/facta/skuvlahistorja2"))
        
    def testName(self):
        self.assertEqual(self.pfile.getName(), os.environ['GTFREE'] + "/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml")
        
    def testLang(self):
        self.assertEqual(self.pfile.getLang(), "sme")
        
    def testGetParallelBasename(self):
        self.assertEqual(self.pfile.getParallelBasename(), "aarseth2-n.htm")
        
    def testGetParallelFilename(self):
        self.assertEqual(self.pfile.getParallelFilename(), os.environ['GTFREE'] + "/prestable/converted/nob/facta/skuvlahistorja2/aarseth2-n.htm.xml")

class TestSentenceDivider(unittest.TestCase):
    """A test class for the SentenceDivider class
    """
    def setUp(self):
        self.sentenceDivider = SentenceDivider("parallelize_data/finnmarkkulahka_web_lettere.pdf.xml", "sme")
        
    def assertXmlEqual(self, got, want):
        """
        Check if two xml snippets are equal
        """
        string_got = etree.tostring(got, pretty_print = True)
        string_want = etree.tostring(want, pretty_print = True)
        
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(string_want, string_got, 0):
            message = checker.output_difference(doctest.Example("", string_want), string_got, 0).encode('utf-8')
            raise AssertionError(message)
        
    def testConstructor(self):
        """Check that the constructor makes what it is suppposed to
        """
        self.assertEqual(self.sentenceDivider.sentenceCounter, 0)
        self.assertEqual(self.sentenceDivider.docLang, 'sme')
        self.assertEqual(self.sentenceDivider.inputEtree.__class__.__name__, '_ElementTree')
    
    def testProcessAllParagraphs(self):
        self.sentenceDivider.processAllParagraphs()
        got = self.sentenceDivider.document
        
        want = etree.parse('parallelize_data/finnmarkkulahka_web_lettere.pdfsme_sent.xml.test')
        
        self.assertXmlEqual(got, want)
        
    def testProcessOneParagraph(self):
        """Check the output of processOneParagraph
        """
        self.sentenceDivider.docLang = 'sme'
        p = etree.XML('<p>Jápmá go sámi kultuvra veahážiid mielde go nuorat ovdal guldalit Britney Spears go Áilluhačča? máksá Finnmárkkuopmodat. § 10 Áššit meahcceeatnamiid</p>')
        got = self.sentenceDivider.processOneParagraph(p)
        want = etree.XML('<p><s id="0">Jápmá go sámi kultuvra veahážiid mielde go nuorat ovdal guldalit Britney Spears go Áillohačča ?</s><s id="1">máksá Finnmárkkuopmodat .</s><s id="2">§ 10 Áššit meahcceeatnamiid </s></p>')
        self.assertXmlEqual(got, want)
        
        p = etree.XML('<p>Stuora oassi Romssa universitehta doaimmain lea juohkit dieđuid sámi, norgga ja riikkaidgaskasaš dutkanbirrasiidda, sámi ja norgga eiseválddiide, ja sámi servodagaide (geahča mielddus A <em type="italic"><span type="quote">“Romssa universitehta ja guoskevaš institušuvnnaid sámi dutkan ja oahpahus”</span></em>  álggahusa ).</p>')
        got = self.sentenceDivider.processOneParagraph(p)
        want = etree.XML('<p><s id="3">Stuora oassi Romssa universitehta doaimmain lea juohkit dieđuid sámi , norgga ja riikkaidgaskasaš dutkanbirrasiidda , sámi ja norgga eiseválddiide , ja sámi servodagaide ( geahča mielddus A “ Romssa universitehta ja guoskevaš institušuvnnaid sámi dutkan ja oahpahus ” álggahusa ) .</s></p>')
        self.assertXmlEqual(got, want)

        p = etree.XML('<p>Artikkel i boka Samisk skolehistorie 2 . Davvi Girji 2007.</p>')
        got = self.sentenceDivider.processOneParagraph(p)
        want = etree.XML('<p><s id="4">Artikkel i boka Samisk skolehistorie 2 .</s><s id="5">Davvi Girji 2007 .</s></p>')
        self.assertXmlEqual(got, want)

        self.sentenceDivider.docLang = 'nob'
        p = etree.XML('<p><em type="bold">Bjørn Aarseth med elever på skitur - på 1950-tallet.</em> (Foto: Trygve Madsen)</p>')
        got = self.sentenceDivider.processOneParagraph(p)
        want = etree.XML('<p><s id="6">Bjørn Aarseth med elever på skitur - på 1950-tallet .</s><s id="7">( Foto : Trygve Madsen )</s></p>')
        self.assertXmlEqual(got, want)
        
        p = etree.XML('<p>finne rom for etablering av en fast tilskuddsordning til allerede etablerte språksentra..</p>')
        got = self.sentenceDivider.processOneParagraph(p)
        want = etree.XML('<p><s id="8">finne rom for etablering av en fast tilskuddsordning til allerede etablerte språksentra . .</s></p>')
        self.assertXmlEqual(got, want)
        
        p = etree.XML('<p>elevene skal få!  Sametingsrådet mener målet</p>')
        got = self.sentenceDivider.processOneParagraph(p)
        want = etree.XML('<p><s id="9">elevene skal få !</s><s id="10">Sametingsrådet mener målet</s></p>')
        self.assertXmlEqual(got, want)
    
    def testDotFollowedByDot(self):
        """Test of how processOneParagraph handles a paragraph 
        with . and ... in the end.
        tca2 doesn't accept sentences without real letters, so we have to make
        sure the ... doesn't end up alone inside a s tag"""
        self.sentenceDivider.docLang = 'nob'
        p = etree.XML('<p>Alt det som har med norsk å gjøre, har jeg gruet meg for og hatet hele mitt liv - og kommer kanskje til å fortsette med det. ...</p>')
        got = self.sentenceDivider.processOneParagraph(p)
        want = etree.XML('<p><s id="0">Alt det som har med norsk å gjøre , har jeg gruet meg for og hatet hele mitt liv - og kommer kanskje til å fortsette med det . ...</s></p>')
        self.assertXmlEqual(got, want)
        
    def testQuotemarks(self):
        """Test how SentenceDivider handles quotemarks
        """
        self.sentenceDivider.docLang = 'nob'
        p = etree.XML('<p>Forsøksrådet for skoleverket godkjente det praktiske opplegget for kurset i brev av 18/8 1959 og uttalte da bl. a.: «Selve innholdet i kurset virker gjennomtenkt og underbygd og ser ut til å konsentrere seg om vesentlige emner som vil få stor betydning for elevene i deres yrkesarbeid. Med flyttsame-kunnskapen som bakgrunn er det grunn til å vente seg mye av dette kursopplegget.» Med denne tillitserklæring i ryggen har vi så fra år til år søkt å forbedre kursoppleggene til vi foran 1963-kursene står med planer som vi anser tilfredsstillende , men ikke endelige .)</p>')
        got = self.sentenceDivider.processOneParagraph(p)
        want = etree.XML('<p><s id="0">Forsøksrådet for skoleverket godkjente det praktiske opplegget for kurset i brev av 18/8 1959 og uttalte da bl. a. : « Selve innholdet i kurset virker gjennomtenkt og underbygd og ser ut til å konsentrere seg om vesentlige emner som vil få stor betydning for elevene i deres yrkesarbeid .</s><s id="1"> Med flyttsame-kunnskapen som bakgrunn er det grunn til å vente seg mye av dette kursopplegget . »</s><s id="2">Med denne tillitserklæring i ryggen har vi så fra år til år søkt å forbedre kursoppleggene til vi foran 1963-kursene står med planer som vi anser tilfredsstillende , men ikke endelige . )</s></p>')
        self.assertXmlEqual(got, want)

    def testMakeSentence(self):
        s = self.sentenceDivider.makeSentence([u'Sámerievtti', u'ovdáneapmi', u'lea', u'dahkan', u'vuđđosa', u'Finnmárkkuláhkii'])
        
        self.assertEqual(s.attrib["id"], '0')
        self.assertEqual(s.text, u'Sámerievtti ovdáneapmi lea dahkan vuđđosa Finnmárkkuláhkii')

class SentenceDivider:
    """A class that takes a giellatekno xml document as input.
    It spits out an xml document that has divided the text inside the p tags
    into sentences, but otherwise is unchanged.
    Each sentence is encases in an s tag, and has an id consisting of the 
    outputfilename and a numberic
    """
    def __init__(self, inputXmlfile, lang):
        
        self.sentenceCounter = 0
        self.docLang = lang
        self.inputEtree = etree.parse(inputXmlfile)
    
    def processAllParagraphs(self):
        """Go through all paragraphs in the etree and process them one by one.
        """
        self.document = etree.Element('document')
        body = etree.Element('body')
        self.document.append(body)
        
        for paragraph in self.inputEtree.findall('//p'):
            body.append(self.processOneParagraph(paragraph))
    
    def writeResult(self, outfile):
        """Write self.document to the given outfile name
        """
        f = open(outfile, 'w')
        et = etree.ElementTree(self.document)
        et.write(f, pretty_print = True, encoding = "utf-8", xml_declaration = True)
        f.close()
       
    def getPreprocessOutput(self, preprocessInput):
        """Send the text in preprocessInput into preprocess, return the result. 
        If the process fails, exit the program
        """
        preprocessCommand = []
        if (self.docLang == 'nob'):
            abbrFile = os.path.join(os.environ['GTHOME'], 'st/nob/bin/abbr.txt')
            preprocessCommand = ['preprocess', '--abbr=' + abbrFile]
        else:
            abbrFile = os.path.join(os.environ['GTHOME'], 'gt/sme/bin/abbr.txt')
            corrFile = os.path.join(os.environ['GTHOME'], 'gt/sme/bin/corr.txt')
            preprocessCommand = ['preprocess', '--abbr=' + abbrFile, '--corr=' + corrFile]
            
        subp = subprocess.Popen(preprocessCommand, stdin = subprocess.PIPE, stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate(preprocessInput.encode('utf-8'))
        
        if subp.returncode != 0:
            print >>sys.stderr, 'Could not divide into sentences'
            print >>sys.stderr, output
            print >>sys.stderr, error
            sys.exit()
        else:
            return output
            
    def processOneParagraph(self, origParagraph):
        """Run the content of the origParagraph through preprocess, make sentences
        Return a new paragraph containing the marked up sentences
        """
        newParagraph = etree.Element("p")

        allText = origParagraph.xpath('.//text()')
        preprocessInput = "".join(allText)

        # Check if there is any text from preprocess
        if (preprocessInput):
            output = self.getPreprocessOutput(preprocessInput)
            sentence = []
            insideQuote = False
            previousWord = ''
            incompleteSentences = ['.', '?', '!', ')', ']', '...', '"', '»', '']
            words = output.split('\n')
            i = 0
            while i < len(words):
                word = words[i].strip()
                sentence.append(word.decode('utf-8'))
                
                if (word == '.' or word == '?' or word == '!'):
                    while i + 1 < len(words) and words[i + 1].strip() in incompleteSentences:
                        if words[i + 1] != '':
                            sentence.append(words[i + 1].decode('utf-8').strip())
                        i = i + 1
                    newParagraph.append(self.makeSentence(sentence))
                    sentence = []

                i = i + 1
                
            if len(sentence) > 1:
                newParagraph.append(self.makeSentence(sentence))
    
        return newParagraph
        
    def makeSentence(self, sentence):
        """Make an s element, set the id and set the text to be the content of 
        the list sentence
        """
        s = etree.Element("s")
        s.attrib["id"] = str(self.sentenceCounter)
        s.text = ' '.join(sentence)
        self.sentenceCounter += 1
        
        return s
        
class Parallelize:
    """
    A class to parallelize two files
    Input is the xml file that should be parallellized and the language that it
    should be parallellized with.
    The language of the input file is found in the metadata of the input file.
    The other file is found via the metadata in the input file
    """
    
    def __init__(self, origfile1, lang2):
        """
        Set the original file name, the lang of the original file and the 
        language that it should parallellized with.
        Parse the original file to get the access to metadata
        """
        self.origfiles = []
        
        tmpfile = ParallelFile(os.path.abspath(origfile1), lang2)
        self.origfiles.append(tmpfile)
        
        tmpfile = ParallelFile(self.origfiles[0].getParallelFilename(), self.origfiles[0].getLang())
        self.origfiles.append(tmpfile)
        
        if self.isTranslatedFromLang2():
            self.reshuffleFiles()
            
    def reshuffleFiles(self):
        """
        Change the order of the files (so that the translated text is last)
        """
        tmp = self.origfiles[0]
        self.origfiles[0] = self.origfiles[1]
        self.origfiles[1] = tmp
        
    def getFilelist(self):
        """
        Return the list of (the two) files that are aligned
        """
        return self.origfiles

    def getLang1(self):
        return self.origfiles[0].getLang()
        
    def getLang2(self):
        return self.origfiles[1].getLang()
        
    def getOrigfile1(self):
        return self.origfiles[0].getName()
        
    def getOrigfile2(self):
        return self.origfiles[1].getName()
    
    def isTranslatedFromLang2(self):
        """
        Find out if the given doc is translated from lang2
        """
        result = False
        origfile1Tree = etree.parse(self.getOrigfile1())
        root = origfile1Tree.getroot()
        translated_from = root.find(".//translated_from")
        if translated_from is not None:
            if translated_from.attrib['{http://www.w3.org/XML/1998/namespace}lang'] == self.getLang2():
                result = True

        return result
    
    def generateAnchorFile(self):
        """
        Generate an anchor file with lang1 and lang2. Return the path to the anchor file
        """
        infile1 = os.path.join(os.environ['GTHOME'], 'gt/common/src/anchor.txt')
        infile2 = os.path.join(os.environ['GTHOME'], 'gt/common/src/anchor-admin.txt')
        
        subp = subprocess.Popen(['generate-anchor-list.pl', '--lang1=' + self.getLang1(), '--lang2' + self.getLang2(), '--outdir=' + os.environ['GTFREE'], infile1, infile2], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate()
        
        if subp.returncode != 0:
            print >>sys.stderr, 'Could not generate ', pfile.getName(), ' into sentences'
            print >>sys.stderr, output
            print >>sys.stderr, error
            return subp.returncode

        # Return the absolute path of the resulting file
        outFilename = 'anchor-' + self.getLang1() + self.getLang2() + '.txt'
        return os.path.join(os.environ['GTFREE'], outFilename)
        
    def dividePIntoSentences(self):
        """
        Call corpus-analyse.pl which reads an xml file and makes it palatable for tca2
        """
        for pfile in self.origfiles:
            infile = os.path.join(pfile.getName())
            if os.path.exists(infile):
                outfile = self.getSentFilename(pfile)
                divider = SentenceDivider(infile, pfile.getLang())
                divider.processAllParagraphs()
                divider.writeResult(outfile)
            else:
                print >>sys.stderr, infile, "doesn't exist"
                return 2
                    
        return 0

    def getSentFilename(self, pfile):
        """
        Compute a name for the corpus-analyze output and tca2 input file
        Input is a ParallelFile
        """
        origfilename = pfile.getBasename().replace('.xml', '')
        return os.environ['GTFREE'] + '/tmp/' + origfilename + pfile.getLang() + '_sent.xml'
        
    def parallelizeFiles(self):
        """
        Parallelize two files using tca2
        """
        anchorName = self.generateAnchorFile()
        
        subp = subprocess.Popen(['tca2.sh', anchorName, self.getSentFilename(self.getFilelist()[0]), self.getSentFilename(self.getFilelist()[1])], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate()
            
        if subp.returncode != 0:
            print >>sys.stderr, 'Could not parallelize', self.getSentFilename(self.getFilelist()[0]), 'and', self.getSentFilename(self.getFilelist()[1]), ' into sentences'
            print >>sys.stderr, output
            print >>sys.stderr, error
                
        return subp.returncode

class TestParallelize(unittest.TestCase):
    """
    A test class for the Parallelize class
    """
    def setUp(self):
        self.parallelize = Parallelize(os.environ['GTFREE'] + "/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml", "nob")
    
    def testOrigPath(self):
        self.assertEqual(self.parallelize.getOrigfile1(), os.environ['GTFREE'] + "/prestable/converted/nob/facta/skuvlahistorja2/aarseth2-n.htm.xml")
        
    def testParallelPath(self):
        self.assertEqual(self.parallelize.getOrigfile2(), os.environ['GTFREE'] + "/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml")
        
    def testLang1(self):
        self.assertEqual(self.parallelize.getLang1(), "nob")
        
    def testLang2(self):
        self.assertEqual(self.parallelize.getLang2(), "sme")
        
    def testGetSentFilename(self):
        self.assertEqual(self.parallelize.getSentFilename(self.parallelize.getFilelist()[0]), os.environ['GTFREE'] + "/tmp/aarseth2-n.htmnob_sent.xml")
        
    def testDividePIntoSentences(self):
        self.assertEqual(self.parallelize.dividePIntoSentences(), 0)

    def testParallizeFiles(self):
        self.assertEqual(self.parallelize.parallelizeFiles(), 0)
        
    def testGenerateAnchorFile(self):
        self.assertEqual(self.parallelize.generateAnchorFile(), os.path.join(os.environ['GTFREE'], 'anchor-nobsme.txt'))
        
class Tmx:
    """
    A class that reads a tmx file, and implements a bare minimum of functionality
    to be able to compare two tmx'es
    """
    
    def __init__(self, tmx):
        self.tmx = tmx
        
    def getSrcLang(self):
        """
        Get the srclang from the header element
        """
        return self.tmx.find(".//header").attrib['srclang'][:3]
        
    def getTmx(self):
        """
        Get the tmx xml element
        """
        return self.tmx
        
    def tuToString(self, tu):
        """
        Extract the two strings of a tu element
        """
        string = ""
        try:
            string = string + tu[0][0].text.strip()
        except(AttributeError):
            pass
            
        string += '\t'
        
        try:
            string = string + tu[1][0].text.strip()
        except(AttributeError):
            pass
        
        string += '\n'
        return string.encode('utf-8')
    
    def tuvToString(self, tuv):
        """
        Extract the string from the tuv element
        """
        string = ""
        try:
            string = tuv[0].text.strip()
        except(AttributeError):
            pass
        
        return string.encode('utf-8')
        
    def langToStringlist(self, lang):
        """
        Get all the strings in the tmx in language lang, insert them 
        into the list strings
        """
        all_tuv = self.getTmx().xpath('.//tuv[@xml:lang="' + lang + '"]',
            namespaces={'xml':'http://www.w3.org/XML/1998/namespace'})

        strings = []
        for tuv in all_tuv:
            strings.append(self.tuvToString(tuv))
        
        return strings
    
    def tmxToStringlist(self):
        """
        Extract all string pairs in a tmx to a list of strings
        """
        all_tu = self.getTmx().findall('.//tu')
        strings = []
        for tu in all_tu:
            strings.append(self.tuToString(tu))
        
        return strings
        
    def prettifySegs(self, tu):
        """
        Input is a tu-element
        """
        try:
            string = tu[0][0].text.strip()
            tu[0][0].text = string
        except(AttributeError):
            pass
            
        try:
            string = tu[1][0].text.strip()
            tu[1][0].text = string
        except(AttributeError):
            pass
        
        return tu
        
    def reverseLangs(self):
        """
        Reverse the langs in a tmx
        Return the reverted tmx
        """
        all_tu = self.getTmx().findall('.//tu')
        body = etree.Element('body')
        for tu in all_tu:
            tmp = etree.Element('tu')
            tmp.append(tu[1])
            tmp.append(tu[0])
            tmp = self.prettifySegs(tmp)
            body.append(tmp)
        
        tmx = etree.Element('tmx')
        tmx.append(body)
        
        self.tmx = tmx
        #et = etree.ElementTree(self.tmx)
        #et.write(sys.stdout, pretty_print = True, encoding = "utf-8", xml_declaration = True)
        
class TestTmx(unittest.TestCase):
    """
    A test class for the Tmx class
    """
    def setUp(self):
        self.tmx = Tmx(etree.parse('parallelize_data/aarseth2-n.htm.tmx'))
        
    def assertXmlEqual(self, got, want):
        """
        Check if two xml snippets are equal
        """
        string_got = etree.tostring(got, pretty_print = True)
        string_want = etree.tostring(want, pretty_print = True)
        
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(string_want, string_got, 0):
            message = checker.output_difference(doctest.Example("", string_want), string_got, 0).encode('utf-8')
            raise AssertionError(message)
        
        
    def testGetSrcLang(self):
        """Test the getSrcLang routine
        """
        self.assertEqual(self.tmx.getSrcLang(), "nob")
        
    def testTuToString(self):
        tu = etree.XML('<tu><tuv xml:lang="sme"><seg>Sámegiella</seg></tuv><tuv xml:lang="nob"><seg>Samisk</seg></tuv></tu>')
        
        self.assertEqual(self.tmx.tuToString(tu), "Sámegiella\tSamisk\n")

    def testTuvToString(self):
        tuv = etree.XML('<tuv xml:lang="sme"><seg>Sámegiella</seg></tuv>')
        
        self.assertEqual(self.tmx.tuvToString(tuv), "Sámegiella")
        
    def testLangToStringList(self):
        f = open('parallelize_data/aarseth2-n.htm.tmx.as.txt', 'r')
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
        f = open('parallelize_data/aarseth2-n.htm.tmx.as.txt', 'r')
        wantList = f.readlines()
        f.close()
        #self.maxDiff = None
        self.assertEqual(self.tmx.tmxToStringlist(), wantList)
    
    def testPrettifySegs(self):
        wantXml = etree.XML('<tu><tuv xml:lang="nob"><seg>ubba gubba. ibba gibba.</seg></tuv><tuv xml:lang="sme"><seg>abba gabba. ebba gebba.</seg></tuv></tu>')
        gotXml = etree.XML('<tu><tuv xml:lang="nob"><seg>ubba gubba. ibba gibba.\n</seg></tuv><tuv xml:lang="sme"><seg>abba gabba. ebba gebba.\n</seg></tuv></tu>')
        self.assertXmlEqual(self.tmx.prettifySegs(gotXml), wantXml)
        
class TmxFromTca2(Tmx):
    """
    A class to make tmx files based on the output from tca2
    """
    def __init__(self, filelist):
        """
        Input is a list of ParallelFile objects
        """
        self.filelist = filelist
        Tmx.__init__(self, self.setTmx())
    
    def makeTu(self, line1, line2):
        """
        Make a tmx tu element based on line1 and line2 as input
        """
        tu = etree.Element("tu")
        
        tu.append(self.makeTuv(line1, self.filelist[0].getLang()))
        tu.append(self.makeTuv(line2, self.filelist[1].getLang()))
        
        return tu
    
    def makeTuv(self, line, lang):
        """
        Make a tuv element given an input line and a lang variable
        """
        tuv = etree.Element("tuv")
        tuv.attrib["{http://www.w3.org/XML/1998/namespace}lang"] = lang
        seg = etree.Element("seg")
        seg.text = self.removeSTag(line).strip().decode("utf-8")
        tuv.append(seg)
        
        return tuv
        
    def makeTmxHeader(self, lang):
        """
        Make a tmx header based on the lang variable
        """
        header = etree.Element("header")
        
        # Set various attributes
        header.attrib["segtype"] = "sentence"
        header.attrib["o-tmf"] = "OmegaT TMX"
        header.attrib["adminlang"] = "en-US"
        header.attrib["srclang"] = lang
        header.attrib["datatype"] = "plaintext"
        
        return header

    def removeSTag(self, line):
        """
        Remove the s tags that tca2 has added
        """
        line = line.replace('</s>','')
        sregex = re.compile('<s id="[^ ]*">')
        line = sregex.sub('', line)
        
        return line

    def getOutfileName(self):
        """
        Compute the name of the tmx file
        """
        
        origPathPart = '/converted/' + self.filelist[0].getLang() + '/'
        # First compute the part that shall replace /orig/ in the path
        replacePathPart = '/tmx/' + self.filelist[0].getLang() + '2' + self.filelist[1].getLang() + '/'
        # Then set the outdir
        outDirname = self.filelist[0].getDirname().replace(origPathPart, replacePathPart)
        # Replace xml with tmx in the filename
        outFilename = self.filelist[0].getBasename().replace('.xml', '.tmx')

        return os.path.join(outDirname, outFilename)
        
    def printTmxFile(self):
        """
        Write a tmx file given a tmx etree element
        """
        outFilename = self.getOutfileName()
        
        try:
            f = open(outFilename, "w")
            
            et = etree.ElementTree(self.getTmx())
            et.write(f, pretty_print = True, encoding = "utf-8", xml_declaration = True)
            f.close()
        except IOError:
            print "ouch, printTmxFile"
        
        return outFilename
    
    def setTmx(self):
        """
        Make tmx file based on the two output files of tca2
        """
        tmx = etree.Element("tmx")
        header = self.makeTmxHeader(self.filelist[0].getLang())
        tmx.append(header)
        
        pfile1_data = self.readTca2Output(self.filelist[0])
        pfile2_data = self.readTca2Output(self.filelist[1])

        body = etree.SubElement(tmx, "body")
        for line1, line2 in map(None, pfile1_data, pfile2_data):
            tu = self.makeTu(line1, line2)
            body.append(tu)
            
        return tmx
        
    def readTca2Output(self, pfile):
        """
        Read the output of tca2
        Input is a ParallelFile
        """
        text = ""
        pfileName = self.getSentFilename(pfile).replace('.xml', '_new.txt')
        try:
            f = open(pfileName, "r")
            text = f.readlines()
            f.close()
        except IOError as (errno, strerror):
            print "I/O error({0}): {1}".format(errno, strerror)
            
        return text
    

    def getSentFilename(self, pfile):
        """
        Compute a name for the corpus-analyze output and tca2 input file
        Input is a ParallelFile
        """
        origfilename = pfile.getBasename().replace('.xml', '')
        return os.environ['GTFREE'] + '/tmp/' + origfilename + pfile.getLang() + '_sent.xml'
        
class TestTmxFromTca2(unittest.TestCase):
    """
    A test class for the TmxFromTca2 class
    """
    def setUp(self):
        """
        Hand the data from the Parallelize class to the tmx class
        """
        para = Parallelize(os.environ['GTFREE'] + "/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml", "nob")

        self.tmx = TmxFromTca2(para.getFilelist())
    
    def assertXmlEqual(self, got, want):
        """
        Check if two xml snippets are equal
        """
        string_got = etree.tostring(got, pretty_print = True)
        string_want = etree.tostring(want, pretty_print = True)
        
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(string_want, string_got, 0):
            message = checker.output_difference(doctest.Example("", string_want), string_got, 0).encode('utf-8')
            raise AssertionError(message)
        
        
    def testMakeTu(self):
        line1 = '<s id="1">ubba gubba.</s> <s id="2">ibba gibba.</s>'
        line2 = '<s id="1">abba gabba.</s> <s id="2">ebba gebba.</s>'
        
        gotTu = self.tmx.makeTu(line1, line2)

        wantTu = etree.XML('<tu><tuv xml:lang="nob"><seg>ubba gubba. ibba gibba.</seg></tuv><tuv xml:lang="sme"><seg>abba gabba. ebba gebba.</seg></tuv></tu>')
        
        self.assertXmlEqual(gotTu, wantTu)

    def testMakeTuv(self):
        line =  '<s id="1">ubba gubba.</s> <s id="2">ibba gibba.</s>'
        lang = 'smi'
        gotTuv = self.tmx.makeTuv(line, lang)
        
        wantTuv = etree.XML('<tuv xml:lang="smi"><seg>ubba gubba. ibba gibba.</seg></tuv>')
        
        self.assertXmlEqual(gotTuv, wantTuv)
        
    def testMakeTmxHeader(self):
        lang = 'smi'
        gotTuv = self.tmx.makeTmxHeader(lang)
        
        wantTuv = etree.XML('<header segtype="sentence" o-tmf="OmegaT TMX" adminlang="en-US" srclang="smi" datatype="plaintext"/>')
        
        self.assertXmlEqual(gotTuv, wantTuv)
        
    def testRemoveSTag(self):
        got = self.tmx.removeSTag('<s id="1">ubba gubba.</s> <s id="2">ibba gibba.</s>')
        want =  'ubba gubba. ibba gibba.'
        
        self.assertEqual(got, want)
        
    def testGetOutfileName(self):
        self.assertEqual(self.tmx.getOutfileName(), os.path.join(os.environ['GTFREE'], 'prestable/tmx/nob2sme/facta/skuvlahistorja2/aarseth2-n.htm.tmx'))
    
    def testPrintTmxFile(self):
        want = etree.parse('parallelize_data/aarseth2-n.htm.tmx')
        self.tmx.printTmxFile()
        got = etree.parse(self.tmx.getOutfileName())
        
        self.assertXmlEqual(got, want)

class TmxComparator:
    """
    A class to compare two tmx-files
    """
    def __init__(self, wantTmx, gotTmx):
        self.wantTmx = wantTmx
        self.gotTmx = gotTmx
        
        
    def getLinesInWantedfile(self):
        """
        Return the number of lines in the reference doc
        """
        return len(self.wantTmx.tmxToStringlist())
        
            
    def getNumberOfDifferingLines(self):
        """
        Given a unified_diff, find out how many lines in the reference doc
        differs from the doc to be tested. A return value of -1 means that
        the docs are equal
        """
        # Start at -1 because a unified diff always starts with a --- line
        numDiffLines = -1
        for line in difflib.unified_diff(self.wantTmx.tmxToStringlist(), self.gotTmx.tmxToStringlist(), n = 0):
            if line[:1] == '-':
                numDiffLines += 1
        
        return numDiffLines
        
    def getDiffAsText(self):
        """
        Return a stringlist containing the diff lines
        """
        diff = []
        for line in difflib.unified_diff(self.wantTmx.tmxToStringlist(), self.gotTmx.tmxToStringlist(), n = 0):
            diff.append(line)
          
        return diff
        
    def getLangDiffAsText(self, lang):
        """
        Return a stringlist containing the diff lines
        """
        diff = []
        for line in difflib.unified_diff(self.wantTmx.langToStringlist(lang), self.gotTmx.langToStringlist(lang), n = 0):
            diff.append(line + '\n')
          
        return diff
        
class TestTmxComparator(unittest.TestCase):
    """
    A test class for the TmxComparator class
    """
    def testEqualTmxes(self):
        comp = TmxComparator(Tmx(etree.parse('parallelize_data/aarseth2-n.htm.tmx')), Tmx(etree.parse('parallelize_data/aarseth2-n.htm.tmx')))
        
        self.assertEqual(comp.getNumberOfDifferingLines(), -1)
        self.assertEqual(comp.getLinesInWantedfile(), 269)
        self.assertEqual(len(comp.getDiffAsText()), 0)
        
    #def testUnEqualTmxes(self):
        #gotFile = os.path.join(os.environ['GTFREE'], 'prestable/tmx/nob2sme/laws/other_files/finnmarksloven.pdf.tmx')
        #wantFile = os.path.join(os.environ['GTFREE'], 'prestable/tmx/goldstandard/nob2sme/laws/other_files/finnmarksloven.pdf.tmx')
        #comp = TmxComparator(Tmx(etree.parse(wantFile)), Tmx(etree.parse(gotFile)))

        #self.assertEqual(comp.getNumberOfDifferingLines(), 7)
        #self.assertEqual(comp.getLinesInWantedfile(), 632)
        #self.assertEqual(len(comp.getDiffAsText()), 28)

    #def testReversedlang(self):
        #wantFile = Tmx(etree.parse('aarseth2-n.htm.tmx'))
        #gotFile = Tmx(etree.parse('aarseth2-s.htm.tmx'))
        #gotFile.reverseLangs()
        
        #comp = TmxComparator(wantFile, gotFile)
        
        #print comp.getDiffAsText()
        #self.assertEqual(comp.getNumberOfDifferingLines(), -1)
        #self.assertEqual(comp.getLinesInWantedfile(), 274)
        #self.assertEqual(len(comp.getDiffAsText()), 0)
        

class TmxTestDataWriter():
    """
    A class that writes tmx test data to a file
    """
    def __init__(self, filename):
        self.filename = filename
        
        try:
            tree = etree.parse(filename)
            self.setParagsTestingElement(tree.getroot())
        except IOError:
            self.setParagsTestingElement(self.makeParagstestingElement())
        #except etree.XMLSyntaxError:
            #self.setParagsTestingElement(self.makeParagstestingElement())
        
    def getFilename(self):
        return self.filename
        
    def makeFileElement(self, name, gspairs, diffpairs):
        """
        Make the element file, set the attributes
        """
        fileElement = etree.Element("file")
        fileElement.attrib["name"] = name
        fileElement.attrib["gspairs"] = gspairs
        fileElement.attrib["diffpairs"] = diffpairs
        
        return fileElement
        
    def setParagsTestingElement(self, paragstesting):
        self.paragstesting = paragstesting
        
    def makeTestrunElement(self, datetime):
        """
        Make the testrun element, set the attribute
        """
        testrunElement = etree.Element("testrun")
        testrunElement.attrib["datetime"] = datetime
        
        return testrunElement
    
    def makeParagstestingElement(self):
        """
        Make the paragstesting element
        """
        paragstestingElement = etree.Element("paragstesting")
        
        return paragstestingElement
    
    def insertTestrunElement(self, testrun):
        self.paragstesting.insert(0, testrun)
        
    def writeParagstestingData(self):
        """
        Write the paragstesting data to a file
        """
        try:
            f = open(self.filename, "w")
            
            et = etree.ElementTree(self.paragstesting)
            et.write(f, pretty_print = True, encoding = "utf-8", xml_declaration = True)
            f.close()
        except IOError:
            print "ouch, Paragstestingresults"
        
class TestTmxTestDataWriter(unittest.TestCase):
    """
    A class to test TmxTestDataWriter
    """
    def setUp(self):
        self.writer = TmxTestDataWriter("testfilename")
        
    def assertXmlEqual(self, got, want):
        """
        Check if two xml snippets are equal
        """
        string_got = etree.tostring(got, pretty_print = True)
        string_want = etree.tostring(want, pretty_print = True)
        
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(string_want, string_got, 0):
            message = checker.output_difference(doctest.Example("", string_want), string_got, 0).encode('utf-8')
            raise AssertionError(message)
        
    def testGetFilename(self):
        self.assertEqual(self.writer.getFilename(), "testfilename")
        
    def testMakeFileElement(self):
        wantElement = etree.XML('<file name="abc" gspairs="634" diffpairs="84"/>')
        gotElement = self.writer.makeFileElement("abc", "634", "84")
        
        self.assertXmlEqual(gotElement, wantElement)
    
    def testMakeTestrunElement(self):
        wantElement = etree.XML('<testrun datetime="20111208-1234"><file name="abc" gspairs="634" diffpairs="84"/></testrun>')
        gotElement = self.writer.makeTestrunElement("20111208-1234")
        fileElement = self.writer.makeFileElement("abc", "634", "84")
        gotElement.append(fileElement)
        
        self.assertXmlEqual(gotElement, wantElement)
    
    def testMakeParagstestingElement(self):
        wantElement = etree.XML('<paragstesting><testrun datetime="20111208-1234"><file name="abc" gspairs="634" diffpairs="84"/></testrun></paragstesting>')
        gotElement = self.writer.makeParagstestingElement()
        testrunElement = self.writer.makeTestrunElement("20111208-1234")
        fileElement = self.writer.makeFileElement("abc", "634", "84")
        testrunElement.append(fileElement)
        gotElement.append(testrunElement)
        
        self.assertXmlEqual(gotElement, wantElement)
    
    def testInsertTestrunElement(self):
        wantElement = etree.XML('<paragstesting><testrun datetime="20111208-2345"><file name="abc" gspairs="634" diffpairs="84"/></testrun><testrun datetime="20111208-1234"><file name="abc" gspairs="634" diffpairs="84"/></testrun></paragstesting>')
        
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
        
        self.assertXmlEqual(gotElement, wantElement)
        
    def testWriteParagstestingData(self):
        want = etree.XML('<paragstesting><testrun datetime="20111208-1234"><file name="abc" gspairs="634" diffpairs="84"/></testrun></paragstesting>')
        
        gotElement = self.writer.makeParagstestingElement()
        self.writer.setParagsTestingElement(gotElement)
        testrunElement = self.writer.makeTestrunElement("20111208-1234")
        fileElement = self.writer.makeFileElement("abc", "634", "84")
        testrunElement.append(fileElement)
        gotElement.append(testrunElement)

        
        self.writer.writeParagstestingData()
        got = etree.parse(self.writer.filename)
        
        self.assertXmlEqual(got, want)
        
class TmxGoldstandardTester:
    """
    A class to test the alignment pipeline againt the tmx goldstandard
    """
    def __init__(self, testresult_filename, dateformat_addition = None):
        """
        Set the name where the testresults should be written
        Find all goldstandard tmx files
        """
        self.numberOfDiffLines = 0
        self.testresultWriter = TmxTestDataWriter(testresult_filename)
        if dateformat_addition is None:
            self.date = self.dateformat()
        else:
            self.date = self.dateformat() + dateformat_addition
        
    def setNumberOfDiffLines(self, diffLines):
        """
        Increase the total number of difflines in this test run
        """
        self.numberOfDiffLines += diffLines

    def getNumberOfDiffLines(self):
        return self.numberOfDiffLines

    def dateformat(self):
        """
        Get the date and time, 20111209-1234. Used in a testrun element
        """
        import datetime
        import time
        d = datetime.datetime.fromtimestamp(time.time())
        
        return d.strftime("%Y%m%d-%H%M")

    def runTest(self):
        # Make a testrun element, which will contain the result of the test
        testrun = self.testresultWriter.makeTestrunElement(self.date)
        
        paralang = ""
        # Go through each tmx goldstandard file
        for wantTmxFile in self.findGoldstandardTmxFiles():
            print "testing", wantTmxFile, "..."
            
            # Calculate the parallel lang, to be used in parallelization
            if wantTmxFile.find('nob2sme') > -1:
                paralang = 'sme'
            else:
                paralang = 'nob'
                
            # Align files
            self.alignFiles(testrun, wantTmxFile, paralang)
        
        # All files have been tested, insert this run at the top of the paragstest element
        self.testresultWriter.insertTestrunElement(testrun)
        # Write data to file
        self.testresultWriter.writeParagstestingData()

    def alignFiles(self, testrun, wantTmxFile, paralang):
        """
        Align files
        Compare the tmx's of the result of this parallellization and the tmx of the goldstandard file
        Write the result to a file
        Write the diffs of these to tmx's to a separate file
        """
        
        # Compute the name of the main file to parallelize
        xmlFile = self.computeXmlfilename(wantTmxFile)

        parallelizer = Parallelize(xmlFile, paralang)
        if parallelizer.dividePIntoSentences() == 0:
            if parallelizer.parallelizeFiles() == 0:
                
                # The result of the alignment is a tmx element
                filelist = parallelizer.getFilelist()
                gotTmx = TmxFromTca2(filelist)
        
                # This is the tmx element fetched from the goldstandard file
                wantTmx = Tmx(etree.parse(wantTmxFile))
                
                # Instantiate a comparator with the two tmxes
                comparator = TmxComparator(wantTmx, gotTmx)
        
                # Make a fileElement for our results file
                fileElement = self.testresultWriter.makeFileElement(filelist[0].getBasename(), str(comparator.getLinesInWantedfile()), str(comparator.getNumberOfDifferingLines()))
                
                self.setNumberOfDiffLines(comparator.getNumberOfDifferingLines())
                
                # Append the result for this file to the testrun element
                testrun.append(fileElement)
                
                self.writeDiffFiles(comparator, parallelizer, filelist[0].getBasename())

    def computeXmlfilename(self, wantTmxFile):
        """
        Compute the name of the xmlfile which should be aligned
        """
        xmlFile = wantTmxFile.replace('tmx/goldstandard/', 'converted/')
        xmlFile = xmlFile.replace('nob2sme', 'nob')
        xmlFile = xmlFile.replace('sme2nob', 'sme')
        xmlFile = xmlFile.replace('.tmx', '.xml')
            
        return xmlFile
        
    def writeDiffFiles(self, comparator, parallelizer, filename):
        """
        Write diffs to a jspwiki file
        """
        print "writeDiffFiles", filename
        filename = filename + '_' + self.date + '.jspwiki'
        dirname = os.path.join(os.path.dirname(self.testresultWriter.getFilename()), 'tca2testing')
        
        try:
            f = open(os.path.join(dirname, filename), "w")
        except IOError:
            print "couldn't write file", os.path.join(dirname, filename)
            sys.exit(4)
        
        f.write('!!!' + filename + '\n')
        f.write("!!TMX diff\n{{{\n")
        f.writelines(comparator.getDiffAsText())
        f.write("\n}}}\n!!" + parallelizer.getLang1() + " diff\n{{{\n")
        f.writelines(comparator.getLangDiffAsText(parallelizer.getLang1()))
        f.write("\n}}}\n!!" + parallelizer.getLang2() + " diff\n{{{\n")
        f.writelines(comparator.getLangDiffAsText(parallelizer.getLang2()))
        f.write("\n}}}\n")
        f.close()
        
    def findGoldstandardTmxFiles(self):
        """
        Find the goldstandard tmx files, return them as a list
        """
        subp = subprocess.Popen(['find', os.path.join(os.environ['GTFREE'], 'prestable/tmx/goldstandard'), '-name', '*.tmx', '-print' ], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate()

        if subp.returncode != 0:
            print >>sys.stderr, 'Error when searching for goldstandard docs'
            print >>sys.stderr, error
            sys.exit(1)
        else:
            files = output.split('\n')
            return files[:-1]

class TmxFixer:
    """
    A class to reverse the langs and change the name of a tmx file if needed
    Possible errors of a tmx file:
    * the languages can be in the wrong order
    * the name is wrong
    * the file is placed in the wrong lang directory
    """
    
    def __init__(self, filetofix):
        """
        Input is the tmx file we should consider to fix
        """
        pass
    
    
if __name__ == '__main__':
    #
    for test in [TestSentenceDivider, TestParallelFile, TestParallelize, TestTmx, TestTmxFromTca2, TestTmxComparator, TestTmxTestDataWriter]:
        testSuite = unittest.TestSuite()
        testSuite.addTest(unittest.makeSuite(test))
        unittest.TextTestRunner().run(testSuite)
