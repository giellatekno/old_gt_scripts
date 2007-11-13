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

my $file_name = $ARGV[$#ARGV];
my $inroot = 0;
if ($file_name =~ /\/sm[ej]-lex./) { $inroot = 1; }

my $root_comments = "";

if ( $inroot ) {
    # Skip the definitions in the beginning of the file
    # Start processing the first lexicon
    while(<>) {
        print;
        last if (/LEXICON/);
    }
}

while (<>) {

	#Pitäisi hypätä tyhjien rivien yli
    if (/^\s*$/) { print; next; }

	#Pitäisi hypätä rivien yli, jotka alkaa '!' -merkillä
    if (/^\!/) { print; next; }

	if (/LEXICON/ && $inroot) {
		if (! /\!.*\+/) { $root_comments = ""; print; next; }
		else {
			my ($entry, $comments) = split (/\!/, $_);
			(my $new_comments = $comments) =~ s/\+/\+/g;
			my @strings = split(/\s+/,$new_comments);
			#print "jee @strings";
			my @tagset;
			for my $t (@strings) {
				if ($t =~ /^\+/) { push @tagset, $t; }
			}
			$root_comments = join ("",@tagset);
			print;
			next;
		}
	}

	if ((! /\!.*\+/) && ($root_comments eq "")) { print; next; }
#	if (/^\!/) { print; next; }
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
    $entry =~ s/^\s*//;
	my $new_line = $root_comments . $new_tags . $entry . ";" . $comments . "\n";
	print $new_line;
}





