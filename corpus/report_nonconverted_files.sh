#!/bin/bash

if [ "$1" == "" ]
then
    echo "Use a corpus-directory as an argument, for example:"
    echo "report_nonconverted_files.sh /home/apache_corpus/freecorpus"
    exit 1
else
    for XSL in `find $1/orig -name \*.xsl`
    do
        XML=`echo $XSL | sed -e 's/orig/converted/' | sed -e 's/\.xsl/\.xml/'`
        if [ \! -f $XML ]
        then
            echo $XML
        fi
    done
fi
