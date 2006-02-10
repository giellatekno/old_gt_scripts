#!/bin/bash

#****************************************************************
#			clean_log.sh
#			written by Saara Huhmarniemi
#			Feb 10, 2006
#
#           Clean the corpus log
#
# $Id$
#****************************************************************

#corpdir=/usr/local/share/corp
corpdir=/home/saara/samipdf
log_dirs="$corpdir/tmp
$corpdir/upload"

year_month=`date +%Y-%b`
month_day=`date +%b-%d`

# Move the log files in tmp and upload directory to tarball,
# and store it under subdirectory old/
# The script is supposed to be run each day before midnight.
# one tarball contains the log files of that day.

create_tar () 
{
	for dir in "$@"
	do 

	  log_files=`ls -C $dir/$month_day-*`
	  tar_file=$dir/old/$year_month/$month_day.tar

	  if [ -z "$log_files" ]; then
		  exit 0
	  fi

	  mkdir -p $dir/old/$year_month

	  if [ ! -e $tar_file.gz ]
	  then 
		  tar -c --file=$tar_file $log_files
	  else 
		  gunzip $tar_file.gz
		  tar -A --file=$tar_file $log_files
	  fi

	  gzip -f $tar_file
	  chgrp -R cvs $dir/old/$year_month
	  rm -rf $log_files

	done
	exit 0
}

create_tar $log_dirs

exit 0
