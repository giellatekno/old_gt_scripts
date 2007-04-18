#!/bin/sh

# $1 = large input
# $2 = target
# $3 = sorted output

# 1 get the initial chars from sigma
printf "load stack < $2/bin/spellernonrec-$2.fst \n \
sigma \n \
quit \n " > tmp/sigma-script

# 2 grep with the initial chars and the numbers, get the lines from bigfile, store to separate files
# 3 for each separate file, sort, and store as -sorted
for i in `xfst -utf8 -f tmp/sigma-script -q | tr ' ' '\n' | grep '^.$' | egrep '[[:alpha:]]' | LANG= sort -ru` 
do
	grep ^$i $1 > $2/int/$i-init.plx
	sort -ru $2/int/$i-init.plx > $2/int/$i-init-sorted.plx
	rm -f $2/int/$i-init.plx
done

for i in 9 8 7 6 5 4 3 2 1 0
do
	grep ^$i $1 > $2/int/num-init.plx
	sort -ru $2/int/num-init.plx > $2/int/num-init-sorted.plx
done

# Be sure to delete old garbage
rm -f tmp/large-$2-sorted.plx

# 4 concatenate the files, in sorted order, and store as total
for i in `xfst -utf8 -f tmp/sigma-script -q | tr ' ' '\n' | grep '^.$' | egrep '[[:alpha:]]' | LANG= sort -ru` 
do
	cat $2/int/$i-init-sorted.plx >> tmp/large-$2-sorted.plx
done

cat $2/int/num-init-sorted.plx >> tmp/large-$2-sorted.plx


# Børre pseudo:
# for each line, 
# split line into $firstchar $rest
# write line to file large-$firstchar
# 
# sed 's/(^.)(.*$)/$1$2/g
# write $1$2 to large-$1
