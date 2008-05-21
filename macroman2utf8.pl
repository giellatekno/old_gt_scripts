#!/usr/bin/perl
# Converting text from plain text mac-files that are sent to Linux.
use utf8;

while (<>) 
{
# convert 6 of the 7 sami letters (the seventh being á)
# The values below are the positions to which the mac-to-linux
# conversion utility has put the Sami letters (not recognising them
# as such, here these 'wherever' positions are translated to the
# digraphs that are in use in the morphological analyser.

s/∏/č/g;
s/π/đ/g;
s/∫/ŋ/g;
s/ª/š/g;
s/º/ŧ/g; # was removed earlier, why?
s/Ω/ž/g;
s/Ω/ž/g;
s/¢/Č/g;
s/∞/Đ/g;
s/±/Ŋ/g;
s/¥/Š/g;
s/µ/Ŧ/g;
s/∑/Ž/g;



# remove punctuation, should be omitted when a preprocessor
# is in place.
#s/[".,:;\?\*\(\)]//g ;
#s/[2-9]//g ;
#s/ 1//g ;
print ;
}
