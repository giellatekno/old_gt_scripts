#!/bin/sh

FILE=$@

# for kvart ord (kvar line) i FILE:
for word in `cat $FILE`

do

# grep dette ordet i  *.txt & tel det:
result=`grep "$word" *.txt | wc -l`

# Skriv ut resultatet:
echo "$result $word"

done 
