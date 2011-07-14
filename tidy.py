#!/usr/bin/env python
# -*- coding: utf-8 -*-

import BeautifulSoup
import sys
import os

def Usage():
	print 'Usage: tidy.py inputfile outputfile'

if len(sys.argv) != 3:
	Usage()
	exit(1)

if not os.path.exists(sys.argv[1]):
	print 'Input file', sys.argv[1], "doesn't exist"
	Usage()
	exit(2)
	
s = open(sys.argv[1])
sbuffer = s.read()
s.close()

try:
	soup = BeautifulSoup.BeautifulSoup(sbuffer, convertEntities=BeautifulSoup.BeautifulStoneSoup.HTML_ENTITIES)
except HTMLParseError, e:
	print 'Cannot parse', sys.argv[1]
	print 'Reason', e
	exit(4)

comments = soup.findAll(text=lambda text:isinstance(text, BeautifulSoup.Comment))
[comment.extract() for comment in comments]

[item.extract() for item in soup.findAll(text = lambda text:isinstance(text, BeautifulSoup.ProcessingInstruction ))]
[item.extract() for item in soup.findAll(text = lambda text:isinstance(text, BeautifulSoup.Declaration ))]
    
remove_tags = ['noscript', 'script', 'input', 'img', 'v:shapetype', 'v:shape', 'textarea', 'label', 'o:p', 'st1:metricconverter', 'st1:placename', 'st1:place', 'meta']
for remove_tag in remove_tags:
	removes = soup.findAll(remove_tag)
	for remove in removes:
		remove.extract()

print 'finding text', soup.findAll(text="<")

try:
	if not ("xmlns", "http://www.w3.org/1999/xhtml") in soup.html.attrs:
		soup.html.attrs.append(("xmlns", "http://www.w3.org/1999/xhtml"))
except AttributeError:
	pass
	#print 'soup.html', soup.html
	#soup.html['xmlns'] = "http://www.w3.org/1999/xhtml"

s = open(sys.argv[2], 'w')
s.write(str(soup.prettify()))
s.close()
