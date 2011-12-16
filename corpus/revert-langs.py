#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This program reverses the order of the langs in a tmx file
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with NickelsWebTranslator.  If not, see <http://www.gnu.org/licenses/>.
#
#   Copyright 2011 Børre Gaup <borre.gaup@uit.no>
#

import sys
import os
import argparse
import lxml.etree

sys.path.append(os.getenv('GTHOME') + '/gt/script/langTools')
import parallelize

def parse_options():
    parser = argparse.ArgumentParser(description = 'Reverse the order of the langs in a tmx file. Print the output to stdout')
    parser.add_argument('input_file', help = "The input file")
    
    args = parser.parse_args()
    return args

def main():
    args = parse_options()
    parallelizer = parallelize.Tmx(lxml.etree.parse(args.input_file))
    parallelizer.reverseLangs()

if __name__ == "__main__":
    main()
