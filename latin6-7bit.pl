#!/usr/bin/perl -w

while (<>) 
{
# convert the 6 sami letters from L6 to 7bit format
s/\310/C1/g ; 
s/\350/c1/g ; 
s/\251/D1/g ; 
s/\271/d1/g ; 
s/\257/N1/g ; 
s/\277/n1/g ; 
s/\252/S1/g ; 
s/\272/s1/g ; 
s/\253/T1/g ; 
s/\273/t1/g ;
s/\254/Z1/g ;
s/\274/z1/g ;
s/\320/D1/g ; # just in case icelandic abuse
s/\360/d1/g ; # just in case icelandic abuse



# remove punctuation, should be omitted when a preprocessor
# is in place.
#s/[0".,:;\?\-\*\(\)]//g ;
#s/[2-9]//g ;
#s/ 1//g ;
print ;
}
