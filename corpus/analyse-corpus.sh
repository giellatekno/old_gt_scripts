#!/bin/bash

cd $GTHOME
svn up
SVNREVISION=`svn info | grep Revision | cut -f1 -d" "`

ANALYSED_DIR="/Users/hoavda/Public/corp/analysed/`date +%Y-%m-%d`"

mkdir $ANALYSED_DIR

for SMILANG in sma sme smj
do
    cd $GTHOME/gt
    make TARGET=$SMILANG
    if [ $SMILANG == "sma" ]
    then
        PREPROCESS="preprocess"
    else
        PREPROCESS="preprocess --abbr=$GTHOME/gt/$SMILANG/bin/abbr.txt"
    fi

    for CORPUS in boundcorpus freecorpus
    do
        for GENREDIR in `ls /Users/hoavda/Public/corp/$CORPUS/converted/$SMILANG`
        do
            touch $ANALYSED_DIR/$SMILANG-$GENREDIR-dep.txt
            time ccat -l $SMILANG -a -r /Users/hoavda/Public/corp/$CORPUS/converted/$SMILANG/$GENREDIR > $ANALYSED_DIR/$SMILANG-$GENREDIR.ccat.txt
            time cat $ANALYSED_DIR/$SMILANG-$GENREDIR.ccat.txt | $PREPROCESS | lookup -flags mbTT $GTHOME/gt/$SMILANG/bin/$SMILANG.fst | lookup2cg | vislcg3 -g $GTHOME/gt/$SMILANG/bin/$SMILANG-dis.bin | vislcg3 -g $GTHOME/gt/smi/bin/smi-dep.bin >> $ANALYSED_DIR/$SMILANG-$GENREDIR-dep.txt
        done
    done
done
