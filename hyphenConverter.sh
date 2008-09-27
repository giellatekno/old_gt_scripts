#!/bin/bash

# File        : hyphenConverter.sh
#
# Description : transforms Divvun PLX hyphenation to PLD PLX hyphenation
#               translation table used:
#
#               code     hard-hyphen  compound soft-hypen  soft-hyphen
#               =======  ===========  ===================  ===========
#               Divvun:  -            #                    ^
#               PLD      --           -                    -
#                 
# Assumptions : - bash must be available in /bin/bash
#               - sed must be available 
#
# History:      when        who  what
#               ==========  ===  =====================================
#               2007-02-07  PFB  creation             

#=== Check 1: must have 2 parameters
 
if [ $# -ne 2 ] ; then
    printf "Usage: $0 <inputfile> <outputfile>\n";
    printf "  reads <inputfile>;"
    printf "  doubles hyphens and replaces ^ and # by hyphen\n";
    printf "  writes the result to <outputfile>\n";
    exit 1;
fi;

#=== Check 2: parameter 1 must be existing file

if [ ! -f $1 ]; then
    printf "FATAL: can not open file \"$1\"\n";
    exit 1;
fi;

#=== Check 3: parameter 2 may not be existing file

if [ -f $2 ]; then
    printf "FATAL: file \"$2\" already exists\n";
    exit 1;
fi;

#=== ... and the actual work

sed -e 's/-/--/g' -e 's/\^/-/g' -e 's/#/-/g' $1 > $2

