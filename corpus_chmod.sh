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

host=$(hostname)

# Set variables according to the current host.
if [ "$host" == "hum-tf4-ans142.hum.uit.no" ]
then
	corpdir=/Users/hoavda/Public/corp
	corpus_group="staff"
	free_group="staff"
else
	corpdir=/usr/local/share/corp
	corpus_group="corpus"
	free_group="cvs"
fi

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
		chgrp $corpus_group $file
		chmod 0640 $file
	  done

	  xslfiles=`find $orig/$dir -type f -name "*.xsl,v"`
	  for file in $xslfiles
	  do 
		chgrp $corpus_group $file
		chmod 0440 $file
	  done

	  subdirs=$(find $orig/$dir -type d)
	  for sub in $subdirs
	  do
		chgrp $corpus_group $sub
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
		chgrp $corpus_group $file
		chmod 0660 $file
	  done
	  subdirs=$(find $bound/$dir -type d)
	  for sub in $subdirs
	  do
		chgrp $corpus_group $sub
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
		chgrp $free_group $file
		chmod 0664 $file
	  done

	  subdirs=$(find $free/$dir -type d)
	  for sub in $subdirs
	  do
		chgrp $free_group $sub
		chmod 0775 $sub
	  done
	done
}

if [ "$host" == "hum-tf4-ans142.hum.uit.no" ]
then
	gtbound $langdirs
else
	orig $langdirs
	gtbound $langdirs
	gtfree $langdirs
fi

exit 0
