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

cvs -d /usr/local/cvs/repository checkout -d $tmpdir/gt gt

time_suffix=`stat -c "%y" "$outdir/corpus-summary.xml" |sed -e "s/ .*//"`;
old_summary=corpus-summary-$time_suffix.xml

cp $outdir/corpus-summary.xml $outdir/$old_summary

echo "perl $tmpdir/gt/script/corpus-summary.pl --dir=/usr/local/share/corp/bound --outdir=$outdir"
perl $tmpdir/gt/script/corpus-summary.pl --dir=/usr/local/share/corp/bound --outdir=$outdir

echo "xmllint --dtdvalid $tmpdir/gt/dtd/corpus-content.dtd --encode UTF-8 --noout $outdir/corpus-content.xml"
if ! xmllint --dtdvalid $tmpdir/gt/dtd/corpus-content.dtd --encode UTF-8 --noout $outdir/corpus-content.xml 
then
echo "corpus-content.xml was not valid. exiting.."
exit
fi
echo "xmllint --dtdvalid $tmpdir/gt/dtd/corpus-summary.dtd --encode UTF-8 --noout $outdir/corpus-summary.xml"
if  ! xmllint --dtdvalid $tmpdir/gt/dtd/corpus-summary.dtd --encode UTF-8 --noout $outdir/corpus-summary.xml 
then
echo "corpus-summary.xml was not valid. exiting.."
exit
fi

exit
if [ -s "$outdir/corpus-summary.xml" ]
then
	echo "checkin $outdir/corpus-summary.xml"
	cvs ci -m"cron checkin of generated summary" $outdir/corpus-summary.xml
	echo "adding $outdir/$old_summary"
	cvs add -m"cron moving old summary to a new name" $outdir/$old_summary
	cvs ci -m"cron moving old summary to a new name" $outdir/$old_summary
fi

if [ -s "$outdir/corpus-content.xml" ]
then
	echo "checkin $outdir/corpus-content.xml"
	cvs ci -m"cron checkin of generated summary" $outdir/corpus-content.xml
fi

