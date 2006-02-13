#!/bin/bash

#****************************************************************
#			gt2ga.sh
#			written by Saara Huhmarniemi
#			Feb 10, 2006
#
#           Analyze the files in corpus hierarchy
#
# $Id$
#****************************************************************

PATH=$PATH:/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin

# add the analyzed languages here
languages="sme"
tmpdir="/usr/tmp"
gadir=/usr/local/share/corp/ga

umask=0112

# Build an up-to-date analyzator and cg and
# analyze the contents of the corpus-hierarchy.
# The results are stored under /usr/local/share/corp/ga

analyze_gt ()
{
	for lang in "$@"
	do 
		cvs -d /usr/local/cvs/repository checkout -d $tmpdir/gt gt
		cd $tmpdir/gt && make TARGET=$lang 

		mkdir -p $gadir/$lang
		echo "processing directory $lang/..."
		for dir in `ls -C /usr/local/share/corp/gt/$lang`
		do
			mkdir -p $gadir/$lang/$dir;
			echo "processing directory $lang/$dir..."
			/usr/local/bin/ccat -r /usr/local/share/corp/gt/$lang/$dir/ | $tmpdir/gt/script/preprocess --abbr=$tmpdir/gt/$lang/bin/abbr.txt | lookup -flags mbTT $tmpdir/gt/$lang/bin/$lang.fst | $tmpdir/gt/script/lookup2cg | vislcg --grammar=$tmpdir/gt/$lang/src/$lang-dis.rle  > $gadir/$lang/$dir/$dir.analyzed
		done
		chgrp -R cvs $gadir/$lang
	done
	return 0
}

analyze_gt $languages

exit 0
