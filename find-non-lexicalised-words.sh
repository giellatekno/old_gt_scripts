#!/bin/bash

# Usage:
# find-non-lexicalised-words.sh file-with-analysed-words
# Input is a file that has one word per line

for word in `cat $1`
do
    ok=0
    outword=""
    analisys=`echo $word | lookup -flags mbTT $GTHOME/gt/sme/bin/sme.fst 2> /dev/null | grep -v "?" | grep -v +Der`
    
    if [ `echo ${#analisys}` == "0" ]
    then
        echo "$word"
    fi
done
