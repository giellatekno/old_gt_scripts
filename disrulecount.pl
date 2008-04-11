#!/usr/bin/perl -w
use encoding 'utf-8';

my $i = 1 ;

while (<>){

if ( /^(MAP|ADD|SELECT|REMOVE|SUBSTITUTE|IFF) (.*)/ ) {
	$_ =~ s/^(MAP|ADD|SELECT|REMOVE|SUBSTITUTE|IFF) (.*)/$1:r$i $2/;
	$i++;
	}
print;
}


# File to add index to dis rules.
# At present, it
# does not name already named rules