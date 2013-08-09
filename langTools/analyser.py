#!/usr/bin/env python
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
import lxml.etree as etree

class Analyser:
    def __init__(self, lang, xmlFile):
        self._lang = lang
        self.eTree = etree.parse(xmlFile)
        self.calculateFilenames(xmlFile)

    def getLang(self):
        """
        @brief Get the mainlang from the xml file

        :returns: the language as set in the xml file
        """
        if self.eTree.getroot().attrib['{http://www.w3.org/XML/1998/namespace}lang'] is not None:
            return self.eTree.getroot().attrib['{http://www.w3.org/XML/1998/namespace}lang']
        else:
            return 'none'

    def getGenre(self):
        """
        @brief Get the genre from the xml file

        :returns: the genre as set in the xml file
        """
        if self.eTree.getroot().find(".//genre") is not None:
            return self.eTree.getroot().find(".//genre").attrib["code"]
        else:
            return 'none'

    def getTranslatedfrom(self):
        """
        @brief Get the translated_from value from the xml file

        :returns: the value of translated_from as set in the xml file
        """
        if self.eTree.getroot().find(".//translated_from") is not None:
            return self.eTree.getroot().find(".//translated_from").attrib["{http://www.w3.org/XML/1998/namespace}lang"]
        else:
            return 'none'

    def calculateFilenames(self, xmlFile):
        """Set the names of the analysis files
        """


        basename = xmlFile[:-4]

        self.xmlFile = xmlFile
        self.ccatName = basename + '.ccat'
        self.preprocessName = basename + '.preprocess'
        self.lookupName = basename + '.lookup'
        self.lookup2cgName = basename + '.lookup2cg'
        self.disambiguationAnalysisName = basename + '.dis'
        self.dependencyAnalysisName = basename + '.dep'

    def ccat(self):
        """Runs ccat on the input file
        Returns the output of ccat
        """
        ccatCommand = ['ccat', '-a', '-l', self._lang, self.xmlFile]

        outfile = open(self.ccatName, "w")
        subprocess.call(ccatCommand,
                        stdout = outfile)
        outfile.close()

    def preprocess(self):
        """Runs preprocess on the ccat output.
        Returns the output of preprocess
        """
        preProcessCommand = ['preprocess']

        if self._lang == 'sme':

            abbrFile = os.path.join(os.environ['GTHOME'], 'gt/sme/bin/abbr.txt')
            corrFile = os.path.join(os.environ['GTHOME'], 'gt/sme/bin/corr.txt')
            preProcessCommand.append('--abbr=' + abbrFile)
            preProcessCommand.append('--corr=' + corrFile)

        infile = open(self.ccatName)
        outfile = open(self.preprocessName, "w")
        subprocess.call(preProcessCommand,
                        stdin = infile,
                        stdout = outfile)
        infile.close()
        outfile.close()

        os.unlink(self.ccatName)

    def lookup(self):
        """Runs lookup on the preprocess output
        Returns the output of preprocess
        """
        lookupCommand = ['lookup', '-q', '-flags', 'mbTT']

        if self._lang == 'sme':

            fstFile = os.path.join(os.getenv('GTHOME'), 'gt/' + self._lang +
                                   '/bin/' + self._lang + '.fst')
            lookupCommand.append(fstFile)
        else:
            fstFile = os.path.join(os.getenv('GTHOME'),
                                   'langs/' + self._lang + '/src/analyser-gt-desc.xfst')
            lookupCommand.append(fstFile)

        infile = open(self.preprocessName)
        outfile = open(self.lookupName, "w")
        subprocess.call(lookupCommand,
                        stdin = infile,
                        stdout = outfile)
        infile.close()
        outfile.close()

        os.unlink(self.preprocessName)

    def lookup2cg(self):
        """Runs the lookup on the lookup output
        Returns the output of lookup2cg
        """
        lookup2cgCommand = ['lookup2cg']

        infile = open(self.lookupName)
        outfile = open(self.lookup2cgName, "w")
        subprocess.call(lookup2cgCommand,
                        stdin = infile,
                        stdout = outfile)
        infile.close()
        outfile.close()

        os.unlink(self.lookupName)

    def disambiguationAnalysis(self):
        """Runs vislcg3 on the lookup2cg output, which produces a disambiguation
        analysis
        The output is stored in a .dis file
        """

        disambiguationAnalysisCommand = ['vislcg3', '-g']

        if self._lang == "sme":
            disambiguationFile = os.path.join(os.getenv('GTHOME'), 'gt/' +
                                              self._lang + '/src/' + self._lang + '-dis.rle')
            disambiguationAnalysisCommand.append(disambiguationFile)
        else:
            disambiguationFile = os.path.join(os.getenv('GTHOME'), 'langs/' +
                                              self._lang + '/src/syntax/disambiguation.cg3')
            disambiguationAnalysisCommand.append(disambiguationFile)

        infile = open(self.lookup2cgName)
        outfile = open(self.disambiguationAnalysisName, "w")

        # Leave a clue for the AnalysisConcatenator
        # Will go unchanged through dependencyAnalysis as vislcg3
        # won't try to analyse clean text
        outfile.write(self.getLang() + '_' + self.getTranslatedfrom() + '_' + self.getGenre() + '\n')

        outfile.write(subprocess.check_output(disambiguationAnalysisCommand,
                        stdin = infile))
        infile.close()
        outfile.close()

        os.unlink(self.lookup2cgName)

    def dependencyAnalysis(self):
        """Runs vislcg3 on the .dis file.
        Produces output in a .dep file
        """

        dependencyAnalysisCommand = ['vislcg3', '-g']

        if self._lang == 'sme':
            dependencyFile = os.path.join(os.getenv('GTHOME'),
                                          'gt/smi/src/smi-dep.rle')
            dependencyAnalysisCommand.append(dependencyFile)

        else:

            dependencyFile = os.path.join( os.getenv('GTHOME'),
                                          'gt/smi/src/smi-dep.rle')
            dependencyAnalysisCommand.append(dependencyFile)

        infile = open(self.disambiguationAnalysisName)
        outfile = open(self.dependencyAnalysisName, "w")
        subprocess.call(dependencyAnalysisCommand,
                        stdin = infile,
                        stdout = outfile)
        infile.close()
        outfile.close()

    def analyse(self):
        self.ccat()
	if os.path.isfile(self.ccatName):
            self.preprocess()
	    if os.path.isfile(self.preprocessName):
                self.lookup()
	        if os.path.isfile(self.lookupName):
                    self.lookup2cg()
	            if os.path.isfile(self.lookup2cgName):
                        self.disambiguationAnalysis()
	                if os.path.isfile(self.disambiguationAnalysisName):
                            self.dependencyAnalysis()

