#!/usr/bin/perl -w
use strict;

use encoding 'utf-8';
use open ':utf8';

# use Perl module XML::Twig for XML-handling
# http://www.xmltwig.com/
use XML::Twig;

my $twig = new XML::Twig;
$twig->set_pretty_print('record');

my $file = "../sme/src/propernoun-sme-lex.txt";
#my $file = "testi.txt";

open (FH, "$file") or die "Cannot open file $file: $!";

my $FH1;
open($FH1, ">koe.txt");

# The xml specifications, name of dtd-file and root node.
print $FH1 qq|<?xml version='1.1'  encoding="UTF-8"?>|;
print $FH1 qq|<!DOCTYPE dict PUBLIC "-//DIVVUN//DTD Proper Noun Dictionary V1.0//EN"|;
print $FH1 qq|"http://www.divvun.no/dtd/prop-noun-dict-v10.dtd">|;
print $FH1 qq|\n<dict>|;

my $line;
# Ignore the morphology part in this test version.
while( $line = <FH> ) {
	last if ($line =~ /ProperNounFirstPart/ );
	}

while ($line = <FH>) {

	#discard comments, empty lines and for now, LEXICONs
	next if ($line =~ /^\!/);
	next if ($line =~ /^\s*$/);
	next if ($line =~ /^LEXICON/);

	# Check the regular expression!!
	if ($line =~ /^(.*?)\s+(.*?)\s?\;/) {

		my $word = $1;
		my $contlex_text = $2;

		my ($lemma_text, $stem_text) = split (/:/, $word, 2);

		# Split e.g. ACCRA-fem
		my ($cnt_text, $sem_text) = split(/-/, $contlex_text, 2);

		# Create a new entry and paste it to the XML-tree.
		my $entry = XML::Twig::Elt->new('e');
		$entry->set_att('id', $lemma_text);
#		$entry->paste('last_child', $dict);

		my $form = XML::Twig::Elt->new('f');
		$form->set_att('lg', "sme");
		$form->paste('last_child', $entry);

		my $lemma = XML::Twig::Elt->new('lm');
		$lemma->set_text($lemma_text);
		$lemma->paste('last_child', $form);

		my $stem = XML::Twig::Elt->new('st');
		if ($stem_text) {
			$stem->set_text($stem_text);			
		}
		$stem->paste('last_child', $form);

		my $cnt = XML::Twig::Elt->new('cnt');
		$cnt->set_text($cnt_text);		
		$cnt->paste('last_child', $form);

		my $sem = XML::Twig::Elt->new('sem');
		if ($sem_text) {
			$sem->set_text($sem_text);		
		}
		$sem->paste('last_child', $entry);

		$entry->print($FH1);
		$entry->DESTROY;

	}

	else { print STDERR "Line not included: $line"; }
}

close (FH);

print $FH1 qq|</dict>\n|;
close ($FH1);

$twig->purge;

#close ($FH);

