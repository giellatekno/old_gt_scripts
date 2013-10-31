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
    def __init__(self, lang, xmlFile):
        self.lang = lang
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
        self.disambiguationAnalysisName = basename + '.dis'
        self.disambiguationAnalysisNameOld = basename + '.disold'
        self.dependencyAnalysisName = basename + '.dep'
        self.dependencyAnalysisNameOld = basename + '.depold'

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

        if self.lang == 'sme':

            abbrFile = os.path.join(os.environ['GTHOME'], 'gt/sme/bin/abbr.txt')
            corrFile = os.path.join(os.environ['GTHOME'], 'gt/sme/bin/corr.txt')
            preProcessCommand.append('--abbr=' + abbrFile)
            preProcessCommand.append('--corr=' + corrFile)

        subp = subprocess.Popen(preProcessCommand,
                        stdin = subprocess.PIPE,
                        stdout = subprocess.PIPE)
        (output, error) = subp.communicate(self.ccat().replace('\\', ''))

        return output

    def lookup(self):
        """Runs lookup on the preprocess output
        Returns the output of preprocess
        """
        lookupCommand = ['lookup', '-q', '-flags', 'mbTT']

        if self.lang == 'sme':

            fstFile = os.path.join(os.getenv('GTHOME'), 'gt/' + self.lang +
                                   '/bin/' + self.lang + '.fst')
            lookupCommand.append(fstFile)
        else:
            fstFile = os.path.join(os.getenv('GTHOME'),
                                   'langs/' + self.lang + '/src/analyser-gt-desc.xfst')
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
        disambiguationAnalysisCommand = ['vislcg3', '-t', '-g']
        try:
            f = open(disambiguationFile)
        except:
            print "Unexpected error:", sys.exc_info()[0]
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

    def disambiguationAnalysisSme(self, lookup2cg):
        try:
            f = open(os.path.join(os.getenv('GTHOME'), 'gt/sme/src/sme-dis.rle'))
        except:
            print "Unexpected error:", sys.exc_info()[0]
            raise

        subp = subprocess.Popen(
            [
                'vislcg3',
                '-t',
                '-g',
                os.path.join(os.getenv('GTHOME'), 'gt/sme/src/sme-dis.rle'),
            ],
            stdin = subprocess.PIPE,
            stdout = subprocess.PIPE,
            stderr = subprocess.PIPE
        )

        (disoutput, diserror) = subp.communicate(lookup2cg)
        self.checkError(self.disambiguationAnalysisName, diserror)
        try:
            f = open(os.path.join(os.getenv('GTHOME'), 'gt/sme/src/smi-syn.rle'))
        except:
            print "Unexpected error:", sys.exc_info()[0]
            raise

        subp = subprocess.Popen(
            [
                'vislcg3',
                '-t',
                '-g',
                os.path.join(os.getenv('GTHOME'), 'gt/sme/src/smi-syn.rle')
            ],
            stdin = subprocess.PIPE,
            stdout = subprocess.PIPE,
            stderr = subprocess.PIPE
        )

        (synoutput, synerror) = subp.communicate(disoutput)
        self.checkError(self.disambiguationAnalysisName, synerror)
        outfile = open(self.disambiguationAnalysisName, "w")

        # Leave a clue for the AnalysisConcatenator
        # Will go unchanged through dependencyAnalysis as vislcg3
        # won't try to analyse clean text
        outfile.write(self.getLang() + '_' + self.getTranslatedfrom() + '_' + self.getGenre() + '\n')

        outfile.write(synoutput)
        outfile.close()

    def disambiguationAnalysis(self):
        """Runs vislcg3 on the lookup2cg output, which produces a disambiguation
        analysis
        The output is stored in a .dis file
        """

        lookup2cg = self.lookup2cg()

        if self.lang == "sme":
            self.disambiguationAnalysisOldSme(lookup2cg)
            self.disambiguationAnalysisSme(lookup2cg)
        else:
            disambiguationAnalysisCommand = ['vislcg3', '-t', '-g']
            disambiguationFile = os.path.join(os.getenv('GTHOME'), 'langs/' +
                                              self.lang + '/src/syntax/disambiguation.cg3')
            try:
                f = open(disambiguationFile)
            except:
                print "Unexpected error:", sys.exc_info()[0]
                raise

            disambiguationAnalysisCommand.append(disambiguationFile)

            subp = subprocess.Popen(disambiguationAnalysisCommand,
                                    stdin = subprocess.PIPE,
                                    stdout = subprocess.PIPE,
                                    stderr = subprocess.PIPE)
            (output, error) = subp.communicate(lookup2cg)
            outfile = open(self.disambiguationAnalysisName, "w")

            # Leave a clue for the AnalysisConcatenator
            # Will go unchanged through dependencyAnalysis as vislcg3
            # won't try to analyse clean text
            outfile.write(self.getLang() + '_' + self.getTranslatedfrom() + '_' + self.getGenre() + '\n')

            outfile.write(output)
            outfile.close()
            self.checkError(self.disambiguationAnalysisName, error)

    def dependencyAnalysis(self):
        """Runs vislcg3 on the .dis file.
        Produces output in a .dep file
        """
        if self.lang == "sme":
            dependencyAnalysisCommand = ['vislcg3', '-t']
            dependencyAnalysisCommand.append("-I")
            dependencyAnalysisCommand.append(self.disambiguationAnalysisNameOld)
            dependencyAnalysisCommand.append("-O")
            dependencyAnalysisCommand.append(self.dependencyAnalysisNameOld)
            dependencyAnalysisCommand.append('-g')
            try:
                f = open(os.path.join( os.getenv('GTHOME'), 'gt/smi/src/smi-dep.rle'))
            except:
                print "Unexpected error:", sys.exc_info()[0]
                raise

            dependencyAnalysisCommand.append(
                os.path.join( os.getenv('GTHOME'), 'gt/smi/src/smi-dep.rle'))

            subp = subprocess.Popen(dependencyAnalysisCommand,
                                    stdin = subprocess.PIPE,
                                    stdout = subprocess.PIPE,
                                    stderr = subprocess.PIPE)
            (output, error) = subp.communicate()
            dependencyAnalysisCommand = []


        dependencyAnalysisCommand = ['vislcg3', '-t']
        dependencyAnalysisCommand.append("-I")
        dependencyAnalysisCommand.append(self.disambiguationAnalysisName)
        dependencyAnalysisCommand.append("-O")
        dependencyAnalysisCommand.append(self.dependencyAnalysisName)
        dependencyAnalysisCommand.append('-g')
        try:
            f = open(os.path.join( os.getenv('GTHOME'), 'gt/smi/src/smi-dep.rle'))
        except:
            print "Unexpected error:", sys.exc_info()[0]
            raise
        dependencyAnalysisCommand.append(
            os.path.join( os.getenv('GTHOME'), 'gt/smi/src/smi-dep.rle'))

        subp = subprocess.Popen(dependencyAnalysisCommand,
                                stdin = subprocess.PIPE,
                                stdout = subprocess.PIPE,
                                stderr = subprocess.PIPE)
        (output, error) = subp.communicate()
        self.checkError(self.dependencyAnalysisName, error)

    def checkError(self, filename, error):
        if len(error) > 0:
            print >>sys.stderr
            print >>sys.stderr, filename
            print >>sys.stderr, error
    def analyse(self):
        self.disambiguationAnalysis()
        self.dependencyAnalysis()

class AnalysisConcatenator:
    def __init__(self, goalDir, xmlFiles):
        """
        @brief Receives a list of filenames that has been analysed
        """
        self.basenames = xmlFiles
        self.disFiles = {}
        self.depFiles = {}
        self.disoldFiles = {}
        self.depoldFiles = {}
        self.goalDir = os.path.join(goalDir, datetime.date.today().isoformat())
        os.makedirs(self.goalDir)

    def concatenateAnalysedFiles(self):
        """
        @brief Concatenates analysed files according to origlang, translated_from_lang and genre
        """
        for xmlFile in self.basenames:
            self.concatenateAnalysedFile(xmlFile[1].replace(".xml", ".dis"))
            self.concatenateAnalysedFile(xmlFile[1].replace(".xml", ".dep"))
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
