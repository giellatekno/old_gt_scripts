#!/usr/bin/perl
use strict;
use Getopt::Long;

use utf8;

# reformat-space-text.pl
# Perl-script for converting space-text output from xfst to a PLX text file
# with analyses as comments. This is used in debugging the PLX conversion.
#
# Input, first lines:
# # -*- coding: utf-8 -*-
# u v 0 t e d h +V +PrfPrc 0 0 0 0 @D.NeedNoun.ON@ 	 V I
# å v ^ t 0 0 0 0     0    e ^ m e @D.NeedNoun.ON@ 	 V I
# 
# u v 0 t e d h +V +PrfPrc 0 0 0 0 @D.NeedNoun.ON@ 	 N A I B E
# å v ^ t 0 0 0 0     0    e ^ m e @D.NeedNoun.ON@ 	 N A I B E
# 
#
# Corresponding expected output:
# åv-te-me	VI	// uvtedh+V+PrfPrc
# åv-te-me	NAIBE	// uvtedh+V+PrfPrc

# Use empty lines as separator:
$/ = "";

# Read while not eol
while(<>) {
	next if /coding: utf-8/ ; # skip the first line
	my $analysis;
	my $wordform;
	my $anal;
	my $plx;

	($analysis, $wordform) = split(/\n/, $_, 2);
	chomp $wordform;
	chomp $analysis;
	$analysis = cleanSpaceText($analysis);
	$wordform = cleanSpaceText($wordform);
	($anal,$plx) = split(/\t/,$analysis);
	print "$wordform\t// $anal\n";
}

sub cleanSpaceText {
	my $string = shift(@_);

	$string =~ s/\/0 /"0"/g;          # Rescue literal zeroes
	$string =~ s/" "/"XXX"/g;         # Rescue literal spaces
	$string =~ s/0 //g;               # Remove epsilons
	$string =~ s/@[.A-Za-z]+@ //g;    # Remove flag diacritics
	$string =~ s/ //g;                # Remove all remaining spaces
	$string =~ s/%#/#/g;              # Un-escape word boundaries
	$string =~ s/"XXX"/ /g;           # Restore literal spaces
	$string =~ s/\%/ /g;           # Restore literal spaces
	$string =~ s/"0"/0/g;             # Restore literal zeroes
	return $string;
}
