# -*- coding: utf-8 -*-
import os
import re
import sys
import subprocess
import difflib
from lxml import etree

class ParallelFile:
    """
    A class that contains the info on a file to be parallellized, name and language
    """
    
    def __init__(self):
        self.name = None
        self.dirname = None
        self.base = None
        self.lang = None
        
    def setName(self, name):
        """
        Expects a absolute path to a files
        """
        self.name = name
        self.base = os.path.basename(name)
        self.dirname = os.path.dirname(name)
        
    def getName(self):
        return self.name
        
    def getDirname(self):
        return self.dirname
        
    def getBasename(self):
        return self.base
        
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
        
        if self.isTranslatedFromLang2():
            self.reshuffleFiles()
            
    def reshuffleFiles(self):
        """
        Change the order of the files (so that the translated text is last)
        """
        tmp = self.origfiles[0]
        self.origfiles[0] = self.origfiles[1]
        self.origfiles[1] = tmp
        
    def getFilelist(self):
        """
        Return the list of (the two) files that are aligned
        """
        return self.origfiles

    def getlang1(self):
        return self.origfiles[0].getLang()
        
    def getlang2(self):
        return self.origfiles[1].getLang()
        
    def getorigfile1(self):
        return os.path.join(self.origfiles[0].getDirname(), self.origfiles[0].getName())
        
    def getorigfile2(self):
        return os.path.join(self.origfiles[1].getDirname(), self.origfiles[1].getName())
    
    def isTranslatedFromLang2(self):
        """
        Find out if the given doc is translated from lang2
        """
        result = False
        root = self.origfile1Tree.getroot()
        translated_from = root.find(".//translated_from")
        if translated_from is not None:
            if translated_from.attrib['{http://www.w3.org/XML/1998/namespace}lang'] == self.getlang2():
                result = True

        return result
    
        
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
    
    def generateAnchorFile(self):
        """
        Generate an anchor file with lang1 and lang2. Return the path to the anchor file
        """
        infile1 = os.path.join(os.environ['GTHOME'], 'gt/common/src/anchor.txt')
        infile2 = os.path.join(os.environ['GTHOME'], 'gt/common/src/anchor-admin.txt')
        
        subp = subprocess.Popen(['generate-anchor-list.pl', '--lang1=' + self.getlang1(), '--lang2' + self.getlang2(), '--outdir=' + os.environ['GTFREE'], infile1, infile2], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate()
        
        if subp.returncode != 0:
            print >>sys.stderr, 'Could not generate ', pfile.getName(), ' into sentences'
            print >>sys.stderr, output
            print >>sys.stderr, error
            return subp.returncode

        # Return the absolute path of the resulting file
        outFilename = 'anchor-' + self.getlang1() + self.getlang2() + '.txt'
        return os.path.join(os.environ['GTFREE'], outFilename)
        
    def dividePIntoSentences(self):
        """
        Call corpus-analyse.pl which reads an xml file and makes it palatable for tca2
        """
        for pfile in self.origfiles:
            infile = os.path.join(pfile.getName())
            if os.path.exists(infile):
                outfile = self.getSentFilename(pfile)
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

    def getSentFilename(self, pfile):
        """
        Compute a name for the corpus-analyze output and tca2 input file
        Input is a ParallelFile
        """
        origfilename = pfile.getBasename().replace('.xml', '')
        return os.environ['GTFREE'] + '/tmp/' + origfilename + pfile.getLang() + '_sent.xml'
        
    def parallelizeFiles(self):
        """
        Parallelize two files using tca2
        """
        anchorName = self.generateAnchorFile()
        subp = subprocess.Popen(['tca2.sh', anchorName, self.getSentFilename(self.getFilelist()[0]), self.getSentFilename(self.getFilelist()[1])], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate()
            
        if subp.returncode != 0:
            print >>sys.stderr, 'Could not parallelize', self.getSentFilename(self.getorigfile1()), 'and', self.getSentFilename(self.getorigfile2()), ' into sentences'
            print >>sys.stderr, output
            print >>sys.stderr, error
            return subp.returncode
                
        return 0

class Tmx:
    """
    A class that reads a tmx file, and implements a bare minimum of functionality
    to be able to compare two tmx'es
    """
    
    def __init__(self, tmx):
        self.tmx = tmx
        
    def getTmx(self):
        """
        Get the tmx xml element
        """
        return self.tmx
        
    def tuToString(self, tu):
        """
        Extract the two strings of a tu element
        """
        string = ""
        try:
            string = string + tu[0][0].text.strip()
        except(AttributeError):
            pass
            
        string += '\t'
        
        try:
            string = string + tu[1][0].text.strip()
        except(AttributeError):
            pass
        
        string += '\n'
        return string.encode('utf-8')
    
    def tuvToString(self, tuv):
        """
        Extract the string from the tuv element
        """
        string = ""
        try:
            string = tuv[0].text.strip()
        except(AttributeError):
            pass
        
        return string.encode('utf-8')
        
    def langToStringlist(self, lang):
        """
        """
        all_tuv = self.getTmx().xpath('.//tuv[@xml:lang="' + lang + '"]',
            namespaces={'xml':'http://www.w3.org/XML/1998/namespace'})

        strings = []
        for tuv in all_tuv:
            strings.append(self.tuvToString(tuv))
        
        return strings
    
    def tmxToStringlist(self):
        """
        Extract all string pairs in a tmx to a list of strings
        """
        all_tu = self.getTmx().findall('.//tu')
        strings = []
        for tu in all_tu:
            strings.append(self.tuToString(tu))
        
        return strings
        
    def prettifySegs(self, tu):
        """
        Input is a tu-element
        """
        try:
            string = tu[0][0].text.strip()
            tu[0][0].text = string
        except(AttributeError):
            pass
            
        try:
            string = tu[1][0].text.strip()
            tu[1][0].text = string
        except(AttributeError):
            pass
        
        return tu
        
    def reverseLangs(self):
        """
        Reverse the langs in a tmx
        """
        all_tu = self.getTmx().findall('.//tu')
        body = etree.Element('body')
        for tu in all_tu:
            tmp = etree.Element('tu')
            tmp.append(tu[1])
            tmp.append(tu[0])
            tmp = self.prettifySegs(tmp)
            body.append(tmp)
        
        tmx = etree.Element('tmx')
        tmx.append(body)
        
        self.tmx = tmx
        et = etree.ElementTree(self.tmx)
        et.write(sys.stdout, pretty_print = True, encoding = "utf-8", xml_declaration = True)
        
class TmxFromTca2(Tmx):
    """
    A class to make tmx files based on the output from tca2
    """
    def __init__(self, filelist):
        """
        Input is a list of ParallelFile objects
        """
        self.filelist = filelist
        Tmx.__init__(self, self.setTmx())
    
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
        outFilename = self.filelist[0].getBasename().replace('.xml', '.tmx')

        return os.path.join(outDirname, outFilename)
        
    def printTmxFile(self):
        """
        Write a tmx file given a tmx etree element
        """
        outFilename = self.getOutfileName()
        
        try:
            f = open(outFilename, "w")
            
            et = etree.ElementTree(self.getTmx())
            et.write(f, pretty_print = True, encoding = "utf-8", xml_declaration = True)
            f.close()
        except IOError:
            print "ouch, printTmxFile"
        
        return outFilename
    
    def setTmx(self):
        """
        Make tmx file based on the two output files of tca2
        """
        tmx = etree.Element("tmx")
        header = self.makeTmxHeader(self.filelist[0].getLang())
        tmx.append(header)
        
        pfile1_data = self.readTca2Output(self.filelist[0])
        pfile2_data = self.readTca2Output(self.filelist[1])

        body = etree.SubElement(tmx, "body")
        for line1, line2 in map(None, pfile1_data, pfile2_data):
            tu = self.makeTu(line1, line2)
            body.append(tu)
            
        return tmx
        
    def readTca2Output(self, pfile):
        """
        Read the output of tca2
        Input is a ParallelFile
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
    

    def getSentFilename(self, pfile):
        """
        Compute a name for the corpus-analyze output and tca2 input file
        Input is a ParallelFile
        """
        origfilename = pfile.getBasename().replace('.xml', '')
        return os.environ['GTFREE'] + '/tmp/' + origfilename + pfile.getLang() + '_sent.xml'
        
        
        
class TmxComparator:
    """
    A class to compare two tmx-files
    """
    def __init__(self, wantTmx, gotTmx):
        self.wantTmx = wantTmx
        self.gotTmx = gotTmx
        
        
    def getLinesInWantedfile(self):
        """
        Return the number of lines in the reference doc
        """
        return len(self.wantTmx.tmxToStringlist())
        
            
    def getNumberOfDifferingLines(self):
        """
        Given a unified_diff, find out how many lines in the reference doc
        differs from the doc to be tested. A return value of -1 means that
        the docs are equal
        """
        # Start at -1 because a unified diff always starts with a --- line
        numDiffLines = -1
        for line in difflib.unified_diff(self.wantTmx.tmxToStringlist(), self.gotTmx.tmxToStringlist(), n = 0):
            if line[:1] == '-':
                numDiffLines += 1
        
        return numDiffLines
        
    def getDiffAsText(self):
        """
        Return a stringlist containing the diff lines
        """
        diff = []
        for line in difflib.unified_diff(self.wantTmx.tmxToStringlist(), self.gotTmx.tmxToStringlist(), n = 0):
            diff.append(line)
          
        return diff
        
    def getLangDiffAsText(self, lang):
        """
        Return a stringlist containing the diff lines
        """
        diff = []
        for line in difflib.unified_diff(self.wantTmx.langToStringlist(lang), self.gotTmx.langToStringlist(lang), n = 0):
            diff.append(line)
          
        return diff
        
        

class TmxTestDataWriter():
    """
    A class that writes tmx test data to a file
    """
    def __init__(self, filename):
        self.filename = filename
        
        try:
            tree = etree.parse(filename)
            self.setParagsTestingElement(tree.getroot())
        except IOError:
            self.setParagsTestingElement(self.makeParagstestingElement())
        except etree.XMLSyntaxError:
            self.setParagsTestingElement(self.makeParagstestingElement())
        
    def makeFileElement(self, name, gspairs, diffpairs):
        """
        Make the element file, set the attributes
        """
        fileElement = etree.Element("file")
        fileElement.attrib["name"] = name
        fileElement.attrib["gspairs"] = gspairs
        fileElement.attrib["diffpairs"] = diffpairs
        
        return fileElement
        
    def setParagsTestingElement(self, paragstesting):
        self.paragstesting = paragstesting
        
    def makeTestrunElement(self, datetime):
        """
        Make the testrun element, set the attribute
        """
        testrunElement = etree.Element("testrun")
        testrunElement.attrib["datetime"] = datetime
        
        return testrunElement
    
    def makeParagstestingElement(self):
        """
        Make the paragstesting element
        """
        paragstestingElement = etree.Element("paragstesting")
        
        return paragstestingElement
    
    def insertTestrunElement(self, testrun):
        self.paragstesting.insert(0, testrun)
        
    def writeParagstestingData(self):
        """
        Write the paragstesting data to a file
        """
        try:
            f = open(self.filename, "w")
            
            et = etree.ElementTree(self.paragstesting)
            et.write(f, pretty_print = True, encoding = "utf-8", xml_declaration = True)
            f.close()
        except IOError:
            print "ouch, Paragstestingresults"
        
class TmxGoldstandardTester:
    """
    A class to test the alignment pipeline againt the tmx goldstandard
    """
    def __init__(self, testresult_filename):
        """
        Set the name where the testresults should be written
        Find all goldstandard tmx files
        """
        self.testresultWriter = TmxTestDataWriter(testresult_filename)
        self.date = self.dateformat()
        
    def dateformat(self):
        """
        Get the date and time, 20111209-1234. Used in a testrun element
        """
        import datetime
        import time
        d = datetime.datetime.fromtimestamp(time.time())
        
        return d.strftime("%Y%m%d-%H%M")

    def runTest(self):
        # Make a testrun element, which will contain the result of the test
        testrun = self.testresultWriter.makeTestrunElement(self.date)
        
        paralang = ""
        # Go through each tmx goldstandard file
        for wantTmxFile in self.findGoldstandardTmxFiles():
            print "testing", wantTmxFile, "..."
            
            # Calculate the parallel lang, to be used in parallelization
            if wantTmxFile.find('nob2sme') > -1:
                paralang = 'sme'
            else:
                paralang = 'nob'
                
            # Compute the name of the main file to parallelize
            xmlFile = wantTmxFile.replace('tmx/goldstandard/', 'converted/')
            xmlFile = xmlFile.replace('nob2sme', 'nob')
            xmlFile = xmlFile.replace('sme2nob', 'sme')
            xmlFile = xmlFile.replace('.tmx', '.xml')
            
            # Align files
            parallelizer = Parallelize(xmlFile, paralang)
            if parallelizer.dividePIntoSentences() == 0:
                if parallelizer.parallelizeFiles() == 0:
                    
                    # The result of the alignment is a tmx element
                    gotTmx = TmxFromTca2(parallelizer.getFilelist())
            
                    # This is the tmx element fetched from the goldstandard file
                    wantTmx = Tmx(etree.parse(wantTmxFile))
                    
                    # Instantiate a comparator with the two tmxes
                    comparator = TmxComparator(wantTmx, gotTmx)
            
                    # Make a fileElement for our results file
                    fileElement = self.testresultWriter.makeFileElement(parallelizer.getorigfile1(), str(comparator.getLinesInWantedfile()), str(comparator.getNumberOfDifferingLines()))
                    
                    # Append the result for this file to the testrun element
                    testrun.append(fileElement)
                    
                    self.writeDiffFiles(comparator, parallelizer)
        
        # All files have been tested, insert this run at the top of the paragstest element
        self.testresultWriter.insertTestrunElement(testrun)
        # Write data to file
        self.testresultWriter.writeParagstestingData()

    def writeDiffFiles(self, comparator, parallelizer):
        """
        Write diffs to a jspwiki file
        """
        filename = parallelizer.getorigfile1() + '_' + self.date + '.jspwiki'
        dirname = os.path.join(os.environ['GTHOME'], 'techdoc/ling')
        try:
            f = open(os.path.join(dirname, filename), "w")
        except IOError:
            print "couldn't write file", os.path.join(dirname, filename)
            sys.exit(4)
        
        f.write('!!!' + parallelizer.getorigfile1() + '\n')
        
        f.write("!!TMX diff\n")
        f.writelines(comparator.getDiffAsText())

        f.write(parallelizer.getlang1() + " diff\n")
        f.writelines(comparator.getLangDiffAsText(parallelizer.getlang1()))
        
        f.write(parallelizer.getlang2() + " diff\n")
        f.writelines(comparator.getLangDiffAsText(parallelizer.getlang2()))

        f.close()
        
    def findGoldstandardTmxFiles(self):
        """
        Find the goldstandard tmx files, return them as a list
        """
        subp = subprocess.Popen(['find', os.path.join(os.environ['GTFREE'], 'prestable/tmx/goldstandard'), '-name', '*.tmx', '-print' ], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate()

        if subp.returncode != 0:
            print >>sys.stderr, 'Could not compile tca2'
            print >>sys.stderr, error
            sys.exit(1)
        else:
            files = output.split('\n')
            return files[:-1]
