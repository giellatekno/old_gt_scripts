#! /bin/bash

# cealkka3
# This is a shell script for analysing Northern Sámi sentences.
# It gives the analysis, but not the number of the rules used to disambiguate
# It uses the vislcg3 parser.

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo -n "Atte cealkaga (ctrl-C = STOP): "          # (message to user)
read sentence                               # next 3 lines is the usual command
echo $sentence | \
preprocess --abbr=$GTHOME/gt/sme/bin/abbr.txt | \
lookup -flags mbTT -utf8 $GTHOME/gt/sme/bin/sme.fst | \
$GTHOME/gt/script/lookup2cg | \
vislcg3 --grammar $GTHOME/gt/sme/src/sme-dis.rle -C UTF-8 | \
vislcg3 --grammar $GTHOME/gt/sme/src/sme-dep.rle -C UTF-8

done                      
exit 0
