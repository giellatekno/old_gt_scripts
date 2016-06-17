#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''This script builds a multilingual forrest site.
--destination (-d) an ssh destination
--sitehome (-s) where sd and techdoc lives
'''

from __future__ import absolute_import
from __future__ import print_function

import argparse
import collections
import fileinput
import glob
import os
import re
import shutil
import subprocess
import sys
import time

import lxml.etree as etree


class StaticSiteBuilder(object):
    '''Class to build a multilingual static version of the divvun site.

    Args:
        builddir (str):     The directory where the forrest site is
        destination (str):  Where the built site is copied (using rsync)
        langs (list):       List of langs to be built

    Attributes:
        builddir (str): The directory where the forrest site is
        destination (str): where the built site is copied (using rsync)
        langs (list): list of langs to be built
        logfile (file handle)
    '''

    def __init__(self, builddir, destination, langs):
        print('Setting up...')
        if builddir.endswith('/'):
            builddir = builddir[:-1]
        self.builddir = builddir
        self.clean()

        if not destination.endswith('/'):
            destination = destination + '/'
        self.destination = destination
        self.langs = langs

        self.logfile_name = os.path.join(self.builddir,
                                         'buildlog' + time.strftime(
                                             '%Y-%m-%d-%H-%M',
                                             time.localtime()))

        if os.path.isdir(os.path.join(self.builddir, 'built')):
            shutil.rmtree(os.path.join(self.builddir, 'built'))

        os.mkdir(os.path.join(self.builddir, 'built'))

    def clean(self):
        subp = subprocess.Popen('forrest clean'.split(),
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                cwd=self.builddir)
        subp.wait()
        if subp.returncode != 0:
            print('forrest clean failed in {}'.format(self.builddir), file=sys.stderr)
            raise SystemExit(subp.returncode)

    def validate(self):
        '''Run forrest validate'''
        print('Validating...')
        subp = subprocess.Popen('forrest validate'.split(),
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                cwd=self.builddir)
        (output, error) = subp.communicate()

        if subp.returncode != 0:
            with open(self.logfile_name, 'w') as logfile:
                logfile.writelines(output)
                logfile.writelines(error)

            if 'Could not validate document' in error:
                print('Invalid xml files found, site was not built', file=sys.stderr)
                raise SystemExit(subp.returncode)

    def set_forrest_lang(self, lang):
        '''Set the language that should be built

        Args:
            lang (str): a two or three character long string
        '''
        for line in fileinput.FileInput(
            os.path.join(self.builddir, 'forrest.properties'),
                inplace=1):
            if 'forrest.jvmargs' in line:
                line = (
                    'forrest.jvmargs=-Djava.awt.headless=true '
                    '-Dfile.encoding=utf-8 -Duser.language={}'.format(lang)
                )
            if 'project.i18n' in line:
                line = 'project.i18n=true'
            print(line.rstrip())

    def parse_broken_links(self):
        '''Since the brokenlinks.xml file is not valid xml, do plain text parsing'''
        print('Broken links', file=sys.stderr)

        counter = collections.Counter()
        for line in fileinput.FileInput(os.path.join(self.builddir, 'build',
                                                     'tmp',
                                                     'brokenlinks.xml')):
            if '<link' in line and '</link>' in line:
                if 'tca2testing' in line:
                    counter['tca2testing'] += 1
                else:
                    counter['broken'] += 1
                    line = line.strip().replace('<link message="', '')
                    line = line.replace('</link>', '')

                    message = line[:line.rfind('"')]
                    text = line[line.rfind('>') + 1:]
                    print('{message}: {text}\n'.format(message=message, text=text), file=sys.stderr)
            elif '<link' in line:
                line = line.strip().replace('<link message="', '')
                print('{message}'.format(message=line), end=' ', file=sys.stderr)
            elif '</link>' in line:
                counter['broken'] += 1
                line = line.strip().replace('</link>', '')

                message = line[:line.rfind('"')]
                text = line[line.rfind('>') + 1:]
                print('{message}: {text}\n'.format(message=message, text=text), file=sys.stderr)

        for name, number in counter.items():
            if 'tca2' in name:
                print(name, file=sys.stderr, end=' ')
            print('{} broken links'.format(number), file=sys.stderr)

    def buildsite(self, lang):
        '''Builds a site in the specified language

        Clean up the build files
        Validate files. If they don't validate, exit program
        Build site. stdout and stderr are stored in output and error,
        respectively.
        If we aren't able to rename the built site, exit program

        Args:
            lang (str): a two or three character long string
        '''
        # This ensures that the build directory is build/site/en
        os.environ['LC_ALL'] = 'C'

        self.set_forrest_lang(lang)
        print('Building', lang, '...')
        subp = subprocess.Popen('forrest site'.split(),
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                cwd=self.builddir)
        (output, error) = subp.communicate()
        subp.wait()

        if subp.returncode != 0:
            with open(self.logfile_name, 'w') as logfile:
                print('Errors', file=logfile)
                print(error, file=logfile)
                print('Stdout', file=logfile)
                print(output, file=logfile)

            self.parse_broken_links()

    def add_language_changer(self, this_lang):
        '''Add a language changer in all .html files for one language

        Args:
            this_lang (str): a two or three character long string
        '''
        builddir = os.path.join(self.builddir, 'build/site/en')

        for root, dirs, files in os.walk(builddir):
            for f in files:
                if f.endswith('.html'):
                    f2b = LanguageAdder(os.path.join(root, f), this_lang,
                                        self.langs, builddir)
                    f2b.add_lang_info()

    def rename_site_files(self, lang):
        '''Search for files ending with html and pdf in the build site.

        Give all these files the ending '.lang'.
        Move them to the 'built' dir

        Args:
            lang (str): a two or three character long string
        '''

        builddir = os.path.join(self.builddir, 'build/site/en')
        builtdir = os.path.join(self.builddir, 'built')

        if len(self.langs) == 1:
            for item in glob.glob(builddir + '/*'):
                shutil.move(item, builtdir)
        else:
            for root, dirs, files in os.walk(builddir):
                goal_dir = root.replace('build/site/en', 'built')

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
        '''Copy the entire site to self.destination'''
        builtdir = os.path.join(self.builddir, 'built/')
        subp = subprocess.Popen(
            ['rsync', '-avz', '-e', 'ssh', builtdir, self.destination],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        subp.wait()

        ckdir = os.path.join(self.builddir, 'src/documentation/resources/ckeditor')
        if os.path.exists(ckdir):
            subp = subprocess.Popen(
                ['rsync', '-avz', '-e', 'ssh', ckdir, self.destination + 'skin/'],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            subp.wait()


class LanguageAdder(object):
    '''Add a language changer to an html document

    Args:
        filename (str):     path to the html file
        this_lang (str):     The language of this document
        langs (list):   The list of all languages that should added to the
                        language element
        builddir (str): The basedir where the html files are found

    Attributes:
        filename (str):     path to the html file
        this_lang (str):     The language of this document
        langs (list):   The list of all languages that should added to the
                        language element
        builddir (str): The basedir where the html files are found
        namespace (dict):   the namespace used in the html document
        tree (lxml etree):  an lxml etree of the parsed file
    '''
    def __init__(self, filename, this_lang, langs, builddir):
        self.filename = filename
        self.this_lang = this_lang
        self.langs = langs
        self.builddir = builddir

        self.namespace = {'html': 'http://www.w3.org/1999/xhtml'}
        self.tree = etree.parse(filename, etree.HTMLParser())

    def __del__(self):
        '''Write self.tree to self.filename'''
        with open(self.filename, 'w') as outhtml:
            outhtml.write(etree.tostring(self.tree, encoding='utf8',
                                         pretty_print=True, method='html'))

    def add_lang_info(self):
        '''Create the language navigation element and add it to self.tree

        '''
        my_nav_bar = self.tree.getroot().find('.//div[@id="myNavbar"]',
                                              namespaces=self.namespace)
        if my_nav_bar is not None:
            my_nav_bar.append(self.make_lang_menu())

    def make_lang_menu(self):
        '''Make the language menu for self.this_lang'''
        trlangs = {u'fi': u'Suomeksi', u'no': u'På norsk',
                   u'sma': u'Åarjelsaemien', u'se': u'Davvisámegillii',
                   u'smj': u'Julevsábmáj', u'sv': u'På svenska',
                   u'en': u'In English'}

        right_menu = etree.Element('ul')
        right_menu.set('class', 'nav navbar-nav navbar-right')

        dropdown = etree.Element('li')
        dropdown.set('class', 'dropdown')
        right_menu.append(dropdown)

        dropdown_toggle = etree.Element('a')
        dropdown_toggle.set('class', 'dropdown-toggle')
        dropdown_toggle.set('data-toggle', 'dropdown')
        dropdown_toggle.set('href', '#')
        dropdown_toggle.text = u'Change language'
        dropdown.append(dropdown_toggle)

        span = etree.Element('span')
        span.set('class', 'caret')
        dropdown_toggle.append(span)

        dropdown_menu = etree.Element('ul')
        dropdown_menu.set('class', 'dropdown-menu')
        dropdown.append(dropdown_menu)

        for lang in self.langs:
            if lang != self.this_lang:
                li = etree.Element('li')
                a = etree.Element('a')
                filename = '/' + lang + self.filename.replace(self.builddir, '')
                a.set('href', filename)
                a.text = trlangs[lang]
                li.append(a)
                dropdown_menu.append(li)

        return right_menu


def parse_options():
    parser = argparse.ArgumentParser(
        description='This script builds a multilingual forrest site.')
    parser.add_argument('--destination', '-d',
                        help='an ssh destination',
                        required=True)
    parser.add_argument('--sitehome', '-s',
                        help='where the forrest site lives',
                        required=True)
    parser.add_argument('langs', help='list of languages',
                        nargs='+')

    args = parser.parse_args()
    return args


def main():
    args = parse_options()

    builder = StaticSiteBuilder(args.sitehome, args.destination, args.langs)
    builder.validate()
    builder.build_all_langs()
    builder.copy_to_site()


if __name__ == '__main__':
    main()
