#! /bin/bash

# loop-sent-disamb.sh
# This is a shell script for analysing (at the moment, only) Northern S?mi sentences with the vislcg3 parser.
# It gives the analysis, and optionally the number of the disambiguation rules.

#usage:
# <script_name> (-t) -l=<lang_code>
# to output the number of disambiguation rules, too, use the parameter '-t'
# parametized for language (sme as default)

# You need to make GT_HOME point to your gt/ directory, normally one of the two following:
# export GT_HOME=/Users/<your_user_name> 
# export GT_HOME=/Users/<your_user_name>/Documents

# todo: merge sme-multi.sh, loop-disamb, and loop-sent-depend.sh
# todo: extend the script to other languages for which there is a LANG-dis.rle


ft=$(echo "$@" | grep '\-t')

if [ ! -z "$ft" ]
then
    t="-t"
else
    t=""
fi

fl=$(echo "$@" | grep '\-l\=')

if [ ! -z "$fl" ]
then
    l=$(echo "$@" | perl -pe "s/.*?-l=(...).*/\1/")
else
    l="sme"
fi

case $l in
    sme) message="Atte cealkaga: "  ;;
    sma) message="Skriv setning: "  ;;
    smj) message="Atte tjielgga: "  ;;
    fin) message="Skriv setning: "  ;;
    kom) message="Skriv setning: "  ;;
    fao) message="Skriv setning: "  ;;
    nob) message="Skriv setning: "  ;;
    nno) message="Skriv setning: "  ;;
    kal) message="Skriv setning: "  ;;
    *)   message="Write sentence: " ;;
esac

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo "$message"                             # (message to user)
read sentence                               # next line calls the usual command which is the script sent-disamb.sh
./sent-disamb.sh $t "-l=$l" "${sentence}"
done                      
exit 0
