#!/usr/bin/perl
use strict;

# Script that transforms something into something else
# Used for converting output from cg-analysis of speller into
# something to be fed into cg-based speller evaluation.

# usage: 
# input

my $inputForm = "";

while (<>) {
  chomp;
  if (/^\"(\<.+\>)\"$/) {
    $inputForm = $1;
  } elsif (/^(\s)*(\".+\")(.+)$/) {
    print "\t$2 $inputForm $3 &fromspeller\n";    
  } else {
    print "$_ is not a known pattern!\n";
  }
}





