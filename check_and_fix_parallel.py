#!/usr/bin/python

"""Usage: either check_and_fix_parallel.py <xslfile> or find . -name \*.xsl | xargs check_and_fix_parallel.py
This script looks for parallel texts as reported in para_xxx in the metadata files
If the parallel file isn't found, it tries to downcase the parallel filename.
If the downcased version exists, the entry is corrected to accordingly
If even that doesn't exist, the error is reported to stderr
"""
import sys, fileinput, os

for filename in sys.argv[1:]:
	for line in fileinput.FileInput(filename, inplace = 1):
		if (line.find("para_") > 0):
			lineparts = line.strip().split("'")
			paraname = lineparts[1]
			
			if (len(paraname) > 0):
				#print paraname
				
				x = line.find("para_")
				paralang = line[x+5:x+8]
			
				dirname = os.path.dirname(os.path.abspath(filename))
				basename = os.path.basename(filename)
				origlang = dirname[dirname.find("orig/")+5:dirname.find("orig/")+8]
				#print origlang
				parapath = dirname.replace(origlang, paralang)
				#print "parapath", parapath
				if (not os.path.isfile(os.path.join(parapath, paraname))):
					if(os.path.isfile(os.path.join(parapath, paraname.lower()))):
						line = line.lower()
						#print line
					else:
						sys.stderr.write(os.path.join(dirname, basename) + " " + line)
		print line[:-1]
