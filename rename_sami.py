#!/usr/bin/env python
# -*- coding: utf-8 -*

############################################################################
#    Copyright (C) 2006 by Børre Gaup   #
#    boerre@skolelinux.no   #
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
	for i in u'åÅæÆäÄáÁ':
		AsciiName = AsciiName.replace(i, 'a')
	for i in u'øØöÖóÓ':
		AsciiName = AsciiName.replace(i, 'o')
	for i in u'šŠ':
		AsciiName = AsciiName.replace(i, 's')
	for i in u'ŧŦ':
		AsciiName = AsciiName.replace(i, 't')
	for i in u'ŋŊ':
		AsciiName = AsciiName.replace(i, 'n')
	for i in u'đĐ':
		AsciiName = AsciiName.replace(i, 'd')
	for i in u'žŽ':
		AsciiName = AsciiName.replace(i, 'z')
	for i in u'čČ':
		AsciiName = AsciiName.replace(i, 'c')
	for i in u'•':
		AsciiName = AsciiName.replace(i, '_bullit_')
	return AsciiName

def RenameProblemTree(ProblemTree):
	for root, dirs, files in os.walk(ProblemTree, topdown=False):
		if 'Library' in dirs:
			dirs.remove('Library') # Don't visit Library directories
			
		uniroot = unicodedata.normalize('NFC', root.decode('utf-8', root)) + '/'
		for dir in dirs:
			unidir = unicodedata.normalize('NFC', dir.decode('utf-8', dir))
			newdir = ChangeProblematicName(unidir)
			if newdir != unidir:
				#print "in dirs ", uniroot + unidir , uniroot + newdir
				os.rename(uniroot + unidir , uniroot + newdir)
		
		for file in files:
			unifile = unicodedata.normalize('NFC', file.decode('utf-8', file))
			newfile = ChangeProblematicName(unifile)
			if newfile != unifile:
				#print "in files ", uniroot + unifile, uniroot + newfile
				os.rename(uniroot + unifile, uniroot + newfile)


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
