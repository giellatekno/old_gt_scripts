#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os.path
import shutil
import string
import sys

def generate_nums(lang,max_limit):
	plxfile = open(os.path.join(os.path.expanduser("~"),"gt/" + lang + "/polderland/generated_nums-" + lang + "-plx.txt"),"w")
	for x in range(1,max_limit + 1):
		plxfile.write(`x` + '\t' + 'UI\n')
		plxfile.write(`x` + '-' + '\t' + 'UL\n')

def usage():
	print "This script generates numerals."
	print "It needs two arguments, the language, which can be sme or smj"
	print "and the upper limit for the numerals"
	print "The result is printed to the file $HOME/gt/<lang>/polderland/generated_nums-<lang>-plx.txt"
	print "Examples:"
	print '\t', "generate-plx-numerals.py sme 1000"
	print '\t', "generate-plx-numerals.py smj 1000000"


def main():
	if (len(sys.argv) != 3):
		# print help information and exit:
		print "\nToo few arguments\n"
		usage()
		sys.exit(2)
	if (sys.argv[1] != 'sme'):
		# print help information and exit:
		print "\nWrong language, has to be either sme or smj\n"
		usage()
		sys.exit(2)
	if (sys.argv[1] != 'smj'):
		# print help information and exit:
		print "\nWrong language, has to be either sme or smj\n"
		usage()
		sys.exit(2)
	else:
		generate_nums(sys.argv[1], string.atoi(sys.argv[2]))
   
if __name__ == "__main__":
    main()
