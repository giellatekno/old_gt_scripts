#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This file contains routines to convert pdf files to xml 
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
#   Copyright 2012 Børre Gaup <borre.gaup@uit.no>
#

import os
from lxml import etree
from lxml import doctestcompare

import unittest

class TestPdf2Xml(unittest.TestCase):
    """
    A class to test pdf to "our" xml conversion
    """
    def setup():
        pass
    
    def testConstruction(self):
        """
        Test the constructor
        """
        # Make sure that an IOError is thrown on a non-existing file
        self.assertRaises(IOError, Pdf2Xml, "foofile")
        # Make sure that an etree.XMLSyntaxError is raised when opening a non xml file
        self.assertRaises(etree.XMLSyntaxError, Pdf2Xml, os.path.join(os.environ['GTFREE'], "orig/sme/admin/others/jahkediedahus_2009.pdf"))
        # Check that we raise a ValueError when the input doc isn't a pdf2xml doc
        self.assertRaises(ValueError, Pdf2Xml, "pdf2xml_data/non_pdf2xml.xml")
        
    def testRemoveTableOfContent(self):
        pass
        
class Pdf2Xml:
    """
    A class to convert pdf to "our" xml format.
    Input is a file that has been converted to libpopplers pdf2xml format.
    This file is then further processed and then converted to "our" format
    """
    
    def __init__(self, inXmlFile):
        """
        Parse the infile
        """
        self.etree = etree.parse(inXmlFile)
        root = self.etree.getroot()
        
        # Raise an exception if this isn't the kind of xml doc this program can handle
        if root.tag != "pdf2xml":
            raise ValueError(root.tag)
        
    def removeTableOfContent(self):
        """
        Remove lines containing four or more consecutive . marks
        """
        pass
    
    def removeTopText(self):
        """
        Remove page numbers and other repeated content at the top of the page
        """
        pass
    
    def removeBottomText(self):
        """
        Remove page numbers and other repeated content at the top of the page
        """
        pass
    
    def findStandardFont(self):
        """
        Find the font that is used mostly in the doc
        """
        pass
    
if __name__ == '__main__':
    unittest.main()
    #testSuite = unittest.TestSuite()
    #testSuite.addTest(unittest.makeSuite(TestPdf2Xml))
    #unittest.TextTestRunner().run(testSuite)
    
