#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib2
import feedparser
import os
import sys
import BeautifulSoup
from HTMLParser import HTMLParseError
import fileinput
sys.path.append(os.getenv('GTHOME') + '/gt/script/langTools')
import ngram

class SamediggiArticleSaver:
    def __init__(self):
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

        self.langs = {'sme':'Samisk', 'nob':'Norsk'}
        self.change_variables = {'sub_email': 'divvun@samediggi.no', 'license_type': 'free', 'publisher': 'Sámediggi/Sametinget', 'publChannel': 'http://samediggi.no' }
        self.lg = ngram.NGram(self.gthome + '/tools/lang-guesser/LM/')

        self.files_to_commit = []

        if('--test' in sys.argv):
            self.test = 1
        else:
            self.test = 0

    def set_variable(self, key, value):
        self.change_variables[key] = value

    def detectLanguage(self, text):
        text = text.encode("ascii", "ignore")
        return self.lg.classify(text)

    def save_articles(self, article_number):
        for key, value in self.langs.iteritems():
            self.set_variable('filename', 'http://samediggi.no/Artikkel.aspx?aid=' + article_number + '&sprak=' + value + '&Print=1')

            path = self.freehome + '/orig/' + key + '/admin/sd/samediggi.no/'
            articlename = 'samediggi-article-'+ article_number + '.html'
            fullname = path + articlename

            if not os.path.exists(fullname):
                if key == self.get_lang_and_title():
                    if self.test:
                        print "The article: " + fullname + " doesn't exist"
                    self.set_variable('mainlang', key)
                    self.set_variable('parallel_texts', str('1'))
                    if(key == 'sme'):
                        self.set_variable('para_' + key, '')
                        self.set_variable('para_nob', articlename)
                        self.set_variable('translated_from', 'nob')
                    else:
                        self.set_variable('para_' + key, '')
                        self.set_variable('para_sme', articlename)
                        self.set_variable('translated_from', '')

                    self.save_article(fullname)
                    self.save_metadata(fullname)


    def get_lang_and_title(self):
        '''
        Copy the article given in the feed. Count the words and set that
        variable, too
        '''
        try:
            origarticle = urllib2.urlopen(self.change_variables['filename'])
        except urllib2.HTTPError:
            return 'undef'
            
        self.filebuffer = origarticle.read()
        origarticle.close()

        try:
            soup = BeautifulSoup.BeautifulSoup(self.filebuffer, convertEntities=BeautifulSoup.BeautifulStoneSoup.HTML_ENTITIES)
        except HTMLParseError:
            return 'undef'

        # Find the title
        self.set_variable('title', soup.html.head.title.string.strip().encode('utf-8'))

        # Extract the text
        comments = soup.findAll(text=lambda text:isinstance(text,
 BeautifulSoup.Comment))
        for comment in comments:
            comment.extract()
        scripts = soup.findAll('script')
        for script in scripts:
            script.extract()
        body = soup.body(text=True)
        text = ''.join(body)

        # count the words
        words = text.split(None)
        self.set_variable('wordcount', str(len(words)))

        # Detect the language
        return self.detectLanguage(text)



    def save_article(self, filename):
        # Save the file in the correct folder
        if(self.test):
            print "Saving the article: " + filename
        svnarticle = open(filename, 'w')
        svnarticle.write(self.filebuffer)
        svnarticle.close()
        self.files_to_commit.append(filename)



    def save_metadata(self, filename):
        '''
        Save all the gathered metadata to the xsl filebuffer
        '''
        if(self.test):
            print "Saving the metadata: " + filename + '.xsl'
        template = open(self.gthome + '/gt/script/corpus/XSL-template.xsl', 'r')
        metadata = open(filename + '.xsl', 'w')

        for line in template:
            for key, value in self.change_variables.iteritems():
                if line.find('"' + key + '"') != -1:
                    line = line.replace('\'\'', '\'' + value.replace('&', '&amp;') + '\'')
            metadata.write(line)
        metadata.close()
        self.files_to_commit.append(filename + '.xsl')
        
    def add_and_commit_files(self):
        '''
        Add and commit the file pair to svn
        '''
        if self.test:
            start = 0
            end = 4
            nr = len(self.files_to_commit)
            while end < nr:
                print "Adding and committing: "  + " ".join(self.files_to_commit[start:end])
                start = start + 4
                end = end + 4

            print "Adding and committing the last files: "  + " ".join(self.files_to_commit[start:nr])
        else:
            # Add 256 files in a batch (fearing restriction on number of arguments)
            if len(self.files_to_commit) > 0:
                start = 0
                distance = 256
                end = distance
                nr = len(self.files_to_commit)
                while end < nr:
                    os.system('svn add '  + " ".join(self.files_to_commit[start:end]))
                    os.system('svn ci -m"Added automatically by the atomfilesaver" '  + " ".join(self.files_to_commit[start:end]))
                    start = end
                    end = end + distance
                os.system('svn add '  + " ".join(self.files_to_commit[start:nr]))
                os.system('svn ci -m"Added automatically by the atomfilesaver" '  + " ".join(self.files_to_commit[start:nr]))
            else:
                print "No new files found"

class FeedHandler:
    def __init__(self, feedUrl):
        '''
        Get a rssfeed, parse it and normalize it
        '''
        self.doc = feedparser.parse(feedUrl)

    def get_data_from_feed(self):
        '''
        Get metadata from feed
        '''
        saver = SamediggiArticleSaver()
        for entry in self.doc.entries:
            entry_id = entry.id[entry.id.rfind('/') + 1:]
            article_number = entry_id[3:]
            saver.set_variable('year', str(entry.updated_parsed[0]))
            saver.save_articles(article_number)
        saver.add_and_commit_files()

class IdFetcher:
    def __init__(self, idsfile):
        idf = open(idsfile, 'r')
        self.article_ids = set()
        for line in fileinput.FileInput(idsfile):
            nline = line.lower()
            aid = nline.find('aid')
            if aid > 0:
                nline = nline[aid:]
                amp = nline.find('&')
                if amp > 0:
                    self.article_ids.add(nline[:amp].split('=')[1])
                else:
                    self.article_ids.add(nline.strip().split('=')[1])

    def get_data_from_ids(self):
        saver = SamediggiArticleSaver()
        for article_id in self.article_ids:
            print "getting article: " + article_id
            saver.save_articles(article_id)
        saver.add_and_commit_files()

if('--file' in sys.argv):
    id_handler = IdFetcher(sys.argv[len(sys.argv) - 1])
    id_handler.get_data_from_ids()
    
else:
    feeds = ['http://www.sametinget.no/artikkelrss.ashx?NyhetsKategoriId=1&Spraak=Samisk', 'http://www.sametinget.no/artikkelrss.ashx?NyhetsKategoriId=3539&Spraak=Samisk']

    for feed in feeds:
        fd = FeedHandler(feed)
        fd.get_data_from_feed()
