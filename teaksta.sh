#! /bin/bash

# teaksta
# This is a shell script for analysing Northern Sámi text
# It gives the analysis, but not the number of the rules used to disambiguate

# usage:
# teaksta.sh filename

# You need to make GT_HOME point to your gt/ directory, normally one of the two following:
# export GT_HOME=/Users/<your_user_name> 
# export GT_HOME=/Users/<your_user_name>/Documents

cat  $1 | preprocess --abbr=$GT_HOME/gt/sme/bin/abbr.txt --corr=$GT_HOME/gt/sme/src/typos.txt | \
lookup -flags mbTT -utf8 $GT_HOME/gt/sme/bin/sme.fst | $GT_HOME/gt/script/lookup2cg | \
vislcg --grammar $GT_HOME/gt/sme/src/sme-dis.rle --minimal


# Notes for further development:
# ==============================

# At the moment, there is a family of scripts for analysis, in addition to this one:
# cealkka (sentence), sme-dis.sh (sentence, with rule nr), sme-multi.sh (sentence w/o disamb)
#                     smj-dis.sh (sentence, with rule nr), smj-multi.sh (sentence w/o disamb)
# With more lgs and more options this will develop into a wildernis.

# What we want:
# One script, with parametrised options along several paths:
# What language, 
# What kind of input (plain text, xml text, evt. other text formats as well)
# What kind of output (disambiguated text with and without rule numbers, non-disambiguated text with and without syntactic tags
# What kind of morphological transducers (standard (tolerant) or normative (restricted))
# 
# dis.sh (script for disambiguating text)
# options:
# -l <lang> what disambiguator to call for (compulsatory)
# -n        gives the rule number (no rule numbers is default)
# -m        gives the non-disambiguated output (only section 1 in the .rle file)
# -norm     uses normative transducers for the morphological analysis,
#           ie will not recognise any non-conformant spellings
# -i <type> gives text type:
#           xml  (default, calls for ccat with the same <lang> as given above)
#           txt  (takes plain text as input, is basically the script we have now)
#           doc  (if we bother doing this, it would call for ... | antiword -db | ccat | ...)
#           odt  (openoffice documents could probably get the same treatment
#           html (importing relevant code from convert2xml.pl)
#           pdf  (importing relevant code from convert2xml.pl)
# -o <type> visl (default is the standard vislcg output format)
#           xml  (gives xml-tagget output)

