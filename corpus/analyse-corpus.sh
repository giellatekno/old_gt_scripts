#!/bin/bash

function build_lang {
    LANG=$1
    
    if [ "$LANG" == "sme" ]
    then
        cd $GTHOME/gt/$LANG
        make GTLANG=$LANG > /dev/null
        make GTLANG=$LANG abbr > /dev/null
    else 
        cd $GTHOME/langs/$LANG
        ./autogen.sh > /dev/null
        ./configure > /dev/null
        make > /dev/null
    fi
}

function preprocess_lookup2cg {
    INPUTFILE=$1
    LANG=$2

    if [ "$LANG" == "sme" ]
    then
        preprocess --abbr=$GTHOME/gt/$SMILANG/bin/abbr.txt --corr=$GTHOME/gt/$SMILANG/bin/corr.txt $INPUTFILE 2> /dev/null | lookup -q -flags mbTT $GTHOME/gt/$LANG/bin/$LANG.fst | lookup2cg > $INPUTFILE.lookup2cg
    else
        preprocess $INPUTFILE 2> /dev/null | lookup -q -flags mbTT $GTHOME/langs/$SMILANG/src/analyser.gt.xfst | lookup2cg > $INPUTFILE.lookup2cg
    fi
}

function disambiguation_analysis {
    INPUTFILE=$1
    LANG=$2
    
    if [ "$LANG" == "sme" ] 
    then
        vislcg3 -g $GTHOME/gt/$SMILANG/src/$SMILANG-dis.rle -I $INPUTFILE.lookup2cg > $INPUTFILE.dis
    else
        vislcg3 -g $GTHOME/langs/$SMILANG/src/syntax/disambiguation.cg3 -I $INPUTFILE.lookup2cg > $INPUTFILE.dis
    fi
}

function dependency_analysis {
    INPUTFILE=$1
    
    vislcg3 -g $GTHOME/gt/smi/src/smi-dep.rle -I $INPUTFILE.dis >> $ANALYSED_DIR/`basename $INPUTFILE.ccat.txt`.dep.txt
}

# main
cd $GTHOME
SVNREVISION=`svn info | grep Revision | cut -f1 -d" "`

ANALYSED_DIR="/Users/hoavda/Public/corp/analysed/`date +%Y-%m-%d`"

if [ -d $ANALYSED_DIR ]
then
    rm $ANALYSED_DIR/*
else
    mkdir $ANALYSED_DIR
fi
chmod 777 $ANALYSED_DIR

for SMILANG in sma sme smj
do
    # First ccat all texts
    for CORPUS in boundcorpus freecorpus
    do
        cd /Users/hoavda/Public/corp/$CORPUS/converted/$SMILANG
        for GENREDIR in `ls`
        do
            for f in `find $GENREDIR -type f`
            do
                # ccat makes nonvalid utf8 of some files, ignore them
                ccat -a $f | iconv -f utf-8 -t utf-8 > /dev/null
                if [ $? -eq 0 ]
                then
                    if [ "`basename $f`" != "xb.html.xml" -a "`basename $f`" != "lule_sami_new_testament.html.xml" ]
                    then
                        TRANSLATED_FROM=`grep translated_from $f | cut -f2 -d'"'`
                        if [ "$TRANSLATED_FROM" == "" ]
                        then
                            CCAT_FILE="$ANALYSED_DIR/$SMILANG-$GENREDIR.ccat.txt"
                        else
                            CCAT_FILE="$ANALYSED_DIR/$SMILANG-$TRANSLATED_FROM-$GENREDIR.ccat.txt"
                        fi
                        touch $CCAT_FILE
                        ccat -l $SMILANG -a $f >> $CCAT_FILE
                    fi
                else
                    echo "ccat made invalid utf8, ignoring $f"
                fi
            done
        done
    done

    build_lang $SMILANG
    
    for INPUTFILE in $ANALYSED_DIR/$SMILANG*.ccat.txt
    do
        preprocess_lookup2cg $INPUTFILE $SMILANG
        disambiguation_analysis $INPUTFILE $SMILANG
        touch $ANALYSED_DIR/`basename $INPUTFILE .ccat.txt`.dep.txt
        dependency_analysis $INPUTFILE
    done
done

