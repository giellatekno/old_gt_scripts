#!/bin/bash

function build_lang {
    LANG=$1

    if [ "$LANG" == "sme" ]
    then
        echo "cd $GTHOME/gt"
        cd $GTHOME/gt
        echo "make GTLANG=$LANG > /dev/null"
        make GTLANG=$LANG > /dev/null
        echo "make GTLANG=$LANG abbr > /dev/null"
        make GTLANG=$LANG abbr > /dev/null
    else
        echo "cd $GTHOME/langs/$LANG"
        cd $GTHOME/langs/$LANG
        echo "./autogen.sh > /dev/null"
        ./autogen.sh > /dev/null
        echo "./configure > /dev/null"
        ./configure > /dev/null
        echo "make > /dev/null"
        make > /dev/null
    fi
}

function preprocess_lookup2cg {
    INPUTFILE=$1
    LANG=$2

    if [ "$LANG" == "sme" ]
    then
        echo "preprocess --abbr=$GTHOME/gt/$SMILANG/bin/abbr.txt --corr=$GTHOME/gt/$SMILANG/bin/corr.txt $INPUTFILE 2> /dev/null | lookup -q -flags mbTT $GTHOME/gt/$LANG/bin/$LANG.fst | lookup2cg > $INPUTFILE.lookup2cg"
        time preprocess --abbr=$GTHOME/gt/$SMILANG/bin/abbr.txt --corr=$GTHOME/gt/$SMILANG/bin/corr.txt $INPUTFILE 2> /dev/null | lookup -q -flags mbTT $GTHOME/gt/$LANG/bin/$LANG.fst | lookup2cg > $INPUTFILE.lookup2cg
    else
        echo "preprocess $INPUTFILE 2> /dev/null | lookup -q -flags mbTT $GTHOME/langs/$SMILANG/src/analyser-gt-desc.xfst | lookup2cg > $INPUTFILE.lookup2cg"
        time preprocess $INPUTFILE 2> /dev/null | lookup -q -flags mbTT $GTHOME/langs/$SMILANG/src/analyser-gt-desc.xfst | lookup2cg > $INPUTFILE.lookup2cg
    fi
}

function disambiguation_analysis {
    INPUTFILE=$1
    LANG=$2

    if [ "$LANG" == "sme" ]
    then
        echo "vislcg3 -g $GTHOME/gt/$SMILANG/src/$SMILANG-dis.rle -I $INPUTFILE.lookup2cg > $INPUTFILE.dis"
        time vislcg3 -g $GTHOME/gt/$SMILANG/src/$SMILANG-dis.rle -I $INPUTFILE.lookup2cg > $INPUTFILE.dis
    else
        echo "vislcg3 -g $GTHOME/langs/$SMILANG/src/syntax/disambiguation.cg3 -I $INPUTFILE.lookup2cg > $INPUTFILE.dis"
        time vislcg3 -g $GTHOME/langs/$SMILANG/src/syntax/disambiguation.cg3 -I $INPUTFILE.lookup2cg > $INPUTFILE.dis
    fi
}

function dependency_analysis {
    INPUTFILE=$1

    echo "vislcg3 -g $GTHOME/gt/smi/src/smi-dep.rle -I $INPUTFILE.dis >> $ANALYSED_DIR/`basename $INPUTFILE.ccat.txt`.dep.txt"
    time vislcg3 -g $GTHOME/gt/smi/src/smi-dep.rle -I $INPUTFILE.dis >> $ANALYSED_DIR/`basename $INPUTFILE.ccat.txt`.dep.txt
}

function ccat_all_texts {
    SMILANG=$1
    BOUND=$2
    FREE=$3

    for CORPUS in $BOUND $FREE
    do
        cd $CORPUS/converted/$SMILANG
        for GENREDIR in `ls`
        do
            for f in `find $GENREDIR -type f`
            do
                OCR="`grep 'ocr/' $f`"
                if [ "$OCR" == "" ]
                then
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
                else
                    echo "ocr found in $f"
                fi
            done
        done
        cd ../../..
    done
}
# main
thisdir=`pwd`

BOUND_DIR=$thisdir/$1
FREE_DIR=$thisdir/$2
ANALYSED_DIR="$thisdir/$3/`date +%Y-%m-%d`"

if [ -d $ANALYSED_DIR ]
then
    rm $ANALYSED_DIR/*
else
    mkdir $ANALYSED_DIR
fi

for SMILANG in sma smj sme
do
    build_lang $SMILANG
    cd $thisdir
    ccat_all_texts $SMILANG $BOUND_DIR $FREE_DIR
    cd $thisdir

    for INPUTFILE in $ANALYSED_DIR/$SMILANG*.ccat.txt
    do
        preprocess_lookup2cg $INPUTFILE $SMILANG
        disambiguation_analysis $INPUTFILE $SMILANG
        dependency_analysis $INPUTFILE
    done
done

