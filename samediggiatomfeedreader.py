#!/usr/bin/env python
# -*- coding: utf-8 -*-

from urllib2 import urlopen
import feedparser
import os
import sys
from BeautifulSoup import BeautifulSoup
import re

class FeedHandler:
    def __init__(self, feedUrl):
        '''
        Get a rssfeed, parse it and normalize it
        '''
        self.gthome = os.getenv('GTHOME')
        if self.gthome is None:
            print 'You have to set the environment variable $GTHOME'
            print 'Use the gtsetup.sh which is in the'
            print 'same folder as this script'
            sys.exit(1)

        self.freehome = os.getenv('GTFREE')
        if self.freehome is None:
            print 'You have to set the environment variable $GTFREE'
            print 'Use the gtsetup.sh which is in the'
            print 'same folder as this script'
            sys.exit(2)

            
        self.doc = feedparser.parse(feedUrl)
        self.langs = {'sme':'Samisk', 'nob':'Norsk'}
        self.change_variables = {'sub_email': 'divvun@samediggi.no', 'licence_type': 'free', 'publisher': 'Sámediggi/Sametinget', 'publChannel': 'http://samediggi.no' }

    def get_data_from_feed(self):
        '''
        Get metadata from feed
        '''
        for entry in self.doc.entries:
            entry_id = entry.id[entry.id.rfind('/') + 1:]
            article_number = entry_id[3:]

            for key, value in self.langs.iteritems():
                path = self.freehome + '/orig/' + key + '/admin/sd/samediggi.no/'
                articlename = 'samediggi-article-' + article_number + '.html'
                fullname = path + articlename
                self.change_variables['year'] = str(entry.updated_parsed[0])
            
                if not os.path.exists(fullname):
                    self.change_variables['filename'] = 'http://samediggi.no/Artikkel.aspx?aid=' + article_number + '&sprak=' + value + '&Print=1'
                    self.get_article(fullname)
                    self.change_variables['mainlang'] = key
                    self.change_variables['parallel_texts'] = str('1')
                    if(key == 'sme'):
                        self.change_variables['para_' + key] = ''
                        self.change_variables['para_nob']= articlename
                    else:
                        self.change_variables['para_' + key] = ''
                        self.change_variables['para_sme']= articlename
                    self.save_metadata(fullname)
                    self.add_and_commit_files(fullname)

                
    def get_article(self, filename):
        '''
        Copy the article given in the feed. Count the words and set that
        variable, too
        '''
        print "fetching: " + self.change_variables['filename']
        origarticle = urlopen(self.change_variables['filename'])
        filebuffer = origarticle.read()
        soup = BeautifulSoup(filebuffer)
        origarticle.close()

        # Find the title
        self.change_variables['title'] = soup.html.head.title.string.strip().encode('utf-8')
        print "The title is: " + self.change_variables['title']

        svnarticle = open(filename, 'w')
        print "Saving the article: " + filename
        svnarticle.write(filebuffer)
        svnarticle.close()

    def save_metadata(self, filename):
        '''
        Save all the gathered metadata to the xsl filebuffer
        '''
        template = open(self.gthome + '/gt/script/corpus/XSL-template.xsl', 'r')
        metadata = open(filename + '.xsl', 'w')

        for line in template:
            for key, value in self.change_variables.iteritems():
                if line.find('"' + key + '"') != -1:
                    line = line.replace('\'\'', '\'' + value.replace('&', '&amp;') + '\'')
                    print "This is metadata line: " + line
            metadata.write(line)
        print "Saving the metadata" + filename
        metadata.close()

    def add_and_commit_files(self, filename):
        '''
        Add and commit the file pair to svn
        '''
        os.system('svn add ' +  filename + ' ' + filename + '.xsl')
        os.system('svn ci -m"Added automatically by the atomfilesaver" ' + filename + ' ' + filename + '.xsl')

feeds = ['http://www.sametinget.no/artikkelrss.ashx?NyhetsKategoriId=1&Spraak=Samisk', 'http://www.sametinget.no/artikkelrss.ashx?NyhetsKategoriId=3539&Spraak=Samisk']

for feed in feeds:
    fd = FeedHandler(feed)
    fd.get_data_from_feed()
