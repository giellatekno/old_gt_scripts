#! /bin/bash

# sme-snt.sh
# This is a shell script for analysing Northern Sámi sentences.
# It gives the analysis, and the number of the rules used to disambiguate

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo -n "Atte cealkaga: "                   # (message to user)
read sentence                               # next 3 lines is the usual command
echo $sentence | preprocess --abbr=~/gt/sme/bin/abbr.txt | \
lookup -flags mbTT -utf8 ~/gt/sme/bin/sme.fst | ~/gt/script/lookup2cg | \
 vislcg --grammar ~/gt/sme/src/sme-dis.rle --minimal  # no m4
#dis.sh --grammar ~/gt/sme/bin/sme-dis.rle --minimal  # m4

done                      
exit 0
