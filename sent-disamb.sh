#! /bin/bash

# sent-dis.sh
# This is a shell script for analysing (at the moment, only) Northern Sámi sentences with the vislcg3 parser.
# It gives the analysis, and optionally the number of the disambiguation rules.

#usage:
# <script_name> <sentence_to_analyze> (-t)
# to output the number of disambiguation rules, too, use the parameter '-t'

if [ `hostname` == 'victorio.uit.no' ]
then
    LOOKUP=/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup
else
    LOOKUP=`which lookup`
fi

if [ "$2" = "-t" ]
then
    TRACE="--trace"
else
    TRACE=""
fi

echo $1 | \
preprocess --abbr=$GTHOME/gt/sme/bin/abbr.txt | \
$LOOKUP -flags mbTT -utf8 $GTHOME/gt/sme/bin/sme.fst | \
$GTHOME/gt/script/lookup2cg | \
vislcg3 -g $GTHOME/gt/sme/src/sme-dis.rle $TRACE
