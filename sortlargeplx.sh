#!/bin/sh
gunzip -c $1 | split -l 25000000 - large
for i in large*
do
	LANG= sort -ru $i > $i-sorted
done
LANG= sort -mru *-sorted > $2


# Tomis alterntative
# find ~/gt/smj/polderland -name 'large??' -print0 | xargs -0 -n1 sort -ru
