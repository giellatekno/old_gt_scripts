#!/usr/bin/perl -w
# Converting text from plain text mac-files that are sent to Linux.

while (<>) 
{
# convert 6 of the 7 sami letters (the seventh being á)
# The values below are the positions to which the mac-to-linux
# conversion utility has put the Sami letters (not recognising them
# as such, here these 'wherever' positions are translated to the
# digraphs that are in use in the morphological analyser.

s/¢/C1/g ;
s/½/c1/g ;
s/Ð/D1/g ;
s/¼/d1/g ;
s/±/N1/g ;
s/\206/n1/g ;
s/¥/S1/g ;
s/ª/s1/g ;
s/µ/T1/g ;
s/º/t1/g ;
s/\205/Z1/g ;
s/\207/z1/g ;


# remove punctuation, should be omitted when a preprocessor
# is in place.
s/[".,:;\?\*\(\)]//g ;
#s/[2-9]//g ;
#s/ 1//g ;
print ;
}
