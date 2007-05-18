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

	if (! /\!\s*\+/) { print; next; }
	if (/^\!/) { print; next; }
	chomp;
	my $line = $_;

	my ($entry, $tags) = split (/\;/, $line);
	(my $new_tags = $tags) =~ s/[\!\s]//g;
	my $new_line = $new_tags . $entry . ";" . $tags . "\n";
	print $new_line;
}
	
	



