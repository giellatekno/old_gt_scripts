#! /bin/bash

# nob-snt.sh
# This is a shell script for analysing Northern S�mi sentences.
# It gives the analysis, and the number of the rules used to disambiguate

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo -n "Atte cealkaga: "                   # (message to user)
read sentence                               # next 3 lines is the usual command
echo $sentence | preprocess --abbr=~/gtsvn/st/nob/bin/abbr.txt | \
lookup -flags mbTT -utf8 ~/gtsvn/st/nob/bin/nob.fst | ~/gtsvn/st/script/lookup2cg | \
 vislcg3 -g ~/gtsvn/st/nob/src/nob-dis.rle


done                      
exit 0
