#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This file contains a program to fetch .jspwiki files from a forrest localhost
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this file. If not, see <http://www.gnu.org/licenses/>.
#
#   Copyright 2013-2014 Børre Gaup <borre.gaup@uit.no>
#

'''This is a script to test if .jspwiki files are valid.

Usage:
Start forrest in the directory that you'd like to test,
e.g. $GTHOME/xtdoc/gtuit, in one terminal.

In a second terminal, go to the same directory and run this program.
'''

import os
import sys
import urllib2
import time

xdocs = 'src/documentation/content/xdocs'

for root, dirs, files in os.walk(xdocs, followlinks=True):
    for f in files:
        if f.endswith('.jspwiki'):
            url = 'http://localhost:8888' + root.replace(xdocs, '') + '/' + f.replace('jspwiki', 'xml')

            print url,
            try:
                t0 = time.time()
                response = urllib2.urlopen(url)
                html = response.read()
                response.close()
                print time.time() - t0
            except urllib2.HTTPError:
                print "\t!!!whoops!!!", os.path.join(root, f)
