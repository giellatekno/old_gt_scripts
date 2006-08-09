#!/usr/bin/perl -w

#use encoding 'utf8';
#use open ':utf8';

# use Perl module XML::Twig for XML-handling
# http://www.xmltwig.com/
use XML::Twig;

my $language = "sme";

my $twig = XML::Twig->new( output_encoding => "utf8");
$twig->set_pretty_print('record');

# Usage: 
# perl namelex2xml.pl
#
# Specify the $infile and $outfile to the files you want:

my $infile = "../sme/src/propernoun-sme-lex.txt";
#my $infile = "prop-test.txt";
my $outfile = "terms-sme.xml";
my $outfile_common = "termcenter.xml";

open (FH, "<utf8", "$infile") or die "Cannot open file $infile: $!";

my $FH1;
my $FH2;
open($FH1,  ">$outfile_common");
open($FH2, ">$outfile");

# The root element. Name??
my $dict = XML::Twig::Elt->new('dict');
 
# The xml specifications, name of dtd-file and root node.
print $FH1 qq|<?xml version='1.0'  encoding="UTF-8"?>|;
print $FH2 qq|<?xml version='1.0'  encoding="UTF-8"?>|;
# Commented out the DOCTYPE for the time being - it requires extra setup in eXist,
# and we really don't use it. Besides, the center-doc and the lang-docs require
# different DTDs, and thus different DOCTYPEs. SNM 010806.
#print $FH1 qq|<!DOCTYPE dict PUBLIC "-//DIVVUN//DTD Proper Noun Dictionary V1.0//EN"|;
#print $FH1 qq|"http://www.divvun.no/dtd/prop-noun-dict-v10.dtd">|;
print $FH1 qq|\n<dict>|;
print $FH2 qq|\n<dict>|;

my $line;
# Ignore the morphology part in this test version.
while( $line = <FH> ) {

	last if ($line =~ /^LEXICON ProperNoun$/ );
	}

my $prev_word=undef;
my $prev_entry="";
my %termc_entries;
my %term_entries;
my @contlex_texts;

my $last=0;

FILE:
while ($line = <FH> ) {

	#discard comments, empty lines and for now, LEXICONs
	next if ($line =~ /^\!/);
	next if ($line =~ /^\s*$/);
	next if ($line =~ /^LEXICON/);

	chomp $line;
	# Replace space in multipart names temporarily with $.
	$line =~ s/% /\$/g;
	
	my ($word, $contlex_text) = split (/\s+/, $line);
	$word =~ s/\$/ /g;

	# something wrong
	if ( !$word || ! $contlex_text) {
		print STDERR "Line not included: $line\n";
		next;
	}

	# first line
	if (! $prev_word ) {
		$prev_word = $word;
		push (@contlex_texts, $contlex_text);
		next;
	}

	# consequtive identical entries are collected
	while ( $prev_word eq $word && ! eof ) {
		print "$prev_word $word\n";
		push (@contlex_texts, $contlex_text);
		next FILE;
	}

	my ($lemma_text, $stem_text) = split (/:/, $prev_word, 2);

	# Find out all the semantic categories associated with this word.
	my @contlexes;
	for my $cont ( @contlex_texts ) {
		
		# Take comment out, split e.g. ACCRA-fem
		my ($contlex, $comment) = split(/\!/, $cont);
		$contlex =~ s/\s?\;\s?$//;
		$contlex =~ s/^\s+//;
		
		push (@contlexes, $contlex);
		my ($infl_text, $sem_text) = split(/-/, $contlex);
		
		if ($sem_text) { $sem_text =~ s/\s+$//; }
		else { $sem_text = "empty"; }

		if($sem_text ne "empty" && (length($sem_text) > 3)) {
		    $sem_texts{substr($sem_text, 0, 3)} = 1;
		    $sem_texts{substr($sem_text, 3, 3)} = 1;
		}
		else { $sem_texts{$sem_text} = 1; }

	}
	# Create one termc entry for each semantic category.
	my $i=0;
	if (%sem_texts) {
		for my $key (keys %sem_texts) {

			# Create a new entry for each semantic category
			my $entry = XML::Twig::Elt->new('entry');
			if ($i > 0) { $lemma_2 = $lemma_text . "_" . $i; }
			else { $lemma_2 = $lemma_text }
			$entry->set_att('id', $lemma_2);

			my $sem = XML::Twig::Elt->new('sem');
			if ($key ne "empty") {
				my $sem_type = XML::Twig::Elt->new($key);
				$sem_type->paste('last_child', $sem);
			}
			$sem->paste('last_child', $entry);

			$termc_entries{$key} = $entry;
			$i++;
		}
	}
	# if there is no semantic category specified, create one termc entry.
	else {
		my $entry = XML::Twig::Elt->new('entry');
		$entry->set_att('id', $lemma_text);
		
		$termc_entries{'empty'} = $entry;
	}

	for my $cont (@contlexes) {

		my ($infl_text, $sem_text) = split(/-/, $cont);
		
		if ($sem_text) { $sem_text =~ s/\s+$//; }
		else { $sem_text = "empty" }

		undef %sem_texts;		
		if($sem_text ne "empty"  && length($sem_text) > 3) {
		    $sem_texts{substr($sem_text, 0, 3)} = 1;
		    $sem_texts{substr($sem_text, 3, 3)} = 1;
		}
		else { $sem_texts{$sem_text} = 1; }

		# Find the termc entry that corresponds the semantic class in question
		# take the id.
		for my $key (keys %sem_texts) {

			my $termc_entry = $termc_entries{$key};
			my $id = $termc_entry->{'att'}->{'id'};
			
			# If there is terms-entry with the same id, just add
			# new inflection class.
			if( $term_entries{$id} ) {
				my $infl = XML::Twig::Elt->new('infl');
				$infl->set_att('lexc', $infl_text);		
				$infl->paste('last_child', $term_entries{$id});
			}

			# Otherwise create new terms-entry.
			else {
				my $entry = XML::Twig::Elt->new('entry');
				$entry->set_att('id', $id);
				if ($stem_text && ($stem_text ne $lemma_text)) {
					my $stem = XML::Twig::Elt->new('stem');
					$stem->set_text($stem_text);
					$stem->paste('last_child', $entry);
				}
				# Add reference to the termc
				my $senses = XML::Twig::Elt->new('senses');
				my $sense = XML::Twig::Elt->new('sense');
				$sense->set_att('ref', $id);
				$sense->paste('last_child', $senses);
				$senses->paste('last_child', $entry);

				my $infl = XML::Twig::Elt->new('infl');
				$infl->set_att('lexc', $infl_text);		
				$infl->paste('last_child', $entry);

				# Alter termc entry by adding reference to terms
				my $langentry = XML::Twig::Elt->new('langentry');
				$langentry->set_att('lang', $language);
				$langentry->set_att('ref', $id);
				$langentry->paste('last_child', $termc_entry);
				
				$term_entries{$id} = $entry;
			}
		}
	}
	
	for my $ent ( keys %termc_entries )	{
		$termc_entries{$ent}->print($FH1);
		$termc_entries{$ent}->DESTROY;
	}

	for my $ent ( sort { $a cmp $b } keys %term_entries ) {
		$term_entries{$ent}->print($FH2);
		$term_entries{$ent}->DESTROY;
	}

	undef %sem_texts;
	undef %term_entries;
	undef %termc_entries;

	$prev_word = $word;

	@contlex_texts=undef;
	pop @contlex_texts;
	push (@contlex_texts, $contlex_text);	
}

print $FH1 qq|\n</dict>|;
close $FH1;

print $FH2 qq|\n</dict>|;
close $FH2;
