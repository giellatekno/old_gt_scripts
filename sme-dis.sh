#! /bin/bash

# sme-snt.sh
# This is a shell script for analysing Northern Sámi sentences.
# It gives the analysis, and the number of the rules used to disambiguate

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo -n "Atte cealkaga: "                   # (message to user)
read sentence                               # next 3 lines is the usual command
echo $sentence | ~/bin/tokenize ~/gt/sme/bin/tok.fst | \
lookup -flags mbTT ~/gt/sme/bin/sme.fst | ~/gt/script/lookup2cg | \
vislcg --grammar ~/gt/sme/src/sme-dis.rle --minimal

done                      
exit 0
