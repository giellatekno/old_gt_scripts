#!/bin/bash

cd $GTHOME
SVNREVISION=`svn info | grep Revision | cut -f1 -d" "`

ANALYSED_DIR="/Users/hoavda/Public/corp/analysed/`date +%Y-%m-%d`"

mkdir $ANALYSED_DIR

for LANG in sma sme smj
do
    touch $ANALYSED_DIR/$LANG-dep.txt
    for CORPUS in boundcorpus freecorpus
    do
        if [ $LANG == "sma" ]
        then
            PREPROCESS="preprocess"
        else
            PREPROCESS="preprocess --abbr=$GTHOME/gt/$LANG/bin/abbr.txt"
        fi
        time ccat -l $LANG -a -r /Users/hoavda/Public/corp/$CORPUS/converted/$LANG | $PREPROCESS | lookup -flabs mbTT $GTHOME/gt/$LANG/bin/$LANG.fst | lookup2cg | vislcg3 -g $GTHOME/gt/$LANG/bin/$LANG-dis.bin | vislcg3 -g $GTHOME/gt/smi/bin/smi-dep.bin >> $ANALYSED_DIR/$LANG-dep.txt
    done
done
