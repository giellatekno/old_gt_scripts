#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,string,sys,gzip


def main():
	foundChars = []
	openFiles = {}
	for fname in sys.argv[1:]:
		if (fname == '-'):
			largefile = sys.stdin
		elif (fname[-2:] == 'gz'):
			largefile = gzip.GzipFile(fname)
		else:
			largefile = open(fname)
		
		firstchar = ''
		
		for line in largefile:
			line = unicode(line, 'utf8')
			firstChar = line[0]
			
			if firstChar not in foundChars:
				foundChars = foundChars + [firstChar]
				if firstChar != firstChar.lower():
					openFiles[firstChar] = open('tmp/' + firstChar.lower() + '_' + '-init.plx', 'w')
				else:
					openFiles[firstChar] = open('tmp/' + firstChar + '-init.plx', 'w')
				#print line.encode('utf8')
			
			openFiles[firstChar].write(line.encode('utf8'))
			
	foundChars.sort()
	foundChars.reverse()
	
	charfile = open("charfile",'w')
	for i in foundChars:
		if i != i.lower():
			charfile.write( unicode(i.lower() + '_ ').encode('utf8'))
		else:
			charfile.write( unicode(i + ' ').encode('utf8'))


if __name__ == "__main__":
	main()