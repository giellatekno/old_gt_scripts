#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys

def fix_file(origname):
    try:
        origfile = open(origname)
        newfile = open(origname.replace('?','_') + '.html', 'w')
        inside_article = 0
        
        newfile.write('<html>\n<body>\n')
        
        for line in origfile:
	    line = unicode(line,'latin1')
            if line.find('<table class="nyhet3"') != -1:
                inside_article = 1
            
            if inside_article == 1:
                if line.find('</table') != -1 :
                    inside_article = inside_article - 1
                newfile.write(line.encode('utf8'))
    
        origfile.close()
        newfile.write('</body>\n</html>\n')
        newfile.close()
        
    except IOError:
        print "oops, couldn't open file " + origname
        sys.exit(2)
            
    
def usage():
    print "This script fixes Min Áigi files."
    print "It takes a file fetched from http://minaigi.no/ "
    print "by the script fetchdailyminaigi.sh and extracts the article"
    print "This is printed to the original filename + the .html extension"

def main():
    
    if len(sys.argv) != 2:
        # print help information and exit:
        usage()
        sys.exit(2)
    else:
        fix_file(sys.argv[1])

   
if __name__ == "__main__":
    main()
    
    