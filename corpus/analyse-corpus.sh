#!/bin/bash

cd $GTHOME
echo "svn up in $GTHOME"
svn -q up
SVNREVISION=`svn info | grep Revision | cut -f1 -d" "`

ANALYSED_DIR="/Users/hoavda/Public/corp/analysed/`date +%Y-%m-%d`"

if [ -d $ANALYSED_DIR ]
then
	echo "removing content in $ANALYSED_DIR"
	rm $ANALYSED_DIR/*
else
	mkdir $ANALYSED_DIR
fi
chmod 777 $ANALYSED_DIR

for SMILANG in sma sme smj
do
	# First ccat all texts
	echo "ccat'ing all $SMILANG xml files"
    for CORPUS in boundcorpus freecorpus
    do
        
        cd /Users/hoavda/Public/corp/$CORPUS/converted/$SMILANG
        for GENREDIR in `ls`
        do
			if [ "`basename $f`" != "xb.html.xml" -a "`basename $f`" != "lule_sami_new_testament.html.xml" ]
			then
				for f in `find $GENREDIR -type f`
				do
					# ccat makes nonvalid utf8 of some files, ignore them
					ccat -a $f | iconv -f utf-8 -t utf-8 > /dev/null
					if [ $? -eq 0 ]
					then
						TRANSLATED_FROM=`grep translated_from $f | cut -f2 -d'"'`
						if [ "$TRANSLATED_FROM" == "" ]
						then
							CCAT_FILE="$ANALYSED_DIR/$SMILANG-$GENREDIR.ccat.txt"
						else
							CCAT_FILE="$ANALYSED_DIR/$SMILANG-$TRANSLATED_FROM-$GENREDIR.ccat.txt"
						fi
						touch $CCAT_FILE
	# 					echo "ccat'ing $f into $CCAT_FILE"
						ccat -l $SMILANG -a $f >> $CCAT_FILE
					else
						echo "ccat made invalid utf8, ignoring $f"
					fi
				done
			fi
        done
    done

    cd $GTHOME/gt
    make TARGET=$SMILANG
    if [ $SMILANG == "sma" ]
    then
        PREPROCESS="preprocess"
    else
        PREPROCESS="preprocess --abbr=$GTHOME/gt/$SMILANG/bin/abbr.txt"
    fi

    for i in $ANALYSED_DIR/$SMILANG*.ccat.txt
    do
		echo "Preprocessing $i …"
		time cat $i | $PREPROCESS 2> /dev/null | lookup -flags mbTT $GTHOME/gt/$SMILANG/bin/$SMILANG.fst | lookup2cg > $i.lookup2cg
		echo "$SMILANG dis analysis of $i.lookup2cg …"
		time vislcg3 -g $GTHOME/gt/$SMILANG/bin/$SMILANG-dis.bin -I $i.lookup2cg > $i.dis
		echo "$SMILANG dep analysis of $i.dis …"
		touch $ANALYSED_DIR/`basename $i .ccat.txt`.dep.txt
		time vislcg3 -g $GTHOME/gt/smi/bin/smi-dep.bin -I $i.dis >> $ANALYSED_DIR/`basename $i .ccat.txt`.dep.txt
	done
done
