#! /bin/bash

# cealkka
# This is a shell script for analysing Northern Sámi sentences.
# It gives the analysis, but not the number of the rules used to disambiguate

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo -n "Atte cealkaga (ctrl-C = STOP): "          # (message to user)
read sentence                               # next 3 lines is the usual command
echo $sentence | preprocess --abbr=~/gtsvn/gt/sme/bin/abbr.txt | \
lookup -flags mbTT -utf8 ~/gtsvn/gt/sme/bin/sme.fst | ~/gtsvn/gt/script/lookup2cg | \
vislcg --grammar $HOME/gtsvn/gt/sme/src/sme-dis.rle | ~/gtsvn/gt/script/cg2visl.pl
#$HOME/gtsvn/gt/script/dis.sh --grammar $HOME/gtsvn/gt/sme/bin/sme-dis.rle  # m4
 #--minimal

done                      
exit 0
