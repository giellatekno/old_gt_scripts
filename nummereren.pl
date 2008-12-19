#!/usr/bin/perl -w
use encoding 'utf-8';

my $i = 1 ;

while (<>){


if ( /(davvi_s) (.*)/ ) {
	$_ =~ s/(davvi_s) (.*)/$1$i$2/;
	$i++;
	}
print;
}


# File to add index to "davvi_s" (or something else) for e.g. sentence-alignment.
