#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os.path

knownSites = { 'minaigi.no': 'news', 'nsr.no': 'facta', 'galdu.org': 'facta', 'nrk.no/sami': 'news', 'nrk.no/izu': 'news', 'nrk.no/ardna': 'news',  'samishkhs.no': 'facta' }

knownFeeds = { 'minaigi.no': 'http://www.minaigi.no/rss.php' }

class SitePageFetcher:
    def __init__(self, site):
        self.corpPath = os.path.join('/usr/local/share/corp/orig/sme',knownSites[site],site)
    
    def ReadFeed(self, rssFeed):
        import feedparser
        import urllib2
        
        feed = feedparser.parse(knownFeeds['minaigi.no'])
        
        for i in range( 0, len(feed) - 1 ):
            outFilename = os.path.join(self.corpPath, os.path.basename( feed.entries[i].link ))
            if (os.path.exists(outFilename) != 1):
                outfile = open(outFilename, 'w')
                infile = urllib2.urlopen( feed.entries[i].link )
                
                for line in infile:
                    outfile.write(line)
                
                outfile.close()
                infile.close()
                self.ProcessFetchedPage(os.path.join(self.corpPath, os.path.basename( feed.entries[i].link )))
    
    def ReadFrontpage(self, frontpage):
        pass
    
    def ProcessFetchedPage(self, page):
        import formatter, htmllib
        try:
            origfile = open(page)
            newfile = open(page.replace('?','_') + '.html', 'w')
            inside_article = 0
            
            #outfile = open('outfile.txt','w')
            #f = formatter.AbstractFormatter(formatter.DumbWriter(outfile))
            #p = htmllib.HTMLParser(f)
            
            newfile.write('<html>\n<head>\n<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8">\n</head>\n<body>\n')
            
            for line in origfile:
                line = unicode(line,'latin1')
                if line.find('<table class="nyhet3"') != -1:
                    inside_article = 1
                
                if inside_article == 1:
                    if line.find('</table') != -1 :
                        inside_article = inside_article - 1
                    newfile.write(line.encode('utf8'))
        
            #p.close()
            origfile.close()
            newfile.write('</body>\n</html>\n')
            newfile.close()
            
        except IOError:
            print "oops, couldn't open file " + page
            sys.exit(2)
                

        pass
    
def main():
    import sys
    fetcher = SitePageFetcher('minaigi.no')
    fetcher.ReadFeed('minaigi.no')
    
if __name__ == "__main__":
    main()
