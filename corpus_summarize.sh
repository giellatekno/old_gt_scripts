#!/bin/bash

#****************************************************************
#			corpus_summarize.sh
#			written by Saara Huhmarniemi
#			May 4, 2006
#
#           Store the corpus summary info to cvs.
#
# $Id$
#****************************************************************

# Run the script corpus_summary.pl, check the result and store to cvs.
# Script is used mainly via crontab.

corpdir=/usr/local/share/corp
tmpdir=/home/saara/cron
outdir=$tmpdir/gt/doc/lang/corp
time_suffix=`date +%F`;
summary_file=corpus-summary-$time_suffix.xml

cvs -d /usr/local/cvs/repository checkout -d $tmpdir/gt gt

perl $tmpdir/gt/script/corpus-summary.pl --dir=/usr/local/share/corp/gtbound --outdir=$outdir --sumfile=$summary_file

if [! -z $outdir/corpus-summary.xml ]
then
	echo "checkin $outdir/corpus-summary.xml
	cvs ci -m"cron checkin of generated summary" $outdir/corpus-summary.xml
fi

if [! -z $outdir/$summary_file ]
then
	echo "checkin $outdir/$summary_file
	cvs ci -m"cron checkin of generated summary" $outdir/$summary_file
fi

