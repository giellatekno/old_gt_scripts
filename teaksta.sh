#! /bin/bash

# teaksta
# This is a shell script for analysing Northern Sámi text
# It gives the analysis, but not the number of the rules used to disambiguate

# usage:
# teaksta.sh filename

# This one does not work:
cat  $1 | preprocess --abbr=~/gt/sme/bin/abbr.txt --corr=~/gt/sme/src/typos.txt | \
lookup -flags mbTT -utf8 ~/gt/sme/bin/sme.fst | ~/gt/script/lookup2cg | \
vislcg --grammar ~/gt/sme/src/sme-dis.rle | less #--minimal

# This one works when I stand in gt/script, but not elsewhere
#cat  $1 | preprocess --abbr=../sme/bin/abbr.txt --corr=../sme/src/typos.txt | \
#lookup -flags mbTT -utf8 ../sme/bin/sme.fst | ../script/lookup2cg | \
#vislcg --grammar ../sme/src/sme-dis.rle | less #--minimal
