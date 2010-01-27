#! /bin/bash

# sme-snt.sh
# This is a shell script for analysing Northern S�mi sentences.
# It gives the analysis, and the number of the rules used to disambiguate

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo -n "Atte cealkaga: "                   # (message to user)
read sentence                               # next 3 lines is the usual command
echo $sentence | preprocess --abbr=$GTHOME/gt/sme/bin/abbr.txt | \
lookup -flags mbTT -utf8 $GTHOME/gt/sme/bin/sme.fst | $GTHOME/gt/script/lookup2cg
#vislcg --grammar $GTHOME/gt/sme/src/sme-dis.rle --minimal

done                      
exit 0
