#!/usr/bin/perl
use strict;

use utf8;

# sort-cohort.pl
# Perl script for sorting the analyses in a CG stream cohort. The main
# purpose is to guarantee a consistent ordering of the analyses across
# invocations, versions and tools, so that it is possible to make meaningful
# diffs of the output of morphological analysis.
#
# This script differs from sort-cohort.pl in the type of input it takes:
# instead of Xerox lookup-type input, where the cohorts are separated
# by empty lines, and all analyses are preceeded with the lemma, and the
# lemma only, it takes a stream of cohorts separated by non-blank first
# characters.
#
# Input: 
# "<Iđđes>"
# 	 "iđđes" Adv
# "<dii.>"
# 	 "dii" N ABBR Nom
# 	 "dii" N ABBR Acc
# 	 "dii" N ABBR Attr
# 	 "dii" N ABBR Gen
#
# Output:
# "<Iđđes>"
# 	 "iđđes" Adv
# "<dii.>"
# 	 "dii" N ABBR Acc
# 	 "dii" N ABBR Attr
# 	 "dii" N ABBR Gen
# 	 "dii" N ABBR Nom

# Set the record separator to newline + "
$/ = "\n\"";

# Boolean variable to identify the first cohort:
my $nonfirst = 0;

# Read while not eol
while(<>) {
	chomp ;
	my $cohort = "";
	# Only add an initial " to the non-first cohort - since the first
	# one has the initial " that is otherwise part of the separator, and
	# gets removed; without this conditiona, the first cohort will get
	# an initial double " - not nice:
	if ($nonfirst)
		{ $cohort = "\"" . $_ ; }
	else
		{ $cohort = $_ ; }
	my ($lemma, $lines) = split(/\n/, $cohort, 2);
	my @lines = split(/\n/, $lines);
	my @newlines = sort @lines;
	my $sortlines = join("\n", @newlines);
	print "$lemma\n$sortlines\n";
	$nonfirst = 1;
}
