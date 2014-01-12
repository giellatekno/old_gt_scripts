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
#   Copyright 2013 Børre Gaup <borre.gaup@uit.no>
#

import os
import sys
import subprocess
import re
import datetime
import lxml.etree as etree
from io import open
import StringIO
import ccat

class Analyser(object):
    def __init__(self, lang, xmlFile, old=False):
        self.lang = lang
        self.old = old
        self.xmlFile = xmlFile
        self.analysisXmlFile = self.xmlFile.replace(u'converted/', u'analysed/')
        self.eTree = etree.parse(xmlFile)
        self.calculateFilenames(xmlFile)

    def makedirs(self):
        u"""Make the converted directory
        """
        try:
            os.makedirs(os.path.dirname(self.analysisXmlFile))
        except OSError:
            pass

    def getLang(self):
        u"""
        @brief Get the mainlang from the xml file

        :returns: the language as set in the xml file
        """
        if self.eTree.getroot().attrib[u'{http://www.w3.org/XML/1998/namespace}lang'] is not None:
            return self.eTree.getroot().attrib[u'{http://www.w3.org/XML/1998/namespace}lang']
        else:
            return u'none'

    def getGenre(self):
        u"""
        @brief Get the genre from the xml file

        :returns: the genre as set in the xml file
        """
        if self.eTree.getroot().find(u".//genre") is not None:
            return self.eTree.getroot().find(u".//genre").attrib[u"code"]
        else:
            return u'none'

    def getOcr(self):
        u"""
        @brief Check if the ocr element exists

        :returns: the ocr element or None
        """
        return self.eTree.getroot().find(u".//ocr")

    def getTranslatedfrom(self):
        u"""
        @brief Get the translated_from value from the xml file

        :returns: the value of translated_from as set in the xml file
        """
        if self.eTree.getroot().find(u".//translated_from") is not None:
            return self.eTree.getroot().find(u".//translated_from").attrib[u"{http://www.w3.org/XML/1998/namespace}lang"]
        else:
            return u'none'

    def calculateFilenames(self, xmlFile):
        u"""Set the names of the analysis files
        """
        self.dependencyAnalysisName = xmlFile.replace(u'/converted/', u'/analysed')

    def ccat(self):
        u"""Runs ccat on the input file
        Returns the output of ccat
        """
        xp = ccat.XMLPrinter(self.xmlFile, lang=self.lang, allP=True)
        xp.outfile = StringIO.StringIO()
        xp.processFile()

        return xp.outfile.getvalue()

    def preprocess(self):
        u"""Runs preprocess on the ccat output.
        Returns the output of preprocess
        """
        preProcessCommand = [u'preprocess']

        if self.lang in [u'sma', u'sme', u'smj'] :
            abbrFile = os.path.join(
                os.environ[u'GTHOME'],
                u'langs/' + self.lang + u'/src/syntax/abbr.txt')
            if not os.path.exists(abbrFile):
                raise IOError((-1, abbrFile + u' does not exist'))

            preProcessCommand.append(u'--abbr=' + abbrFile)

        if self.lang == u'sme':
            corrFile = os.path.join(os.environ[u'GTHOME'], u'langs/' + self.lang + u'/src/syntax/corr.txt')
            if not os.path.exists(corrFile):
                raise IOError((-1, corrFile + u' does not exist'))
            preProcessCommand.append(u'--corr=' + corrFile)

        subp = subprocess.Popen(preProcessCommand,
                        stdin = subprocess.PIPE,
                        stdout = subprocess.PIPE)
        (output, error) = subp.communicate(self.ccat())

        return output

    def lookup(self):
        u"""Runs lookup on the preprocess output
        Returns the output of preprocess
        """
        lookupCommand = [u'lookup', u'-q', u'-flags', u'mbTT']
        fstFile = os.path.join(os.getenv(u'GTHOME'),
                               u'langs/' +
                               self.lang +
                               u'/src/analyser-gt-desc.xfst')
        if not os.path.exists(fstFile):
            raise IOError((-1, fstFile + u' does not exist'))
        lookupCommand.append(fstFile)

        subp = subprocess.Popen(lookupCommand,
                        stdin = subprocess.PIPE,
                        stdout = subprocess.PIPE)
        (output, error) = subp.communicate(self.preprocess())

        return output

    def lookup2cg(self):
        u"""Runs the lookup on the lookup output
        Returns the output of lookup2cg
        """
        lookup2cgCommand = [u'lookup2cg']

        subp = subprocess.Popen(lookup2cgCommand,
                        stdin = subprocess.PIPE,
                        stdout = subprocess.PIPE)
        (output, error) = subp.communicate(self.lookup())

        return output


    def disambiguationAnalysisOldSme(self, lookup2cg):
        disambiguationFile = os.path.join(os.getenv(u'GTHOME'), u'gt/' +
                                          self.lang + u'/src/Old' + self.lang + u'-dis.rle')
        disambiguationAnalysisCommand = [u'vislcg3', u'-g']
        try:
            f = open(disambiguationFile)
        except:
            print u"Unexpected error:", sys.exc_info()[0]
            raise
        disambiguationAnalysisCommand.append(disambiguationFile)

        subp = subprocess.Popen(disambiguationAnalysisCommand,
                                stdin = subprocess.PIPE,
                                stdout = subprocess.PIPE,
                                stderr = subprocess.PIPE)
        (output, error) = subp.communicate(lookup2cg)
        outfile = open(self.disambiguationAnalysisNameOld, u"w")

        # Leave a clue for the AnalysisConcatenator
        # Will go unchanged through dependencyAnalysis as vislcg3
        # won't try to analyse clean text
        outfile.write(self.getLang() + u'_' + self.getTranslatedfrom() + u'_' + self.getGenre() + u'\n')

        outfile.write(output)
        outfile.close()

    def disambiguationAnalysis(self):
        u"""Runs vislcg3 on the lookup2cg output, which produces a disambiguation
        analysis
        The output is stored in a .dis file
        """

        lookup2cg = self.lookup2cg()

        if self.lang == u"sme" and self.old:
            self.disambiguationAnalysisOldSme(lookup2cg)

        disambiguationAnalysisCommand = [u'vislcg3', u'-g']
        disambiguationFile = os.path.join(os.getenv(u'GTHOME'), u'langs/' +
                                          self.lang + u'/src/syntax/disambiguation.cg3')
        f = open(disambiguationFile)
        f.close()

        disambiguationAnalysisCommand.append(disambiguationFile)

        subp = subprocess.Popen(disambiguationAnalysisCommand,
                                stdin = subprocess.PIPE,
                                stdout = subprocess.PIPE,
                                stderr = subprocess.PIPE)
        (self.disambiguation, error) = subp.communicate(lookup2cg)

    def getDisambiguation(self):
        return self.disambiguation

    def getDisambiguationXml(self):
        disambiguation = etree.Element(u'disambiguation')
        disambiguation.text = self.disambiguationAnalysis().decode(u'utf8')
        body = etree.Element(u'body')
        body.append(disambiguation)

        oldbody = self.eTree.find(u'.//body')
        oldbody.getparent().replace(oldbody, body)

        return self.eTree

    def functionAnalysis(self):
        u"""Runs vislcg3 on the dis file
        Return the output of this process
        """
        self.disambiguationAnalysis()

        functionAnalysisCommand = [
            u'vislcg3',
            u'-g',
            os.path.join(
                os.getenv(u'GTHOME'),
                u'gtcore/langs-templates/smi/src/syntax/functions.cg3'),
            ]

        subp = subprocess.Popen(
            functionAnalysisCommand,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
            )
        (output, error) = subp.communicate(self.getDisambiguation())

        self.checkError(u'functionAnalysis', error)

        return output

    def dependencyAnalysis(self):
        u"""Runs vislcg3 on the .dis file.
        Produces output in a .dep file
        """
        dependencyAnalysisCommand = [u'vislcg3']
        dependencyAnalysisCommand.append(u'-g')
        dependencyAnalysisCommand.append(
            os.path.join(
                os.getenv(u'GTHOME'),
                u'gtcore/langs-templates/smi/src/syntax/dependency.cg3'))

        subp = subprocess.Popen(dependencyAnalysisCommand,
                                stdin = subprocess.PIPE,
                                stdout = subprocess.PIPE,
                                stderr = subprocess.PIPE)
        (self.dependency, error) = subp.communicate(self.functionAnalysis())
        self.checkError(self.dependencyAnalysisName, error)

    def getDependency(self):
        return self.dependency

    def getAnalysisXml(self):
        body = etree.Element(u'body')

        disambiguation = etree.Element(u'disambiguation')
        disambiguation.text = self.getDisambiguation().decode(u'utf8')
        body.append(disambiguation)

        dependency = etree.Element(u'dependency')
        dependency.text = self.getDependency().decode(u'utf8')
        body.append(dependency)

        oldbody = self.eTree.find(u'.//body')
        oldbody.getparent().replace(oldbody, body)

        return self.eTree

    def checkError(self, filename, error):
        if len(error) > 0:
            print >>sys.stderr
            print >>sys.stderr, filename
            print >>sys.stderr, error

    def analyse(self):
        u'''Analyse a file if it is not ocr'ed
        '''
        if self.getOcr() is None:
            self.dependencyAnalysis()
            self.makedirs()
            self.getAnalysisXml().write(
                self.analysisXmlFile,
                encoding=u'utf8',
                xml_declaration=True)

