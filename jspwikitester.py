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
#   Copyright 2013 Børre Gaup <borre.gaup@uit.no>
#

import os
import sys
import urllib2
import time

gtuit = 'src/documentation/content/xdocs'
#gthome = os.getenv('GTHOME')
#gtuit = os.path.join(gthome, realpath)

print gtuit

for root, dirs, files in os.walk(gtuit, followlinks=True):
    for f in files:
        if f.endswith('.jspwiki') and not '/words/' in root:
            url = 'http://localhost:8888/' + root.replace(gtuit, '') + '/' + f.replace('jspwiki', 'xml')
            print os.path.join(root, f)
            #print url

            try:
                t0 = time.time()
                response = urllib2.urlopen(url)
                html = response.read()
                # do something
                response.close()  # best practice to close the file
                print time.time() - t0
            except urllib2.HTTPError:
                print "\t!!!whoops!!!", url
