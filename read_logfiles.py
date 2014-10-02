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

import iptocountry


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
        self.ip_to_country: instance of the class that maps ip numbers to
        countries
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
            'FDM 3.x']
        self.found_lists = []
        for i in range(0, len(self.our_targets.keys())):
            self.found_lists.append([])
        self.report_file = open(self.outfile, 'w')
        self.ip_to_country = iptocountry.IPToCountry()

    def write_header(self):
        self.report_file.write('!!!Download log for the Divvun tools\n\n')

    def write_summary(self):
        """
        Return how many lines we have
        """
        total_found = 0
        for found_list in self.found_lists:
            total_found = total_found + len(found_list)
        self.report_file.write('!!Summary of downloads\n\n')
        self.report_file.write('All of the Divvun tools have been downloaded ')
        self.report_file.write(str(total_found) + ' times\n\n')
        for x, target in enumerate(self.our_targets.keys()):
            self.report_file.write('* ' + self.our_targets[target] +
                                   ' has been downloaded ' +
                                   str(len(self.found_lists[x])) + ' times\n')
        return total_found

    def write_by_year(self):
        self.report_file.write('\n!!Downloads sorted by year\n')
        for x, target in enumerate(self.our_targets.keys()):
            year_dict = {}
            for found_line in self.found_lists[x]:
                year = self.get_year(found_line)
                sys.stderr.write('Year found: ' + year + ' ' +
                                 found_line + '\n')
                if year in year_dict:
                    year_dict[year] = year_dict[year] + 1
                else:
                    year_dict[year] = 1
            self.report_file.write('\n!' + self.our_targets[target] + '\n')
            self.report_file.write('|| Year || Count\n')
            for year, count in year_dict.items():
                self.report_file.write('|' + year + ' | ' + str(count) + '\n')

    def write_by_country(self):
        self.report_file.write('\n!!Downloads sorted by country\n')
        for x, target in enumerate(self.our_targets.keys()):
            counted_countries = {}
            for found_line in self.found_lists[x]:
                country = self.ip_to_country.get_countrycode(
                    found_line.split()[0]).upper()
                if country in counted_countries:
                    counted_countries[country] = counted_countries[country] + 1
                else:
                    counted_countries[country] = 1
            self.report_file.write('\n!' + self.our_targets[target] + '\n')
            self.report_file.write('|| Country || Count\n')

            for country in sorted(counted_countries,
                                  key=counted_countries.get, reverse=True):
                self.report_file.write('|' + country + ' | ' +
                                       str(counted_countries[country]) + '\n')

    def get_year(self, line):
        """
        The date is inside a [] pair and has the format:
        [day/month/year:hours:minutes:seconds timezone]
        """
        time_start = line.find('[') + 1
        time_end = line.find(']') - 1
        time_string = line[time_start:time_end].split()[0]
        cal_date = time_string.split(':')[0]
        return cal_date.split('/')[2]

    def find_lines(self):
        """
        Go through all the access log files in a given directory. Pick out
        the lines that has one our download goals, which has been fully fetched
        and which hasn't been downloaded by a bot.
        """
        for access_file in glob.glob(
                os.path.join(self.log_directory, '*access*')):
            sys.stderr.write('Now handling  ' + access_file + '\n')
            if access_file[-3:] == '.gz':
                infile = gzip.open(access_file)
            else:
                infile = open(access_file)
            for line in infile:
                bot_flag = False
                for bot in self.bots:
                    if line.find(bot) > 0:
                        bot_flag = True
                        pass
                if bot_flag is False:
                    for x, target in enumerate(self.our_targets.keys()):
                        if (line.find(target) != -1 and
                                line.find(' 200 ') != -1):
                            self.found_lists[x].append(line)
                            pass
                else:
                    pass

    def generate_report(self):
        self.write_header()
        total_lines = self.write_summary()
        self.write_by_year()
        self.write_by_country()
        self.debug_input(total_lines)

    def debug_input(self, total_found):
        debugfile = open('debugfile', 'w')
        numLines = 0
        for found_list in self.found_lists:
            for line in found_list:
                debugfile.write(line)
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
