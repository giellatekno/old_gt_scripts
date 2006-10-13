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
languages="sme nob"

crondir="/Users/saara/cron"
tmpdir=$corproot/tmp
corproot="/Users/hoavda/Public/corp"
gt=bound

umask=0112

files="/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_1_01.doc.xml,/Users/hoavda/Public/corp/bound/nob/admin/sd/sp_1_01.doc.xml
/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_1_02.doc.xml,/Users/hoavda/Public/corp/bound/nob/admin/sd/sp_1_02.doc.xml
/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_1_98.doc.xml,/Users/hoavda/Public/corp/bound/nob/admin/sd/sp_1_98.doc.xml
/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_2_01.doc.xml,/Users/hoavda/Public/corp/bound/nob/admin/sd/sp_2_01.doc.xml
/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_2_02.doc.xml,/Users/hoavda/Public/corp/bound/nob/admin/sd/sp_2_02.doc.xml
/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_2_98.doc.xml,/Users/hoavda/Public/corp/bound/nob/admin/sd/sp_2_98.doc.xml
/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_3_01.doc.xml,/Users/hoavda/Public/corp/bound/nob/admin/sd/sp_3_01.doc.xml
/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_3_05.doc.xml,/Users/hoavda/Public/corp/bound/nob/admin/sd/sp_3_05.doc.xml
/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_3_98.doc.xml,/Users/hoavda/Public/corp/bound/nob/admin/sd/sp_3_98.doc.xml
/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_4_01.doc.xml,/Users/hoavda/Public/corp/bound/nob/admin/sd/sp_4_01.doc.xml
/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_4_98.doc.xml,/Users/hoavda/Public/corp/bound/nob/admin/sd/sp_4_98.doc.xml
/Users/hoavda/Public/corp/bound/sme/admin/sd/dc_5_05.doc.xml,/Users/hoavda/Public/corp/bound/nob/admin/sd/sp_5_05.doc.xml
/Users/hoavda/Public/corp/bound/sme/admin/sd/spr_1_04.doc.xml,/Users/hoavda/Public/corp/bound/nob/admin/sd/sprd_1_04.doc.xml
/Users/hoavda/Public/corp/bound/sme/admin/sd/vl_1_05.doc.xml,/Users/hoavda/Public/corp/bound/nob/admin/sd/vn_1_05.doc.xml"


# Copy the gt-directory from victorio for each language.
copy_gt ()
{
    for lang in "$@"
      do 
      scp -r saara@victorio.uit.no:/usr/local/share/corp/$gt/$lang /Users/hoavda/Public/corp/$gt
    done
    return 0
}

# Build an up-to-date analyzator and cg and
# analyze the contents of the corpus-hierarchy.
# The results are stored under /usr/local/share/corp/ga

make_gt ()
{
    for lang in "$@"
      do 
      cd $crondir && cvs -d :ext:victorio.uit.no:/usr/local/cvs/repository checkout gt
#      cd $crondir/gt && make TARGET=$lang 

      cd $crondir && cvs -d :ext:victorio.uit.no:/usr/local/cvs/repository checkout st
      cd $crondir/st/nob/src && make abbr 
    done
}

sent ()
{
    for file in $files
    do
      file1=$(echo $file | sed -e "s/\,.*$//")
      file2=$(echo $file | sed -e "s/^.*\,//")

      base01=$(basename $file1 .xml)
      base1=$(basename $file1)

      base2=$(basename $file2)

      dir=$corproot/parallel/$base01
      mkdir -p $dir
      
      if [ ! -e $dir/$base1.sent.xml ]
	  then
	  perl /Users/saara/cron/gt/script/corpus-parallel.pl --lang=sme --outdir="$dir" "$file1"
      fi

    done
}

analyze ()
{ 
    for file in $files

      do
      file1=$(echo $file | sed -e "s/\,.*$//")
      fs[$i]=$file1
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
    
process ()
{
    file="$1"

    base=$(basename $file .xml)
    in=$corproot/parallel/$base/$base.sent.xml
    out=$corproot/parallel/$base/$base.analyzed.xml
    echo "$crondir/gt/script/corpus-analyze.pl --output=$out $in"

    $crondir/gt/script/corpus-analyze.pl --output=$out $in
    
    return 0
}

#copy_gt $languages
#make_gt $languages
#sent
analyze

exit 0
