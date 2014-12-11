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
import lxml.etree as etree

class StaticSiteBuilder:
    """This class is used to build a multilingual static version of the divvun site.
    """

    def __init__(self, builddir, destination, langs):
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
            print >>sys.stderr, "forrest clean failed"

        if os.path.isdir(os.path.join(self.builddir, "built")):
            shutil.rmtree(os.path.join(self.builddir, "built"))

        os.mkdir(os.path.join(self.builddir, "built"))

    def __del__(self):
        """Close the logfile
        """
        self.logfile.close()

    def validate(self):
        '''Run forrest validate
        '''
        print "Validating..."
        os.chdir(self.builddir)
        subp = subprocess.Popen(["forrest", "validate"],
                                stdout=self.logfile, stderr=self.logfile)
        subp.wait()

        if subp.returncode != 0:
            if "Could not validate document" in error:
                print >>sys.stderr, "\n\nCould not validate doc\n\n"
                self.logfile.writelines(output)
                self.logfile.writelines(error)

                raise SystemExit(subp.returncode)

    def set_forrest_lang(self, lang):
        for line in fileinput.FileInput(
            os.path.join(self.builddir, "forrest.properties"),
                inplace=1):
            if 'forrest.jvmargs' in line:
                line = 'forrest.jvmargs=-Djava.awt.headless=true -Dfile.encoding=utf-8 -Duser.language=' + lang
            print line.rstrip()

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
        print "Building", lang, "..."
        subp = subprocess.Popen(["forrest", "site"],
                                stdout=self.logfile, stderr=self.logfile)
        subp.wait()
        if subp.returncode != 0:
            print >>sys.stderr, "Linking errors detected when building", lang

        print "Done building "

    def tobootstrap(self, lang):
        builddir = os.path.join(self.builddir, "build/site/en")

        for root, dirs, files in os.walk(builddir):
            for f in files:
                if f.endswith('.html'):
                    f2b = Forrest2Bootstrap(os.path.join(root, f))
                    f2b.convert(lang, self.langs, builddir)

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
                    shutil.copy(
                        os.path.join(root, file_),
                        os.path.join(goal_dir, newname))

            shutil.move(builddir, os.path.join(builtdir, lang))

    def build_all_langs(self):
        '''Build all the langs
        '''
        for lang in self.langs:
            self.buildsite(lang)
            self.tobootstrap(lang)
            self.rename_site_files(lang)

    def copy_to_site(self):
        """Copy the entire site to self.destination
        """
        builtdir = os.path.join(self.builddir, "built/")
        subp = subprocess.Popen(
            ["rsync", "-avz", "-e", "ssh", builtdir, self.destination],
            stdout=self.logfile, stderr=self.logfile)
        subp.wait()


