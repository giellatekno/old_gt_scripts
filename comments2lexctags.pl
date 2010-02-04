#!/usr/bin/perl -w

use strict;
use utf8;


# comments2lexctags.pl
# Perl script for parsing lexicon files for tags.
# Usage: comments2lexctags.pl lexicon_file > output_file
#
# Transform tags in comments to the entry:
# abskis0sa:abskis'sa GOAHTI "absciss N" ; !+SgNomCmp +SgGenCmp +PlGenCmp
# +SgNomCmp+SgGenCmp+PlGenCmpabskis0sa:abskis'sa GOAHTI "absciss N" ; !+SgNomCmp +SgGenCmp +PlGenCmp
#
# $Id$

my $file_name = $ARGV[$#ARGV];
my $inroot = 0;
if ($file_name =~ /\/sm[aej]-lex./) { $inroot = 1; }

my $root_tags = "";

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
	# but allow whitespace chars in front of the !
    if (/^\s*\!/) { print; next; }

	if (/LEXICON/ && $inroot) {
		if (! /\!.*\+/) { $root_tags = ""; print; next; }
		else {
			my ($entry, $comments) = split (/\!/, $_);
			my $tags = &process_comments($comments);
			$root_tags = $tags;
			print;
			next;
		}
	}
	
	if (/LEXICON/ && ! $inroot) {
		print; next;
	}


	if ((! /\!.*/) && ($root_tags eq "")) { print; next; }
	chomp;
	
	my ($entry, $comments) = split (/\;/, $_);
	my $tags = &process_comments($comments);
#	my $new_tags = join ("",@tagset);

    $entry =~ s/^\s*//;
    if ($entry =~ /^\S+\s$/) {$entry = " " . $entry;}
    if ($entry !~ /:/ && $tags =~ /\S+/) {
    	my ($lemma, $cont) = split (/(?<!%)\s+/, $entry);
    	$entry = $lemma . ":" . $lemma . " " . $cont;
    }

	my $new_line = $root_tags . $tags . $entry . ";" . $comments . "\n";
	print $new_line;
}


sub process_comments {
	my $comments = "@_";
	
	my $tags;
	my @tags_use;
	my @tags_dialect;
	

	if ($comments =~ /SUB/) {
		push @tags_use, "+Use/Sub";
	}
	if ($comments =~ /\^C\^/) {
		push @tags_use, "+Use/Circ";
	}
	if ($comments =~ /\^P\^/) {
		push @tags_use, "+Use/Ped";
	}
	if ($comments =~ /\^NG\^/) {
		push @tags_use, "+Use/NG";
	}
	if ($comments =~ /NOT-KJ/) {
		push @tags_dialect, "+Dial/%-KJ";
	}
	if ($comments =~ /NOT-GG/) {
		push @tags_dialect, "+Dial/%-GG";
	}
	if ($comments =~ /NOT-GS/) {
		push @tags_dialect, "+Dial/%-GS";
	}
	
	(my $new_comments = $comments) =~ s/\!//g;
	my @strings = split(/\s+/,$new_comments);
	my @tagset;
	for my $t (@strings) {
		if ($t =~ /^\+/) { push @tagset, $t; }
	}
	my $compound_tags = join ("",@tagset);
	
	my $use_tags = join ("",@tags_use);
	my $dialect_tags = join ("", @tags_dialect);
	
	$tags = $compound_tags . $use_tags . $dialect_tags;
	
#	print "jee @tags_use $comments \n";
	
	return $tags;
}


