#!/bin/sh

# Usage:
# Go to the folder where the file(s) are.
# Check that this script file is executable (chmod 755 utf8-conv.sh)
# Run the file (example: ./utf8-conv.sh *.txt)

for i in $@
do
  /usr/bin/iconv -f ISO-8859-1 -t UTF-8 $i | sed -f ../src/digr-utf8.txt > u-$i
  /bin/mv -f u-$i $i
done
