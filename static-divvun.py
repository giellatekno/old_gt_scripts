#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""This script builds a multilingual forrest site.
--destination (-d) an ssh destination
--vcs (-c) the version control system
--sitehome (-s) where sd and techdoc lives
--langs (-l) comma separated list of languages"""

import subprocess
import os
import sys
import shutil
import time
import re
import argparse
import fileinput

from lxml import etree

class StaticSiteBuilder:
    """This class is used to build a static version of the divvun site.
    """

    def __init__(self, builddir, destination, vcs):
        """
            builddir: The directory where the forrest site is
            destination: where the built site is copied (using ssh)
            vcs: version control system, either svn or git

            Revert files that might be changed
            Clean up the build directory of the forrest site
        """
        print "Setting up..."
        if builddir.endswith('/'):
            builddir = builddir[:-1]
        self.builddir = builddir
        if not destination.endswith('/'):
            destination = destination + '/'
        self.destination = destination
        self.vcs = vcs


        os.chdir(self.builddir)
        self.revert_files(self.vcs, ["forrest.properties", "../sd/src/documentation/resources/schema/symbols-project-v10.ent"])

        subp = subprocess.Popen(["forrest", "clean"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (output, error) = subp.communicate()

        if subp.returncode != 0:
                print >>sys.stderr, "forrest clean failed"
                self.logfile.writelines(output)
                self.logfile.writelines(error)

        self.set_font_path()

        if os.path.isdir(os.path.join(self.builddir, "built")):
           shutil.rmtree(os.path.join(self.builddir, "built"))

        os.mkdir(os.path.join(self.builddir, "built"))
        self.logfile = open(os.path.join(self.builddir, "buildlog" + time.strftime("%Y-%m-%d-%H-%M", time.localtime())), 'w')
        os.environ['LC_ALL'] = "C"
        self.lang_specific_files = []

    def __del__(self):
        """Revert files that might be changed
        Close the logfile
        """
        os.chdir(self.builddir)
        self.revert_files(self.vcs, ["forrest.properties", "../sd/src/documentation/resources/schema/symbols-project-v10.ent"])
        self.logfile.close()

    def revert_files(vcs, files):
        '''Revert the files in the list files
        '''
        if vcs == "svn":
            subp = subprocess.Popen(["svn", "revert"] + files, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            (output, error) = subp.communicate()

            if subp.returncode != 0:
                print >>sys.stderr, "Could not revert files"
                self.logfile.writelines(output)
                self.logfile.writelines(error)
        if vcs == "git":
            subp = subprocess.call(["git", "checkout"] + files)

    def set_font_path(self):
        '''Set the font path for needed by the pdf files.
        This is hardcoded to
        /Users/sd/trunk/xtdoc/sd/src/documentation/resources/fonts/config.xml
        '''
        for line in fileinput.FileInput(os.path.join(self.builddir, "src/documentation/resources/schema/symbols-project-v10.ent"), inplace=1):
            line = line.replace("/Users/sd/trunk/xtdoc/sd", self.builddir).strip()
            print line

    def validate(self):
        '''Run forrest validate
        '''
        print "Validating..."
        os.chdir(self.builddir)
        subp = subprocess.Popen(["forrest", "validate"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (output, error) = subp.communicate()

        if subp.returncode != 0:
            if "Could not validate document" in error:
                print >>sys.stderr, "\n\nCould not validate doc\n\n"
                self.logfile.writelines(output)
                self.logfile.writelines(error)

                raise SystemExit(subp.returncode)

    def buildsite(self, lang):
        """Builds a site in the specified language
        Clean up the build files
        Validate files. If they don't validate, exit program
        Build site. stdout and stderr are stored in output and error,
        respectively.
        If we aren't able to rename the built site, exit program
        """
        os.chdir(self.builddir)
        subp = subprocess.Popen(["forrest", "clean"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (output, error) = subp.communicate()

        if subp.returncode != 0:
            print >>sys.stderr, "forrest clean failed"
            self.logfile.writelines(output)
            self.logfile.writelines(error)

        print "Building", lang, "..."
        subp = subprocess.Popen(["forrest", "site"], stdout=self.logfile, stderr=self.logfile)
        subp.wait()
        if subp.returncode != 0:
            print >>sys.stderr, "Linking errors detected when building", lang

        print "Done building "

    def setlang(self, lang):
        """Set the language in the file forrest.properties
        Forrest uses this to build language specific sites
        Exit if an IOError occurs
        """
        try:
            inproperties = open(os.path.join(self.builddir, "forrest.properties"), 'r')
        except IOError:
            print >>sys.stderr, e
            self.logfile.write("Problems when reading content in forrest.properties")
            self.logfile.write("IOError\n")
            self.logfile.write(str(e) + "\n")
            raise SystemExit(2)
        incontent = inproperties.readlines()
        inproperties.close()

        try:
            outproperties = open(os.path.join(self.builddir, "forrest.properties"), 'w')
        except IOError:
            print >>sys.stderr, e
            self.logfile.write("Problems when writing content to forrest.properties")
            self.logfile.write("IOError\n")
            self.logfile.write(str(e) + "\n")
            raise SystemExit(2)


        for line in incontent:
            if "jvmargs" in line:
                line = line[:-1] + " -Duser.language=" + lang + "\n"
                if line[0] == "#":
                    line = line[1:]

            outproperties.write(line)

        outproperties.close()

    def rename_site_files(self, lang = ""):
        """Search for files ending with html and pdf in the build site. Give all
        these files the ending '.lang'. Move them to the 'built' dir
        """

        builddir = os.path.join(self.builddir, "build/site")
        builtdir = os.path.join(self.builddir, "built")

        # Copy the site to builtdir/lang
        if lang != "":
            langdir = os.path.join(builtdir, lang)
            os.mkdir(langdir)

            tree = os.walk(os.path.join(builddir))

            for leafs in tree:
                for directory in leafs[1]:
                    os.mkdir(langdir + leafs[0][len(builddir):] + "/" + directory)
                    try:
                        os.mkdir(builtdir + leafs[0][len(builddir):] + "/" + directory)
                    except OSError:
                        continue
                files = leafs[2]
                for htmlpdf_file in files:
                    if htmlpdf_file.endswith(".html"):
                        #print leafs[0], htmlpdf_file
                        self.add_lang_info(os.path.join(leafs[0], htmlpdf_file), lang)
                        #shutil.copy(os.path.join(leafs[0], htmlpdf_file), os.path.join(leafs[0], htmlpdf_file + "." + lang))
                        os.unlink(os.path.join(leafs[0], htmlpdf_file))
                    elif htmlpdf_file.endswith(".pdf"):
                        shutil.copy(os.path.join(leafs[0], htmlpdf_file), os.path.join(leafs[0].replace(builddir, builtdir),htmlpdf_file + "." + lang))
                        shutil.move(os.path.join(leafs[0], htmlpdf_file), os.path.join(leafs[0].replace(builddir, langdir),htmlpdf_file + "." + lang))
                    else:
                        shutil.copy(os.path.join(leafs[0], htmlpdf_file), os.path.join(leafs[0].replace(builddir, builtdir),htmlpdf_file))
                        shutil.move(os.path.join(leafs[0], htmlpdf_file), os.path.join(leafs[0].replace(builddir, langdir),htmlpdf_file))
        else:
            os.chdir(builddir)
            os.system("mv * " + builtdir)

        # Copy the site with renamed files to builtdir
        #shutil.copy(builddir, builtdir)

    def add_lang_info(self, filename, lang):
        trlangs = {"fi": "Suomeksi", "no": "På norsk", "sma": "Åarjelsaemien", "se": "Davvisámegillii", "smj": "Julevsábmáj", "sv": "På svenska" , "en": "In English"}
        #print 'filename', filename
        #print 'path', self.builddir + "/build/site"
        the_rest = filename[len(self.builddir + "/build/site"):]
        #print 'the_rest', the_rest
        infile = open(filename)
        outfile1 = open(self.builddir + "/built" + the_rest + "." + lang, "w")
        outfile2 = open(self.builddir + "/built/" + lang + the_rest, "w")

        filebuf = infile.readlines()
        for line in filebuf:
            if line.find('id="content"') > -1:
                line += '<div id="lang-choice">\n<ul>\n'
                for trlang, value in trlangs.items():
                    if trlang != lang:
                        line += '<li><a href="/' + trlang + the_rest + '">' + value + '</a>\n</li>\n'
                    else:
                        line += '<li>' + value + '</li>\n'
                line += '</ul>\n</div>\n'
                #print 'the line became', line
            outfile1.write(line)
            outfile2.write(line)

        infile.close()
        outfile1.close()
        outfile2.close()

    def copy_to_site(self):
        """Copy the entire site to self.destination
        """

        builtdir = os.path.join(self.builddir, "built/")
        os.system("rsync -qavz -e ssh " + builtdir + " " + self.destination + '.')

def parse_options():
    parser = argparse.ArgumentParser(description = 'This script builds a multilingual forrest site.')
    parser.add_argument('--destination', '-d', help = "an ssh destination", required = True)
    parser.add_argument('--vcs', '-c', help = "the version control system", default = 'svn')
    parser.add_argument('--sitehome', '-s', help = "where the forrest site lives", required = True)
    parser.add_argument('langs', help = "list of languages", nargs = '+')

    args = parser.parse_args()
    return args


def main():
    args = parse_options()

    builder = StaticSiteBuilder(args.sitehome, args.destination, args.vcs)
    builder.validate()

    for lang in args.langs:
        builder.setlang(lang)
        builder.buildsite(lang)
        if len(args.langs) == 1:
            builder.rename_site_files()
        else:
            builder.rename_site_files(lang)
    builder.copy_to_site()

if __name__ == "__main__":
    main()
