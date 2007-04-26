#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,string,sys

def main():
    foundChars = []
    openFiles = {}
    if (sys.argv[1] == '-'):
	largefile = sys.stdin
    else:
    	largefile = open(sys.argv[1])
	
    firstchar = ''
    
    for line in largefile:
        line = unicode(line, 'utf8')
        firstChar = line[0]
        
        if firstChar not in foundChars:
            foundChars = foundChars + [firstChar]
            if firstChar != firstChar.lower():
                openFiles[firstChar] = open(firstChar.lower() + '_' + '-init.plx', 'w')
            else:
                openFiles[firstChar] = open(firstChar + '-init.plx', 'w')
            print line.encode('utf8')
        
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