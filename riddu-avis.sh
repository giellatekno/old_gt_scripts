#!/bin/bash

# call this program this way
# ridduavis.sh <inputfile> <outputfile>
# inputfile is an svg-file
# outputfile is a plain text file

xsltproc $GTHOME/gt/script/svg2dumb.xsl $1 | tr -d "\t" | tr "\n" " " | sed -e 's/  */ /g' -e's/– /–/g' -e 's/- /-/g' -e 's/@font-face.*}//g' > $2