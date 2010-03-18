#!/usr/bin/env python
# -*- coding: utf-8 -*
"""
This script fills in a value for a given variable in an xsl file
Run it like this: replace_value.py <variablename> <value> <filename>
"""

import sys, getopt, tempfile, os, shutil

def replace(orig_file, pattern, subst):
	#Create temp file
	fh, abs_path = tempfile.mkstemp()
	new_file = open(abs_path,'w')
	old_file = open(orig_file)
	for line in old_file:
		if line.find("\"" + pattern + "\"") > 0:
			line = line.replace("\"''\"", "\"'" + subst + "'\"")
		new_file.write(line)
	#close temp file
	new_file.close()
	os.close(fh)
	old_file.close()
	#Remove original file
	os.remove(orig_file)
	#Move new file
	shutil.move(abs_path, orig_file)

def main():
	if len(sys.argv) != 4:
		print __doc__
		sys.exit(0)
    # parse command line options
	try:
		opts, args = getopt.getopt(sys.argv[1:], "h", ["help"])
	except getopt.error, msg:
		print msg
		print "for help use --help"
		sys.exit(2)
	# process options
	for o, a in opts:
		if o in ("-h", "--help"):
			print __doc__
			sys.exit(0)

	args = sys.argv[1:]

	replace(args[2], args[0], args[1])
	
if __name__ == "__main__":
	main()