#!/bin/bash

#****************************************************************
#			gt2ga.sh
#			written by Saara Huhmarniemi
#			Feb 10, 2006
#
#           Copy and analyze the files in corpus hierarchy in G5
#
# $Id$
#****************************************************************
#
# Usage examples: 
#   gt2ga.sh copy sme           # copies all the corpus directories.
#   gt2ga.sh copy sme ficti     # copies only the sme/ficti files.
#   gt2ga.sh copy_prooftest sme # copies sme prooftest files.
#   gt2ga.sh analyze sme        # analyze all the sme files to ga-directory.
#
# only one language can be handled at the time.
#

# add the analyzed languages here
languages="sme"

corproot="/Users/hoavda/Public/corp"

minimal="1"
if [ "$minimal" -eq "1" ]
	then
	gadir="$corproot/ga-num"
else
	gadir="$corproot/ga"
fi

gt="bound"


directories="admin facta news laws bible ficti" 
if [ -z "$3" ]; then
	directories="$3"
fi

umask=0112
# Copy the gt-directory from victorio for each language.
copy ()
{
    lang="$1"
	echo "copying $1 $2 files from victorio.."
	if [ -z "$2" ]
		then
		echo "scp -r $USER@victorio.uit.no:/usr/local/share/corp/$gt/$lang $corproot/$gt"
		scp -r $USER@victorio.uit.no:/usr/local/share/corp/$gt/$lang $corproot/$gt
	else
		echo "scp -r $USER@victorio.uit.no:/usr/local/share/corp/$gt/$lang/$2 $corproot/$gt/$lang"
	    scp -r $USER@victorio.uit.no:/usr/local/share/corp/$gt/$lang/$2 $corproot/$gt/$lang
	fi
	
      # Delete the files that were not updated
	  #echo "deleting files that were not updated.."
	  #echo "find $corproot/$gt/$lang ! -mtime 1 -type f -delete"
	  #find $corproot/$gt/$lang ! -mtime 1 -type f -delete

    return 0
}

copy_prooftest ()
{
	
    lang="$1"
    echo "copying $1 prooftest files from victorio.."
	
	echo "scp -r $USER@victorio.uit.no:/usr/local/share/corp/prooftest/$gt/$lang $corproot/prooftest/$gt"
	scp -r $USER@victorio.uit.no:/usr/local/share/corp/prooftest/$gt/$lang $corproot/prooftest/$gt
}


# Build an up-to-date analyzator and cg and
# analyze the contents of the corpus-hierarchy.
# The results are stored under /usr/local/share/corp/ga

analyze ()
{
    lang="$1"

	mkdir -p $gadir/$lang
	echo "processing $lang $2..."
	if [ -z "$2" ]
		then
		directories=`find $corproot/$gt/$lang -maxdepth 1 -mindepth 1 -type d`
	else
		directories=$corproot/$gt/$lang/$2
	fi
	
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

    return 0
	  }
	  

process ()
{
    lang="$1"
    dir="$2"

	echo "processing $lang directory $dir"

	optdir="/opt/smi/$lang/bin"
	abbr="$optdir/abbr.txt"
	corr="$optdir/typos.txt"
	fst="$optdir/$lang.fst"
	preprocess="preprocess --abbr=$abbr --corr=$corr"
	lookup="lookup -flags mbTT -utf8 $optdir/$lang.fst"
	if [ "$minimal" -eq "1" ]
		then
		vislcg="vislcg --grammar=$optdir/sme-dis.rle --minimal"
	else
		vislcg="vislcg --grammar=$optdir/sme-dis.rle"
	fi
	echo $vislcg

	ccat="ccat -l $lang -r $corproot/$gt/$lang/$dir/"

    echo "$ccat | $preprocess | $lookup | lookup2cg | $vislcg > $gadir/$lang/$dir/$dir.analyzed"
    $ccat | $preprocess | $lookup | lookup2cg | $vislcg > $gadir/$lang/$dir/$dir.analyzed
	exit

    return 0

}

if [ -z "$2" ]
then
	echo $"Specify language and action command line."
	echo $"Usage: $0 {copy lang genre | analyze lang genre | copy_prooftest}"
	exit 1
fi


case "$1" in
	copy)
        $@
        ;;
   analyze)
        $@
        ;;
   copy_prooftest)
        $@
        ;;
   *)
        echo $"Usage: $0 {copy lang genre | analyze lang genre | copy_prooftest lang}"
        exit 1
        ;;
esac



exit 0
