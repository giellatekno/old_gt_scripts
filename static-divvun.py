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
import argparse
import fileinput
import glob


class StaticSiteBuilder:
    """This class is used to build a multilingual static version of the divvun site.
    """

    def __init__(self, builddir, destination, vcs, langs):
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
        self.langs = langs

        self.logfile = open(
            os.path.join(self.builddir,
                         "buildlog" + time.strftime("%Y-%m-%d-%H-%M",
                                                    time.localtime())), 'w')
        os.chdir(self.builddir)
        self.revert_files(self.vcs,
                          ["forrest.properties",
                           "../sd/src/documentation/resources/schema/symbols-project-v10.ent"])

        subp = subprocess.Popen(["forrest", "clean"],
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        (output, error) = subp.communicate()

        if subp.returncode != 0:
                print >>sys.stderr, "forrest clean failed"
                self.logfile.writelines(output)
                self.logfile.writelines(error)

        self.set_font_path()

        if os.path.isdir(os.path.join(self.builddir, "built")):
            shutil.rmtree(os.path.join(self.builddir, "built"))

        os.mkdir(os.path.join(self.builddir, "built"))
        self.lang_specific_files = []

    def __del__(self):
        """Revert files that might be changed
        Close the logfile
        """
        os.chdir(self.builddir)
        self.revert_files(self.vcs,
                          ["forrest.properties",
                           "../sd/src/documentation/resources/schema/symbols-project-v10.ent"])
        self.logfile.close()

    def revert_files(self, vcs, files):
        '''Revert the files in the list files
        '''
        if vcs == "svn":
            subp = subprocess.Popen(["svn", "revert"] + files,
                                    stdout=subprocess.PIPE,
                                    stderr=subprocess.PIPE)
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
        for line in fileinput.FileInput(
            os.path.join(self.builddir,
                         "src/documentation/resources/schema/symbols-project-v10.ent"),
                inplace=1):
            line = line.replace("/Users/sd/trunk/xtdoc/sd",
                                self.builddir).strip()
            print line

    def validate(self):
        '''Run forrest validate
        '''
        print "Validating..."
        os.chdir(self.builddir)
        subp = subprocess.Popen(["forrest", "validate"],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
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
        # This ensures that the build directory is build/site/en
        os.environ['LC_ALL'] = "C"

        os.chdir(self.builddir)
        subp = subprocess.Popen(["forrest", "clean"],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (output, error) = subp.communicate()

        if subp.returncode != 0:
            print >>sys.stderr, "forrest clean failed"
            self.logfile.writelines(output)
            self.logfile.writelines(error)

        print "Building", lang, "..."
        subp = subprocess.Popen(["forrest", "site"],
                                stdout=self.logfile, stderr=self.logfile)
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
            inproperties = open(
                os.path.join(self.builddir, "forrest.properties"), 'r')
        except IOError as e:
            print >>sys.stderr, str(e)
            self.logfile.write("Problems when writing content to ")
            self.logfile.write("forrest.properties\n")
            self.logfile.write("IOError\n")
            self.logfile.write(str(e) + "\n")

        incontent = inproperties.readlines()
        inproperties.close()

        try:
            outproperties = open(
                os.path.join(self.builddir, "forrest.properties"), 'w')
        except IOError as e:
            print >>sys.stderr, str(e)
            self.logfile.write("Problems when writing content to ")
            self.logfile.write("forrest.properties\n")
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

    def rename_site_files(self, lang):
        """Search for files ending with html and pdf in the build site. Give all
        these files the ending '.lang'. Move them to the 'built' dir
        """

        builddir = os.path.join(self.builddir, "build/site/en")
        builtdir = os.path.join(self.builddir, "built")

        if len(self.langs) == 1:
            for item in glob.glob(builddir + '/*'):
                shutil.move(item, builtdir)
        else:
            for root, dirs, files in os.walk(builddir):
                goal_dir = root.replace("build/site/en", "built")

                if not os.path.exists(goal_dir):
                    os.mkdir(goal_dir)

                for file_ in files:
                    newname = file_
                    if file_.endswith('.html') or file_.endswith('.pdf'):
                        newname = file_ + '.' + lang

                    fullname = os.path.join(root, file_)
                    if file_.endswith('.html'):
                        self.add_lang_info(fullname, lang)
                    shutil.copy(
                        os.path.join(root, file_),
                        os.path.join(goal_dir, newname))

            shutil.move(builddir, os.path.join(builtdir, lang))

    def add_lang_info(self, filename, lang):
        trlangs = {"fi": "Suomeksi", "no": "På norsk", "sma": "Åarjelsaemien",
                   "se": "Davvisámegillii", "smj": "Julevsábmáj",
                   "sv": "På svenska", "en": "In English"}

        for line in fileinput.FileInput(filename, inplace=1):
            if line.find('id="content"') > -1:
                line += '<div id="lang-choice">\n<ul>\n'
                for trlang, value in trlangs.items():
                    if trlang != lang:
                        line += '<li><a href="/' + trlang + '/'
                        line += filename.replace('./build/site/en/', '')
                        line += '">' + value + '</a>\n</li>\n'
                    else:
                        line += '<li>' + value + '</li>\n'
                line += '</ul>\n</div>\n'
            print line.rstrip()

    def build_all_langs(self):
        '''Build all the langs
        '''
        for lang in self.langs:
            self.setlang(lang)
            self.buildsite(lang)
            self.rename_site_files(lang)

    def copy_to_site(self):
        """Copy the entire site to self.destination
        """
        builtdir = os.path.join(self.builddir, "built/")
        os.system("rsync -qavz -e ssh " + builtdir + " " +
                  self.destination + '.')


def parse_options():
    parser = argparse.ArgumentParser(
        description='This script builds a multilingual forrest site.')
    parser.add_argument('--destination', '-d',
                        help="an ssh destination",
                        required=True)
    parser.add_argument('--vcs', '-c',
                        help="the version control system",
                        default='svn')
    parser.add_argument('--sitehome', '-s',
                        help="where the forrest site lives",
                        required=True)
    parser.add_argument('langs', help="list of languages",
                        nargs='+')

    args = parser.parse_args()
    return args


def main():
    args = parse_options()

    builder = StaticSiteBuilder(args.sitehome, args.destination, args.vcs,
                                args.langs)
    builder.validate()
    builder.build_all_langs()
    builder.copy_to_site()


if __name__ == "__main__":
    main()
