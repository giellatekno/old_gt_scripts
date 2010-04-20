#! /bin/bash

# sent-disamb.sh
# This is a shell script for analysing (at the moment, only) Northern Sámi sentences with the vislcg3 parser.
# It gives the analysis, and optionally the number of the disambiguation rules.

#usage:
# <script_name> (-t) -l=<lang_code> <sentence_to_analyze>
# to output the number of disambiguation rules, too, use the parameter '-t'
# parametized for language (sme as default)
# input sentence always at the end

if [ `hostname` == 'victorio.uit.no' ]
then
    LOOKUP=/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup
else
    LOOKUP=`which lookup`
fi

ft=$(echo "$@" | grep '\-t')
if [ ! -z "$ft" ]
then
    t="--trace"
else
    t=""
fi

fl=$(echo "$@" | grep '\-l\=')
if [ ! -z "$fl" ]
then
    l=$(echo "$@" | perl -pe "s/.*?-l=(...).*/\1/")
    if  [  -f $GTHOME/gt/$l/bin/abbr.txt ]
    then
	abbr="--abbr=$GTHOME/gt/$l/bin/abbr.txt"
    else
	abbr=""
    fi
else
    l="sme"
    if  [  -f $GTHOME/gt/$l/bin/abbr.txt ]
    then
	abbr="--abbr=$GTHOME/gt/$l/bin/abbr.txt"
    else
	abbr=""
    fi
fi

# sentence is the last argument
echo ${@:${#@}} | \
preprocess $abbr | \
$LOOKUP -flags mbTT -utf8 $GTHOME/gt/$l/bin/$l.fst | \
$GTHOME/gt/script/lookup2cg | \
vislcg3 -g $GTHOME/gt/$l/src/$l-dis.rle $t
