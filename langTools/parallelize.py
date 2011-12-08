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
        self.dirname = None
        self.lang = None
        
    def setName(self, name):
        """
        Expects a absolute path to a files
        """
        self.name = os.path.basename(name)
        self.dirname = os.path.dirname(name)
        
    def getName(self):
        return self.name
        
    def getDirname(self):
        return self.dirname
        
    def setLang(self, lang):
        self.lang = lang
        
    def getLang(self):
        return self.lang

class Tmx:
    """
    A class to make tmx files based on the output from tca2
    and to compare two tmx files
    """
    def __init__(self, filelist):
        """
        Input is a list of ParallelFile objects
        """
        self.filelist = filelist
    
    def makeTu(self, line1, line2):
        """
        Make a tmx tu elemenent based on line1 and line2 as input
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
        outFilename = self.filelist[0].getName().replace('.xml', '.tmx')

        return os.path.join(outDirname, outFilename)
        
    def printTmxFile(self, tmx):
        """
        Write a tmx file given a tmx etree element
        """
        outFilename = self.getOutfileName()
        
        try:
            f = open(outFilename, "w")
            
            et = etree.ElementTree(tmx)
            et.write(f, pretty_print = True, encoding = "utf-8", xml_declaration = True)
            f.close()
        except:
            print "ouch, printTmxFile"
        
        return outFilename
    
    def makeTmx(self):
        """
        Make tmx file based on the two output files of tca2
        """
        tmx = etree.Element("tmx")
        header = self.makeTmxHeader(self.filelist[0].getLang())
        tmx.append(header)
        
        pfile1_data = self.readTca2Output(os.path.join(self.filelist[0].getDirname(), self.filelist[0].getName()))
        pfile2_data = self.readTca2Output(os.path.join(self.filelist[1].getDirname(), self.filelist[1].getName()))

        body = etree.SubElement(tmx, "body")
        for line1, line2 in map(None, pfile1_data, pfile2_data):
            tu = self.makeTu(line1, line2)
            body.append(tu)
            
        return tmx
        
    def readTca2Output(self, pfile):
        """
        Read the output of tca2
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
    

    def tuToString(self, tu):
        """
        Extract the two strings of a tu element
        """
        string = ""
        try:
            string = string + tu[0][0].text.strip()
        except(AttributeError):
            pass
            
        string = string + "\t"
        
        try:
            string = string + tu[1][0].text.strip()
        except(AttributeError):
            pass
        
        return string.encode('utf-8')
        
    def tmxToStringlist(self, tmx):
        """
        Extract all string pairs in a tmx to a list of strings
        """
        all_tu = tmx.findall('.//tu')
        strings = []
        for tu in all_tu:
            strings.append(self.tuToString(tu))
        
        return strings
        
    def getSentFilename(self, file):
        """
        Compute a name for the corpus-analyze output and tca2 input file
        """
        origfilename = os.path.basename(file).replace('.xml', '')
        return os.environ['GTFREE'] + '/tmp/' + origfilename + '_sent.xml'
        
        
class TmxComparator:
    """
    A class to compare two tmx-files
    """
    def diffOfTmxes(self, gotTmx, wantTmx):
        """
        Find the diff of two tmx elements
        """
        gotStrings = self.tmxToStringlist(gotTmx)
        wantStrings = self.tmxToStringlist(wantTmx)
        
        return difflib.context_diff(gotStrings, wantStrings, n = 0)
            
    def writeDiffFile(self, contextDiff):
        """
        Given a context_diff, write it and some info to a file
        """
        diff = []
        numDiffs = -1
        numDiffLines = 0
        for line in contextDiff:
            if line[:3] == '---':
                numDiffs += 1
            if line[:1] == '!':
                numDiffLines += 1
            diff.append(line + '\n')
            
        f = open('diff.txt', 'w')
        
        f.write('Number of diffs ' + str(numDiffs) + '\n')
        f.write('Number of lines in the diff ' + str(numDiffLines) + '\n\n')
        f.writelines(diff)
        f.close()
        
    
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
        
    def getFilelist(self):
        return self.origfiles

    def getlang1(self):
        return self.origfiles[0].getLang()
        
    def getlang2(self):
        return self.origfiles[1].getLang()
        
    def getorigfile1(self):
        return os.path.join(self.origfiles[0].getDirname(), self.origfiles[0].getName())
        
    def getorigfile2(self):
        return os.path.join(self.origfiles[1].getDirname(), self.origfiles[1].getName())
    
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
            infile = os.path.join(pfile.getDirname(), pfile.getName())
            if os.path.exists(infile):
                outfile = self.getSentFilename(infile)
                subp = subprocess.Popen(['corpus-analyze.pl', '--all', '--only_add_sentences', '--output=' + outfile, '--lang=' + pfile.getLang(), infile], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
                (output, error) = subp.communicate()
                
                if subp.returncode != 0:
                    print >>sys.stderr, 'Could not divide ', pfile.getName(), ' into sentences'
                    print >>sys.stderr, output
                    print >>sys.stderr, error
                    return subp.returncode
            else:
                print >>sys.stderr, infile, "doesn't exist"
                return 2
                    
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
    
def main():
    p = Parallelize("/home/boerre/Dokumenter/corpus/freecorpus/prestable/converted/sme/facta/skuvlahistorja2/aarseth2-s.htm.xml", "nob")
    p.dividePIntoSentences()
    if p.parallelizeFiles() == 0:
        p.makeTmx()
    
if __name__ == '__main__':
    main()
