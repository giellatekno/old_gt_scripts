#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,string,sys


def main():
	foundChars = []
	openFiles = {}
	lang = sys.argv[1]
	for fname in sys.argv[2:]:
		print "Now extracting from: ", fname
		if (fname == '-'):
			largefile = sys.stdin
		elif (fname[-2:] == 'gz'):
			#largefile = gzip.GzipFile(fname)
			cmd = 'gunzip -c ' + fname
			largefile = os.popen(cmd)
		else:
			largefile = open(fname)
		
		firstChars = ''
		count = 0
		
		for line in largefile:
			count += 1
			line = unicode(line, 'utf8')
			firstChars = line[0]
			#print firstChars
			
			if firstChars not in foundChars:
				foundChars += [firstChars]
				if firstChars == firstChars.lower():
					openFiles[firstChars] = open('tmp/' + firstChars + '-' + lang + '-init.plx', 'w')
				else:
					openFiles[firstChars] = open('tmp/' + firstChars.lower() + '_-' + lang + '-init.plx', 'w')
				#print line.encode('utf8')
			
			openFiles[firstChars].write(line.encode('utf8'))
	
	foundChars.sort()
	foundChars.reverse()

	charfile = open("charfile",'w')
	for i in foundChars:
		if i == '-':
			pass
		elif i == i.lower():
			charfile.write( unicode(i + ' ').encode('utf8'))
		else:
			charfile.write( unicode(i + '_ ').encode('utf8'))


if __name__ == "__main__":
	main()
