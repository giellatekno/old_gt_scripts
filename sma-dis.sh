#! /bin/bash

# sma-snt.sh
# This is a shell script for analysing Southern Sámi sentences.
# It gives the analysis, and the number of the rules used to disambiguate

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo -n "Skriv setning: "                   # (message to user)
read sentence                               # next 3 lines is the usual command
echo $sentence | preprocess | \
lookup -flags mbTT -utf8 $GTHOME/gt/sma/bin/sma.fst | \
$GTHOME/gt/script/lookup2cg | \
vislcg3 -g $GTHOME/gt/sma/src/sma-dis.rle #--trace


done                      
exit 0
