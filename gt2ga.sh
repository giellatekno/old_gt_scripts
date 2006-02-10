#!/bin/bash

#****************************************************************
#			gt2ga.sh
#			written by Saara Huhmarniemi
#			Feb 10, 2006
#
#           Analyze the files in corpus hierarchy
# $Id$
#****************************************************************

PATH=$PATH:/opt/xerox/bin

# add the analyzed languages here
languages=sme
tmpdir="/usr/tmp"
genre_dirs=`ls -C /usr/local/share/corp/gt/sme`
gadir=/usr/local/share/corp/ga

# Build an up-to-date analyzator and cg and
# analyze the contents of the corpus-hierarchy.
# The results are stored under /usr/local/share/corp/ga

analyze_gt ()
{
	for lang in $1
	do 
		cvs -d /usr/local/cvs/repository checkout -d $tmpdir/gt gt		
		cd $tmpdir/gt && make TARGET=$lang 

		mkdir -p $gadir/$lang

		for dir in $genre_dirs
		do
			mkdir -p $gadir/$lang/$dir;
			echo "processing directory $lang/$dir..."
			ccat -r /usr/local/share/corp/gt/$lang/$dir | \
			$tmpdir/gt/script/preprocess --abbr=$tmpdir/gt/$lang/bin/abbr.txt | lookup \
			-flags mbTT $tmpdir/gt/$lang/bin/$lang.fst | $tmpdir/gt/script/lookup2cg \
			| vislcg --grammar=$tmpdir/gt/$lang/src/$lang-dis.rle  > $gadir/$lang/$dir/$dir.analyzed
		done
	done
	chgrp -R cvs $gadir
	return 0
}

analyze_gt $languages

exit 0
