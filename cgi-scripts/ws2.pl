#!/usr/bin/perl -w

while (<>) 
{
# convert the 7 sami letters
#s/Á/A1/g ;
#s/á/a1/g ; 
s/\202/C1/g ; 
s/\204/c1/g ; 
s/\211/D1/g ; 
s/\230/d1/g ; 
s/\270/N1/g ; 
s/\271/n1/g ; 
s/\212/S1/g ; 
s/\232/s1/g ;
s/\274/t1/g ;  
s/\272/T1/g ; 
s/\277/z1/g ;
s/\276/Z1/g ;

# remove punctuation, should be omitted when a preprocessor
# is in place.
s/[0".,:;\?\-\*\(\)]//g ;
s/[2-9]//g ;
s/ 1//g ;
print ;
}
