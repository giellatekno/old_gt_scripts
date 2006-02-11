#!/bin/bash

#****************************************************************
#			copy_corpus_bin.sh
#			written by Saara Huhmarniemi
#			Feb 11, 2006
#
#           Copy the latest versions of scripts to corp/bin
#
# $Id$
#****************************************************************

#bindir=/usr/local/share/corp/bin
bindir=/home/saara/samipdf/bin
tmpdir="/usr/tmp"

scripts="convert2xml.pl
text_cat
LM
add-hyph-tags.pl
XSL-template.xsl
common.xsl
xhtml2corpus.xsl
docbook2corpus2.xsl"

cvs -d /usr/local/cvs/repository checkout -d $tmpdir/gt gt

for file in $scripts
do
  cp -R $tmpdir/gt/script/$file $bindir/$file
done

chgrp cvs $bindir/*

exit 0
