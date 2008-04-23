#! /bin/bash

# sma-snt.sh
# This is a shell script for analysing Northern Sámi sentences.
# It gives the analysis, and the number of the rules used to disambiguate

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo -n "Atte cealkaga: "                   # (message to user)
read sentence                               # next 3 lines is the usual command
echo $sentence | preprocess --abbr=~/gt/sma/bin/abbr.txt | \
lookup -flags mbTT -utf8 ~/gt/sma/bin/sma.fst | ~/gt/script/lookup2cg | \
 vislcg3 -g ~/gt/sma/src/sma-dis.rle --trace  # no m4
#dis.sh --grammar ~/gt/sma/bin/sma-dis.rle --minimal  # m4

done                      
exit 0