class AnalysisConcatenator(object):
    def __init__(self, goalDir, xmlFiles, old=False):
        u"""
        @brief Receives a list of filenames that has been analysed
        """
        self.basenames = xmlFiles
        self.old = old
        if old:
            self.disoldFiles = {}
            self.depoldFiles = {}
        self.disFiles = {}
        self.depFiles = {}
        self.goalDir = os.path.join(goalDir, datetime.date.today().isoformat())
        try:
            os.makedirs(self.goalDir)
        except OSError:
            pass

    def concatenateAnalysedFiles(self):
        u"""
        @brief Concatenates analysed files according to origlang, translated_from_lang and genre
        """
        for xmlFile in self.basenames:
            self.concatenateAnalysedFile(xmlFile[1].replace(u".xml", u".dis"))
            self.concatenateAnalysedFile(xmlFile[1].replace(u".xml", u".dep"))
            if self.old:
                self.concatenateAnalysedFile(xmlFile[1].replace(u".xml", u".disold"))
                self.concatenateAnalysedFile(xmlFile[1].replace(u".xml", u".depold"))


    def concatenateAnalysedFile(self, filename):
        u"""
        @brief Adds the content of the given file to file it belongs to

        :returns: ...
        """
        if os.path.isfile(filename):
            fromFile = open(filename)
            self.getToFile(fromFile.readline(), filename).write(fromFile.read())
            fromFile.close()
            os.unlink(filename)

    def getToFile(self, prefix, filename):
        u"""
        @brief Gets the prefix of the filename. Opens a file object with the files prefix.

        :returns: File object belonging to the prefix of the filename
        """

        prefix = os.path.join(self.goalDir, prefix.strip())
        if filename[-4:] == u".dis":
            try:
                self.disFiles[prefix]
            except KeyError:
                self.disFiles[prefix] = open(prefix + u".dis", u"w")

            return self.disFiles[prefix]

        elif filename[-4:] == u".dep":
            try:
                self.depFiles[prefix]
            except KeyError:
                self.depFiles[prefix] = open(prefix + u".dep", u"w")

            return self.depFiles[prefix]

        if filename[-7:] == u".disold":
            try:
                self.disoldFiles[prefix]
            except KeyError:
                self.disoldFiles[prefix] = open(prefix + u".disold", u"w")

            return self.disoldFiles[prefix]

        elif filename[-7:] == u".depold":
            try:
                self.depoldFiles[prefix]
            except KeyError:
                self.depoldFiles[prefix] = open(prefix + u".depold", u"w")

            return self.depoldFiles[prefix]
