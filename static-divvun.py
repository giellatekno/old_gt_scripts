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
                                stdout=self.logfile, stderr=self.logfile)
        subp.wait()

        if subp.returncode != 0:
            print >>sys.stderr, "forrest clean failed"

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
            subp = subprocess.Popen(
                ["svn", "revert"] + files,
                stdout=self.logfile, stderr=self.logfile)
            subp.wait()

            if subp.returncode != 0:
                print >>sys.stderr, "Could not revert files"
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
                                stdout=self.logfile, stderr=self.logfile)
        subp.wait()

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
                                stdout=self.logfile, stderr=self.logfile)
        subp.wait()

        if subp.returncode != 0:
            print >>sys.stderr, "forrest clean failed"

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
                        self.add_lang_info(fullname, lang, builddir)
                    shutil.copy(
                        os.path.join(root, file_),
                        os.path.join(goal_dir, newname))

            shutil.move(builddir, os.path.join(builtdir, lang))

    def add_lang_info(self, filename, lang, builddir):
        trlangs = {"fi": "Suomeksi", "no": "På norsk", "sma": "Åarjelsaemien",
                   "se": "Davvisámegillii", "smj": "Julevsábmáj",
                   "sv": "På svenska", "en": "In English"}

        for line in fileinput.FileInput(filename, inplace=1):
            if line.find('id="content"') > -1:
                line += '<div id="lang-choice">\n<ul>\n'
                for trlang, value in trlangs.items():
                    if trlang != lang:
                        line += '<li><a href="/' + trlang + '/'
                        line += filename.replace(builddir, '')
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
        self.namespace = {'xhtml': 'http://www.w3.org/1999/xhtml'}
        self.tree = etree.parse(f)

    def getroot(self):
        return self.tree.getroot()

    def getelement(self, tag):
        return self.getroot().find(
            './/xhtml:' + tag, namespaces=self.namespace)

    def handle_head(self):
        head = self.getelement('head')

        for element in head:
            if element.tag != '{http://www.w3.org/1999/xhtml}title':
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
                'id': ['branding-tagline-name', 'branding-tagline-tagline'],
                },
            }

        for tag, attribs in unwanted.items():
            for key, values in attribs.items():
                for value in values:
                    e = body.find('.//xhtml:' + tag +
                                  '[@' + key + '="' + value + '"]',
                                  namespaces=self.namespace)
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

        container = body.find('.//xhtml:div[@id="container"]',
                              namespaces=self.namespace)
        container.set('class', 'container-fluid')
        container.insert(0, self.nav_main_hook2navbar())

        self.menu2accordion()

        header = body.find('.//xhtml:div[@id="header"]',
                           namespaces=self.namespace)
        header.set('class', 'col-sm-12')

        leftbar = body.find('.//xhtml:div[@id="leftbar"]',
                            namespaces=self.namespace)
        leftbar.set('class', 'col-sm-4')

        content = body.find('.//xhtml:div[@id="content"]',
                            namespaces=self.namespace)
        content.set('class', 'col-sm-8')


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
        for i in body.xpath('.//xhtml:img[@class="logoImage"]',
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

        nav_main = body.find('.//xhtml:ul[@id="nav-main"]',
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
        menu = body.find('.//xhtml:div[@id="nav-section"]/xhtml:ul',
                              namespaces=self.namespace)

        menu.set('class', 'nav nav-sidebar')

        for element in menu.iter():
            c = element.get('class')
            if c == 'pagegroup' or c == 'pagegroupselected':
                self.pagegroup2panelgroup(element)
            elif c == 'menuitem':
                element.attrib.pop('class')
            elif (c == 'menuitemgroup' or c == 'selectedmenuitemgroup'):
                self.menuitemgroup2panelcollapse(element)

        self.set_in(menu)

    def set_in(self, menu):
        collapse = menu.xpath('.//div[@class="panel-collapse collapse"]')
        for c in collapse:
            menupage = c.find('.//xhtml:li[@class="menupage"]',
                                 namespaces=self.namespace)
            if menupage is not None:
                c.set('class', 'panel-collapse collapse in')



    def menuitemgroup2panelcollapse(self, element):
        id = element.get('id').replace('.', '_')
        element.attrib.pop('class')
        element.attrib.pop('id')
        parent = element.getparent()
        index = parent.index(element)

        panelbody = etree.Element('div')
        panelbody.set('class', 'panel-body')
        panelbody.append(element)

        panelcollapse = etree.Element('div')
        panelcollapse.set('class', 'panel-collapse collapse')
        panelcollapse.set('id', id)
        panelcollapse.append(panelbody)

        parent.insert(index, panelcollapse)

    def convert(self):
        self.handle_head()
        self.handle_body()

        with open(self.f + '.bg', 'w') as huff:
            huff.write(etree.tostring(self.tree, encoding='UTF-8', pretty_print=True))

    def pagegroup2panelgroup(self, element):
        id = element.get('id').replace('.', '_')
        element.attrib.pop('id')

        self.span2panelhead(element[0], id)

        element.tag = 'div'
        element.set('class', 'panel panel-default')

        element_parent = element.getparent()
        index = element_parent.index(element)

        panelgroup = etree.Element('div')
        panelgroup.set('class', 'panel-group')
        panelgroup.set('id', id)
        panelgroup.append(element)

        element_parent.insert(index, panelgroup)

    def span2panelhead(self, span, id):
        span_parent = span.getparent()
        index = span_parent.index(span)

        span.tag = 'a'
        span.attrib.pop('onclick')
        span.set('data-toggle', 'collapse')
        span.set('data-parent', '#' + id)
        span.set('href', '#' + id.replace('Title', ''))

        h4 = etree.Element('h4')
        h4.set('class', 'panel-title')
        h4.append(span)

        panel_heading = etree.Element('div')
        panel_heading.set('class', 'panel-heading')
        panel_heading.append(h4)

        span_parent.insert(index, panel_heading)


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
