#!/usr/bin/perl

# Script to insert line instead of blanks
# in multiword expressions, in order to 
# make up for vislcg3 behaviour.

use utf8 ;

while (<>) {
    while (/("[^"]+?)\s+([^"]+?")/) {
	s/("[^"]+?)\s+([^"]+?")/$1_$2/;
    }
    print;
}
