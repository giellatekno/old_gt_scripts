#!/bin/bash

#****************************************************************
#			corpus_chmod.sh
#			written by Saara Huhmarniemi
#			Apr 7, 2006
#
#           Fix the permissions of the corpus directories
#
# $Id$
#****************************************************************

# Change file group and permissions for different corpus directories.

corpdir=/usr/local/share/corp
#corpdir=/home/saara/samipdf

# Add different languages here, separated by newline.
langdirs="sme"

# Original documents in orig-hierarchy
# xsl-files that are under version control need not to be modified,
# since they are dependent on the directory settings only.
orig ()
{
	for dir in "$@"
	do
	  echo "fixing $corpdir/orig/$dir..."
	  files=`find $corpdir/orig/$dir -name "*.pdf" -or -name "*.doc" -or -name "*.html" -or -name "*.ptx"` 
	  for file in $files
	  do
		chgrp corpus $file
		chmod 0660 $file
	  done
	  subdirs=`find $corpdir/orig/$dir -type d`
	  for subdir in "$subdirs"
	  do
		chgrp corpus $subdir
		chmod 0770 $subdir
	  done
	done
}

# xml-files in gtbound
gtbound () 
{
	for dir in "$@"
	do
	  echo "fixing $corpdir/gtbound/$dir..."
	  files=`find $corpdir/gtbound/$dir -name "*.xml"`
	  for file in $files
	  do
		chgrp cvs $file
		chmod 0660 $file
	  done
	  subdirs=`find $corpdir/gtbound/$dir -type d`
	  for subdir in "$subdirs"
	  do 
		chgrp cvs $subdir
		chmod 0770 $subdir
	  done
	 done
}

# Free xml-files in gtfree
gtfree () 
{
	for dir in "$@"
	do
	  echo "fixing $corpdir/gtfree/$dir..."
	  files=`find $corpdir/gtfree/$dir -name "*.xml"`
	  for file in $files
	  do
		chgrp cvs $file
		chmod 0664 $file
	  done
	  subdirs=`find $corpdir/gtfree/$dir -type d`
	  for subdir in "$subdirs"
	  do 
		chgrp cvs $subdir
		chmod 0775 $subdir
	  done
	done
}

orig $langdirs
gtbound $langdirs
gtfree $langdirs

exit 0
