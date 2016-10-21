#!/usr/bin/env python
# -*- coding: utf-8 -*
"""This script parses apache log files found in a given directory.

It outputs an xml file, readable by forrest
"""

import argparse
import datetime
import glob
import gzip
import os

import GeoIP
import lxml.etree as etree
from logsparser.lognormalizer import LogNormalizer

normalizer = LogNormalizer('/usr/share/logsparser/normalizers')


class DivvunApacheLogParser(object):
    """Get interesting data about divvun downloads.

    Attributes:
        bots (list): list of known bots.
        found_lists (dict):
        log_directory (str): path to the directory where log files are found.
        found_newlines (boolean): True if new lines are found, False otherwise.
    """

    bots = [
        '80legs.com',
        'AcoonBot',
        'AhrefsBot',
        'AraBot',
        'Arachmo',
        'BDFetch',
        'BUbiNG',
        'Baiduspider',
        'Bot,Robot,Spider,Crawler',
        'Bot.ara.com.tr',
        'Browserlet',
        'CCBot',
        'Charlotte',
        'CompSpyBot',
        'Creative ZENcast',
        'DBLBot',
        'DCPbot',
        'DKIMRepBot',
        'DigExt',
        'DotBot',
        'Download Master',
        'EdisterBot',
        'Eniro NO',
        'Eurobot',
        'Exabot',
        'Ezooms',
        'FAST Search Enterprise Crawler',
        'FDM 3.x',
        'FatRat',
        'Fetch API Request',
        'FigleafBot',
        'GSLFbot',
        'Gaisbot',
        'Gigabot',
        'Googlebot',
        'HTTrack',
        'Hailoobot',
        'Indy Library',
        'IstellaBot',
        'Jakarta Commons-HttpClient',
        'Java/',
        'Jeeves',
        'LexxeBot',
        'Linguee Bot',
        'LinksCrawler',
        'MJ12bot',
        'MSIECrawler',
        'Mail.RU_Bo',
        'Mail.Ru',
        'Microsoft URL Control',
        'NerdByNature',
        'Nutch',
        'OSS-bot',
        'OpenLinkProfiler.org',
        'Plukkie',
        'ProCogBot',
        'PuxaRapido',
        'PycURL',
        'Python-urllib',
        'Riddler',
        'SEOkicks',
        'SMTBot',
        'SWEBot',
        'ScoutJet',
        'Search17Bot',
        'SemrushBot',
        'SeznamBot',
        'SiteBot',
        'SiteExplorer',
        'T-Rank',
        'Thriceler',
        'TurnitinBot',
        'Twiceler',
        'Voluniabot',
        'WBSearchBot',
        'Webbot',
        'Xenu Link Sleuth',
        'XoviBot',
        'Yahoo! Slurp',
        'Yandex',
        'Yanga WorldSearch',
        'archive-no.com',
        'archive.org_bot',
        'awcheckBot',
        'bingbot',
        'citeseerxbot',
        'crawler',
        'discobot',
        'discoverybot',
        'favicon.ico',
        'findfiles.net',
        'heritrix',
        'hivaBot',
        'http://domainreanimator.com',
        'iRc Search',
        'ia_archiver',
        'ichiro',
        'imrbot',
        'integromedb',
        'intelium_bot',
        'larbin',
        'libwww-perl',
        'localhost:8888',
        'ltx71',
        'mlbot',
        'msnbot',
        'msrbot',
        'oBot',
        'page_verifier',
        'puritysearch.net',
        'rdfbot',
        'seoprofiler.com',
        'setooz',
        'speedy_spider',
        'swish-e',
        'thorseek',
        'webalta',
        'www.wotbox.com',
        'yacybot',
    ]

    def __init__(self, log_directory, our_targets):
        """Initialise the DivvunApacheLogParser class.

        Arguments:
            log_directory (str): path to the directory where log files are
                found.
            our_targets (list of str): list of the interesting download targets.
        """
        self.found_lists = {}
        for target in our_targets:
            self.found_lists[target] = []
        self.log_directory = log_directory
        self.found_newlines = False

    def is_bot(self, line):
        """Check if the line contains one of the bots in self.bots.

        Tried to implement this check as a regex, but runtime
        on a 100 000 line test access log went up to 18 seconds
        from about 2.5 seconds with this implementation on my
        test machine.

        Args:
            line (str): a line from the logfile

        Returns:
            boolean: False if line has not bot, True otherwise.
        """
        for bot in self.bots:
            if bot in line:
                return True

        return False

    def get_infile(self, filename):
        """Return an open file like object.

        Args:
            filename (str): path to the log file

        Returns:
            a stream object
        """
        if filename[-3:] == '.gz':
            return gzip.open(filename)
        else:
            return open(filename)

    def set_date(self, date):
        """Set min and max date."""
        if date < self.mindate:
            self.mindate = date
        if date > self.maxdate:
            self.maxdate = date

    def is_target(self, line):
        """Check if a line has one the interesting download targets.

        Args:
            line (str): log file line

        Returns:
            target (str) if the line contains a target, otherwise None
        """
        for target in self.found_lists.keys():
            if target in line:
                return target

    def parse_apachelog(self, filename):
        """Parse an apache log file.

        Args:
            filename (str): path to the log file.
        """
        old_mindate = self.mindate
        old_maxdate = self.maxdate
        for line in self.get_infile(filename):
            target = self.is_target(line)
            if (target is not None and self.is_bot(line) is False and
                    ' 200 ' in line):
                l = {'raw': line,
                     'body': line}
                normalizer.normalize(l)
                if l['date'] < old_mindate or l['date'] > old_maxdate:
                    self.found_newlines = True
                    self.found_lists[target].append(l)
                    self.set_date(l['date'])

    def parse_apachelogs(self):
        """Parse all log files found in self.log_directory."""
        for access_file in glob.glob(
                os.path.join(self.log_directory, '*access*')):
            self.parse_apachelog(access_file)

    def debug_input(self):
        """Write the lines that have been deemed as valid downloads."""
        with open('debugfile', 'w') as debugfile:
            for key in self.found_lists.keys():
                [debugfile.write(line['raw'])
                 for line in self.found_lists[key]]


