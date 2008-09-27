#!/bin/bash

#****************************************************************
#			corpus_missing_orig.sh
#			written by Saara Huhmarniemi
#			Sep 8, 2006
#
#           List xml files with missing original file.
#
# $Id$
#****************************************************************


corpdir=/usr/local/share/corp
#corpdir=/home/saara/samipdf

bounddir=$corpdir/bound
origdir=$corpdir/orig

# Add different subdirectories here, separated by newline.
subdirs="sme"

find_orig ()
{
	for dir in "$@"
	  do
	  files=$(find $bounddir/$dir -type f -name "*.xml")
	  for file in $files
		do 
		ORIGNAME=$(echo "$file" | sed -e "s/bound/orig/" -e "s/\.xml$//")
		if [ ! -e "$ORIGNAME" ]
			then ls -l $file
#			then rm $file
		fi
	  done
	done
}

find_orig $subdirs

exit 0
