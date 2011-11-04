#!/usr/bin/perl
use strict;
use Getopt::Long;

use utf8;

# nom-noun-bigrams
# Perl-script for extracting pairs of nominative noun candidates.
# Outputs such pairs. No disambiguation is assumed, only the presence
# of a nominative tag in one of the analyses of the first word, and a
# noun (and adjective?) tag in one of the analyses of the second word.
#
# Input: 
# Dan     dat+Pron+Dem+Sg+Acc
# Dan     dat+Pron+Dem+Sg+Gen
#
# Output:
# "<Dan>"
#        "dat" Pron Dem Sg Acc
#        "dat" Pron Dem Sg Gen

$/ = "";

# Read while not eol
while(<>) {	
	my $word;
	my $word1;
	my $word2;
	my @Analyses;

	($word, @analysis) = split(/\t/, $_, 2);
	if ( /\+Nom/ ) {
		$word1 = $word
	}
}
