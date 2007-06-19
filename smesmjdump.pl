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
	s/7 / /g ;
	s/8 / /g ;
	s/9 / /g ;
	s/BALAK/ANAR/g ;
	s/HAWAII/ACCRA/g ;
	s/SIEINNUS/DUORTNUS/g ;
	s/SKANIK/SULLOT/g ;
	
	my $line = $_;
	
	if ($line =~ /æ/) {
			# Replace space in multipart names temporarily with $.
		$line =~ s/% /\$/g;
		
		my ($word, $rest) = split (/\s+/, $line, 2);
		$word =~ s/\$/% /g;
		if ($line !~ /\:/) {
			( my $new_word = $word ) =~ s/æ/æ9/g;
			$line = $word . ":" . $new_word . " " . $rest;
		}
		else {
			my ($upper, $lower) = split(/\:/, $word);
			( my $new_lower = $lower ) =~ s/æ/æ9/g;				
			$line = $upper . ":" . $new_lower . " " . $rest;
		}
	}
	print $line;
}
