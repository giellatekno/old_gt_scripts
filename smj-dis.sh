#! /bin/bash

# smj-dis.sh
# This is a shell script for analysing Lule S�mi sentences.
# It gives the analysis, and the number of the rules used to disambiguate

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo -n "Atte tjielgga: "                   # (message to user)
read sentence                               # next 3 lines is the usual command
echo $sentence | preprocess | lookup -flags mbTT -utf8 ~/gt/smj/bin/smj.fst | ~/gt/script/lookup2cg | \
vislcg --grammar ~/gt/smj/src/smj-dis.rle --minimal

done                      
exit 0
