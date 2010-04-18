#! /bin/bash

# sent-dis.sh
# This is a shell script for analysing (at the moment, only) Northern Sámi sentences with the vislcg3 parser.
# It gives the analysis, and optionally the number of the disambiguation rules.

#usage:
# <script_name> (-t)
# to output the number of disambiguation rules, too, use the parameter '-t'

# You need to make GT_HOME point to your gt/ directory, normally one of the two following:
# export GT_HOME=/Users/<your_user_name> 
# export GT_HOME=/Users/<your_user_name>/Documents

# todo: parametize for language!

if [ `hostname` == 'victorio.uit.no' ]
then
    LOOKUP=/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup
else
    LOOKUP=`which lookup`
fi

if [ "$1" = "-t" ]
then
    TRACE="--trace"
else
    TRACE=""
fi


while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo "Atte cealkaga: "                   # (message to user)
read sentence                               # next 3 lines is the usual command
echo $sentence | preprocess --abbr=$GTHOME/gt/sme/bin/abbr.txt | \
$LOOKUP -flags mbTT -utf8 $GTHOME/gt/sme/bin/sme.fst | $GTHOME/gt/script/lookup2cg | \
 vislcg3 -g $GTHOME/gt/sme/src/sme-dis.rle $TRACE  # no m4
#dis.sh --grammar $GTHOME/gt/sme/bin/sme-dis.rle --minimal  # m4

done                      
exit 0
