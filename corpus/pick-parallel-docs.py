#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This is a program to pick out parallel files to prestable/converted
#   inside a corpus directory
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

from __future__ import print_function
import os
import sys
import argparse
sys.path.append(os.getenv('GTHOME') + '/gt/script/langTools')
import parallelize
from lxml import etree
from lxml import doctestcompare
import doctest
import shutil
import inspect

def PrintFrame(input = "empty"):
    """
    Print debug output
    """
    callerframerecord = inspect.stack()[1]    # 0 represents this line
                                                # 1 represents line at caller
    frame = callerframerecord[0]
    info = inspect.getframeinfo(frame)
    
    print( info.lineno, info.function, input)

class ParallelPicker:
    def __init__(self, language1Dir, parallelLanguage, minratio, maxratio):
        self.language1Dir = language1Dir
        self.calculateLanguage1(language1Dir)
        self.parallelLanguage = parallelLanguage
        self.minratio = minratio
        self.maxratio = maxratio
        self.oldFiles = []
        self.noOrig = []
        self.noParallel = []
        self.poorRatio = []
        self.tooFewWords = []

    def calculateLanguage1(self, language1Dir):
        """
        The language is the part after 'converted/'
        """
        convertedPos = language1Dir.find('converted/')
        partAfterConverted = language1Dir[convertedPos + len('converted/'):]
        
        if partAfterConverted.find('/') == -1:
            self.language1 = partAfterConverted
        else:
            self.language1 = partAfterConverted[:partAfterConverted.find('/')]
    
    def getLanguage1(self):
        return self.language1
    
    def getParallelLanguage(self):
        return self.parallelLanguage
    
    def addOldfiles(self, filename):
        """
        Add a filename to the list of files that were in prestable before
        new files were added
        """
        self.oldFiles.append(filename)
        
    def addNoOrig(self, filename):
        """
        Add a filename to the list of files in prestable that had no original 
        file before new files were added
        """
        self.noOrig.append(filename)
        
    def addNoParallel(self, filename):
        """
        Add a filename to the list of files in prestable that had no original 
        file before new files were added
        """
        self.noParallel.append(filename)
        
    def removeFile(self, filename):
        """
        Remove the given file
        """
        os.remove(filename)
        
    def checkPrestableFile(self, corpusFile):
        """
        Remove a file and its parallel file from prestable if it has no orig file
        Remove a file from prestable if it has no parallel
        If not, add the file name to the list of old files
        """
        PrintFrame()
        if not self.hasOrig(corpusFile):
            self.addNoOrig(corpusFile.getName())
            self.removeFile(corpusFile.getName())
            
            if self.hasParallel(corpusFile):
                self.addNoOrig(corpusFile.getParallelFilename())
                self.removeFile(corpusFile.getParallelFilename())
            
        elif not self.hasParallel(corpusFile):
            self.addNoParallel(corpusFile.getName())
            self.removeFile(corpusFile.getName())
            
        else:
            self.addOldfiles(corpusFile.getName())
    
    def getOldFileNames(self):
        """
        Get all the filenames in prestable for the language pair that is given to the program
        """
        
        prestableDir = self.language1Dir.replace('converted/', 'prestable/converted/')
        PrintFrame(prestableDir)
        
        for root, dirs, files in os.walk(prestableDir): # Walk directory tree
            for f in files:
                if f.endswith('.xml'):
                    PrintFrame(os.path.join(root, f))
                    corpusFile = parallelize.CorpusXMLFile(os.path.join(root, f), self.getParallelLanguage())
                    self.checkPrestableFile(corpusFile)
        
        l2prestableDir = prestableDir.replace('/' + self.getLanguage1(), '/' + self.getParallelLanguage())
        
        for root, dirs, files in os.walk(l2prestableDir): # Walk directory tree
            for f in files:
                if f.endswith('.xml'):
                    PrintFrame(os.path.join(root, f))
                    corpusFile = parallelize.CorpusXMLFile(os.path.join(root, f), self.getLanguage1())
                    self.checkPrestableFile(corpusFile)

    def findLang1Files(self):
        """
        Find the language1 files
        """
        language1Files = []
        for root, dirs, files in os.walk(self.language1Dir): # Walk directory tree
            for f in files:
                if f.endswith('.xml'):
                    language1Files.append(parallelize.CorpusXMLFile(root + '/' + f, self.parallelLanguage))
                
        return language1Files
    
    def hasParallel(self, language1File):
        """
        Check if the given file has a parallel file
        """
        
        return language1File.getParallelFilename() is not None and os.path.isfile(language1File.getParallelFilename())

    def hasOrig(self, language1File):
        """
        Check if the given file has an original file
        """
        
        return language1File.getOriginalFilename() is not None and os.path.isfile(language1File.getOriginalFilename())

    def hasSufficientWords(self, language1File, parallelFile):
        """
        Check if the given file contains more words than the threshold
        """
        
        if language1File.getWordCount() is not None and float(language1File.getWordCount()) > 30 and parallelFile.getWordCount() is not None and float(parallelFile.getWordCount()) > 30 :
            return True
        else:
            PrintFrame(u'Too few words ' + language1File.getName() + ' ' + language1File.getWordCount() + ' ' + parallelFile.getName() + ' ' + parallelFile.getWordCount())
            self.addTooFewWords(language1File.getName(), parallelFile.getName())
            return False
            
    def addTooFewWords(self, name1, name2):
        """
        Add the file names of the files with to few words
        """
        self.tooFewWords.append(name1 + ' ' + name2)
        
    def hasSufficientRatio(self, file1, file2):
        """
        See if the ratio of words is good enough
        """
        
        ratio = float(file1.getWordCount())/float(file2.getWordCount())*100
        
        if ratio > float(self.minratio) and ratio < float(self.maxratio):
            return True
        else:
            self.addPoorRatio(file1.getName(), file2.getName(), ratio)
            return False
            
    def addPoorRatio(self, name1, name2, ratio):
        self.poorRatio.append(name1 + ',' + name2 + ',' + repr(ratio))

    def traverseFiles(self):
        """
        Go through all files
        """
        for language1File in self.findLang1Files():
            print('.', end='')
            
            if self.hasParallel(language1File):
                
                parallelFile = parallelize.CorpusXMLFile(language1File.getParallelFilename(), language1File.getLang())
                
                PrintFrame(language1File.getName() + ' ' + language1File.getWordCount())
                PrintFrame(parallelFile.getName() + ' ' + parallelFile.getWordCount())
                
                if self.hasSufficientWords(language1File, parallelFile) and \
                self.hasSufficientRatio(language1File, parallelFile):
                        
                        if parallelFile.getTranslatedFrom() == language1File.getLang() and language1File.getTranslatedFrom() == self.parallelLanguage:
                            print ("Both files claim to be translations of the other")
                                
                        elif language1File.getTranslatedFrom() == self.parallelLanguage or parallelFile.getTranslatedFrom() == language1File.getLang():
                            #self.addFilePair(language1File, parallelFile)
                            
                            if self.validDiff(language1File, parallelFile.getLang()):
                                self.copyFile(language1File)
                            
                            if self.validDiff(parallelFile, language1File.getLang()):
                                self.copyFile(parallelFile)
                                
                        else:
                            print ("None of the files are translations of the other", language1File.getName(), parallelFile.getName())
                        
                    
    def validDiff(self, convertedFile, parallelLanguage):
        """
        Check if there are differences between the files in
        converted and prestable/converted
        """
        
        isValidDiff = True
        
        prestableFilename = convertedFile.getName().replace('converted/', 'prestable/converted/')
        
        if os.path.isfile(prestableFilename):
            prestableFile = parallelize.CorpusXMLFile(prestableFilename, parallelLanguage)
            
            prestableFile.removeVersion()
            convertedFile.removeVersion()
            
            # checkDiff sets isValidDiff either True or False
            PrintFrame(convertedFile.getName())
            PrintFrame(prestableFile.getName())
            isValidDiff = self.checkDiff(convertedFile.geteTree(), prestableFile.geteTree())
            
        return isValidDiff
            
    def checkDiff(self, eTree1, eTree2):
        """
            Return true if there is a difference between the
            content of eTree1 and eTree2
        """
        doc1 = etree.tostring(eTree1)
        doc2 = etree.tostring(eTree2)

        checker = doctestcompare.LXMLOutputChecker()
        
        if not checker.check_output(doc1, doc2, 0):
            return True
        else:
            return False
        
    def copyFile(self, xmlFile):
        """
        Copy xmlFile to prestable/converted
        """
        prestableDir = xmlFile.getDirname().replace('converted/', 'prestable/converted/')
        
        if not os.path.isdir(prestableDir):
            try:
                os.makedirs(prestableDir)
            except os.error:
                print ("couldn't make", prestableDir)
                
        shutil.copy(xmlFile.getName(), prestableDir)
    
def parseOptions():
    parser = argparse.ArgumentParser(description = 'Pick out parallel files from converted to prestable/converted.')
    
    parser.add_argument('language1Dir', help = "directory where the files of language1 exist")
    parser.add_argument('-p', '--parallelLanguage', dest = 'parallelLanguage', help = "The language where we would like to find parallel documents", required = True)
    parser.add_argument('--minratio', dest = 'minratio', help = "The minimum ratio", required = True)
    parser.add_argument('--maxratio', dest = 'maxratio', help = "The maximum ratio", required = True)
    
    args = parser.parse_args()
    return args

def main():
    args = parseOptions()
    
    language1Dir = args.language1Dir
    parallelLanguage = args.parallelLanguage
    minratio = args.minratio
    maxratio = args.maxratio
    
    pp = ParallelPicker(language1Dir, parallelLanguage, minratio, maxratio)
    pp.getOldFileNames()
    pp.traverseFiles()
    
if __name__ == '__main__':
    main()