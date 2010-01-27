#! /bin/bash

# kal-snt.sh
# This is a shell script for analysing Northern S·mi sentences.
# It gives the analysis, and the number of the rules used to disambiguate

if [ `hostname` == 'victorio.uit.no' ]
then
    LOOKUP=/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup
else
    LOOKUP=`which lookup`
fi

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo -n "Skriv sætning på grønlandsk: "                   # (message to user)
read sentence                               # next 5 lines is the usual command
echo $sentence | \
preprocess --abbr=$GTHOME/st/kal/bin/abbr.txt | \
$LOOKUP -flags mbTT -utf8 $GTHOME/st/kal/bin/kal.fst | \
$GTHOME/gt/script/lookup2cg | \
vislcg3 -g $GTHOME/st/kal/src/kal-dis3.rle #--trace

done                      
exit 0