class Forrest2Bootstrap(object):
    '''Class to convert an html document built with forrest
    to use the Twitter Bootstrap framework
    '''
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

    def handle_head(self):
        head = self.getelement('head')

        for element in head:
            if element.tag != 'title':
                element.getparent().remove(element)


        e1 = etree.Element('meta')
        e1.set('charset', 'utf-8')
        head.append(e1)

        e2 = etree.Element('meta')
        e2.set('name', 'viewport')
        e2.set('content', 'width=device-width, initial-scale=1')
        head.append(e2)

        e3 = etree.Element('link')
        e3.set('rel', 'stylesheet')
        e3.set( 'href', 'http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css')
        head.append(e3)

    def remove_unwanted(self):
        body = self.getelement('body')

        unwanted = {
            'div': {
                'id': ['branding-tagline-name', 'branding-tagline-tagline',
                       'publishedStrip', 'level2tabs', 'roundbottom'],
                'class': ['searchbox', 'breadtrail']
                },
            }

        for tag, attribs in unwanted.items():
            for key, values in attribs.items():
                for value in values:
                    elements = body.xpath('.//' + tag +
                                  '[@' + key + '="' + value + '"]',
                                  namespaces=self.namespace)

                    for e in elements:
                        e.getparent().remove(e)


    def add_bootstrap_body(self):
        body = self.getelement('body')
        b = ['https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js',
             'http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js']
        for value in b:
            s = etree.Element('script')
            s.set('src', value)
            body.append(s)

    def handle_body(self):
        self.remove_unwanted()
        self.add_bootstrap_body()
        self.set_bootstrap_classes()

    def set_bootstrap_classes(self):
        body = self.getelement('body')

        container = body.find('.//div[@id="main"]',
                              namespaces=self.namespace)
        container.set('class', 'container-fluid')


        header = body.find('.//div[@class="header"]',
                           namespaces=self.namespace)
        header.set('class', 'header col-sm-12')
        header.insert(0, self.nav_main_hook2navbar())

        self.menu2accordion()
        leftbar = body.find('.//div[@id="menu"]',
                            namespaces=self.namespace)
        leftbar.set('class', 'col-sm-4')

        content = body.find('.//div[@id="content"]',
                            namespaces=self.namespace)
        content.set('class', 'col-sm-8')

        for img in content.xpath('.//img',
                                 namespaces=self.namespace):
            if img.get('class') != 'icon':
                img.set('class', 'img-responsive')

        for table in content.xpath('.//table',
                                 namespaces=self.namespace):
            if table.get('class') == 'invisible':
                table.attrib.pop('class')

    def nav_main_hook2navbar(self):
        body = self.getelement('body')

        button = etree.Element('button')
        button.set('type', 'button')
        button.set('class', 'navbar-toggle')
        button.set('data-toggle', 'collapse')
        button.set('data-target', '#myNavbar')

        for i in range(0, 3):
            span = etree.Element('span')
            span.set('class', 'icon-bar')
            button.append(span)

        huff = etree.Element('div')
        huff.set('id', 'huff')
        for i in body.xpath('.//img[@class="logoImage"]',
                            namespaces=self.namespace):
            i.set('height', '30')
            huff.append(i)

        a_brand = etree.Element('a')
        a_brand.set('class', 'navbar-brand')
        a_brand.set('href', '/index.html')
        a_brand.append(huff)

        navbar_header = etree.Element('div')
        navbar_header.set('class', 'navbar-header')
        navbar_header.append(button)
        navbar_header.append(a_brand)

        menu_div = etree.Element('div')
        menu_div.set('id', 'myNavbar')
        menu_div.set('class', 'collapse navbar-collapse')
        huff = self.get_forrest_tabs()
        menu_div.append(huff)

        div_fluid = etree.Element('div')
        div_fluid.set('class', 'container-fluid')
        div_fluid.append(navbar_header)
        div_fluid.append(menu_div)

        nav = etree.Element('nav')
        nav.set('class', 'navbar navbar-default')
        nav.append(div_fluid)

        return nav

    def get_forrest_tabs(self):
        body = self.getelement('body')

        nav_main = body.find('.//ul[@id="tabs"]',
                              namespaces=self.namespace)
        nav_main.attrib.pop('id')
        nav_main.set('class', 'nav navbar-nav')

        for li in nav_main:
            if li.get('class') == 'current':
                li.set('class', 'active')
            else:
                if li.get('class') is not None:
                    li.attrib.pop('class')

            li[0].attrib.pop('class')

        return nav_main
        body = self.getelement('body')

    def menu2accordion(self):
        '''
        class "menupage" -> class="panel-collapse collapse in", forelderen til dette elementet skal være åpen
        class "menuitem" -> remove class
        li class "pagegroup" -> div class "panel panel-default"
            etterfølgende span blir
            div class panel-heading
                h4 panel-title
                    a data-toggle="collapse", etc
            ul class menuitemgroup -> omsluttes av div class panel-body, fjern klassen
        '''
        body = self.getelement('body')
        menu = body.find('.//div[@id="menu"]',
                              namespaces=self.namespace)
        menu.set('class', 'nav nav-sidebar')
        menu.attrib.pop('id')
        menu.tag = 'ul'
        menu_parent = menu.getparent()
        menu_index = menu_parent.index(menu)


        new_menu = etree.Element('div')
        new_menu.set('id', 'menu')
        new_menu.append(menu)

        menu_parent.insert(menu_index, new_menu)

        for element in menu.iter():
            c = element.get('class')
            if c == 'menutitle':
                element.tag = 'li'
                self.pagegroup2panelgroup(element)
            elif c == 'menuitem':
                element.attrib.pop('class')
                element.tag = 'li'
            elif c == 'menupage':
                element.tag = 'li'
            elif (c == 'menuitemgroup' or c == 'selectedmenuitemgroup'):
                self.menuitemgroup2panelcollapse(element)

        self.set_in(menu)

    def set_in(self, menu):
        '''Open all the collapsed menu items that contain the active document
        '''
        collapse = menu.xpath('.//div[@class="accordion-collapse collapse"]',
                              namespaces=self.namespace)
        for c in collapse:
            menupage = c.find('.//li[@class="menupage"]',
                                 namespaces=self.namespace)
            if menupage is not None:
                c.set('class', 'accordion-collapse collapse in')

    def menuitemgroup2panelcollapse(self, element):
        id = element.get('id').replace('.', '_')
        element.attrib.pop('class')
        element.attrib.pop('id')
        #element.attrib.pop('style')
        element.tag = 'ul'
        parent = element.getparent()
        index = parent.index(element)

        panelbody = etree.Element('div')
        panelbody.set('class', 'accordion-body')
        panelbody.append(element)

        panelcollapse = etree.Element('div')
        panelcollapse.set('class', 'accordion-collapse collapse')
        panelcollapse.set('id', id)
        panelcollapse.append(panelbody)

        parent.insert(index, panelcollapse)

    def pagegroup2panelgroup(self, element):
        id = element.get('id').replace('.', '_')
        element.attrib.pop('id')
        element.attrib.pop('onclick')

        element.insert(0, self.panelhead(element, id))

        element.tag = 'div'
        element.set('class', 'accordion accordion-default')

        element_parent = element.getparent()
        index = element_parent.index(element)

        panelgroup = etree.Element('div')
        panelgroup.set('class', 'accordion-group')
        panelgroup.set('id', id)
        panelgroup.append(element)

        element_parent.insert(index, panelgroup)

    def panelhead(self, element, id):
        a = etree.Element('a')
        a.set('data-toggle', 'collapse')
        a.set('data-parent', '#' + id)
        a.set('href', '#' + id.replace('Title', ''))
        a.text = element.text
        element.text = None

        h4 = etree.Element('h4')
        h4.set('class', 'accordion-title')
        h4.append(a)

        panel_heading = etree.Element('div')
        panel_heading.set('class', 'accordion-heading')
        panel_heading.append(h4)

        return panel_heading

    def add_lang_info(self, lang, langs, builddir):
        body = self.getelement('body')
        my_nav_bar = body.find('.//div[@id="myNavbar"]',
                           namespaces=self.namespace)
        my_nav_bar.append(self.make_lang_menu(lang, langs, builddir))

    def make_lang_menu(self, this_lang, langs, builddir):
        trlangs = {u"fi": u"Suomeksi", u"no": u"På norsk", u"sma": u"Åarjelsaemien",
                   u"se": u"Davvisámegillii", u"smj": u"Julevsábmáj",
                   u"sv": u"På svenska", u"en": u"In English"}

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
                filename = '/' + lang + '/' + self.f.replace(builddir, '')
                a.set('href', filename)
                a.text = trlangs[lang]
                li.append(a)
                dropdown_menu.append(li)

        return right_menu



    def convert(self, lang, langs, builddir):
        self.handle_head()
        self.handle_body()
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
