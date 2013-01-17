#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import subprocess
import os

def run_visglcg3(vislcg3input):

    vislcg3command = ['vislcg3', '-g', os.path.join(os.getenv('GTHOME'), 'gt/sme/src/sme-dis.rle')]

    subp = subprocess.Popen(vislcg3command, stdin = subprocess.PIPE, stdout = subprocess.PIPE, stderr = subprocess.PIPE)
    (output, error) = subp.communicate(vislcg3input)

    if subp.returncode == 0:
        print 'all well'
    else:
        print 'all hell'
        print output
        print error

def main():
    f = open(sys.argv[1])

    lines = []
    clbno = 0
    for line in f:
        lines.append(line)
        if '"." CLB' in line:
            clbno = clbno + 1
            vislcg3input = ''.join(lines)
            clbfile = open(str(clbno), 'w')
            clbfile.write(vislcg3input)
            clbfile.close()
            sys.stdout.write(sys.argv[1] + ' ' + str(clbno) + ' ' + str(len(lines)) + ' ')
            sys.stdout.flush()
            run_visglcg3(vislcg3input)
            lines = []

if __name__ == "__main__":
    main()
