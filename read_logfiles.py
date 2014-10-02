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
        self.report_file = open(self.outfile, 'w')
        self.mindate = datetime.datetime(2100, 1, 1, 0, 0, 0)
        self.maxdate = datetime.datetime(2000, 1, 1, 0, 0, 0)

    def write_header(self):
        self.report_file.write('''<?xml version="1.0" encoding="UTF-8"?>\n''')
        self.report_file.write('''<!DOCTYPE document PUBLIC "-//APACHE//DTD Documentation V2.0//EN"\n''')
        self.report_file.write('''"http://forrest.apache.org/dtd/document-v20.dtd">\n''')
        self.report_file.write('''<document xml:lang="en">\n''')
        self.report_file.write('''<header>\n''')
        self.report_file.write('<title>Download log for the Divvun tools</title>\n')
        self.report_file.write('''</header>\n''')
        self.report_file.write('''<body>\n''')

    def write_footer(self):
        self.report_file.write('''</body>\n''')
        self.report_file.write('''</document>\n''')

    def write_summary(self):
        """
        Return how many lines we have
        """
        total_found = 0
        for key in self.found_lists.keys():
            total_found = total_found + len(self.found_lists[key])
        self.report_file.write('<section>\n')
        self.report_file.write('<title>Summary of downloads</title>\n')
        self.report_file.write('<p>All of the Divvun tools have been downloaded ')
        self.report_file.write(str(total_found) + ' times between <em id="mindate">')
        self.report_file.write(str(self.mindate))
        self.report_file.write('</em> and <em id="maxdate">')
        self.report_file.write(str(self.maxdate))
        self.report_file.write('</em></p>\n')
        self.report_file.write('<ul>\n')
        for target in self.our_targets.keys():
            self.report_file.write('<li>' + self.our_targets[target] +
                                   ' has been downloaded ' +
                                   str(len(self.found_lists[target])) + ' times</li>\n')
        self.report_file.write('</ul>\n')
        self.report_file.write('</section>\n')
        return total_found

    def write_by_year(self):
        self.report_file.write('<section>\n')
        self.report_file.write('<title>Downloads sorted by year</title>\n')
        for target in self.our_targets.keys():
            year_dict = {}
            for found_line in self.found_lists[target]:
                year = found_line['date'].year
                if year in year_dict:
                    year_dict[year] = year_dict[year] + 1
                else:
                    year_dict[year] = 1
            self.report_file.write('<section>\n')
            self.report_file.write('<title>' + self.our_targets[target] + '</title>\n')
            self.report_file.write('<table>\n')
            self.report_file.write('<tr><th>Year</th><th>Count</th></tr>\n')
            for year in sorted(year_dict,
                                      key=year_dict.get,
                                      reverse=True):
                self.report_file.write('<tr><td>' + str(year) + '</td><td>' + str(year_dict[year]) + '</td></tr>\n')
            self.report_file.write('</table>\n')
            self.report_file.write('</section>\n')
        self.report_file.write('</section>\n')

    def write_by_useragent(self):
        self.report_file.write('<section>\n')
        self.report_file.write('<title>Downloads sorted by useragent</title>\n')
        for target in self.our_targets.keys():
            year_dict = {}
            for found_line in self.found_lists[target]:
                year = found_line['useragent']
                if year in year_dict:
                    year_dict[year] = year_dict[year] + 1
                else:
                    year_dict[year] = 1
            self.report_file.write('<section>\n')
            self.report_file.write('<title>' + self.our_targets[target] + '</title>\n')
            self.report_file.write('<table>\n')
            self.report_file.write('<tr><th>Useragent string</th><th>Count</th></tr>\n')
            for year in sorted(year_dict,
                               key=year_dict.get,
                               reverse=True):
                self.report_file.write('<tr><td>' + str(year) + '</td><td>' + str(year_dict[year]) + '</td></tr>\n')
            self.report_file.write('</table>\n')
            self.report_file.write('</section>\n')
        self.report_file.write('</section>\n')

    def write_by_country(self):
        locator = GeoIP.new(GeoIP.GEOIP_MEMORY_CACHE)
        self.report_file.write('<section>\n')
        self.report_file.write('<title>Downloads sorted by country</title>\n')
        for target in self.our_targets.keys():
            counted_countries = {}
            for found_line in self.found_lists[target]:
                country = locator.country_name_by_addr(
                    found_line['source_ip'])
                if country is not None:
                    if country in counted_countries:
                        counted_countries[country] = counted_countries[country] + 1
                    else:
                        counted_countries[country] = 1
                else:
                    print 'no country', found_line['raw']

            self.report_file.write('<section>\n')
            self.report_file.write('<title>' + self.our_targets[target] + '</title>\n')
            self.report_file.write('<table>\n')
            self.report_file.write('<tr><th>Country</th><th>Count</th></tr>\n')
            for country in sorted(counted_countries,
                                  key=counted_countries.get, reverse=True):
                self.report_file.write('<tr><td>' + country + '</td><td>' +
                                       str(counted_countries[country]) + '</td></tr>\n')
            self.report_file.write('</table>\n')
            self.report_file.write('</section>\n')
        self.report_file.write('</section>\n')

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

    def find_lines(self):
        """
        Go through all the access log files in a given directory. Pick out
        the lines that has one our download goals, which has been fully fetched
        and which hasn't been downloaded by a bot.
        """
        lines = 1
        for access_file in glob.glob(
                os.path.join(self.log_directory, '*access*')):
            sys.stderr.write('Now handling  ' + access_file + '\n')
            if access_file[-3:] == '.gz':
                infile = gzip.open(access_file)
            else:
                infile = open(access_file)
            for line in infile:
                if lines % 100000 == 0:
                    print lines
                lines += 1
                if self.is_bot(line) is False and ' 200 ' in line:
                    for target in self.our_targets.keys():
                        if target in line:
                            l = {'raw': line,
                                 'body': line}
                            normalizer.normalize(l)
                            self.found_lists[target].append(l)
                            if l['date'] < self.mindate:
                                self.mindate = l['date']
                            if l['date'] > self.maxdate:
                                self.maxdate = l['date']
                            pass

    def generate_report(self):
        self.write_header()
        total_lines = self.write_summary()
        self.write_by_year()
        self.write_by_country()
        self.write_by_useragent()
        self.write_footer()
        self.debug_input(total_lines)

    def debug_input(self, total_found):
        debugfile = open('debugfile', 'w')
        numLines = 0
        for key in self.found_lists.keys():
            for line in self.found_lists[key]:
                debugfile.write(line['raw'])
                numLines = numLines + 1
        debugfile.write('Number of lines' + str(numLines) + '\n')
        debugfile.write('TotalFound reported: ' + str(total_found) + '\n')
        debugfile.close()


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


if __name__ == "__main__":
    main()
