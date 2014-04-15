#!/usr/bin/env python
# -*- coding: utf-8 -*
# Version : $Id$
############################################################################
#    Copyright (C) 2006 by Børre Gaup   #
#    borre.gaup@uit.no   #
#                                                                          #
#    This program is free software; you can redistribute it and#or modify  #
#    it under the terms of the GNU General Public License as published by  #
#    the Free Software Foundation; either version 2 of the License, or     #
#    (at your option) any later version.                                   #
#                                                                          #
#    This program is distributed in the hope that it will be useful,       #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#    GNU General Public License for more details.                          #
#                                                                          #
#    You should have received a copy of the GNU General Public License     #
#    along with this program; if not, write to the                         #
#    Free Software Foundation, Inc.,                                       #
#    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
############################################################################


"""
Usage:

rename_sami.py dir1 [dir2 dir3 ...]

This script renames files and directories that has got problematic characters
to ascii characters.

The script takes one or more directories as arguments, and renames all
directories and files that has got any of the characters listed in the function
ChangeProblematicName.

Typical use:
	cd /Users
	for i in *; do cd $i; rename_sami.py *; cd ..; done

"""

import os
import sys
import unicodedata
import getopt
import os.path

def ChangeProblematicName(ProblematicName):
	AsciiName = ProblematicName.strip()
        AsciiName = AsciiName.replace(' ','')
	AsciiName = AsciiName.replace('A\xCC\x81', 'AI') # Á
        AsciiName = AsciiName.replace('A\xCC\x88', 'AE') # Ä
        AsciiName = AsciiName.replace('A\xCC\x8A', 'AA') # Å
        AsciiName = AsciiName.replace('C\xCC\x8C', 'TSJ') # Č
        AsciiName = AsciiName.replace('O\xCC\x88', 'OE') # Ö
        AsciiName = AsciiName.replace('S\xCC\x8C', 'SJ') # Š
        AsciiName = AsciiName.replace('Z\xCC\x8C', 'DSJ') # Ž
        AsciiName = AsciiName.replace('a\xCC\x81', 'a') # á
        AsciiName = AsciiName.replace('a\xCC\x88', 'ae') # ä
        AsciiName = AsciiName.replace('a\xCC\x8A', 'aa') # å
        AsciiName = AsciiName.replace('c\xCC\x8C', 'tsj') # č
        AsciiName = AsciiName.replace('o\xCC\x88', 'oe') # ö
        AsciiName = AsciiName.replace('s\xCC\x8C', 'sj') # š
        AsciiName = AsciiName.replace('z\xCC\x8C', 'dsj') # ž
        AsciiName = AsciiName.replace('\xC3\x86', 'AE') # Æ
        AsciiName = AsciiName.replace('\xC3\x98', 'OE') # Ø
        AsciiName = AsciiName.replace('\xC3\xA6', 'ae') # æ
        AsciiName = AsciiName.replace('\xC3\xB8', 'oe') # ø
        AsciiName = AsciiName.replace('\xC4\x90', 'DH') # Đ
        AsciiName = AsciiName.replace('\xC4\x91', 'dh') # đ
        AsciiName = AsciiName.replace('\xC5\x8A', 'NG') # Ŋ
        AsciiName = AsciiName.replace('\xC5\x8B', 'ng') # ŋ
        AsciiName = AsciiName.replace('\xC5\xA6', 'TH') # Ŧ
        AsciiName = AsciiName.replace('\xC5\xA7', 'th') # ŧ
        return AsciiName

def RenameProblemTree(ProblemTree):
	for root, dirs, files in os.walk(ProblemTree, topdown=False):
		if 'Library' in dirs:
			dirs.remove('Library') # Don't visit Library directories

		for mydir in dirs:
			newdir = ChangeProblematicName(mydir)
			if newdir != mydir:
			        print "in dirs ", root + '/' + mydir, '-->', root + '/' + newdir
				os.rename(root + '/' + mydir, root + '/' + newdir)

	for root, dirs, files in os.walk(ProblemTree):
		if 'Library' in dirs:
			dirs.remove('Library') # Don't visit Library directories

                for file in files:
			newfile = ChangeProblematicName(file)
			if newfile != file:
			     print "in files ", root + '/' + file , root + '/' + newfile
			     os.rename(root + '/' + file, root + '/' + newfile)


def main():
	if len(sys.argv) == 1:
		print __doc__
	else:
		args = sys.argv[1:]
		for arg in args:
			if arg[len(arg) - 1] == '/':
				arg = arg.replace('/','')
			RenameProblemTree(arg)

if __name__ == "__main__":
	main()
