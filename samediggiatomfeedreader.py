#!/usr/bin/env python
# -*- coding: utf-8 -*-

from urllib2 import urlopen
import feedparser
import os
import sys
import BeautifulSoup
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

        if('--test' in sys.argv):
            self.test = 1
        else:
            self.test = 0

    def set_variable(self, key, value):
        self.change_variables[key] = value

    def detectLanguage(self, text):
        text = text.encode("ascii", "ignore")
        return self.lg.classify(text)

    def save_and_commit(self, article_number):
        for key, value in self.langs.iteritems():
            self.set_variable('filename', 'http://samediggi.no/Artikkel.aspx?aid=' + article_number + '&sprak=' + value + '&Print=1')

            path = self.freehome + '/orig/' + key + '/admin/sd/samediggi.no/'
            articlename = 'samediggi-article-'+ article_number + '.html'
            fullname = path + articlename

            if( key == self.get_lang_and_title() and not os.path.exists(fullname)):
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
                self.add_and_commit_files(fullname)


    def get_lang_and_title(self):
        '''
        Copy the article given in the feed. Count the words and set that
        variable, too
        '''
        origarticle = urlopen(self.change_variables['filename'])
        self.filebuffer = origarticle.read()
        origarticle.close()

        soup = BeautifulSoup.BeautifulSoup(self.filebuffer, convertEntities=BeautifulSoup.BeautifulStoneSoup.HTML_ENTITIES)

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

    def add_and_commit_files(self, filename):
        '''
        Add and commit the file pair to svn
        '''
        if self.test:
            print "Adding and committing: "  + filename + ' ' + filename + '.xsl'
        else:
            os.system('svn add ' +  filename + ' ' + filename + '.xsl')
            os.system('svn ci -m"Added automatically by the atomfilesaver" ' + filename + ' ' + filename + '.xsl')

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
            saver.save_and_commit(article_number)

if('--file' in sys.argv):
    print "Getting article numbers from a file"
else:
    feeds = ['http://www.sametinget.no/artikkelrss.ashx?NyhetsKategoriId=1&Spraak=Samisk', 'http://www.sametinget.no/artikkelrss.ashx?NyhetsKategoriId=3539&Spraak=Samisk']

    for feed in feeds:
        fd = FeedHandler(feed)
        fd.get_data_from_feed()
