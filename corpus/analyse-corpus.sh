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

function preprocess_file {
    INPUTFILE=$1
    LANG=$2

    if [ "$LANG" == "sme" ]
    then
        echo "preprocess --abbr=$GTHOME/gt/$SMILANG/bin/abbr.txt --corr=$GTHOME/gt/$SMILANG/bin/corr.txt $INPUTFILE 2> /dev/null | lookup -q -flags mbTT $GTHOME/gt/$LANG/bin/$LANG.fst > $INPUTFILE.preprocess"
        time preprocess --abbr=$GTHOME/gt/$SMILANG/bin/abbr.txt --corr=$GTHOME/gt/$SMILANG/bin/corr.txt $INPUTFILE 2> /dev/null | lookup -q -flags mbTT $GTHOME/gt/$LANG/bin/$LANG.fst > $INPUTFILE.preprocess
    else
        echo "preprocess $INPUTFILE 2> /dev/null | lookup -q -flags mbTT $GTHOME/langs/$SMILANG/src/analyser-gt-desc.xfst > $INPUTFILE.preprocess"
        time preprocess $INPUTFILE 2> /dev/null | lookup -q -flags mbTT $GTHOME/langs/$SMILANG/src/analyser-gt-desc.xfst > $INPUTFILE.preprocess
    fi
}

function disambiguation_analysis {
    INPUTFILE=$1
    LANG=$2

    if [ "$LANG" == "sme" ]
    then
        echo "lookup2cg $INPUTFILE.preprocess | vislcg3 -g $GTHOME/gt/$SMILANG/src/$SMILANG-dis.rle > $INPUTFILE.dis"
        time lookup2cg $INPUTFILE.preprocess | vislcg3 -g $GTHOME/gt/$SMILANG/src/$SMILANG-dis.rle > $INPUTFILE.dis
    else
        echo "lookup2cg $INPUTFILE.preprocess | vislcg3 -g $GTHOME/langs/$SMILANG/src/syntax/disambiguation.cg3 > $INPUTFILE.dis"
        time lookup2cg $INPUTFILE.preprocess | vislcg3 -g $GTHOME/langs/$SMILANG/src/syntax/disambiguation.cg3 > $INPUTFILE.dis
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
        preprocess_file $INPUTFILE $SMILANG
        disambiguation_analysis $INPUTFILE $SMILANG
        dependency_analysis $INPUTFILE
    done
done

