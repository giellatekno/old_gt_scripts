#!/usr/bin/perl -w

use strict;
use utf8;

# multiword-split.pl
# Perl script for parsing lexicon files for multiword entries.
# Usage: PRINT lexicon_file | multiword-split.pl > output_file

# Transform multiword entries:
# Finn^comm% Airlines LONDON-org ;
#
# Finn^comm+N+Multi # ;
# Airlines LONDON-org ;
#
# $Id$

while (<STDIN>) {

	if (! /\%\ /) { print ; next; }
	if (/^\!/) { print; next; }
	if (/\+Pron/) { print; next; }
	chomp;
	
	my @strings = split (/\%\ /, $_);
	my $end = 0;
	
	for my $i (@strings) {
		if ($i =~ /:/) { (my $entry = $i) =~ s/:.*//g; print "$entry:"; $end=1; }
		elsif ($i !~ /\;/ && !$end) { print "$i\+N\+Multi:$i # ;\n"; }
		elsif ($i =~ /\;/) { print "$i\n"; }
	}
}