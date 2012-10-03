#!/bin/bash

# Usage:
# find-non-lexicalised-words.sh file-with-analysed-words
# Input is a file that has one word per line

for word in `cat $1`
do
    ok=0
    analisys=`echo $word | lookup -flags mbTT $GTHOME/gt/sme/bin/sme.fst 2> /dev/null | grep -v "?" | grep + | cut -f2 | cut -f1 -d'+' | sort -u`
    for line in $analisys
    do
        if [ "$line" == "$word" ]
        then
            ok=1
            break
        fi
    done
    
    if [ "$ok" == "0" ]
    then
        echo $word
    fi
done