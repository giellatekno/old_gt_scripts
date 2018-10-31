#!/usr/bin/env python3
# -*- coding: utf-8 -*-
'''Print entries from the daily termwiki dump to stdout

The lang1 and lang2 output are separated by a tab.

If there are several expressions in each language, they are separated by
a comma.
'''
import argparse
import os
import sys

import lxml.etree as etree

sys.path.append(os.path.join(os.getenv('GTHOME'), 'tools/TermWikiImporter'))

from termwikiimporter import bot


def parse_options():
    """Parse options given to the script."""
    parser = argparse.ArgumentParser(
        description='Print sanctioned tab separated term sets')

    parser.add_argument('lang1', choices=['fi', 'nb', 'nn', 'sv', 'se', 'sma',
                                          'smj', 'smn', 'sms', 'lat', 'en'])
    parser.add_argument('lang2', choices=['fi', 'nb', 'nn', 'sv', 'se', 'sma',
                                          'smj', 'smn', 'sms', 'lat', 'en'])

    args = parser.parse_args()

    return args


def main():
    args = parse_options()
    if args.lang1 == args.lang2:
        raise SystemExit(
            'Please specify different languages for lang1 and lang2')

    dumphandler = bot.DumpHandler()
    dumphandler.print_expression_pairs(args.lang1, args.lang2)


if __name__ == '__main__':
    main()
