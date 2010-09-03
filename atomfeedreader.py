#!/usr/bin/env python
# -*- coding: utf-8 -*-

from urllib2 import urlopen
import feedparser
import os

class FeedHandler:
    def __init__(self, feedUrl):
        '''
        Get a atomfeed, parse it and normalize it
        '''
        self.doc = feedparser.parse(r'./avvir.atom.xml')
        self.change_variables = {'sub_name': u'Børre Gaup', 'sub_email': u'borre.gaup@samediggi.no', 'licence_type': u'standard', 'mainlang': u'sme', 'publisher': u'Ávvir', 'publChannel': u'http://avvir.no' }

    def get_text_from_construct(self, element):
        '''
        Return the content of an Atom element declared with the
        atomTextConstruct pattern.  Handle both plain text and XHTML
        forms.  Return a UTF-8 encoded string.
        '''
        if element.getAttributeNS(EMPTY_NAMESPACE, u'type') == u'xhtml':
            #Grab the XML serialization of each child
            childtext = [ c.toxml('utf-8') for c in element.childNodes ]
            #And stitch it together
            content = ''.join(childtext).strip()
            return content
        else:
            return element.firstChild.data.encode('utf-8')

    def get_data_from_feed(self):
        '''
        Get metadata from feed
        '''
        elements_to_get = [ 'title', 'id', 'published', 'name' ]
        entry_element = {}

        for entry in self.doc.entries:
            entry_id = entry.id
            published = entry.published
            number = entry_id.split('=')[1]
            self.articlename = 'avvir-article-' + number + '.txt'

            if not os.path.exists(self.articlename):
                self.change_variables['filename'] = entry_id.replace('index', 'feed') + '&output_type=txt'

                self.change_variables['title'] = entry.title
                self.get_author_from_feed(entry.author)
                self.change_variables['year'] = str(entry.published_parsed[0])

                self.get_article()
                self.save_metadata()
                self.add_and_commit_files()

    def get_author_from_feed(self, nameline):   
        '''
        nameline contains the authors name and possibly email address
        Strip away the email address, fill in forname and surname if
        possible
        '''
        namelist = nameline.split()

        if len(namelist) == 1:
            if namelist[0].find('@') > 0:
                self.change_variables['author1_fn'] = ''
            else:
                self.change_variables['author1_fn'] = namelist[0]
    
            self.change_variables['author1_ln'] = ' '
        else:
            lastelement = namelist[-1:]
            if lastelement[0].find('@') > 0:
                namelist = namelist[:-1]

            self.change_variables['author1_ln'] = namelist[-1:][0]
            self.change_variables['author1_fn'] = ' '.join(namelist[:-1])

    def get_article(self):
        '''
        Copy the article given in the feed. Count the words and set that
        variable, too
        '''
        origarticle = urlopen(self.change_variables['filename'])
        filebuffer = origarticle.read()
        self.change_variables['wordcount'] = str(len(filebuffer.split(None)))
    
        svnarticle = open(self.articlename, 'w')
        svnarticle.write(filebuffer)
        svnarticle.close()

    def save_metadata(self):
        '''
        Save all the gathered metadata to the xsl filebuffer
        '''
        template = open('XSL-template.xsl', 'r')
        metadata = open(self.articlename + '.xsl', 'w')

        for line in template:
            for key, value in self.change_variables.iteritems():
                if line.find('"' + key + '"') != -1:
                    line = line.replace('\'\'', '\'' + value.replace('&', '&amp;') + '\'')
            metadata.write(line.encode('utf-8'))

        metadata.close()

    def add_and_commit_files(self):
        '''
        Add and commit the file pair to svn
        '''
        os.system('svn add ' + self.articlename + ' ' + self.articlename + '.xsl')
        os.system('svn ci -m"Added automatically by the atomfilesaver" ' + self.articlename + ' ' + self.articlename + '.xsl')

fd = FeedHandler('http://avvir.no/feed.php?output_type=atom')
fd.get_data_from_feed()
