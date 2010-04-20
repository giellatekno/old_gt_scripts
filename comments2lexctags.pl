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
my $inacro = 0;
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
	
	if (/LEXICON/ && $inacro) { $inacro = 0; }


	if ((/LEXICON FIRSTLETTER/ || /LEXICON ARABIC\s/ || /LEXICON SCND/ || /LEXICON THRD/ || /LEXICON FRTH/) || $inacro) {
		$inacro = 1;
		print; next;
	}
	
	if (/LEXICON/ && ! $inroot) {
		print; next;
	}
	


	if ((! /\!.*/) && ($root_tags eq "")) { print; next; }
	chomp;
	
	my ($entry, $comments) = split (/\;/, $_);
	my $tags = &process_comments($comments);
#	my $new_tags = join ("",@tagset);

    $entry =~ s/^\s+//;
#    $entry = " " . $entry;
    if ($entry !~ /:/ && $tags =~ /\S+/) {
    	if ($entry =~ /^\S+\s+$/) {
    		$entry = ": " . $entry;
    	}
    	else {
#    		print $entry; print "TOMI";
    		my ($lemma, $cont) = split (/(?<!%)\s+/, $entry);
#    		if ($lemma =~ /@/) {
#    			my $stem = $lemma;
#    			$stem =~ s/@.+@//;
#    			$entry = $stem . ":" . $lemma . " " . $cont;
#    		}
    		$entry = $lemma . ":" . $lemma . " " . $cont;
#    		print $entry;
    	}
    }

    if ($entry =~ /:/ && $tags =~ /\S+/) {
    	my ($lemma, $cont) = split (/:/, $entry, 2);
    	$entry = $lemma . $root_tags . $tags . ":" . $cont;
    }
    
#    my $begin = "";
#    my $end = "";
#    ($begin, $end) = split (/:/, $entry);
#    if ($end =~ //) {$end = " ";}
#    $entry = $begin . $root_tags . $tags . ":" . $end;
    
    $comments = &clean_comments($comments);

	my $new_line = " " . $entry . ";" . $comments . "\n";
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
	if ($comments =~ /MARG/) {
		push @tags_use, "+Use/Marg";
	}
	if ($comments =~ /\^C\^/) {
		push @tags_use, "+Use/Circ";
	}
	if ($comments =~ /\^N\^/) {
		push @tags_use, "+Use/CircN";
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

sub clean_comments {
	my $comments = "@_";
	
	if ($comments =~ /SUB/) {
		$comments =~ s/SUB//;
	}
	if ($comments =~ /MARG/) {
		$comments =~ s/MARG//;
	}
	if ($comments =~ /\^C\^/) {
		$comments =~ s/\^C\^//;
	}
	if ($comments =~ /\^N\^/) {
		$comments =~ s/\^N\^//;
	}
	if ($comments =~ /\^P\^/) {
		$comments =~ s/\^P\^//;
	}
	if ($comments =~ /\^NG\^/) {
		$comments =~ s/\^NG\^//;
	}
	if ($comments =~ /NOT-KJ/) {
		$comments =~ s/NOT-KJ//;
	}
	if ($comments =~ /NOT-GG/) {
		$comments =~ s/NOT-GG//;
	}
	if ($comments =~ /NOT-GS/) {
		$comments =~ s/NOT-GS//;
	}
	
	return $comments;
}


