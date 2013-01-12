#!/usr/bin/env python
# -*- coding:utf-8 -*-

#
#   This is a program to move files in a git repository
#   with non ascii chars file names to ascii file names
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this file. If not, see <http://www.gnu.org/licenses/>.
#
#   Copyright 2013 Børre Gaup <borre.gaup@uit.no>
#

import unicodedata
import sys
import os
import subprocess

chars = {u'á':'a', u'š':'s', u'ŧ':'t', u'ŋ':'n', u'đ':'d', u'ž':'z', u'č':'c', u'å':'a', u'ø':'o', u'æ':'a', u'ö':'o', u'ä':'a', u'ï':'i'}

for line in sys.stdin:
    dirname = os.path.dirname(line.strip().decode('utf8'))
    oldname = os.path.basename(line.strip().decode('utf8'))
    newname = os.path.basename(line.strip().decode('utf8'))
    for key, value in chars.items():
        utf8keys = [unicodedata.normalize('NFD', key), unicodedata.normalize('NFD', key).upper(), unicodedata.normalize('NFC', key), unicodedata.normalize('NFC', key).upper()]
        for utf8key in utf8keys:
            if utf8key in newname:
                newname = newname.replace(utf8key, value)

    if newname != oldname:
        fromname = os.path.join(dirname, oldname)
        toname = os.path.join(dirname, newname.lower())
        if os.path.exists(fromname):
            subp = subprocess.Popen(['git', 'mv', '-f', fromname, toname], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
            (output, error) = subp.communicate()

            if subp.returncode != 0:
                print >>sys.stderr, 'Could not move', fromname, 'to', toname
                print >>sys.stderr, output
                print >>sys.stderr, error
            else:
                print "moved", fromname, "to", toname
        else:
            print >>sys.stderr, 'Does not exist', line.strip()
