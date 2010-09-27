#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Written by Børre Gaup <borre.gaup@samediggi.no>

import sys
import fileinput

def usage():
	print 'This is a script that changes empty values in an corpus xsl file'
	print 'Call the program like this: change_xsl.py variable-value-pairs filename'
	print 'This requires an odd number of args to the script'
	print 'If a value contains a space, use "-chars around it.'
	print 'e.g. change_xsl_generic.py sub_name "Jens Kristensen" sub_email jens.kristensen@samediggi.no kraken.html.xsl'

# check that there is exactly one argument given to the program
if ( len(sys.argv) % 2 ) != 0:
	usage()
	sys.exit()

# Initiate an empty dict
change_variables = {}

# read in the variable-value pairs, add them in the dict
for index in range(1, len(sys.argv) - 1, 2):
	change_variables[sys.argv[index]] = sys.argv[index + 1]

xsl_filename = sys.argv[len(sys.argv) - 1]
	
# Do an inline replacement of lines in the xsl file
for line in fileinput.FileInput(xsl_filename, inplace = 1):
	for key, value in change_variables.iteritems():
		if line.find('"' + key + '"') != -1:
			line = line.replace('\'\'', '\'' + value + '\'')
	print line
