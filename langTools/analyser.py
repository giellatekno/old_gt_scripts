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
import datetime
import lxml.etree as etree

class Analyser:
    def __init__(self, lang, xmlFile, old=False):
        self.lang = lang
        self.old = old
        self.xmlFile = xmlFile
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

    def getOcr(self):
        """
        @brief Check if the ocr element exists

        :returns: the ocr element or None
        """
        return self.eTree.getroot().find(".//ocr")

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
        self.dependencyAnalysisName = xmlFile.replace('/converted/', '/analysed')

    def ccat(self):
        """Runs ccat on the input file
        Returns the output of ccat
        """
        ccatCommand = ['ccat', '-a', '-l', self.lang, self.xmlFile]

        return subprocess.check_output(ccatCommand)

    def preprocess(self):
        """Runs preprocess on the ccat output.
        Returns the output of preprocess
        """
        preProcessCommand = ['preprocess']

        if self.lang in ['sma', 'sme', 'smj'] :
            abbrFile = os.path.join(
                os.environ['GTHOME'],
                'langs/' + self.lang + '/src/syntax/abbr.txt')
            if not os.path.exists(abbrFile):
                raise IOError((-1, abbrFile + ' does not exist'))

            preProcessCommand.append('--abbr=' + abbrFile)

        if self.lang == 'sme':
            corrFile = os.path.join(os.environ['GTHOME'], 'langs/' + self.lang + '/src/syntax/corr.txt')
            if not os.path.exists(corrFile):
                raise IOError((-1, corrFile + ' does not exist'))
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
        fstFile = os.path.join(os.getenv('GTHOME'),
                               'langs/' +
                               self.lang +
                               '/src/analyser-gt-desc.xfst')
        if not os.path.exists(fstFile):
            raise IOError((-1, fstFile + ' does not exist'))
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


    def disambiguationAnalysisOldSme(self, lookup2cg):
        disambiguationFile = os.path.join(os.getenv('GTHOME'), 'gt/' +
                                          self.lang + '/src/Old' + self.lang + '-dis.rle')
        disambiguationAnalysisCommand = ['vislcg3', '-g']
        try:
            f = open(disambiguationFile)
        except:
            print("Unexpected error:", sys.exc_info()[0])
            raise
        disambiguationAnalysisCommand.append(disambiguationFile)

        subp = subprocess.Popen(disambiguationAnalysisCommand,
                                stdin = subprocess.PIPE,
                                stdout = subprocess.PIPE,
                                stderr = subprocess.PIPE)
        (output, error) = subp.communicate(lookup2cg)
        outfile = open(self.disambiguationAnalysisNameOld, "w")

        # Leave a clue for the AnalysisConcatenator
        # Will go unchanged through dependencyAnalysis as vislcg3
        # won't try to analyse clean text
        outfile.write(self.getLang() + '_' + self.getTranslatedfrom() + '_' + self.getGenre() + '\n')

        outfile.write(output)
        outfile.close()

    def disambiguationAnalysis(self):
        """Runs vislcg3 on the lookup2cg output, which produces a disambiguation
        analysis
        The output is stored in a .dis file
        """

        lookup2cg = self.lookup2cg()

        if self.lang == "sme" and self.old:
            self.disambiguationAnalysisOldSme(lookup2cg)

        disambiguationAnalysisCommand = ['vislcg3', '-g']
        disambiguationFile = os.path.join(os.getenv('GTHOME'), 'langs/' +
                                          self.lang + '/src/syntax/disambiguation.cg3')
        f = open(disambiguationFile)
        f.close()

        disambiguationAnalysisCommand.append(disambiguationFile)

        subp = subprocess.Popen(disambiguationAnalysisCommand,
                                stdin = subprocess.PIPE,
                                stdout = subprocess.PIPE,
                                stderr = subprocess.PIPE)
        (output, error) = subp.communicate(lookup2cg)

        return output

    def getDisambiguationXml(self):
        disambiguation = etree.Element('disambiguation')
        disambiguation.text = self.disambiguationAnalysis().decode('utf8')
        body = etree.Element('body')
        body.append(disambiguation)

        oldbody = self.eTree.find('.//body')
        oldbody.getparent().replace(oldbody, body)

        return self.eTree

    def functionAnalysis(self):
        """Runs vislcg3 on the dis file
        Return the output of this process
        """
        functionAnalysisCommand = [
            'vislcg3',
            '-g',
            os.path.join(
                os.getenv('GTHOME'),
                'gtcore/langs-templates/smi/src/syntax/functions.cg3'),
            '-I',
            self.disambiguationAnalysisName
            ]

        subp = subprocess.Popen(
            functionAnalysisCommand,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
            )
        (output, error) = subp.communicate()
        self.checkError('functionAnalysis', error)

        return output

    def dependencyAnalysis(self):
        """Runs vislcg3 on the .dis file.
        Produces output in a .dep file
        """
        if self.lang == "sme" and self.old:
            dependencyAnalysisCommand = ['vislcg3']
            dependencyAnalysisCommand.append("-I")
            dependencyAnalysisCommand.append(self.disambiguationAnalysisNameOld)
            dependencyAnalysisCommand.append("-O")
            dependencyAnalysisCommand.append(self.dependencyAnalysisNameOld)
            dependencyAnalysisCommand.append('-g')
            try:
                f = open(os.path.join( os.getenv('GTHOME'), 'gt/smi/src/smi-dep.rle'))
            except:
                print("Unexpected error:", sys.exc_info()[0])
                raise

            dependencyAnalysisCommand.append(
                os.path.join( os.getenv('GTHOME'), 'gt/smi/src/smi-dep.rle'))

            subp = subprocess.Popen(dependencyAnalysisCommand,
                                    stdin = subprocess.PIPE,
                                    stdout = subprocess.PIPE,
                                    stderr = subprocess.PIPE)
            (output, error) = subp.communicate()
            dependencyAnalysisCommand = []


        dependencyAnalysisCommand = ['vislcg3']
        dependencyAnalysisCommand.append("-O")
        dependencyAnalysisCommand.append(self.dependencyAnalysisName)
        dependencyAnalysisCommand.append('-g')
        try:
            f = open(
                os.path.join(
                    os.getenv('GTHOME'),
                    'gtcore/langs-templates/smi/src/syntax/dependency.cg3'))
        except:
            print("Unexpected error:", sys.exc_info()[0])
            raise
        dependencyAnalysisCommand.append(
            os.path.join(
                os.getenv('GTHOME'),
                'gtcore/langs-templates/smi/src/syntax/dependency.cg3'))

        subp = subprocess.Popen(dependencyAnalysisCommand,
                                stdin = subprocess.PIPE,
                                stdout = subprocess.PIPE,
                                stderr = subprocess.PIPE)
        (output, error) = subp.communicate(self.functionAnalysis())
        self.checkError(self.dependencyAnalysisName, error)

    def checkError(self, filename, error):
        if len(error) > 0:
            print(file=sys.stderr)
            print(filename, file=sys.stderr)
            print(error, file=sys.stderr)

    def analyse(self):
        '''Analyse a file if it is not ocr'ed
        '''
        if self.getOcr() is None:
            self.disambiguationAnalysis()
            self.dependencyAnalysis()

