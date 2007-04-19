#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,string,sys

def main():
    foundChars = []
    openFiles = {}
    largefile = open(sys.argv[1])
    firstchar = ''
    
    for line in largefile:
        line = unicode(line, 'utf8')
        firstChar = line[0]
        
        #
         #   firstChar = firstChar.lower() + '_'
            
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
    
    filefile = open("filefile",'w')
    for i in foundChars:
    	if i != i.lower():
            filefile.write( unicode(i.lower() + "_-sorted-init.plx ").encode('utf8'))
        else:
            filefile.write( unicode(i + "_-sorted-init.plx ").encode('utf8'))


if __name__ == "__main__":
    main()