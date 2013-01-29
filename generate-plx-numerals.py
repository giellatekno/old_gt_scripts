#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os.path
import os
import shutil
import string
import sys

def generate_nums(lang, max_limit):
#	plxfile = open(os.path.join(os.getcwd(),lang + "/polderland/generated_nums-plx.txt"),"w")

#	if (lang == "sme"):
	for x in range(0,max_limit + 1):
		print(str(x) + '\t' + 'UIE')
		print(str(x) + '\t' + 'JuO')
		print(str(x) + '\t' + 'JuBX')
		print(str(x) + '--\t' + 'JuBX')
		print(str(x) + '--\t' + 'JuO')
		print('0' + str(x) + '\t' + 'UIE')
		print('0' + str(x) + '\t' + 'JuO')
		print('0' + str(x) + '\t' + 'JuBX')
		print('0' + str(x) + '--\t' + 'JuBX')
		print('0' + str(x) + '--\t' + 'JuO')
		print(str(x) + ':t' + '\t' + 'UIE')
		print(str(x) + ':sis' + '\t' + 'UIE')
		print(str(x) + ':siin' + '\t' + 'UIE')
		print(str(x) + ':sii' + '\t' + 'UIE')
		print(str(x) + ':sa' + '\t' + 'UIE')
		print(str(x) + ':s' + '\t' + 'UIE')
		print(str(x) + ':n' + '\t' + 'UIE')
		print(str(x) + ':in' + '\t' + 'UIE')
		print(str(x) + ':id' + '\t' + 'UIE')
		print(str(x) + ':i-guin' + '\t' + 'UIE')
		print(str(x) + ':i-de' + '\t' + 'UIE')
		print(str(x) + ':i' + '\t' + 'UIE')
		print(str(x) + ':dis' + '\t' + 'UIE')
		print(str(x) + ':din' + '\t' + 'UIE')
		print(str(x) + ':diin' + '\t' + 'UIE')
		print(str(x) + ':diid-da' + '\t' + 'UIE')
		print(str(x) + ':diid' + '\t' + 'UIE')
		print(str(x) + ':dii' + '\t' + 'UIE')
		print(str(x) + ':di-guin' + '\t' + 'UIE')
		print(str(x) + ':dat' + '\t' + 'UIE')
		print(str(x) + ':da' + '\t' + 'UIE')
#	else:
#		for x in range(1,max_limit + 1):
#			print(str(x) + '--\t' + 'NL\n')
#			print(str(x) + ':n' + '\t' + 'UIE\n')
#			print(str(x) + ':v' + '\t' + 'UIE\n')
#			print(str(x) + ':jv' + '\t' + 'UIE\n')
#			print(str(x) + ':jt' + '\t' + 'UIE\n')
#			print(str(x) + ':j' + '\t' + 'UIE\n')
#			print(str(x) + ':jda' + '\t' + 'UIE\n')
#			print(str(x) + ':js' + '\t' + 'UIE\n')
#			print(str(x) + ':jn' + '\t' + 'UIE\n')


#def usage():
#	print "This script generates numerals for compounding, like 10-feet."
#	print "It needs one arguments, the upper limit for the numerals"
#	print "The result is printed to the file $HOME/gt/$LANG/polderland/generated_nums-plx.txt"
#	print "Example:"
#	print '\t', "generate-plx-numerals.py smj 1000000"


def main():
	if (len(sys.argv) != 3):
		# print help information and exit:
		print ("\nToo few arguments\n")
#		usage()
		sys.exit(2)
	else:
		generate_nums(sys.argv[1], int(sys.argv[2]))
   
if __name__ == "__main__":
    main()
