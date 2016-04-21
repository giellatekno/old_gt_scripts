#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""This script builds a multilingual forrest site.
--destination (-d) an ssh destination
--sitehome (-s) where sd and techdoc lives
"""

from __future__ import absolute_import
from __future__ import print_function
import argparse
import fileinput
import glob
import lxml.etree as etree
import os
import shutil
import subprocess
import sys
import time


class StaticSiteBuilder(object):
    """Class to build a multilingual static version of the divvun site."""

    def __init__(self, builddir, destination, langs):
        """
            builddir: The directory where the forrest site is
            destination: where the built site is copied (using ssh)
            langs: list of langs to be built

            Revert files that might be changed
            Clean up the build directory of the forrest site
        """
        print("Setting up...")
        if builddir.endswith('/'):
            builddir = builddir[:-1]
        self.builddir = builddir
        if not destination.endswith('/'):
            destination = destination + '/'
        self.destination = destination
        self.langs = langs

        self.logfile = open(
            os.path.join(self.builddir,
                         "buildlog" + time.strftime("%Y-%m-%d-%H-%M",
                                                    time.localtime())), 'w')
        os.chdir(self.builddir)
        subp = subprocess.Popen(["forrest", "clean"],
                                stdout=self.logfile, stderr=self.logfile)
        subp.wait()

        if subp.returncode != 0:
            print("forrest clean failed", file=sys.stderr)

        if os.path.isdir(os.path.join(self.builddir, "built")):
            shutil.rmtree(os.path.join(self.builddir, "built"))

        os.mkdir(os.path.join(self.builddir, "built"))

    def __del__(self):
        """Close the logfile"""
        self.logfile.close()

    def validate(self):
        '''Run forrest validate'''
        print("Validating...")
        os.chdir(self.builddir)
        subp = subprocess.Popen(["forrest", "validate"],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (output, error) = subp.communicate()
        self.logfile.writelines(output)
        self.logfile.writelines(error)

        if subp.returncode != 0:
            if "Could not validate document" in error:
                print("\n\nCould not validate doc\n\n", file=sys.stderr)
                raise SystemExit(subp.returncode)

    def set_forrest_lang(self, lang):
        for line in fileinput.FileInput(
            os.path.join(self.builddir, "forrest.properties"),
                inplace=1):
            if 'forrest.jvmargs' in line:
                line = (
                    'forrest.jvmargs=-Djava.awt.headless=true '
                    '-Dfile.encoding=utf-8 -Duser.language={}'.format(lang)
                )
            if 'project.i18n' in line:
                line = 'project.i18n=true'
            print(line.rstrip())

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
        self.set_forrest_lang(lang)
        print("Building", lang, "...")
        subp = subprocess.Popen(["forrest", "site"],
                                stdout=self.logfile, stderr=self.logfile)
        subp.wait()
        if subp.returncode != 0:
            print("Linking errors detected when building", lang, file=sys.stderr)

        print("Done building ")

    def add_language_changer(self, lang):
        builddir = os.path.join(self.builddir, "build/site/en")

        for root, dirs, files in os.walk(builddir):
            for f in files:
                if f.endswith('.html'):
                    f2b = LanguageAdder(os.path.join(root, f))
                    f2b.convert(lang, self.langs, builddir)

    def rename_site_files(self, lang):
        """Search for files ending with html and pdf in the build site.

        Give all these files the ending '.lang'.
        Move them to the 'built' dir
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
                    shutil.copy(
                        os.path.join(root, file_),
                        os.path.join(goal_dir, newname))

            shutil.move(builddir, os.path.join(builtdir, lang))

    def build_all_langs(self):
        '''Build all the langs'''
        for lang in self.langs:
            self.buildsite(lang)
            if len(self.langs) > 1:
                self.add_language_changer(lang)
            self.rename_site_files(lang)

    def copy_to_site(self):
        """Copy the entire site to self.destination"""
        builtdir = os.path.join(self.builddir, "built/")
        subp = subprocess.Popen(
            ["rsync", "-avz", "-e", "ssh", builtdir, self.destination],
            stdout=self.logfile, stderr=self.logfile)
        subp.wait()


class LanguageAdder(object):
    '''Add a language changer to an html document'''
    def __init__(self, f):
        self.f = f
        self.namespace = {'html': 'http://www.w3.org/1999/xhtml'}
        parser = etree.HTMLParser()
        self.tree = etree.parse(f, parser)

    def getroot(self):
        return self.tree.getroot()

    def getelement(self, tag):
        return self.getroot().find(
            './/' + tag, namespaces=self.namespace)

    def add_lang_info(self, lang, langs, builddir):
        body = self.getelement('body')
        my_nav_bar = body.find('.//div[@id="myNavbar"]',
                               namespaces=self.namespace)
        my_nav_bar.append(self.make_lang_menu(lang, langs, builddir))

    def make_lang_menu(self, this_lang, langs, builddir):
        trlangs = {u"fi": u"Suomeksi", u"no": u"På norsk",
                   u"sma": u"Åarjelsaemien", u"se": u"Davvisámegillii",
                   u"smj": u"Julevsábmáj", u"sv": u"På svenska",
                   u"en": u"In English"}

        right_menu = etree.Element('ul')
        right_menu.set('class', 'nav navbar-nav navbar-right')

        dropdown = etree.Element('li')
        dropdown.set('class', 'dropdown')
        right_menu.append(dropdown)

        dropdown_toggle = etree.Element('a')
        dropdown_toggle.set('class', 'dropdown-toggle')
        dropdown_toggle.set('data-toggle', 'dropdown')
        dropdown_toggle.set('href', '#')
        dropdown_toggle.text = u"Change language"
        dropdown.append(dropdown_toggle)

        span = etree.Element('span')
        span.set('class', 'caret')
        dropdown_toggle.append(span)

        dropdown_menu = etree.Element('ul')
        dropdown_menu.set('class', 'dropdown-menu')
        dropdown.append(dropdown_menu)

        for lang in langs:
            if lang != this_lang:
                li = etree.Element('li')
                a = etree.Element('a')
                filename = '/' + lang + self.f.replace(builddir, '')
                a.set('href', filename)
                a.text = trlangs[lang]
                li.append(a)
                dropdown_menu.append(li)

        return right_menu

    def convert(self, lang, langs, builddir):
        self.add_lang_info(lang, langs, builddir)
        with open(self.f, 'w') as huff:
            huff.write(etree.tostring(self.tree, encoding='utf8',
                                      pretty_print=True, method='html'))


def parse_options():
    parser = argparse.ArgumentParser(
        description='This script builds a multilingual forrest site.')
    parser.add_argument('--destination', '-d',
                        help="an ssh destination",
                        required=True)
    parser.add_argument('--sitehome', '-s',
                        help="where the forrest site lives",
                        required=True)
    parser.add_argument('langs', help="list of languages",
                        nargs='+')

    args = parser.parse_args()
    return args


def main():
    args = parse_options()

    builder = StaticSiteBuilder(args.sitehome, args.destination, args.langs)
    builder.validate()
    builder.build_all_langs()
    builder.copy_to_site()


if __name__ == "__main__":
    main()
