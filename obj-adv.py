#!/usr/bin/env python
'''Usage example:
obj-adv.py /Users/hoavda/Public/corp/analysed/2014-11-17/sme_*.dep
'''
import sys


search_list = [" @-F<ADVL ", " @-FADVL> ", " @<ADVL ", " @ADVL ", " @ADVL ", " @ADVL> ", " @FS-<ADVL ", " @FS-ADVL> ", " @-F<OBJ ", " @-FOBJ> ", " @<OBJ ", " @FS-OBJ ", " @ICL-OBJ ", " @OBJ> "]


abba = {}

for s in search_list:
    abba[s] = {}
    for f in sys.argv[1:]:
        with open(f) as fub:
            for line in fub.readlines():
                if s in line:
                    hm1 = line.find(s) + len(s) + 1
                    hm2 = line.find('->')
                    distance = int(line[hm2 + 2:]) - int(line[hm1:hm2])
                    try:
                        abba[s][distance] += 1
                    except KeyError:
                        abba[s][distance] = 1

for key, value in abba.iteritems():
    total = 0
    print key
    print '\tdistance | #'
    for k, v in value.iteritems():
        total += v
        print '\t', k, '\t', v
    print '\t', 'total', total
