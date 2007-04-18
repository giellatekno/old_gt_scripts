#!/bin/sh
split -l 25000000 $1 $2-large
for i in $2-large*
do
	LANG= sort -ru $i > $2/int/$i-sorted
	rm -f $i
done
LANG= sort -mru $2/int/*-sorted > $3


# Tomis alterntative
# find ~/gt/smj/polderland -name 'large??' -print0 | xargs -0 -n1 sort -ru
