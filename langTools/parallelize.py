#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import sys
import subprocess
from lxml import etree

class ParallelFile:
    """
    A class that contains the info on a file to be parallellized, name and language
    """
    
    def __init__(self):
        self.name = None
        self.lang = None
        
    def setName(self, name):
        self.name = name
        
    def getName(self):
        return self.name
        
    def setLang(self, lang):
        self.lang = lang
        
    def getLang(self):
        return self.lang
        
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
        self.origfile1Tree = etree.parse(origfile1)
        
        tmpfile = ParallelFile()
        tmpfile.setName(os.path.abspath(origfile1))
        tmpfile.setLang(self.origfile1Tree.getroot().attrib['{http://www.w3.org/XML/1998/namespace}lang'])
        self.origfiles.append(tmpfile)
        
        tmpfile = ParallelFile()
        tmpfile.setLang(lang2)
        self.origfiles.append(tmpfile)
        self.origfiles[1].setName(self.setOrigfile2Name())
        
        

    def getlang1(self):
        return self.origfiles[0].getLang()
        
    def getlang2(self):
        return self.origfiles[1].getLang()
        
    def getorigfile1(self):
        return self.origfiles[0].getName()
        
    def getorigfile2(self):
        return self.origfiles[1].getName()
    
    def findParallelFilename(self):
        """
        Find the name of the parallel file to the original input file
        """
        root = self.origfile1Tree.getroot()
        parallelFiles = root.findall(".//parallel_text")
        for p in parallelFiles:
            if p.attrib['{http://www.w3.org/XML/1998/namespace}lang'] == self.getlang2():
                return p.attrib['location']
        
    def parallelizeText(self):
        parseOrigFile()
        pass

    def setOrigfile2Name(self):
        """
        Infer the path of the second file
        """
        return os.path.dirname(self.getorigfile1()).replace('/' + self.getlang1() + '/', '/' + self.getlang2() + '/') + '/' + self.findParallelFilename() + '.xml'
    
    def dividePIntoSentences(self):
        """
        Call corpus-analyse.pl which reads an xml file and makes it palatable for tca2
        """
        for pfile in self.origfiles:
            subp = subprocess.Popen(['corpus-analyze.pl', '--all', '--only_add_sentences', '--output=' + self.getSentFilename(pfile.getName()), '--lang=' + pfile.getLang(), pfile.getName()], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
            (output, error) = subp.communicate()
            
            if subp.returncode != 0:
                print >>sys.stderr, 'Could not divide ', pfile.getName(), ' into sentences'
                print >>sys.stderr, output
                print >>sys.stderr, error
                return subp.returncode
                
        return 0

    def getSentFilename(self, file):
        """
        Compute a name for the corpus-analyze output and tca2 input file
        """
        origfilename = os.path.basename(file).replace('.xml', '')
        return '/home/boerre/Dokumenter/corpus/freecorpus' + '/tmp/' + origfilename + '_sent.xml'
        
    def parallelizeFiles(self):
        """
        Parallelize two files using tca2
        """
        anchorName = '/home/boerre/Dokumenter/corpus/freecorpus/' + 'anchor-' + self.getlang1() + self.getlang2() + '.txt'
        subp = subprocess.Popen(['tca2.sh', anchorName, self.getorigfile1(), self.getorigfile2()], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate()
            
        if subp.returncode != 0:
            print >>sys.stderr, 'Could not parallelize', self.getorigfile1(), 'and', self.getorigfile2(), ' into sentences'
            print >>sys.stderr, output
            print >>sys.stderr, error
            return subp.returncode
                
        return 0
        
        pass
    
    def makeTmx(self):
        pass
    
    def calculateBase(self):
        pass
    
    def readTca2Output(self):
        pass
    
    def makeTuv(self):
        pass
    
    def printTmxFile(self):
        pass
    
    def printTmxHeader(self):
        pass

def main():
    p = Parallelize("/home/boerre/Dokumenter/corpus/freecorpus/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml", "sme", "nob")
    p.findParallelFilename()
    
    u = Urga("hirra")
    print u.getName()
    
if __name__ == '__main__':
    main()
