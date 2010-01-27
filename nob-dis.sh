#! /bin/bash

# nob-snt.sh
# This is a shell script for analysing Northern Sámi sentences.
# It gives the analysis, and the number of the rules used to disambiguate

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo -n "Atte cealkaga: "                   # (message to user)
read sentence                               # next 3 lines is the usual command
echo $sentence | \
preprocess --abbr=$GTHOME/st/nob/bin/abbr.txt | \
lookup -flags mbTT -utf8 $GTHOME/st/nob/bin/nob.fst | \
$GTHOME/st/script/lookup2cg | \
vislcg3 -g $GTHOME/st/nob/src/nob-dis.rle


done                      
exit 0
