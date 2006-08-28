#! /bin/bash

# teaksta
# This is a shell script for analysing Northern Sámi text
# It gives the analysis, but not the number of the rules used to disambiguate


teaksta                                    # for input file
{                                          # run the following loop
ccat -l sme $1 | preprocess --abbr=~/gt/sme/bin/abbr.txt | corrtypos.pl | \
lookup -flags mbTT -utf8 ~/gt/sme/bin/sme.fst | ~/gt/script/lookup2cg | \
vislcg --grammar ~/gt/sme/src/sme-dis.rle #--minimal

}                      
exit 0
