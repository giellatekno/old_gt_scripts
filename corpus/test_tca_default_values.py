#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
#   This program tests the max and min values of tca2 applied to the tmx goldstandard files
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with program.  If not, see <http://www.gnu.org/licenses/>.
#
#   Copyright 2011 Børre Gaup <borre.gaup@uit.no>
#

# test tca2 parameters min and max values
import os
import sys
import shutil
import subprocess

sys.path.append(os.environ['GTHOME'] + '/gt/script/langTools')
import parallelize

def main():
    # A dictionary of constants
    default = {}
    default['DEFAULT__ANCHORWORD_MATCH_WEIGHT'] = ['0.5', '3.0']
    default['DEFAULT__ANCHORPHRASE_MATCH_WEIGHT'] = ['0.5', '3.0']
    default['DEFAULT__PROPERNAME_MATCH_WEIGHT'] = ['0.5', '3.0']
    default['DEFAULT__DICE_MATCH_WEIGHT'] = ['0.5', '3.0']
    default['DEFAULT__DICEPHRASE_MATCH_WEIGHT'] = ['0.5', '3.0']
    default['DEFAULT__NUMBER_MATCH_WEIGHT'] = ['0.5', '3.0']
    default['DEFAULT__SCORINGCHARACTER_MATCH_WEIGHT'] = ['0.5', '3.0']

    # Set the name of the file to write the test to
    paragstestfile = os.path.join(os.environ['GTHOME'], 'techdoc/ling/tca2_testruns.paragstesting.xml')
    
    # First a run with the default values
    compile_tca()
    # Initialize an instance of a tmx test data writer
    tester = parallelize.TmxGoldstandardTester(paragstestfile)
    # run the test
    tester.runTest()

    # copy the original file to a backup file
    shutil.copy(os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java'), os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java.tcatest'))
    
    # Then for each constant, change them
    for constant, values in default.iteritems():
        print "testing", constant
        for value in values:
            print value
            # setvalue
            set_value(constant, value)
            compile_tca()
            # Initialize an instance of a tmx test data writer
            tester = parallelize.TmxGoldstandardTester(paragstestfile)
            # run the test
            tester.runTest()
            # reset to the orig file after each run
            shutil.copy(os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java.tcatest'), os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java'))
            
    return 0

def set_value(constant, value):
    """
    Replace the line containing constant with value
    """
    import fileinput
    
    for line in fileinput.FileInput(os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java'), inplace = 1):
        if line.find(constant) > 0:
            line = line[:line.find(constant) + len(constant)]
            line = line + " = " + value + "f;\n"
        print line[:-1]
    
def compile_tca():
    """
    Compile tca2
    """
    os.chdir(os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2'))
    subp = subprocess.Popen(['ant'], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
    (output, error) = subp.communicate()
        
    if subp.returncode != 0:
        print >>sys.stderr, 'Could not compile tca2'
        print >>sys.stderr, output
        print >>sys.stderr, error
        sys.exit(1)

    
if __name__ == "__main__":
    main()