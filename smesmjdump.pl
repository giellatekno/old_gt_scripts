#!/usr/bin/perl -w
#
# smesmjdump.pl
# Convert names in the sme propernoun lexicon to smj.
# $Id$

use strict;
use utf8;

while(<>) {
	last if (/The dump/);
}

while(<>) {

	s/ C-FI-NEN/nen LONDON/g ;
	s/SUND/BERN/g ;
	s/HEIM/BERN/g ;
	s/NIKOSIIJA/ACCRA/g ;
	s/SIJTE/ACCRA/g ;
	s/j9/j/g ;
	s/7 / /g ;
	s/8 / /g ;
	s/9 / /g ;
	s/ss /ss9 /g ;
	s/st /st9 /g ;
	s/BALAK/ANAR/g ;
	s/HAWAII/ACCRA/g ;
	s/SIEINNUS/DUORTNUS/g ;
	s/SKANIK/SULLOT/g ;
	s/t:(.*)h /t:$1d9 /g ;
	s/šž/sjtj/g ;
	s/Šž/Sjtj/g ;
	s/šš/ssj/g ;
	s/žž/dtj/g ;
	s/Š/Sj/g ;
	s/š/sj/g ;
	s/ž/dj/g ;
	my $line = $_;
	
	if ($line =~ /æ/) {
			# Replace space in multipart names temporarily with $.
		$line =~ s/% /\$/g;
		
		my ($word, $rest) = split (/\s+/, $line, 2);
		$word =~ s/\$/% /g;
		if ($line !~ /\:/) {
			( my $int_word = $word )     =~ s/æ/æ9/g;
			$int_word =~ s/ä/ä9/g;
			$line = $word . ":" . $int_word . " " . $rest;
		}
		else {
			my ($upper, $lower) = split(/\:/, $word);
			( my $int_word = $lower )     =~ s/æ/æ9/g;
			$int_word =~ s/ä/ä9/g;
			$line = $upper . ":" . $int_word . " " . $rest;
		}
	}
	print $line;
}

