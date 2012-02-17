#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import argparse

sys.path.append(os.getenv('GTHOME') + '/gt/script/langTools')
import parallelize


def parse_options():
    parser = argparse.ArgumentParser(description = 'Sentence align two files. Input is the document containing the main language, and language to parallelize it with.')
    parser.add_argument('input_file', help = "The input file")
    parser.add_argument('-p', '--parallel_language', dest = 'parallel_language', help = "The language to parallelize the input document with", required = True)
    
    args = parser.parse_args()
    return args

def main():
    args = parse_options()
    parallelizer = parallelize.Parallelize(args.input_file, args.parallel_language)
    
    print "Aligning", args.input_file, "and it's parallel file"
    print "Adding sentence structure that tca2 needs ..."
    if parallelizer.dividePIntoSentences() == 0:
        print "Aligning files ..."
        if parallelizer.parallelizeFiles() == 0:
            tmx = parallelize.Tca2ToTmx(parallelizer.getFilelist())
            print "Generating the tmx file", tmx.getOutfileName()
            tmx.writeTmxFile(tmx.getOutfileName())

if __name__ == "__main__":
    main()
