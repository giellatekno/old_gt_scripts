#!/usr/bin/perl
use strict;

use utf8;

# sort_cohort.pl
# Perl script for sorting the analyses in a cohort. The main purpose is to
# guarantee a consistent ordering across invocations, versions and tools,
# so that it is possible to make meaningful diffs of the output of
# morphological analysis.
#
# Input: 
#   jahkedieđáhusáššiid     jahki+N#dieđáhus+N#ášši+N+Pl+Gen
#   jahkedieđáhusáššiid     jahki+N#dieđáhus+N#ášši+N+Pl+Acc
#   jahkedieđáhusáššiid     jahke#dieđáhus+N#ášši+N+Pl+Gen
#   jahkedieđáhusáššiid     jahke#dieđáhus+N#ášši+N+Pl+Acc
#
# Output:
#   jahkedieđáhusáššiid     jahke#dieđáhus+N#ášši+N+Pl+Acc
#   jahkedieđáhusáššiid     jahke#dieđáhus+N#ášši+N+Pl+Gen
#   jahkedieđáhusáššiid     jahki+N#dieđáhus+N#ášši+N+Pl+Acc
#   jahkedieđáhusáššiid     jahki+N#dieđáhus+N#ášši+N+Pl+Gen
#

$/ = "";

# Read while not eol
while(<>) {
	my @lines = split(/\n/, $_);
	my @newlines = sort @lines;
	my $cohort = join("\n", @newlines);
	print "$cohort\n\n";
}
