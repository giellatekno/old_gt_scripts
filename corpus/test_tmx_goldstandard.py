#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import argparse
import lxml.etree

sys.path.append(os.environ['GTHOME'] + '/gt/script/langTools')
import parallelize

def dateformat():
    """
    Get the date and time, 20111209-1234. Used in a testrun element
    """
    import datetime
    import time
    d = datetime.datetime.fromtimestamp(time.time())
    
    return d.strftime("%Y%m%d-%H%M")

def parse_options():
    """
    Parse the command line. Expected input is one or more tmx goldstandard files.
    """
    parser = argparse.ArgumentParser(description = 'Compare goldstandard tmx files to files produced by the parallelizer pipeline.')
    parser.add_argument('input_files', help = "The goldstandard tmx file(s)", metavar="filename", nargs="+" )
    
    args = parser.parse_args()
    return args

def main():
    # Get the filenames to test
    args = parse_options()

    # Set the name of the file to write the test to
    paragstestfile = os.path.join(os.environ['GTHOME'], 'techdoc/ling/testruns.paragstesting.xml')
    
    # Initialize an instance of a tmx test data writer
    writer = parallelize.TmxTestDataWriter(paragstestfile)
    
    # Make a testrun element, which will contain the result of the test
    testrun = writer.makeTestrunElement(dateformat())
    
    paralang = ""
    
    # Go through each tmx goldstandard file
    for wantTmxFile in args.input_files:
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
        parallelizer = parallelize.Parallelize(xmlFile, paralang)
        if parallelizer.dividePIntoSentences() == 0:
            if parallelizer.parallelizeFiles() == 0:
                
                # The result of the alignment is a tmx element
                gotTmx = parallelize.TmxFromTca2(parallelizer.getFilelist())
        
                # This is the tmx element fetched from the goldstandard file
                wantTmx = parallelize.Tmx(lxml.etree.parse(wantTmxFile))
                
                # Instantiate a comparator with the two tmxes
                comparator = parallelize.TmxComparator(wantTmx, gotTmx)
        
                # Make a fileElement for our results file
                fileElement = writer.makeFileElement(wantTmxFile, str(comparator.getLinesInWantedfile()), str(comparator.getNumberOfDifferingLines()))
                
                print "The tmx diff is"
                for line in comparator.getDiffAsText():
                    print line
        
                print "The diff for", parallelizer.getlang1(), "is"
                for line in comparator.getLangDiffAsText(parallelizer.getlang1()):
                    print line
                
                print "The diff for", parallelizer.getlang2(), "is"
                for line in comparator.getLangDiffAsText(parallelizer.getlang2()):
                    print line
                
                # Append the result for this file to the testrun element
                testrun.append(fileElement)
    
    # All files have been tested, insert this run at the top of the paragstest element
    writer.insertTestrunElement(testrun)
    
    # Write data to file
    writer.writeParagstestingData()
        
if __name__ == '__main__':
    main()
    