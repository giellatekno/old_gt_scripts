#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os.path
import os
import shutil
import string
import sys

def generate_nums(lang, max_limit):
	plxfile = open(os.path.join(os.getcwd(),lang + "/polderland/generated_nums-plx.txt"),"w")

#	if (lang == "sme"):
	for x in range(1,max_limit + 1):
		plxfile.write(`x` + '--\t' + 'NL\n')
#			plxfile.write(`x` + ':i' + '\t' + 'UI\n')
#			plxfile.write(`x` + ':s' + '\t' + 'UI\n')
#			plxfile.write(`x` + ':in' + '\t' + 'UI\n')
#			plxfile.write(`x` + ':n' + '\t' + 'UI\n')
#			plxfile.write(`x` + ':id' + '\t' + 'UI\n')
#			plxfile.write(`x` + ':ide' + '\t' + 'UI\n')
#			plxfile.write(`x` + ':iguin' + '\t' + 'UI\n')
#	else:
#		for x in range(1,max_limit + 1):
#			plxfile.write(`x` + '--\t' + 'NL\n')
#			plxfile.write(`x` + ':n' + '\t' + 'UI\n')
#			plxfile.write(`x` + ':v' + '\t' + 'UI\n')
#			plxfile.write(`x` + ':jv' + '\t' + 'UI\n')
#			plxfile.write(`x` + ':jt' + '\t' + 'UI\n')
#			plxfile.write(`x` + ':j' + '\t' + 'UI\n')
#			plxfile.write(`x` + ':jda' + '\t' + 'UI\n')
#			plxfile.write(`x` + ':js' + '\t' + 'UI\n')
#			plxfile.write(`x` + ':jn' + '\t' + 'UI\n')


def usage():
	print "This script generates numerals for compounding, like '10-feet'."
	print "It needs one arguments, the upper limit for the numerals"
	print "The result is printed to the file $HOME/gt/$LANG/polderland/generated_nums-plx.txt"
	print "Example:"
	print '\t', "generate-plx-numerals.py smj 1000000"


def main():
	if (len(sys.argv) != 3):
		# print help information and exit:
		print "\nToo few arguments\n"
		usage()
		sys.exit(2)
	else:
		generate_nums(sys.argv[1], string.atoi(sys.argv[2]))
   
if __name__ == "__main__":
    main()
