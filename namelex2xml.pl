#!/usr/bin/perl -w

#use encoding 'utf8';
#use open ':utf8';

# use Perl module XML::Twig for XML-handling
# http://www.xmltwig.com/
use XML::Twig;

#If a common language file is created, change this to 1.
my $common = 0;
# If all the fields are printed (even though empty) change this to 1.
my $all = 0;
my $language = "sme";

my $twig = XML::Twig->new( output_encoding => "utf8");
$twig->set_pretty_print('record');

# Usage: 
# perl namelex2xml.pl
#
# Specify the $infile and $outfile to the files you want:

my $infile = "../sme/src/propernoun-sme-lex.txt";
my $outfile = "terms-sme.xml";
my $outfile_common = "termcenter.xml";

open (FH, "<utf8", "$infile") or die "Cannot open file $infile: $!";

my $FH1;
if ($common) { open($FH1,  ">$outfile_common"); }
else { open($FH1, ">$outfile"); }

# The root element. Name??
my $dict = XML::Twig::Elt->new('dict');

# The xml specifications, name of dtd-file and root node.
print $FH1 qq|<?xml version='1.1'  encoding="UTF-8"?>|;
print $FH1 qq|<!DOCTYPE dict PUBLIC "-//DIVVUN//DTD Proper Noun Dictionary V1.0//EN"|;
print $FH1 qq|"http://www.divvun.no/dtd/prop-noun-dict-v10.dtd">|;
print $FH1 qq|\n<dict>|;

my $line;
# Ignore the morphology part in this test version.
while( $line = <FH> ) {
	last if ($line =~ /^LEXICON ProperNoun$/ );
	}

while ($line = <FH>) {

	#discard comments, empty lines and for now, LEXICONs
	next if ($line =~ /^\!/);
	next if ($line =~ /^\s*$/);
	next if ($line =~ /^LEXICON/);

	chomp $line;
	# Replace space in multipart names temporarily with $.
	$line =~ s/% /\$/g;
	
	my ($word, $contlex_text) = split (/ /, $line, 2);
	$word =~ s/\$/ /g;

	# Check the regular expression!!
	if ($word && $contlex_text) {

		my ($lemma_text, $stem_text) = split (/:/, $word, 2);

		# Take comment out, split e.g. ACCRA-fem
		my ($contlex, $comment) = split(/\!/, $contlex_text);
		$contlex =~ s/\s?\;\s?$//;
		$contlex =~ s/^\s+//;

		my ($infl_text, $sem_text) = split(/-/, $contlex);
		
		if ($sem_text) { $sem_text =~ s/\s+$//; }

		my @sem_texts;
		my $lemma_2;
		my $entry2;
		if($sem_text && length($sem_text) > 3) {
		    push (@sem_texts, substr($sem_text, 0, 3));
		    push (@sem_texts, substr($sem_text, 3, 3));
		    $lemma_2 = $lemma_text . "_2";
		}
		else { push (@sem_texts, $sem_text); }

		# Create a new entry and paste it to the XML-tree.
		my $entry = XML::Twig::Elt->new('entry');
		$entry->set_att('id', $lemma_text);

		# The language-specific part contains stem, inflection class
		# and other fields as well as reference to the entries in the
		# common file.
		if (! $common) {
		    if ($stem_text && ($stem_text ne $lemma_text)) {
				my $stem = XML::Twig::Elt->new('stem');
				$stem->set_text($stem_text);
				$stem->paste('last_child', $entry);
		    }

		    my $infl = XML::Twig::Elt->new('infl');
		    $infl->set_att('lexc', $infl_text);		
		    $infl->paste('last_child', $entry);
		    
		    if ($all) {
				my $name_parts = XML::Twig::Elt->new('name-parts');
				$name_parts->paste('last_child', $entry);
				
				my $variants = XML::Twig::Elt->new('variants');
				my $variant = XML::Twig::Elt->new('variant');
				$variant->set_att('ref', "");		
				$variant->paste('last_child', $variants);
				$variants->paste('last_child', $entry);			
				
				my $etym = XML::Twig::Elt->new('etym');
				$etym->paste('last_child', $entry);			
				
				my $rel_name = XML::Twig::Elt->new('rel-name');
				$rel_name->set_att('ref', "");		
				$rel_name->paste('last_child', $entry);
		    }
			
		    my $senses = XML::Twig::Elt->new('senses');
		    my $sense = XML::Twig::Elt->new('sense');
		    $sense->set_att('ref', $lemma_text);	
		    $sense->paste('last_child', $senses);
		    if ($#sem_texts > 0) {
				my $sense2 = XML::Twig::Elt->new('sense');
				$sense2->set_att('ref', $lemma_2);	
				$sense2->paste('last_child', $senses);
		    }
		    $senses->paste('last_child', $entry);
		}
		# The common part contains the semantic description.
		if($common) {
		    if ($#sem_texts > 0) {
				# Create a new entry and paste it to the XML-tree.
				$entry2 = XML::Twig::Elt->new('entry');
				$entry2->set_att('id', $lemma_2);
				
				my $sem2 = XML::Twig::Elt->new('sem');
				my $sem_type2 = XML::Twig::Elt->new($sem_texts[1]);
				$sem_type2->paste('last_child', $sem2);
				$sem2->paste('last_child', $entry2);
		    }
		    my $sem;
		    if ($sem_text) {
				$sem = XML::Twig::Elt->new('sem');
				my $sem_type = XML::Twig::Elt->new($sem_texts[0]);
				$sem_type->paste('last_child', $sem);
				$sem->paste('last_child', $entry);
		    }
		    
		    if ($all && $sem_text =~ /^plc$/) {
				my $plc = XML::Twig::Elt->new('plc');
				my $geo = XML::Twig::Elt->new('geo');
				
				$geo->paste('last_child', $plc);
				$plc->paste('last_child', $sem);
		    }
		    
		    my $langentry = XML::Twig::Elt->new('langentry');
		    $langentry->set_att('lang', $language);
		    $langentry->set_att('ref', $lemma_text);
		    $langentry->paste('last_child', $entry);
			
		    if ($#sem_texts > 0) {
				my $langentry2 = XML::Twig::Elt->new('langentry');
				$langentry2->set_att('lang', $language);
				$langentry2->set_att('ref', $lemma_2);
				$langentry2->paste('last_child', $entry2);
		    }
		}
		$entry->print($FH1);
		$entry->DESTROY;
		if ($common && $#sem_texts > 0) {
		    $entry2->print($FH1);
		    $entry2->DESTROY;
		}
    }
	
	else { print STDERR "Line not included: $line"; }
}

print $FH1 qq|\n</dict>|;
close $FH1;
