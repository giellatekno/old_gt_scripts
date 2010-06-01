#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import fileinput

def usage():
	print "Call the program like this: change_xsl.py <integer>"

# check that there is exactly one argument given to the program
if len(sys.argv) != 2:
	usage()
	sys.exit()
	
file_number=sys.argv[1]

# Check that the argument is indeed an integer
try:
	int(file_number)
except ValueError:
	usage()
	sys.exit()

# Initiate a dict with the "static" values
change_variables = { 'sub_name': 'Børre Gaup', 'sub_email': 'borre.gaup@samediggi.no', 'licence_type': 'standard', 'mainlang': 'sme', 'publisher': 'Ávvir', 'publChannel': 'http://avvir.no' }

# Set the filename
change_variables['filename'] = 'http://avvir.no/feed.php?news=' + sys.argv[1] + '&output_type=txt'

orig_file = open('avvir-article-' + sys.argv[1] + '.txt', 'r')

index = 0
words = 0

prev_line = ''

# Count the words in the file
for line in orig_file:
	# Set the title
	if index == 0:
			change_variables['title'] = line.split(':')[1].strip()

	# Set the publication year
	# It is found in the line after the one containg lots of = chars
	if prev_line.startswith('==='):
		change_variables['year'] = line.split(' ')[-2].strip()

	index = index + 1

	# find the number of words in a line
	tempwords = line.split(None)
	words = words + len(tempwords)
	prev_line = line

# Set the wordcount
change_variables['wordcount'] = str(words)

# Do an inline replacement of lines in the xsl file
for line in fileinput.FileInput('avvir-article-' + sys.argv[1] + '.txt.xsl', inplace = 1):
	for key, value in change_variables.iteritems():
		if line.find('"' + key + '"') != -1:
			line = line.replace('\'\'', '\'' + value + '\'')
	print line.rstrip()
