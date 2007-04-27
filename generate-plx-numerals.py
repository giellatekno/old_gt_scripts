#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os.path
import os
import shutil
import string
import sys

def generate_nums(max_limit):
	plxfile = open(os.path.join(os.getcwd(),"common/polderland/generated_nums-plx.txt"),"w")
	for x in range(1,max_limit + 1):
		# plxfile.write(`x` + '\t' + 'UIL\n')
		plxfile.write(`x` + '--\t' + 'NL\n')

def usage():
	print "This script generates numerals for compounding, like '10-feet'."
	print "It needs one arguments, the upper limit for the numerals"
	print "The result is printed to the file $HOME/gt/common/polderland/generated_nums-plx.txt"
	print "Example:"
	print '\t', "generate-plx-numerals.py smj 1000000"


def main():
	if (len(sys.argv) != 2):
		# print help information and exit:
		print "\nToo few arguments\n"
		usage()
		sys.exit(2)
	else:
		generate_nums(string.atoi(sys.argv[1]))
   
if __name__ == "__main__":
    main()
