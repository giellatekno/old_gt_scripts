#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This file contains a program to convert corpus files with a 
#   make like function
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
import sys
import subprocess
import argparse
import lxml
import pdfminer

sys.path.append(os.getenv('GTHOME') + '/gt/script/langTools')
import converter

class CorpusBuilder:
    def __init__(self, orig_dir):
        gthome = os.getenv('GTHOME')
        self.converted = 0
        if not os.path.isdir(orig_dir):
            sys.exit(1)
        else:
            self.orig_dir = orig_dir
            self.convertable_files = 0
            self.failed_files = 0

            self.bible_dep = [os.path.join(gthome, 'gt/script/corpus/bible2xml.pl'), os.path.join(gthome, 'gt/script/corpus/paratext2xml.pl')]

            self.pdf_dep = []

            self.html_dep = [os.path.join(gthome, 'gt/script/corpus/xhtml2corpus.xsl')]

            self.svg_dep = [os.path.join(gthome, 'gt/script/corpus/svg2corpus.xsl')]

            self.common_dep = [os.path.join(gthome, 'gt/script/langTools/converter.py'), os.path.join(gthome, 'gt/script/langTools/decode.py'), os.path.join(gthome, 'gt/script/corpus/common.xsl'), os.path.join(gthome, 'gt/script/corpus/convert2xml.py'), os.path.join(gthome, 'gt/script/corpus/XSL-template.xsl'), os.path.join(gthome, 'gt/script/preprocess')]

            self.avvir_dep = [os.path.join(gthome, 'gt/script/corpus/avvir2corpus.xsl')]

            self.doc_dep = [os.path.join(gthome, 'gt/script/corpus/docbook2corpus2.xsl')]

    def find_dependencies(self, xsl_files):
        from distutils.dep_util import newer_group
        
        for xsl_file in xsl_files:
            dependencies = self.common_dep
            xml_file = xsl_file.replace('.xsl', '.xml').replace('orig', 'converted')
            source = xsl_file[:-4]
            
            dependencies.append(xsl_file)
            dependencies.append(source)
            
            if source.endswith('.doc'):
                dependencies = dependencies + self.doc_dep
            elif source.endswith('.pdf'):
                dependencies = dependencies + self.pdf_dep
            elif 'Avvir_xml-filer' in source:
                dependencies = dependencies + self.avvir_dep
            elif source.endswith('.svg'):
                dependencies = dependencies + self.svg_dep
            elif 'bible' in source or source.endswith('.ptx'):
                dependencies = dependencies + self.bible_dep
            elif source.endswith('.htm') or source.endswith('.html') or 'html_id' in source or '.php' in source:
                dependencies = dependencies + self.html_dep
            
            if newer_group(dependencies, xml_file):
                self.convert_file(source)
                                                                                                                                                                                                                                                                
    def convert_file(self, source):
        conv = converter.Converter(source)
        try:
            self.converted += 1
            print self.converted, source
            conv.writeComplete()
            self.converted += 1
            print self.converted, source
        except converter.ConversionException, (instance):
            print "Can't convert: " + instance.parameter
            self.failed_files += 1
        except lxml.etree.XMLSyntaxError:
            print "etree", source
            self.failed_files += 1
        except pdfminer.pdfinterp.PDFTextExtractionNotAllowed:
            print "pdf", source
            self.failed_files += 1
        except lxml.etree.XSLTParseError:
            print "xslt", source
            self.failed_files += 1
        except AssertionError:
            print "pdf?", source
            self.failed_files += 1
        except pdfminer.psparser.PSEOF:
            print "pdf: Unexpected EOF", source
            self.failed_files += 1
        except IOError:
            print "no such file", source
            self.failed_files += 1
        except ValueError:
            print "not valid text for xml:", source
            self.failed_files += 1
        except OSError:
            print "file not found:", source

    def find_xsl_files(self):
        xsl_files = []
        for root, dirs, files in os.walk(self.orig_dir): # Walk directory tree
            for f in files:
                if f.endswith('.xsl'):
                    xsl_files.append(root + '/' + f)
                
        self.convertable_files = len(xsl_files)
        return xsl_files

    def final_call(self):
        if self.failed_files > 0:
            print "Couldn't convert", self.failed_files, "files of", self.convertable_files, "convertable files"
        else:
            print "Converted all", self.convertable_files, "convertible files"

def parse_options():
    parser = argparse.ArgumentParser(description = 'Convert original files to giellatekno xml, using dependency checking.')
    parser.add_argument('orig_dir', help = "directory where the original files exist")
    
    args = parser.parse_args()
    return args

if __name__ == '__main__':
    args = parse_options()
    cb = CorpusBuilder(args.orig_dir)
    cb.find_dependencies(cb.find_xsl_files())
    cb.final_call()