#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,string,sys

def main():
    foundChars = []
    openFiles = {}
    largefile = open(sys.argv[1])
    
    for line in largefile:
        line = unicode(line, 'utf8')
        if line[0] not in foundChars:
            foundChars = foundChars + [line[0]]
            #openFiles = 
            openFiles[line[0]] = open(line[0] + '-init.plx', 'w')
            print line.encode('utf8')
            
        openFiles[line[0]].write(line.encode('utf8'))
            
     # rev, uniq sort the files, delete the old files
     # add the file to the large file in the correct order
    
    foundChars.sort()
    foundChars.reverse()
    
    charfile = open("charfile",'w')
    for i in foundChars:
        charfile.write( unicode(i + " ").encode('utf8'))


if __name__ == "__main__":
    main()