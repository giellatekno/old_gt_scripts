#!/usr/bin/env python
# -*- coding: utf-8 -*
"""
This script parses apache log files found in a given directory.
It outputs a .jspwiki file, readable by forrest
Run it like this:
./read_logfiles.py <directory where apache log files are found> <outputfile>
"""
import sys
import os
import getopt
import glob
import gzip
import datetime
import lxml.etree as etree

import GeoIP
from logsparser.lognormalizer import LogNormalizer
normalizer = LogNormalizer('/usr/share/logsparser/normalizers')


class DivvunApacheLogParser:
    def __init__(self, args):
        """
        Initialize the variables the class needs to handle:
        self.log_directory: Where the log files are
        self.outfile: the output of the program
        self.our_targets: a dict between the downloadable targets and the
        human readable names
        self.bots: List over known bots
        self.found_lists: List of lines that fill the criteria lined out
        further down
        """
        self.log_directory, self.outfile = args
        self.our_targets = {
            'DivvunInstaller.exe': 'MSOffice/Windows',
            'sami-proofing-tools.dmg': 'MSOffice/Mac',
            'indesign-divvuntools.dmg': 'InDesign/Mac',
            'smi-pack.zip': 'OpenOffice.org, pre 3.0',
            'smi.oxt': 'OpenOffice.org 3.0',
            'hunspell-se.tar.gz': 'Hunspell/Unix, Northern Sami',
            'hunspell-smj.tar.gz': 'Hunspell/Unix, Lule Sami',
            'smi.zip': 'Hunspell/Generic'}
        self.bots = [
            'Yanga WorldSearch',
            'Yahoo! Slurp',
            'msnbot',
            'setooz',
            'Baiduspider',
            'Googlebot',
            'Java/',
            'Charlotte',
            'Fetch API Request',
            'Creative ZENcast',
            'iRc Search',
            'Webbot',
            'thorseek',
            'Jakarta Commons-HttpClient',
            'mlbot',
            'ia_archiver',
            'HTTrack',
            '"Mozilla/5.0"',
            'Gigabot',
            'Yandex',
            'Jeeves',
            'rdfbot',
            'Mail.Ru',
            'ichiro',
            'larbin',
            'Eniro NO',
            'Gaisbot',
            'localhost:8888',
            'Twiceler',
            'Nutch',
            'T-Rank',
            'webalta',
            'Microsoft URL Control',
            'favicon.ico',
            'DigExt',
            'Indy Library',
            'ScoutJet',
            'DBLBot',
            'msrbot',
            'MSIECrawler',
            'Arachmo',
            'yacybot',
            'FAST Search Enterprise Crawler',
            'DKIMRepBot',
            'DotBot',
            'BDFetch',
            'speedy_spider',
            'Python-urllib',
            'page_verifier',
            '80legs.com',
            'archive.org_bot',
            'SiteBot',
            'swish-e',
            'findfiles.net',
            'libwww-perl',
            'bingbot',
            'TurnitinBot',
            'CCBot',
            'crawler',
            'citeseerxbot',
            'Bot.ara.com.tr',
            'discobot',
            'LexxeBot',
            'Search17Bot',
            'FDM 3.x',
            'AhrefsBot',
            'SiteExplorer',
            'SEOkicks',
            'LinksCrawler',
            'heritrix',
            'BUbiNG',
            'PycURL',
            'SeznamBot',
            'SemrushBot',
            'Xenu Link Sleuth',
            'integromedb',
            'FatRat',
            'MJ12bot',
            'GSLFbot',
            'Download Master',
            'PuxaRapido',
            'Browserlet',
            'Purebot'
            ]
        self.found_lists = {}
        for key in self.our_targets.keys():
            self.found_lists[key] = []
        self.get_max_and_min_date()
        self.report_file = etree.Element('document')

    def get_max_and_min_date(self):
        '''Set max and min date
        If the date is not found in the xml file, if the xml file does not
        exist or if the file is empty, set default values.
        '''
        try:
            doc = etree.parse(self.outfile)
            self.mindate = datetime.datetime.strptime(
                doc.find('//em[@id="mindate"]').text, '%Y-%m-%d %H:%M:%S')
            self.maxdate = datetime.datetime.strptime(
                doc.find('//em[@id="maxdate"]').text,  '%Y-%m-%d %H:%M:%S')
        except (IOError, etree.XMLSyntaxError, AttributeError):
            self.mindate = datetime.datetime(2100, 1, 1, 0, 0, 0)
            self.maxdate = datetime.datetime(2000, 1, 1, 0, 0, 0)

    def write_header(self):
        header = etree.Element('header')
        title = etree.SubElement(header, 'title')
        title.text = u'Download log for the Divvun tools'

        return header

    def write_body(self):
        body = etree.Element('body')

        body.append(self.write_summary())
        body.append(self.write_by_country())
        body.append(self.write_by_year())
        body.append(self.write_by_useragent())

        return body

    def total_found(self):
        '''Sum up the number of lines found
        '''
        return sum([len(
            self.found_lists[key]) for key in self.found_lists.keys()])

    def make_p(self):
        p = etree.Element('p')
        p.text = u'All of the Divvun tools have been downloaded ' + \
            str(self.total_found()) + u' times between '

        em_min = etree.SubElement(p, 'em')
        em_min.set('id', 'mindate')
        em_min.text = str(self.mindate)
        em_min.tail = u' and '

        em_max = etree.SubElement(p, 'em')
        em_max.set('id', 'maxdate')
        em_max.text = str(self.maxdate)

        return p

    def make_ul(self):
        ul = etree.Element('ul')
        for target in self.our_targets.keys():
            li = etree.Element('li')
            ul.append(li)
            li.text = self.our_targets[target] + \
                ' has been downloaded ' + \
                str(len(self.found_lists[target])) + ' times'

        return ul

    def write_summary(self):
        """
        Return how many lines we have
        """
        section = self.make_section('Summary of downloads')
        section.append(self.make_p())
        section.append(self.make_ul())

        return section

    def write_by_year(self):
        section = self.make_section('Downloads sorted by year')

        for target in self.our_targets.keys():
            subsection = self.make_section(str(self.our_targets[target]))

            table = etree.Element('table')
            table.append(self.make_table_row(['Year', 'Count'], 'th'))

            year_dict = {}
            for found_line in self.found_lists[target]:
                year = found_line['date'].year
                if year in year_dict:
                    year_dict[year] += 1
                else:
                    year_dict[year] = 1

            self.make_table_body(table, year_dict)
            subsection.append(table)
            section.append(subsection)

        return section

    def make_table_body(self, table, dict_):
        for year in sorted(dict_,
                           key=dict_.get,
                           reverse=True):
            table.append(self.make_table_row([str(year), dict_[year]], 'td'))

    def make_section(self, text):
        section = etree.Element('section')
        etree.SubElement(section, 'title').text = text

        return section

    def make_table_row(self, text_list, element):
        tr = etree.Element('tr')
        for text in text_list:
            etree.SubElement(tr, element).text = str(text)

        return tr

    def write_by_useragent(self):
        section = self.make_section('Downloads sorted by useragent')

        for target in self.our_targets.keys():
            subsection = self.make_section(str(self.our_targets[target]))

            table = etree.Element('table')
            table.append(self.make_table_row(['Useragent', 'Count'], 'th'))

            year_dict = {}
            for found_line in self.found_lists[target]:
                year = found_line['useragent']
                if year in year_dict:
                    year_dict[year] = year_dict[year] + 1
                else:
                    year_dict[year] = 1

            self.make_table_body(table, year_dict)
            subsection.append(table)
            section.append(subsection)

        return section

    def write_by_country(self):
        section = self.make_section('Downloads sorted by country')

        locator = GeoIP.new(GeoIP.GEOIP_MEMORY_CACHE)
        for target in self.our_targets.keys():
            subsection = self.make_section(str(self.our_targets[target]))

            table = etree.Element('table')
            table.append(self.make_table_row(['Country', 'Count'], 'th'))

            counted_countries = {}
            for found_line in self.found_lists[target]:
                country = locator.country_name_by_addr(
                    found_line['source_ip'])

                if country is None:
                    country = 'Unknown'

                if country in counted_countries:
                    counted_countries[country] += 1
                else:
                    counted_countries[country] = 1

            self.make_table_body(table, counted_countries)
            subsection.append(table)
            section.append(subsection)

        return section

    def is_bot(self, line):
        """Check if the line contains one of the bots in self.bots
        Tried to implement this check as a regex, but runtime
        on a 100 000 line test access log went up to 18 seconds
        from about 2.5 seconds with this implementation on my
        test machine.
        """
        for bot in self.bots:
            if bot in line:
                return True

        return False

    def get_infile(self, filename):
        if filename[-3:] == '.gz':
            return gzip.open(filename)
        else:
            return open(filename)

    def set_date(self, date):
        if date < self.mindate:
            self.mindate = date
        if date > self.maxdate:
            self.maxdate = date

    def gather_lines(self, filename):
        for line in self.get_infile(filename):
            if self.is_bot(line) is False and ' 200 ' in line:
                for target in self.our_targets.keys():
                    if target in line:
                        l = {'raw': line,
                             'body': line}
                        normalizer.normalize(l)
                        self.found_lists[target].append(l)
                        self.set_date(l['date'])
                        break

    def find_lines(self):
        """
        Go through all the access log files in a given directory. Pick out
        the lines that has one our download goals, which has been fully fetched
        and which hasn't been downloaded by a bot.
        """
        for access_file in glob.glob(
                os.path.join(self.log_directory, '*access*')):
            self.gather_lines(access_file)

    def generate_report(self):
        self.report_file.append(self.write_header())
        self.report_file.append(self.write_body())
        o = open(self.outfile, 'w')
        o.write(etree.tostring(
            self.report_file,
            encoding=u'utf-8',
            pretty_print=True,
            xml_declaration=True,
            doctype='<!DOCTYPE document PUBLIC \
            "-//APACHE//DTD Documentation V2.0//EN" \
            "http://forrest.apache.org/dtd/document-v20.dtd">'))

    def debug_input(self):
        with open('debugfile', 'w') as debugfile:
            for key in self.found_lists.keys():
                [debugfile.write(line['raw']) for line in self.found_lists[key]]


def main():
    if len(sys.argv) != 3:
        print __doc__
        sys.exit(0)
    # parse command line options
    try:
        opts, args = getopt.getopt(sys.argv[1:], "h", ["help"])
    except getopt.error, msg:
        print msg
        print "for help use --help"
        sys.exit(2)
    # process options
    for o, a in opts:
        if o in ("-h", "--help"):
            print __doc__
            sys.exit(0)

    args = sys.argv[1:]

    divvun_parser = DivvunApacheLogParser(args)
    divvun_parser.find_lines()
    divvun_parser.generate_report()
    divvun_parser.debug_input()


if __name__ == "__main__":
    main()
