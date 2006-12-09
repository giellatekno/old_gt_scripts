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

#source /Users/saara/.profile

# add the analyzed languages here
languages="sme"

corproot="/Users/hoavda/Public/corp"

gadir="$corproot/ga"
gt="bound"

umask=0112

# Copy the gt-directory from victorio for each language.
copy_gt ()
{
    for lang in "$@"
      do 
	  echo "copying files from victorio.."
      scp -r $USER@victorio.uit.no:/usr/local/share/corp/$gt/$lang /Users/hoavda/Public/corp/$gt
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

      mkdir -p $gadir/$lang
      echo "processing language $lang..."
      directories=`find $corproot/$gt/$lang -maxdepth 1 -mindepth 1 -type d`
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

	optdir="/opt/smi/$lang/bin"
	abbr="$optdir/abbr.txt"
	corr="$optdir/typos.txt"
	fst="$optdir/$lang.fst"
	preprocess="preprocess --abbr=$abbr --corr=$corr --fst=$fst"
	lookup="lookup -flags mbTT -utf8 -f $optdir/cap-$lang"
	vislcg="vislcg --grammar=$optdir/$lang-dis.rle"
	ccat="ccat -l $lang -r $corproot/$gt/$lang/$dir/"

    echo "processing $lang directory $dir"
    echo "$ccat | $preprocess | $lookup | lookup2cg | $vislcg > $gadir/$lang/$dir/$dir.analyzed"
    $ccat | $preprocess | $lookup | lookup2cg | $vislcg > $gadir/$lang/$dir/$dir.analyzed
	exit

    return 0
}

copy_gt $languages
#analyze_gt $languages

exit 0
