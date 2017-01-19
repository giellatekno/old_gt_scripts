#!/usr/bin/env python3
# -*- coding: UTF-8 -*-
# show the frequency of characters in a string
# Python24 and higher by HAB
# Fetched from http://www.daniweb.com/code/snippet506.html
# Modified by borre.gaup@uit.no to read utf8 input, and
# to read data from either stdin or a file

import sys

char_num = 0
cf_dic = {}
fname = sys.argv[1]
if (fname == '-'):
    infile = sys.stdin
else:
    infile = open(fname)
for line in infile:
    # create a character:frequency dictionary
    for char in line:
        if char not in u" \n\t0123456789.¶,-–:«»!()?[]/'’…<>=;\"&+@*":
            char_num += 1
            cf_dic[char] = cf_dic.get(char, 0) + 1


print('Characters sorted by frequency:')
# convert cf_dic to list of (k, v) tuples with cf_dic.items()
# flip tuple elements to (v, k) using list comprehension
# then sort list of tuples (order is v,k), highest v first
value_key = sorted([(v, k) for k, v in cf_dic.items()], reverse=True)
for frequency, character in value_key:
    # don't show space and newline
    print('{}\t{:>10}\t{:>6.2f}%'.format(character, frequency, frequency/char_num*100))
