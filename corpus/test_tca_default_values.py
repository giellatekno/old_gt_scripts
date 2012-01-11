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
    # Set the name of the file to write the test to
    paragstestfile = os.path.join(os.environ['GTHOME'], 'techdoc/tools/tca2_testruns.paragstesting.xml')
    
    # First a run with the default values
    compile_tca()
    # Initialize an instance of a tmx test data writer
    tester = parallelize.TmxGoldstandardTester(paragstestfile, '_Default_values')
    # run the test
    tester.runTest()
    minDiffLines = tester.getNumberOfDiffLines()

    # copy the original file to a backup file
    shutil.copy(os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java'), os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java.tcatest'))

    winners = findWinners(paragstestfile, minDiffLines)
    
    testWinners(paragstestfile, winners)
    
    return 0

def testWinners(paragstestfile, winners):
    """
    Do a test run with the winners
    """
    
    # Set the constants found in winners
    for constant, value in winners.iteritems():
        set_value(constant, value)
        
    compile_tca()
    # Initialize an instance of a tmx test data writer
    tester = parallelize.TmxGoldstandardTester(paragstestfile, '_Winner_values')
    # run the test
    tester.runTest()
    
    # reset to the orig file after each run
    shutil.copy(os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java.tcatest'), os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java'))
    
    
def findWinners(paragstestfile, defaultWinner):
    """
    Find those combinations of constant, value that gives better results
    than the default setup.
    Collect them in a winners dictionary, and return that
    """
    winners = {}

    # A dictionary of constants
    default = {}
    default['DEFAULT__ANCHORWORD_MATCH_WEIGHT'] = ['0.5', '3.0']
    default['DEFAULT__ANCHORPHRASE_MATCH_WEIGHT'] = ['0.5', '3.0']
    default['DEFAULT__PROPERNAME_MATCH_WEIGHT'] = ['0.5', '3.0']
    default['DEFAULT__DICE_MATCH_WEIGHT'] = ['0.5', '3.0']
    default['DEFAULT__DICEPHRASE_MATCH_WEIGHT'] = ['0.5', '3.0']
    default['DEFAULT__NUMBER_MATCH_WEIGHT'] = ['0.5', '3.0']
    default['DEFAULT__SCORINGCHARACTER_MATCH_WEIGHT'] = ['0.5', '3.0']

    # Then for each constant, change them
    for constant, values in default.iteritems():
        winner = defaultWinner
        print "testing", constant
        for value in values:
            print value
            # setvalue
            set_value(constant, value)
            compile_tca()
            # Initialize an instance of a tmx test data writer
            tester = parallelize.TmxGoldstandardTester(paragstestfile, '_' + constant + '_' + value)
            # run the test
            tester.runTest()
            
            # Find out if this combination of constant and value gives a better 
            # result than the default setting. If it is, add it to the winners
            # dictionary
            if winner > tester.getNumberOfDiffLines():
                winner = tester.getNumberOfDiffLines()
                winners[constant] = value
                
            # reset to the orig file after each run
            shutil.copy(os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java.tcatest'), os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java'))
            
    return winners
    
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