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

downloads_dir=/home/saara/downloads

tmpdir=/usr/tmp
time=`date +%F`

gtfree=$corpdir/free
rem_file=$tmpdir/rem_broken_free.sh
corpus_fix="/home/saara/gt/script/corpus-fix-free.pl"


languages="smj"

for lang in $languages
do

  tmptext=$tmpdir/$lang-txt
  # Remove old txt-directory
  rm -rf $tmptext
  mkdir -p $tmptext

  # Check first the free-catalog
  rm -rf $rem_file
#  perl $corpus_fix --corpdir=$corpdir --lang=$lang --rem_file=$rem_file
  if [ -f $rem_file -a -s $rem_file ]
	  then
	  echo "Fix errors first! See file $rem_file"
	  chmod a+x $rem_file
	  exit
  else
	  echo "No errors. Continuing.."
  fi

  # create plain text files.
  files=`find $gtfree/$lang -type f`
  
  for file in $files
	do
	txtfile=`echo $file | perl -pe "s/xml/txt/; s|$corpdir|$tmpdir|; s|free\/$lang|$lang-txt|"`
	#echo $txtfile
	dir=$(dirname $txtfile)
	mkdir -p $dir
	ccat -l $lang $file > $txtfile
  done

  # Create both xml and text tar-archives.
  tar_file=$tmpdir/$lang-corpus-xml-$time.tar
  echo "cd $gtfree && tar -c --file=$tar_file $lang"
  cd $gtfree && tar -c --file=$tar_file $lang
  echo "gzip -f $tar_file"
  gzip -f $tar_file

  txt_tar_file=$tmpdir/$lang-corpus-txt-$time.tar
  echo "cd $tmpdir && tar -c --file=$txt_tar_file $lang-txt"
  cd $tmpdir && tar -c --file=$txt_tar_file $lang-txt
  echo "gzip -f $txt_tar_file"
  gzip -f $txt_tar_file

  echo "cp $txt_tar_file.gz $downloads_dir"
  echo "cp $tar_file.gz $downloads_dir"

  cp $txt_tar_file.gz $downloads_dir
  cp $tar_file.gz $downloads_dir

done



