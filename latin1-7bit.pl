#!/usr/bin/perl -w

while (<>) 
{
# convert the 6 sami letters from L1 to 7bit format
s/�/z1/g ;
s/�/S1/g ;
s/�/s1/g ;
s/�/n1/g ;
s/�/d1/g ;
s/�/c1/g ;
s/^L/ /g ;
s/�/C1/g ;

print ;
}
