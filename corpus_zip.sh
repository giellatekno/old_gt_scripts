#!/bin/bash

#****************************************************************
#			corpus_zip.sh
#			written by Saara Huhmarniemi
#			Apr 5, 2006
#
#           zip the files in gtfree directory
#
# $Id$
#****************************************************************

# This script copies the gtfree-directory from the corpus dir
# and creates tar-archives of both the xml files and the files
# that contain only the extracted text.
# Automatic copying to download dir is not yet implemented.

corpdir=/usr/local/share/corp
#corpdir=/home/saara/samipdf

tmpdir=/usr/tmp
languages="sme"
time=`date +%F`

rm -rf $tmpdir/gtfree
rm -rf $tmpdir/gttext

mkdir -p $tmpdir/gtfree

for lang in $languages
do
  gtfree=gtfree/$lang
  gttext=gttext/$lang

  cp -r $corpdir/$gtfree $tmpdir/gtfree/

  # temporary fix: remove the bible dir
  rm -rf $tmpdir/$gtfree/bible

  # make the plain text directory.
  cd $tmpdir && cp -r gtfree gttext

  # create plain text files.
  files=`find $tmpdir/$gttext -type f`

  for file in $files
	do
	txtfile=`echo $file | sed s/xml/txt/`
	ccat $file > $txtfile
	rm -rf $file
  done

  # Create both xml and text tar-archives.
  tar_file=$lang-corpus-xml-$time.tar
  cd $tmpdir && tar -c --file=$tar_file $gtfree
  gzip -f $tar_file

  txt_tar_file=$lang-corpus-txt-$time.tar
  cd $tmpdir && tar -c --file=$txt_tar_file $gttext
  gzip -f $txt_tar_file

  cp $tmpdir/$txt_tar_file.gz /home/saara/downloads/
  cp $tmpdir/$tar_file.gz /home/saara/downloads/

done



