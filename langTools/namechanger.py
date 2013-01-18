# -*- coding:utf-8 -*-

#
#   This file contains routines to change names of corpus files
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

import unittest
import os
import unicodedata

class TestNameChanger(unittest.TestCase):
    def testNoneAsciiLower(self):
        want = 'astndzcaoaoai_'

        name = u'ášŧŋđžčåøæöäï+'
        nc = NameChanger(name.encode('utf8'))

        self.assertEqual(nc.newname, want)

    def testNoneAsciiUpper(self):
        want = 'astndzcaoaoai_'

        name = u'ÁŠŦŊĐŽČÅØÆÖÄÏ+'
        nc = NameChanger(name.encode('utf8'))

        self.assertEqual(nc.newname, want)

    def testNoneAsciiBlabla(self):
        want = 'astndzcaoaoai_'

        name = u'ášŧŋđŽČÅØÆÖÄï+'
        nc = NameChanger(name.encode('utf8'))

        self.assertEqual(nc.newname, want)

    def testOwnNameWithOnlyAscii(self):
        want = 'youllneverwalkalone'

        oldname = 'haha'
        newname = 'YoullNeverWalkAlone'
        nc = NameChanger(oldname, newname)

        self.assertEqual(nc.newname, want)

    def testOwnNameWithOnlyAsciiAndSpace(self):
        want = 'youll_never_walk_alone'

        oldname = 'haha'
        newname = 'Youll Never Walk Alone'
        nc = NameChanger(oldname, newname)

        self.assertEqual(nc.newname, want)

    def testOwnNameWithAsciiAndSpaceAndApostrophe(self):
        want = 'you_ll_never_walk_alone'

        oldname = 'haha'
        newname = "You'll Never Walk Alone"
        nc = NameChanger(oldname, newname)

        self.assertEqual(nc.newname, want)

    def testOwnNameWithNonAscii(self):
        want = 'saddago_beaivi_vai_idja'

        oldname = 'haha'
        newname = u'Šaddágo beaivi vai idja'
        klass = newname.encode('utf8')
        nc = NameChanger(oldname.encode('utf8'), klass)

        self.assertEqual(nc.newname, want)

class NameChanger:
    """Class to change names of corpus files.
    Will also take care of changing info in meta data of parallel files.
    """

    def __init__(self, oldname, newname = None):
        """Find the directory the oldname is in.
        self.oldname is the basename of oldname.
        self.newname is the basename of oldname, in lowercase and
        with some characters replaced.
        """
        self.dirname = os.path.dirname(oldname.decode('utf8'))
        self.oldname = os.path.basename(oldname.decode('utf8'))

        if newname is not None:
            self.newname = self.changeToAscii(newname.decode('utf8'))
        else:
            self.newname = self.changeToAscii(self.oldname)

    def changeToAscii(self, oldname):
        """Downcase all chars in oldname, replace some chars
        """
        chars = {u'á':u'a', u'š':u's', u'ŧ':u't', u'ŋ':u'n', u'đ':u'd', u'ž':u'z', u'č':u'c', u'å':u'a', u'ø':u'o', u'æ':u'a', u'ö':u'o', u'ä':u'a', u'ï':u'i', u'+':'_', u' ': u'_', u'(': u'_', u')': u'_', u"'": u'_'}

        newname = oldname.lower()

        for key, value in chars.items():
            utf8keys = [unicodedata.normalize('NFD', key), unicodedata.normalize('NFC', key)]
            for utf8key in utf8keys:
                if utf8key in newname:
                    newname = newname.replace(utf8key, value)

        return newname

    def changeName(self):
        """Change the name of the original file and it's metadata file
        Update the name in parallel files
        Also move the other files that's connected to the original file
        """
        if self.oldname != self.newName:
            self.moveOrigfile()
            self.moveXslfile()
            self.updateNameInParallelFiles()
            self.movePrestableConverted()
            self.movePrestableToktmx()
            self.movePrestableTmx()
