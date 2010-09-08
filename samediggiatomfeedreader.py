#!/usr/bin/env python
# -*- coding: utf-8 -*-

from urllib2 import urlopen
import feedparser
import os
import sys
import re

class FeedHandler:
    def __init__(self, feedUrl):
        '''
        Get a rssfeed, parse it and normalize it
        '''
        self.gthome = os.getenv('GTHOME')
        if self.gthome is None:
            print 'You have to set the environment $GTHOME'
            print 'Use the gtsetup.sh which is in the'
            print 'same folder as this script'
            sys.exit(1)
            
        self.doc = feedparser.parse(feedUrl)
        self.change_variables = {'sub_email': 'divvun@samediggi.no', 'licence_type': 'free', 'publisher': 'Sámediggi/Sametinget', 'publChannel': 'http://samediggi.no' }

    def get_data_from_feed(self):
        '''
        Get metadata from feed
        '''
        for entry in self.doc.entries:
            entry_id = entry.id[entry.id.rfind('/') + 1:]
            self.smearticlename = 'orig/sme/admin/sd/samediggi.no/samediggi-article-' + entry_id + '.html'
            self.nobarticlename = 'orig/nob/admin/sd/samediggi.no/samediggi-article-' + entry_id + '.html'
            self.change_variables['year'] = str(entry.updated_parsed[0])
            
            if not os.path.exists(self.smearticlename):
                self.change_variables['filename'] = entry.link + '&Print=1'
                self.get_article(self.smearticlename)
                self.save_metadata(self.smearticlename)
                self.add_and_commit_files(self.smearticlename)

                self.change_variables['filename'] = entry.link.replace('Samisk', 'Norsk') + '&Print=1'
                self.get_article(self.nobarticlename)
                self.save_metadata(self.nobarticlename)
                self.add_and_commit_files(self.nobarticlename)

                
    def get_article(self, filename):
        '''
        Copy the article given in the feed. Count the words and set that
        variable, too
        '''
        origarticle = urlopen(self.change_variables['filename'])
        filebuffer = origarticle.read()

        # Find the title
        h1 = re.compile('\<title>.*</h1', re.S)
        tmp_result = h1.search(filebuffer).group(0)
        self.change_variables['title'] = tmp_result[tmp_result.find('>') + 1:tmp_result.rfind('<')].strip()

        svnarticle = open(filename, 'w')
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
            metadata.write(line)

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
