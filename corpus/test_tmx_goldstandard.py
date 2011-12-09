#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
sys.path.append(os.environ['GTHOME'] + '/gt/script/langTools')
import parallelize
import lxml.etree

def dateformat():
    import datetime
    import time
    d = datetime.datetime.fromtimestamp(time.time())
    
    return d.strftime("%Y%m%d-%H%M")

def main():
    dateformat()
    goldstandard = {}
    goldstandard['prestable/tmx/goldstandard/nob2sme/samisk_strategiplan_samisk.doc.tmx'] = 'prestable/tmx/sme2nob/admin/others/samisk_strategiplan_samisk.doc.tmx'
    goldstandard['prestable/tmx/goldstandard/nob2sme/dc_05_1.doc.tmx'] = 'prestable/tmx/sme2nob/admin/sd/other_files/dc_05_1.doc.tmx'
    goldstandard['prestable/tmx/goldstandard/nob2sme/finnmarkkulahka_web_lettere.pdf.tmx'] = 'prestable/tmx/sme2nob/laws/other_files/finnmarkkulahka_web_lettere.pdf.tmx'
    
    writer = parallelize.TmxTestDataWriter("meretesting")
    
    testrun = writer.makeTestrunElement(dateformat())
    
    for goldStandardFile, generatedFile in goldstandard.items():
        wantFile = os.path.join(os.environ['GTFREE'], goldStandardFile)
        gotFile = os.path.join(os.environ['GTFREE'], generatedFile)
        
        comparator = parallelize.TmxComparator(parallelize.Tmx(lxml.etree.parse(wantFile)), parallelize.Tmx(lxml.etree.parse(gotFile)))
        
        fileElement = writer.makeFileElement(wantFile, str(comparator.getLinesInWantedfile()), str(comparator.getNumberOfDifferingLines()))
        
        testrun.append(fileElement)
        
    writer.insertTestrunElement(testrun)
    
    writer.writeParagstestingData()
        
if __name__ == '__main__':
    main()
    