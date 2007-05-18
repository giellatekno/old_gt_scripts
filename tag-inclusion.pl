#!/usr/bin/perl -w

use strict;
use utf8;

# tag-inclusion.pl
# Perl script for parsing lexicon files for compound tags.
# Usage: tag-inclusion.pl lexicon_file > output_file
#
# Transform tags in comments to the entry:
# abskis0sa:abskis'sa GOAHTI "absciss N" ; !+SgNomCmp +SgGenCmp +PlGenCmp
# +SgNomCmp+SgGenCmp+PlGenCmpabskis0sa:abskis'sa GOAHTI "absciss N" ; !+SgNomCmp +SgGenCmp +PlGenCmp
#
# $Id$

while(<>) {

	if (! /\!.*\+/) { print; next; }
	if (/^\!/) { print; next; }
	chomp;

	my ($entry, $comments) = split (/\;/, $_);
	(my $new_comments = $comments) =~ s/\!//g;
	my @strings = split(/\s+/,$new_comments);
	#print "jee @strings";
	my @tagset;
	for my $t (@strings) {
		if ($t =~ /^\+/) { push @tagset, $t; }
	}
	my $new_tags = join ("",@tagset);
	my $new_line = $new_tags . $entry . ";" . $comments . "\n";
	print $new_line;
}
	
	