class DivvunLogHandler(object):
    """Make a report file from apache log files.

    Attributes:
        outfile (str): path to the report file.
        our_targets (dict): map download targets to human readable target names.
        report_file (etree.Element): the root element of the report file.
        logparser (DivvunApacheLogParser): apache log file parser.
        totals (dict): count the total of each target
    """

    our_targets = {
        'DivvunInstaller.exe':
            'MSOffice/Windows XP/7',
        'msofficedivvuntools.msi':
            'MSOffice/Windows 7/8',
        'sami-proofing-tools.dmg':
            'MSOffice/Mac',
        'indesign-divvuntools.dmg':
            'InDesign/Mac',
        'smi-pack.zip':
            'OpenOffice.org, pre 3.0',
        'smi.oxt':
            'OpenOffice.org 3.0',
        'hunspell-se.tar.gz':
            'Hunspell/Unix, Northern Sámi',
        'hunspell-smj.tar.gz':
            'Hunspell/Unix, Lule Sámi',
        'smi.zip':
            'Hunspell/Generic',
        'Divvun-sme.msi':
            'Divvun 4 MS Office North Sámi',
        'Divvun-smj.msi':
            'Divvun 4 MS Office Lule Sámi',
        'Divvun-sma.msi':
            'Divvun 4 MS Office South Sámi',
        'Divvun-sme.xpi':
            'Divvun 4 Firefox (Didriksen) North Sámi',
        'Divvun-smj.xpi':
            'Divvun 4 Firefox (Didriksen) Lule Sámi',
        'Divvun-sma.xpi':
            'Divvun 4 Firefox (Didriksen) South Sámi',
        'Mozvoikko-sme.xpi':
            'Divvun 4 Firefox (MozVoikko) North Sámi',
        'Mozvoikko-smj.xpi':
            'Divvun 4 Firefox (MozVoikko) Lule Sámi',
        'Mozvoikko-sma.xpi':
            'Divvun 4 Firefox (MozVoikko) South Sámi',
        'MacVoikko-Northern_Sami-se.service.zip':
            'Divvun 4 OS X North Sámi',
        'MacVoikko-Lule_Sami-smj.service.zip':
            'Divvun 4 OS X Lule Sámi',
        'MacVoikko-Southern_Sami-sma.service.zip':
            'Divvun 4 OS X South Sámi',
        'se_LO-voikko-5.0.oxt':
            'Divvun 4 LibreOffice North Sámi',
        'smj_LO-voikko-5.0.oxt':
            'Divvun 4 LibreOffice Lule Sámi',
        'sma_LO-voikko-5.0.oxt':
            'Divvun 4 LibreOffice South Sámi',
    }

    def __init__(self, log_directory, outfile):
        """Initialise the DivvunLogHandler class.

        Args:
            log_directory (str): path where the log files are found.
            outfile (str): path to the report file.
        """
        self.outfile = outfile
        self.report_file = etree.Element('document')
        self.logparser = DivvunApacheLogParser(log_directory,
                                               self.our_targets.keys())
        self.get_max_and_min_date()
        self.totals = {}
        for target in self.our_targets.keys():
            self.totals[target] = 0

    def get_max_and_min_date(self):
        """Set max and min date in the logparser.

        If the date is not found in the xml file, if the xml file does not
        exist or if the file is empty, set default values.
        """
        try:
            doc = etree.parse(self.outfile)
            self.logparser.mindate = datetime.datetime.strptime(
                doc.find('//em[@id="mindate"]').text, '%Y-%m-%d %H:%M:%S')
            self.logparser.maxdate = datetime.datetime.strptime(
                doc.find('//em[@id="maxdate"]').text, '%Y-%m-%d %H:%M:%S')
        except (IOError, etree.XMLSyntaxError, AttributeError):
            self.logparser.mindate = datetime.datetime(2100, 1, 1, 0, 0, 0)
            self.logparser.maxdate = datetime.datetime(2000, 1, 1, 0, 0, 0)

    def generate_report(self):
        """Generate an xml report file."""
        if self.logparser.found_newlines:
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
        else:
            print 'No need to write new report'

    def write_header(self):
        """Make the header of the report file.

        Returns:
            an etree.Element containing the header.
        """
        header = etree.Element('header')
        title = etree.SubElement(header, 'title')
        title.text = u'Download log for the Divvun tools'

        return header

    def write_body(self):
        """Make the body element of the report.

        Returns:
            etree.Element containing the body element.
        """
        body = etree.Element('body')

        body.append(self.write_summary())
        body.append(self.write_by_country())
        body.append(self.write_by_year())
        body.append(self.write_by_useragent())

        return body

    def total_found(self):
        """Sum up the number of lines found."""
        return sum([len(
            self.logparser.found_lists[key]) for key in
            self.logparser.found_lists.keys()]) + \
            sum([self.totals[key] for key in self.totals.keys()])

    def make_p(self):
        """Make a summary p element.

        Returns:
            An etree.Element containing a p.
        """
        p = etree.Element('p')
        p.text = u'All of the Divvun tools have been downloaded ' + \
            str(self.total_found()) + u' times between '

        em_min = etree.SubElement(p, 'em')
        em_min.set('id', 'mindate')
        em_min.text = str(self.logparser.mindate)
        em_min.tail = u' and '

        em_max = etree.SubElement(p, 'em')
        em_max.set('id', 'maxdate')
        em_max.text = str(self.logparser.maxdate)

        return p

    def make_ul(self):
        """Make an unordered list element.

        Returns:
            An etree.Element containing the unordered list.
        """
        ul = etree.Element('ul')
        for target in self.totals.keys():
            self.totals[target] += len(self.logparser.found_lists[target])

        for target in sorted(self.totals,
                             key=self.totals.get,
                             reverse=True):
            li = etree.Element('li')
            ul.append(li)
            li.text = self.our_targets[target] + \
                ' has been downloaded ' + \
                str(self.totals[target]) + ' times'

        return ul

    def write_summary(self):
        """Make a summary section.

        Returns:
            an etree.Element containing the summary section.
        """
        section = self.make_section('Summary of downloads')
        section.append(self.make_p())
        section.append(self.make_ul())

        return section

    def write_by_year(self):
        """Make section showing yearly downloads.

        Returns:
            an etree.Element containing the yearly downloads section.
        """
        section = self.make_section('Downloads sorted by year')

        for target in self.our_targets.keys():
            subsection = self.make_section(str(self.our_targets[target]),
                                           target_=target)

            table = etree.Element('table')
            table.append(self.make_table_row(['Year', 'Count'], 'th'))

            year_dict = self.get_focus_dict(target, 'year')
            for found_line in self.logparser.found_lists[target]:
                year = str(found_line['date'].year)
                if year in year_dict:
                    year_dict[year] += 1
                else:
                    year_dict[year] = 1

            self.make_table_body(table, year_dict, 'year')
            subsection.append(table)
            section.append(subsection)

        return section

    def get_totals(self):
        """Get totals."""
        try:
            doc = etree.parse(self.outfile)

            for target in self.totals.keys():
                tr_elements = doc.xpath('.//section[@class="' + target +
                                        '"]/table/tr[@class="country"]')
                for tr_element in tr_elements:
                    self.totals[target] += int(tr_element[1].text)

        except IOError:
            pass

    def get_focus_dict(self, target, focus):
        """Make dict from targets and focuses.

        Args:
            target (str):
            focus (str):

        Returns:
            dict
        """
        focus_dict = {}

        try:
            doc = etree.parse(self.outfile)
            tr_elements = doc.xpath('.//section[@class="' + target +
                                    '"]/table/tr[@class="' + focus + '"]')
            for tr_element in tr_elements:
                focus_dict[tr_element[0].text] = int(tr_element[1].text)

        except IOError:
            pass

        return focus_dict

    def make_table_body(self, table, dict_, class_):
        """Make table body."""
        for year in sorted(dict_,
                           key=dict_.get,
                           reverse=True):
            table.append(self.make_table_row([str(year), dict_[year]], 'td',
                                             class_))

    def make_section(self, text, target_=None):
        """Make section element."""
        section = etree.Element('section')
        if target_ is not None:
            section.set("class", target_)
        etree.SubElement(section, 'title').text = text

        return section

    def make_table_row(self, text_list, element, class_=None):
        """Make a table row."""
        tr = etree.Element('tr')
        if class_ is not None:
            tr.set("class", class_)
        for text in text_list:
            etree.SubElement(tr, element).text = str(text)

        return tr

    def write_by_useragent(self):
        """Make table sorted by useragent."""
        section = self.make_section('Downloads sorted by useragent')

        for target in self.our_targets.keys():
            subsection = self.make_section(str(self.our_targets[target]),
                                           target_=target)

            table = etree.Element('table')
            table.append(self.make_table_row(['Useragent', 'Count'], 'th'))

            useragent_dict = self.get_focus_dict(target, 'useragent')
            for found_line in self.logparser.found_lists[target]:
                useragent = found_line['useragent']
                if useragent in useragent_dict:
                    useragent_dict[useragent] = useragent_dict[useragent] + 1
                else:
                    useragent_dict[useragent] = 1

            self.make_table_body(table, useragent_dict, 'useragent')
            subsection.append(table)
            section.append(subsection)

        return section

    def write_by_country(self):
        """Make table sorted by country."""
        section = self.make_section('Downloads sorted by country')

        locator = GeoIP.new(GeoIP.GEOIP_MEMORY_CACHE)
        for target in self.our_targets.keys():
            subsection = self.make_section(str(self.our_targets[target]),
                                           target_=target)

            table = etree.Element('table')
            table.append(self.make_table_row(['Country', 'Count'], 'th'))

            counted_countries = self.get_focus_dict(target, 'country')
            for found_line in self.logparser.found_lists[target]:
                country = locator.country_name_by_addr(
                    found_line['source_ip'])

                if country is None:
                    country = 'Unknown'

                if country in counted_countries:
                    counted_countries[country] += 1
                else:
                    counted_countries[country] = 1

            self.make_table_body(table, counted_countries, 'country')
            subsection.append(table)
            section.append(subsection)

        return section

    def parse_apachelogs(self):
        """Parse the log files."""
        self.get_max_and_min_date()
        self.get_totals()
        self.logparser.parse_apachelogs()

    def debug_input(self):
        """Print debug output."""
        self.logparser.debug_input()


def parse_options():
    """Parse command line options."""
    parser = argparse.ArgumentParser(
        description=__doc__)
    parser.add_argument('log_directory',
                        help='Directory where the apache log files are found')
    parser.add_argument('xmlfile',
                        help='The file where the report is read from and \
                        written to')

    return parser.parse_args()


def main():
    """Read logfiles, make report."""
    args = parse_options()

    divvun_parser = DivvunLogHandler(args.log_directory, args.xmlfile)
    divvun_parser.parse_apachelogs()
    divvun_parser.generate_report()
    divvun_parser.debug_input()


if __name__ == "__main__":
    main()
