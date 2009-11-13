#! /bin/bash

# smj-dis.sh
# This is a shell script for analysing Lule Sámi sentences.
# It gives the analysis, and the number of the rules used to disambiguate

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo -n "Atte tjielgga: "                   # (message to user)
read sentence                               # next 3 lines is the usual command
echo $sentence | preprocess | lookup -flags mbTT -utf8 ~/gtsvn/gt/smj/bin/smj.fst | ~/gtsvn/gt/script/lookup2cg | \
#vislcg3 -g ~/gtsvn/gt/smj/src/smj-dis.rle
vislcg3 -g ~/gtsvn/gt/smj/src/smj-dis.rle --trace

done                      
exit 0
