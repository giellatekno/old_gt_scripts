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

        return subprocess.check_output(ccatCommand)

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

        subp = subprocess.Popen(preProcessCommand,
                        stdin = subprocess.PIPE,
                        stdout = subprocess.PIPE)
        (output, error) = subp.communicate(self.ccat())

        return output

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

        subp = subprocess.Popen(lookupCommand,
                        stdin = subprocess.PIPE,
                        stdout = subprocess.PIPE)
        (output, error) = subp.communicate(self.preprocess())

        return output

    def lookup2cg(self):
        """Runs the lookup on the lookup output
        Returns the output of lookup2cg
        """
        lookup2cgCommand = ['lookup2cg']

        subp = subprocess.Popen(lookup2cgCommand,
                        stdin = subprocess.PIPE,
                        stdout = subprocess.PIPE)
        (output, error) = subp.communicate(self.lookup())

        return output


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

        subp = subprocess.Popen(disambiguationAnalysisCommand,
                                stdin = subprocess.PIPE,
                                stdout = subprocess.PIPE)
        (output, error) = subp.communicate(self.lookup2cg())
        outfile = open(self.disambiguationAnalysisName, "w")

        # Leave a clue for the AnalysisConcatenator
        # Will go unchanged through dependencyAnalysis as vislcg3
        # won't try to analyse clean text
        outfile.write(self.getLang() + '_' + self.getTranslatedfrom() + '_' + self.getGenre() + '\n')

        outfile.write(output)
        outfile.close()

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

        dependencyAnalysisCommand.append("-I")
        dependencyAnalysisCommand.append(self.disambiguationAnalysisName)
        dependencyAnalysisCommand.append("-O")
        dependencyAnalysisCommand.append(self.dependencyAnalysisName)
        subprocess.call(dependencyAnalysisCommand)

    def analyse(self):
        self.disambiguationAnalysis()
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
