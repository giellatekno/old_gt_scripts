#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import re

def one_line_stasher(number_list):
    aff =''.join(number_list).decode('hex').decode('utf16')

    return aff

def parse_lines():
    f = open(sys.argv[1])
    content = f.readlines()

    return_line = ''
    hex_start=''
    hex_string = re.compile("(?P<hexstring>.+hex\([27]\):)(?P<therest>.+)\\\\")
    continuation = False

    for line in content:
        line = line.rstrip()

        if continuation:
            if line.startswith('  ') and line.endswith('\\'):
                return_line = return_line + line[2:-1]
            elif line.startswith('  ') and not line.endswith('\\'):
                return_line = return_line + line[2:]
                # remove what becomes EOL in utf8
                return_line = return_line.replace(',00,00', '')
                print hex_start + one_line_stasher(return_line.split(',')).encode('utf8')
                continuation = False
                return_line = ''
                hex_start = ''

        else:
            match = re.search(hex_string, line)
            if match:
                hex_start = match.group(1)
                return_line = match.group(2)
                continuation = True

            else:
                print line

parse_lines()
