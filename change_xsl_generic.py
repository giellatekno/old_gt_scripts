#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Written by Børre Gaup <borre.gaup@samediggi.no>

import sys
from lxml import etree

def usage():
	print 'This is a script that changes empty values in a corpus xsl file'
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
if (xsl_filename.rfind('.xsl') > 0):
	tree = etree.parse(xsl_filename)
	root = tree.getroot()
	for element in root.iter():
		for key, value in change_variables.iteritems():
			if element.attrib.get('name') == key:
				element.set('select', value)

	try:
		f = open(xsl_filename, 'w')
	except IOError:
		print 'cannot open', xsl_filename
		sys.exit(255)
	else:
		f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
		f.write(etree.tostring(root))
		f.write('\n')
		f.close()

else:
	print "This is not an xsl file: " + xsl_filename
	print
	usage()
