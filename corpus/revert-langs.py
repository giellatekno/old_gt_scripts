#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import argparse
import lxml.etree

sys.path.append(os.getenv('GTHOME') + '/gt/script/langTools')
import parallelize

def parse_options():
    parser = argparse.ArgumentParser(description = 'Reverse the order of the langs in a tmx file.')
    parser.add_argument('input_file', help = "The input file")
    
    args = parser.parse_args()
    return args

def main():
    args = parse_options()
    parallelizer = parallelize.Tmx(lxml.etree.parse(args.input_file))
    parallelizer.reverseLangs()

if __name__ == "__main__":
    main()
