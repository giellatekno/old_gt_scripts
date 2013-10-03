#!/bin/bash

# Sort a selection of lexc entries such that commented entries are kept at
# their alphabetical position. Spaces at the beginning of lines are removed.
#
# NB!!! This script is NOT meant to be used on whole lexc files. It must be used
# semi-automatically at present:
#
# 1. open your lexc file in an editor
# 2. copy-paste the block of lexc entries to be sorted to another file
# 3. sort the temporary file with lexc entries
# 4. copy-paste back the block of sorted entries over the original block
# 5. save the now sorted original file
# 6. repeat for every block of lines you need to sort
#
# Usage:
#
# sort-lexc.sh < INFILE.lexc > OUTFILE.lexc

sed 's/^ *//' | sed 's/^\(\!\{1,\}\)\(.*\)/\2QQQQQ\1/' | LC_ALL='C' sort -f | sed 's/\(.*\)QQQQQ\(.*\)/\2\1/'
