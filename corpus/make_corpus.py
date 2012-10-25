#!/usr/bin/env python

import os
import sys
import subprocess
import argparse

class CorpusBuilder:
    def __init__(self, orig_dir):
        gthome = os.getenv('GTHOME')
        
        if not os.path.isdir(orig_dir):
            sys.exit(1)
        else:
            self.orig_dir = orig_dir
            self.buildable_files = 0
            self.failed_files = 0

            self.bible_dep = [os.path.join(gthome, 'gt/script/langTools/BibleXMLConverter.pm'), os.path.join(gthome, '/gt/script/corpus/bible2xml.pl'), os.path.join(gthome, 'gt/script/corpus/paratext2xml.pl'), os.path.join(gthome, 'gt/script/langTools/ParatextConverter.pm')]

            self.pdf_dep = [os.path.join(gthome, 'gt/script/langTools/PDFConverter.pm'), os.path.join(gthome, 'gt/script/langTools/PlaintextConverter.pm')]

            self.html_dep = [os.path.join(gthome, 'gt/script/langTools/HTMLConverter.pm'), os.path.join(gthome, 'gt/script/langTools/RTFConverter.pm'), os.path.join(gthome, 'gt/script/corpus/xhtml2corpus.xsl')]

            self.svg_dep = [os.path.join(gthome, 'gt/script/langTools/SVGConverter.pm'), os.path.join(gthome, 'gt/script/corpus/svg2corpus.xsl')]

            self.common_dep = [os.path.join(gthome, 'gt/script/langTools/CantHandle.pm'), os.path.join(gthome, 'gt/script/langTools/CorrectXMLConverter.pm'), os.path.join(gthome, 'gt/script/corpus/common.xsl'), os.path.join(gthome, 'gt/script/corpus/convert2xml.pl'), os.path.join(gthome, 'gt/script/langTools/Preconverter.pm'), os.path.join(gthome, 'gt/script/langTools/Converter.pm'), os.path.join(gthome, 'gt/script/langTools/Corpus.pm'), os.path.join(gthome, 'gt/script/langTools/Decode.pm'), os.path.join(gthome, 'gt/script/corpus/XSL-template.xsl')]

            self.avvir_dep = [os.path.join(gthome, 'gt/script/langTools/AvvirXMLConverter.pm'), os.path.join(gthome, 'gt/script/corpus/avvir2corpus.xsl')]

            self.doc_dep = [os.path.join(gthome, 'gt/script/corpus/docbook2corpus2.xsl'), os.path.join(gthome, 'gt/script/langTools/DOCConverter.pm')]

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
            elif 'bible' in source:
                dependencies = dependencies + self.bible_dep
            elif source.endswith('.htm') or source.endswith('.html') or 'html_id' in source:
                dependencies = dependencies + self.html_dep
            
            if newer_group(dependencies, xml_file):
                self.convert_file(source)

    def convert_file(self, source):
        subp = subprocess.Popen(['convert2xml.pl', '--debug', source], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        (output, error) = subp.communicate()

        if subp.returncode != 0:
            #print >>sys.stderr, "couldn't build", source
            #print >>sys.stderr, error
            self.failed_files += 1

    def find_xsl_files(self):
        xsl_files = []
        for root, dirs, files in os.walk(self.orig_dir): # Walk directory tree
            for f in files:
                if f.endswith('.xsl'):
                    xsl_files.append(root + '/' + f)
                
        self.buildable_files = len(xsl_files)
        return xsl_files

    def final_call(self):
        print "Failed at building", self.failed_files, "of", self.buildable_files, "buildable files"

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