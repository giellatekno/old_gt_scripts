#!/usr/bin/env python
# -*- coding: utf-8 -*-

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

    # copy the original file to a backup file
    shutil.copy(os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java'), os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java.tcatest'))
    
    # Set the name of the file to write the test to
    paragstestfile = os.path.join(os.environ['GTHOME'], 'techdoc/ling/tca2_testruns.paragstesting.xml')
    
    # for each constant
    for constant, values in default.iteritems():
        for value in values:
            # setvalue
            set_value(constant, value)
            compile_tca()
            # Initialize an instance of a tmx test data writer
            tester = parallelize.TmxGoldstandardTester(paragstestfile)
            # run the test
            tester.runTest()
            # reset to the orig file
            shutil.copy(os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java.tcatest'), os.path.join(os.environ['GTHOME'], 'tools/alignment-tools/tca2/aksis/alignment/Alignment.java'))
    save_test_in_unique_filename()
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