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

class Analyser:
    def __init__(self, lang, xmlFile):
        self._lang = lang
        self._xmlFile = xmlFile

    def ccat(self):
        """Runs ccat on the input file
        Returns the output of ccat
        """
        ccatCommand = ['ccat', '-a', '-l', self._lang, self._xmlFile]
        ccatProcess = subprocess.Popen(ccatCommand,
                                stdout = subprocess.PIPE)

        return ccatProcess.stdout

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

        preprocessProcess = subprocess.Popen(preProcessCommand,
                                      stdin = self.ccat(),
                                      stdout = subprocess.PIPE)

        return preprocessProcess.stdout

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

        lookupProcess = subprocess.Popen(lookupCommand,
                                  stdin = self.preprocess(),
                                  stdout = subprocess.PIPE)

        return lookupProcess.stdout

    def lookup2cg(self):
        """Runs the lookup on the lookup output
        Returns the output of lookup2cg
        """
        lookup2cgCommand = ['lookup2cg']

        lookup2cgProcess = subprocess.Popen(lookup2cgCommand,
                                     stdin = self.lookup(),
                                     stdout = subprocess.PIPE)

        return lookup2cgProcess.stdout

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

        disambiguationAnalysisCommand.append('-O')
        disambiguationAnalysisCommand.append(self._xmlFile.replace('.xml', '.dis'))

        disambiguationAnalysisProcess = subprocess.Popen(disambiguationAnalysisCommand,
                         stdin = self.lookup2cg())


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

        dependencyAnalysisCommand.append('-I')
        dependencyAnalysisCommand.append(self._xmlFile.replace('.xml', '.dis'))
        dependencyAnalysisCommand.append('-O')
        dependencyAnalysisCommand.append(self._xmlFile.replace('.xml', '.dep'))

        dependencyAnalysisProcess = subprocess.Popen(dependencyAnalysisCommand)
