#!/bin/bash

chars=($(cut -c 1-2 $1 | sort -u))
#chars=($(head -n 1000 sme/aspell/sme.wl | cut -c 1-2))
#chars=($(egrep -o '\b[^0-9]{2}\b' sme/aspell/begin.txt))
counter=0

echo
echo "*** Munching wordlist ***"
echo
echo -en "\t$0%\r"

for char in $(seq 0 $((${#chars[@]} - 1)))
 do
 counter=$(($counter + 1))
 letters=${chars[$char]}
# echo "$letters ${#letters}"
 if [[ ${#letters} == 2 ]]
   then
     /bin/grep ^${chars[$char]} $1 | aspell -l se --dict-dir=/home/tomi/gt/sme/aspell --encoding=l_se munch-list >> $2
     prosentti=($(echo "scale=0; 100*$counter/${#chars[@]}" | bc -l))
     prosentti=$(($prosentti + 1))
     echo -en "\t$prosentti%\r"
 fi
done

echo

exit 0


#use strict;
#use encoding 'utf-8';
#use open ':utf8';

#my @chars = system "cut -c 1-2 sme/aspell/sme.wl";# | sort | uniq";

#for my $char (@chars) {
#    print "grep \"$char\" sme/aspell/sme.wl | aspell -l sme --dict-dir=/home/tomi/gt/sme/aspell --encoding=sme munch-list >> sme/aspell/sme_munched.wl";
#    print "$char";
#}
