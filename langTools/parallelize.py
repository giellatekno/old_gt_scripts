# -*- coding: utf-8 -*-
import os
import re
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
            print "adding sentences ..."
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
        return os.environ['GTFREE'] + '/tmp/' + origfilename + '_sent.xml'
        
    def parallelizeFiles(self):
        """
        Parallelize two files using tca2
        """
        print "parallelizing ..."
        anchorName = os.environ['GTFREE'] + '/anchor-' + self.getlang1() + self.getlang2() + '.txt'
        subp = subprocess.Popen(['tca2.sh', anchorName, self.getSentFilename(self.getorigfile1()), self.getSentFilename(self.getorigfile2())], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate()
            
        if subp.returncode != 0:
            print >>sys.stderr, 'Could not parallelize', self.getSentFilename(self.getorigfile1()), 'and', self.getSentFilename(self.getorigfile2()), ' into sentences'
            print >>sys.stderr, output
            print >>sys.stderr, error
            return subp.returncode
                
        return 0
        
        pass
    
    def makeTmx(self):
        """
        Make tmx file based on the two output files of tca2
        """
        print "making tmx file ..."
        tmx = etree.Element("tmx")
        header = self.makeTmxHeader(self.getlang1())
        tmx.append(header)
        
        pfile1_data = self.readTca2Output(self.getorigfile1())
        pfile2_data = self.readTca2Output(self.getorigfile2())

        body = etree.SubElement(tmx, "body")
        for line1, line2 in map(None, pfile1_data, pfile2_data):
            tu = self.makeTu(line1, line2)
            body.append(tu)
            
        return tmx
        
    def readTca2Output(self, pfile):
        """
        Read the output of tca2
        """
        pfileName = self.getSentFilename(pfile).replace('.xml', '_new.txt')
        f = open(pfileName, "r")
        text = f.readlines()
        f.close()
        
        return text
    
    def makeTu(self, line1, line2):
        """
        Make a tmx tu elemenent based on line1 and line2 as input
        """
        tu = etree.Element("tu")
        
        tu.append(self.makeTuv(line1, self.getlang1()))
        tu.append(self.makeTuv(line2, self.getlang2()))
        
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
        
    def printTmxFile(self, tmx):
        """
        Write a tmx file given a tmx etree element
        """
        print "printing tmx file..."
        outFilename = "/home/boerre/Dokumenter/corpus/freecorpus" + "/prestable/tmx/" + self.getlang1() + self.getlang2() + "/" + os.path.basename(self.getorigfile1()).replace('.xml', '.tmx')
        
        f = open(outFilename, "w")
        
        et = etree.ElementTree(tmx)
        et.write(f, pretty_print = True, encoding = "utf-8", xml_declaration = True)
        f.close()
        
        return outFilename
    
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
        
def main():
    p = Parallelize("/home/boerre/Dokumenter/corpus/freecorpus/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml", "nob")
    p.dividePIntoSentences()
    if p.parallelizeFiles() == 0:
        p.makeTmx()
    
if __name__ == '__main__':
    main()
