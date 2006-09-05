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

orig="$corpdir/orig"
bound="$corpdir/bound"
free="$corpdir/free"

# Add different languages here, separated by newline.
langdirs="sme"

# Original documents in orig-hierarchy
# xsl-files that are under version control need not to be modified,
# since they are dependent on the directory settings only.
orig ()
{
	for dir in "$@"
	do
	  echo "fixing $orig/$dir..."
	  files=`find $orig/$dir -type f ! -name "*.xsl*"` 
	  for file in $files
	  do
		chgrp corpus $file
		chmod 0640 $file
	  done

	  xslfiles=`find $orig/$dir -type f -name "*.xsl,v"`
	  for file in $xslfiles
	  do 
		chgrp corpus $file
		chmod 0440 $file
	  done

	  subdirs=$(find $orig/$dir -type d)
	  for sub in $subdirs
	  do
		chgrp corpus $sub
		chmod 0770 $sub
	  done
	done
}

# xml-files in bound
gtbound () 
{
	for dir in "$@"
	do
	  echo "fixing $bound/$dir..."
	  files=`find $bound/$dir -name "*.xml"`
	  for file in $files
	  do
		chgrp bound $file
		chmod 0660 $file
	  done
	  subdirs=$(find $bound/$dir -type d)
	  for sub in $subdirs
	  do
		chgrp bound $sub
		chmod 0770 $sub
	  done
	 done
}

# Free xml-files in free
gtfree () 
{
	for dir in "$@"
	do
	  echo "fixing $free/$dir..."
	  files=`find $free/$dir -name "*.xml"`
	  for file in $files
	  do
		chgrp cvs $file
		chmod 0664 $file
	  done

	  subdirs=$(find $free/$dir -type d)
	  for sub in $subdirs
	  do
		chgrp cvs $sub
		chmod 0775 $sub
	  done
	done
}

orig $langdirs
gtbound $langdirs
gtfree $langdirs

exit 0