class AnalysisConcatenator:
    def __init__(self, xmlFiles):
        """
        @brief Receives a list of filenames that has been analysed
        """
        self.basenames = xmlFiles
        self.disFiles = {}
        self.depFiles = {}

    def concatenateAnalysedFiles(self):
        """
        @brief Concatenates analysed files according to origlang, translated_from_lang and genre
        """
        for xmlFile in self.basenames:
            self.concatenateAnalysedFile(xmlFile[1].replace(".xml", ".dis"))
            self.concatenateAnalysedFile(xmlFile[1].replace(".xml", ".dep"))


    def concatenateAnalysedFile(self, filename):
        """
        @brief Adds the content of the given file to file it belongs to

        :returns: ...
        """
        if os.path.isfile(filename):
            fromFile = open(filename)
            self.getToFile(fromFile.readline(), filename[-4:]).write(fromFile.read())
            fromFile.close()
            os.unlink(filename)

    def getToFile(self, prefix, extension):
        """
        @brief Gets the prefix of the filename. Opens a file object with the files prefix.

        :returns: File object belonging to the prefix of the filename
        """

        prefix = prefix.strip()
        if extension == ".dis":
            try:
                self.disFiles[prefix]
            except KeyError:
                self.disFiles[prefix] = open(prefix + ".dis", "w")

            return self.disFiles[prefix]

        else:
            try:
                self.depFiles[prefix]
            except KeyError:
                self.depFiles[prefix] = open(prefix + ".dep", "w")

            return self.depFiles[prefix]