class AnalysisConcatenator:
    def __init__(self, goalDir, xmlFiles, old=False):
        """
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
        """
        @brief Concatenates analysed files according to origlang, translated_from_lang and genre
        """
        for xmlFile in self.basenames:
            self.concatenateAnalysedFile(xmlFile[1].replace(".xml", ".dis"))
            self.concatenateAnalysedFile(xmlFile[1].replace(".xml", ".dep"))
            if self.old:
                self.concatenateAnalysedFile(xmlFile[1].replace(".xml", ".disold"))
                self.concatenateAnalysedFile(xmlFile[1].replace(".xml", ".depold"))


    def concatenateAnalysedFile(self, filename):
        """
        @brief Adds the content of the given file to file it belongs to

        :returns: ...
        """
        if os.path.isfile(filename):
            fromFile = open(filename)
            self.getToFile(fromFile.readline(), filename).write(fromFile.read())
            fromFile.close()
            os.unlink(filename)

    def getToFile(self, prefix, filename):
        """
        @brief Gets the prefix of the filename. Opens a file object with the files prefix.

        :returns: File object belonging to the prefix of the filename
        """

        prefix = os.path.join(self.goalDir, prefix.strip())
        if filename[-4:] == ".dis":
            try:
                self.disFiles[prefix]
            except KeyError:
                self.disFiles[prefix] = open(prefix + ".dis", "w")

            return self.disFiles[prefix]

        elif filename[-4:] == ".dep":
            try:
                self.depFiles[prefix]
            except KeyError:
                self.depFiles[prefix] = open(prefix + ".dep", "w")

            return self.depFiles[prefix]

        if filename[-7:] == ".disold":
            try:
                self.disoldFiles[prefix]
            except KeyError:
                self.disoldFiles[prefix] = open(prefix + ".disold", "w")

            return self.disoldFiles[prefix]

        elif filename[-7:] == ".depold":
            try:
                self.depoldFiles[prefix]
            except KeyError:
                self.depoldFiles[prefix] = open(prefix + ".depold", "w")

            return self.depoldFiles[prefix]
