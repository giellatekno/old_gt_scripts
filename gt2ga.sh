#!/bin/bash

#****************************************************************
#			gt2ga.sh
#			written by Saara Huhmarniemi
#			Feb 10, 2006
#
#           Analyze the files in corpus hierarchy in G5
#
# $Id$
#****************************************************************

source /Users/saara/.profile

# add the analyzed languages here
languages="sme"

tmpdir="/Users/saara/cron"
#tmpdir="/tmp"

corproot="/Users/hoavda/Public/corp"

#gadir=/Users/saara/tmp/ga
gadir="$corproot/ga"

umask=0112

# Copy the gt-directory from cochise for each language.
copy_gt ()
{
    for lang in "$@"
      do 
      scp -r saara@cochise.uit.no:/usr/local/share/corp/gt/$lang /Users/hoavda/Public/corp/gt
    done
    return 0
}

# Build an up-to-date analyzator and cg and
# analyze the contents of the corpus-hierarchy.
# The results are stored under /usr/local/share/corp/ga

analyze_gt ()
{
    for lang in "$@"
      do 
      cd $tmpdir && cvs -d :ext:cochise.uit.no:/usr/local/cvs/repository checkout gt
      cd $tmpdir/gt && make TARGET=$lang 
      
      mkdir -p $gadir/$lang
      echo "processing language $lang..."
      directories=`find $corproot/gt/$lang -maxdepth 1 -mindepth 1 -type d`
      i=0
      for dir in $directories
	do
	base="${dir##*/}"
	dirs[$i]=$base
	(( i += 1 ))
      done
      element_count=${#dirs[@]}
      for dir in "${dirs[@]}"
	do
	mkdir -p $gadir/$lang/$dir;
      done
	  
      let divd=element_count/3
      let modd=element_count%3
      j=0
      for (( i = 0 ; i < divd ; i++ ))
	do
	(process $lang ${dirs[$j]}) &
	(process $lang ${dirs[$((j+1))]}) &
	(process $lang ${dirs[$((j+2))]})
	wait
	let j=j+3
      done
      for (( i = 0 ; i < modd ; i++ ))
	do
	process $lang ${dir[$j]}
	let j=j+1
      done
      echo "Ready!"
    done
    return 0
}


process ()
{
    lang="$1"
    dir="$2"
    echo "processing $lang directory $dir"
    echo "/usr/local/bin/ccat -r $corproot/gt/$lang/$dir/ | $tmpdir/gt/script/preprocess --abbr=$tmpdir/gt/$lang/bin/abbr.txt --fst=$tmpdir/gt/$lang/bin/$lang.fst | lookup -flags mbTT $tmpdir/gt/$lang/bin/$lang.fst | $tmpdir/gt/script/lookup2cg | vislcg --grammar=$tmpdir/gt/$lang/src/$lang-dis.rle  > $gadir/$lang/$dir/$dir.analyzed"
    /usr/local/bin/ccat -r $corproot/gt/$lang/$dir/ | $tmpdir/gt/script/preprocess --abbr=$tmpdir/gt/$lang/bin/abbr.txt --fst=$tmpdir/gt/$lang/bin/$lang.fst | lookup -flags mbTT $tmpdir/gt/$lang/bin/$lang.fst | $tmpdir/gt/script/lookup2cg | vislcg --grammar=$tmpdir/gt/$lang/src/$lang-dis.rle  > $gadir/$lang/$dir/$dir.analyzed
    
    return 0
}

copy_gt $languages
analyze_gt $languages

exit 0
