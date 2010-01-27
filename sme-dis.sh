#! /bin/bash

# sme-snt.sh
# This is a shell script for analysing Northern Sámi sentences.
# It gives the analysis, and the number of the rules used to disambiguate

if [ `hostname` == 'victorio.uit.no' ]
then
    LOOKUP=/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup
else
    LOOKUP=`which lookup`
fi

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo -n "Atte cealkaga: "                   # (message to user)
read sentence                               # next 3 lines is the usual command
echo $sentence | preprocess --abbr=$GTHOME/gt/sme/bin/abbr.txt | \
$LOOKUP -flags mbTT -utf8 $GTHOME/gt/sme/bin/sme.fst | $GTHOME/gt/script/lookup2cg | \
 vislcg3 -g $GTHOME/gt/sme/src/sme-dis.rle --trace  # no m4
#dis.sh --grammar $GTHOME/gt/sme/bin/sme-dis.rle --minimal  # m4

done                      
exit 0
