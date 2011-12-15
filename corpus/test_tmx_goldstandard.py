#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import argparse
import lxml.etree

sys.path.append(os.environ['GTHOME'] + '/gt/script/langTools')
import parallelize

def parse_options():
    """
    Parse the command line. Expected input is one or more tmx goldstandard files.
    """
    parser = argparse.ArgumentParser(description = 'Compare goldstandard tmx files to files produced by the parallelizer pipeline.')
    
    args = parser.parse_args()
    return args

def main():
    args = parse_options()

    # Set the name of the file to write the test to
    paragstestfile = os.path.join(os.environ['GTHOME'], 'techdoc/ling/testruns.paragstesting.xml')
    
    # Initialize an instance of a tmx test data writer
    tester = parallelize.TmxGoldstandardTester(paragstestfile)
    tester.runTest()
    
if __name__ == '__main__':
    main()
    