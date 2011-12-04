#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import argparse

sys.path.append(os.getenv('GTHOME') + '/gt/script/langTools')
import parallelize


def usage():
    print 'This is a script that changes empty values in a corpus xsl file'
    print 'Call the program like this: change_xsl.py variable-value-pairs filename'
    print 'This requires an odd number of args to the script'
    print 'If a value contains a space, use "-chars around it.'
    print 'e.g. change_xsl_generic.py sub_name "Jens Kristensen" sub_email jens.kristensen@samediggi.no kraken.html.xsl'

def parse_options():
    parser = argparse.ArgumentParser(description='Sentence align two files. Input is the document containing the main language, and language to parallelize it with.')
    parser.add_argument('input_file', help="The input file")
    parser.add_argument('-p', '--parallel_language', dest='parallel_language', help="The language to parallelize the input document with", required = True)
    
    args = parser.parse_args()
    return args

def main():
    args = parse_options()
    parallelizer = parallelize.Parallelize(args.input_file, args.parallel_language)
    if parallelizer.dividePIntoSentences() == 0:
        if parallelizer.parallelizeFiles() == 0:
            parallelizer.printTmxFile(parallelizer.makeTmx())

if __name__ == "__main__":
    main()
