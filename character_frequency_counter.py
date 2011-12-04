#!/usr/bin/env python
# -*- coding: UTF-8 -*-
# show the frequency of characters in a string
# Python24 and higher by HAB
# Fetched from http://www.daniweb.com/code/snippet506.html
# Modified by boerre@skolelinux.no to read utf8 input, and 
# to read data from either stdin or a file

import sys

cf_dic = {}
fname = sys.argv[1]
if (fname == '-'):
    infile = sys.stdin
else:
    infile = open(fname)
for line in infile:
    line = unicode(line, 'utf8')
    # create a character:frequency dictionary
    
    for char in line.lower():
	cf_dic[char] = cf_dic.get(char, 0) + 1
    
 
print "Characters sorted by frequency:"
# convert cf_dic to list of (k, v) tuples with cf_dic.items()
# flip tuple elements to (v, k) using list comprehension
# then sort list of tuples (order is v,k), highest v first
value_key = sorted([(v, k) for k, v in cf_dic.items()], reverse=True)
for vk in value_key:
    # don't show space and newline
    if vk[1] not in u" \n0123456789.¶,-–:«»!()?[]/'’…":
	c = unicode(vk[1]).encode('utf8')
        print c , vk[0]
 
