#!/bin/bash

#****************************************************************
#	    run_analyze.sh
#	    written by Saara Huhmarniemi
#	    Oct 11, 2006
#
#           Analyze parallel files in G5
#
# $Id$
#****************************************************************

source /Users/saara/.profile

# add the analyzed languages here
languages="sme"

crondir="/Users/saara"
tmpdir=$corproot/tmp
corproot="/Users/hoavda/Public/corp"
parallel_dir="parallel_new"
#parallel_dir="parallel"
distdir=$corproot/dist

gt=bound
group=staff

umask=0112

parallel=1

#files="/Users/hoavda/Public/corp/bound/sme/admin/sd/2000_1s.doc.xml
#/Users/hoavda/Public/corp/bound/sme/admin/sd/2000_2s.doc.xml
#/Users/hoavda/Public/corp/bound/sme/admin/sd/2000_3s.doc.xml
#/Users/hoavda/Public/corp/bound/sme/admin/sd/1999_1s.doc.xml
#/Users/hoavda/Public/corp/bound/sme/admin/sd/1999_2s.doc.xml
#/Users/hoavda/Public/corp/bound/sme/admin/sd/1999_3s.doc.xml
#/Users/hoavda/Public/corp/bound/sme/admin/sd/1999_4s.doc.xml"

#files="/Users/hoavda/Public/corp/bound/sme/admin/others/samisk_strategiplan_samisk.doc.xml"
#files="/Users/hoavda/Public/corp/bound/sme/admin/depts/NAC_1994_21.pdf.xml"
#/Users/hoavda/Public/corp/bound/sme/admin/depts/STM_TS007SA.pdf.xml"
#
#files="/Users/hoavda/Public/corp/bound/sme/admin/depts/NAC_2001_35.pdf.xml"

#files="/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_02_1.doc.xml
#/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_05_1.doc.xml
#/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_05_3.doc.xml
#/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_05_4.doc.xml
#/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_05_5.doc.xml
#/Users/hoavda/Public/corp/bound/sme/admin/sd/spr_04_1.doc.xml"


# Copy the gt-directory from victorio for each language.
copy_gt ()
{
    for lang in "$@"
      do 
      scp -r saara@victorio.uit.no:/usr/local/share/corp/$gt/$lang /Users/hoavda/Public/corp/$gt
    done
    return 0
}

# Create directory for the file.
preprocess ()
{
    for file in "$@"
    do

      base01=$(basename $file .xml)
      base1=$(basename $file)

      dir=$corproot/$parallel_dir/$base01
      mkdir -p $dir

#      newfile=$dir/$base1
#	  echo "NEW $newfile"

	  if [ "$parallel" ]
		  then
		  echo "perl /Users/saara/gt/script/corpus-parallel.pl --lang=sme --para_lang=nob --outdir=\"$dir\" \"$file\""
		  perl /Users/saara/gt/script/corpus-parallel.pl --lang=sme --para_lang=nob --outdir="$dir" "$file"
	  else
		  echo "jee2"
		  perl $corpus_analyze --all --output="$outfile" --only_add_sentences --lang="$lang" "$file"
	  fi

	  chmod -R g+w $dir
	  #chgrp -R $group $dir

    done

	return 0
}

analyze ()
{ 
    for file in "$@"

      do
      fs[$i]=$file
      (( i += 1 ))
    done

    element_count=${#fs[@]}
	
	let divd=element_count/3
	let modd=element_count%3
	j=0
	for (( i = 0 ; i < divd ; i++ ))
	  do
	  (process ${fs[$j]}) &
	  (process ${fs[$((j+1))]}) &
	  (process ${fs[$((j+2))]})
	  wait
	  let j=j+3
	done
	for (( i = 0 ; i < modd ; i++ ))
	  do
	  process ${fs[$j]}
	  let j=j+1
	done
	echo "Ready!"
	return 0
    }
    
# function that is called to get multiple processes.
process ()
{
    file="$1"

    base=$(basename $file .xml)
    in=$corproot/$parallel_dir/$base/$base.sent.xml
    out=$corproot/$parallel_dir/$base/$base.analyzed.xml
    echo "perl -I /Users/saara/gt/script $crondir/gt/script/corpus-analyze.pl --all --output=$out $in"

    perl -I /Users/saara/gt/script $crondir/gt/script/corpus-analyze.pl --all --output=$out $in
    
    return 0
}

pack ()
{

	mkdir -p $distdir
	echo "Files with sent.xml are unanalyzed." > readme
	tar -c --file=$distdir/$1 readme
	echo tar -c $distdir/$1

    for file in $files
    do
      base01=$(basename $file .xml)
	  sentfiles=$(find $corproot/$parallel_dir/$base01/ -name "*.sent.xml" -or -name "*.analyzed.xml")
	  for sent in $sentfiles
		do
		echo perl -pi -e "s/\/home\/saara\/lcorp\/orig\///" $sent
		perl -pi -e "s/\/home\/saara\/lcorp\/orig\///" $sent
		
		sentbase=$(basename $sent)
		tar --file=$distdir/$1 -C $corproot/$parallel_dir/$base01/ -r $sentbase
		echo tar --file=$distdir/$1 -C $corproot/$parallel_dir/$base01/ -r $sentbase
		done
	done
}

case "$1" in
	copy_gt)
        $@
        ;;
   preprocess)
        $@
        ;;
   analyze)
        $@
        ;;
   pack)
        $@
        ;;
   *)
        echo $"Usage: $0 {copy_gt lang | preprocess files.. | analyze files.. | pack tarfile }"
        exit 1
        ;;
esac

exit 0
