#!/usr/bin/perl -w

while (<>) 
{
# convert the 6 sami letters from L1 to 7bit format
s/º/z1/g ;
s/²/S1/g ;
s/³/s1/g ;
s/±/n1/g ;
s/¤/d1/g ;
s/¢/c1/g ;
s/^L/ /g ;
s/¡/C1/g ;

print ;
}
