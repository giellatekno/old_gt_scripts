#!/bin/bash

#****************************************************************
#			copy_corpus_bin.sh
#			written by Saara Huhmarniemi
#			Feb 11, 2006
#
#           Copy the latest versions of scripts to corp/bin
#           Running it requires admin privileges + sudo
#
# $Id$
#****************************************************************

corpdir=/usr/local/share/corp
bindir=$corpdir/bin
tmpdir="/usr/tmp"
tooldir=$GT_HOME/tools/lang-guesser

scripts="convert2xml.pl
$tooldir/text_cat.pl
paratext2xml.pl
bible2xml.pl
pdf2xml.pl
corpus_call_jpedal.sh
add-hyph-tags.pl
convert_eol.pl
XSL-template.xsl
common.xsl
empty.xsl
xhtml2corpus.xsl
docbook2corpus2.xsl
tidy-config.txt"

makefile="corpus.make"

svn checkout https://victorio.uit.no/langtech/trunk/gt/script/ $tmpdir/gt/script/
echo "svn checkout https://victorio.uit.no/langtech/trunk/gt/script/ $tmpdir/gt/script/"

for file in $scripts
do
  cp $tmpdir/gt/script/$file $bindir/$file
  echo "copying file $bindir/$file"
done

cp $tmpdir/gt/script/LM/* $bindir/LM/
echo "copying $tmpdir/gt/script/LM/* $bindir/LM/"

cp $tmpdir/gt/script/$makefile $corpdir/Makefile
echo "copying $tmpdir/gt/script/$makefile $corpdir/Makefile"

cd $bindir && perl $tmpdir/gt/script/reformat_commonxsl.pl
chgrp cvs $bindir/*

exit 0
