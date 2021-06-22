#!/bin/bash

while read i
do
#    echo "$i" |\
    sed 's/<[^>]*>//g;' |\
	grep -v 'e="preserve">thumb' |\
	grep -v '__NOEDITSECTION__' |\
    sed 's/^.*preserve">//g;' |\
    grep -v NOTOC
done 

    
