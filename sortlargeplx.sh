#!/bin/sh
gunzip -c $1 | split -l 25000000 - large
for i in large*
do
	sort -ru $i > $i-sorted
done
sort -mru *-sorted > finishedlargefile



# find ~/gt/smj/polderland -name 'large??' -print0 | xargs -0 -n1 sort -ru
