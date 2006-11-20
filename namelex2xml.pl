#!/usr/bin/perl -w

use strict;

#use encoding 'utf8';
#use open ':utf8';

binmode STDOUT;

# use Perl module XML::Twig for XML-handling
# http://www.xmltwig.com/
use XML::Twig;

my $mainlang = "sme";
my @other_langs = ("smj", "sma");

my $twig = XML::Twig->new( output_encoding => "utf8");
$twig->set_pretty_print('record');

# Usage: 
# perl namelex2xml.pl
#
# Specify the $infile and $outfile to the files you want:

my $infile = "../".$mainlang."/src/propernoun-".$mainlang."-lex.txt";
#my $infile = "../smj/src/propernoun-smj-lex.txt";
#my $infile = "prop-test.txt";
my $outfile = "terms-" . $mainlang . ".xml";
my $outfile_common = "termcenter.xml";

open (FH, "<utf8", "$infile") or die "Cannot open file $infile: $!";

my $FH1;
my $FH2;
open($FH1, ">$outfile_common");
open($FH2, ">$outfile");

 # Set the conversion time for the XML output;
# This will be stored as part of the XML files.
my $convtime = &timestring;

# The xml specifications, name of dtd-file and root node.
print $FH1 qq|<?xml version='1.0'  encoding="UTF-8"?>|;
print $FH2 qq|<?xml version='1.0'  encoding="UTF-8"?>|;
# Commented out the DOCTYPE for the time being - it requires extra setup in eXist,
# and we really don't use it. Besides, the center-doc and the lang-docs require
# different DTDs, and thus different DOCTYPEs. SNM 010806.
#print $FH1 qq|<!DOCTYPE dict PUBLIC "-//DIVVUN//DTD Proper Noun Dictionary V1.0//EN"|;
#print $FH1 qq|"http://www.divvun.no/dtd/prop-noun-dict-v10.dtd">|;
print $FH1 qq|\n<dict xmlns:xi="http://www.w3.org/2001/XInclude" last-update="$convtime">|;
print $FH2 qq|\n<dict xmlns:xi="http://www.w3.org/2001/XInclude" last-update="$convtime">|;

my %outfiles;
for my $lang (@other_langs) {
	my $out = "terms-" . $lang . ".xml";
	my $fh_out;
	open($fh_out, ">$out");
	print $fh_out qq|<?xml version='1.0'  encoding="UTF-8"?>|;
	print $fh_out qq|\n<dict xmlns:xi="http://www.w3.org/2001/XInclude" last-update="$convtime">|;
	$outfiles{$lang} = $fh_out;
}

my @all_langs = @other_langs;
push @all_langs, $mainlang;

# The root element.
my $dict = XML::Twig::Elt->new('dict');

my $line;
# Ignore the morphology part in this test version.
while( $line = <FH> ) {

	last if ($line =~ /^LEXICON ProperNoun$/ );
	}

my $prev_word=undef;
my $prev_entry="";
my @contlex_texts;

my $last=0;

FILE:
while ($line = <FH> ) {

	if ($mainlang eq "smj") {
		last FILE if $line =~ /Dump/;
	}

	my %termc_entries;
	my %term_entries;
	my %sem_texts;
	my $lemma_2;

	#discard comments, empty lines and for now, LEXICONs
	next if ($line =~ /^\!/);
	next if ($line =~ /^\s*$/);
	next if ($line =~ /^LEXICON/);

	chomp $line;
	# Replace space in multipart names temporarily with $.
	$line =~ s/% /\$/g;
	
	my ($word, $contlex_text) = split (/\s+/, $line, 2);
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
		push (@contlex_texts, $contlex_text);
		next FILE;
	}

	my ($lemma_text, $stem_text) = split (/:/, $prev_word, 2);

	# Find out all the semantic categories associated with this word.
	my @contlexes;
	my $sub;
	for my $cont ( @contlex_texts ) {
		
		# Take comment out
		my ($contlex, $comment) = split(/\!/, $cont);
		$contlex =~ s/\s?\;\s?$//;
		$contlex =~ s/^\s+//;
	
		if($comment && $comment =~ /SUB/) { $sub=1;}
		
		push (@contlexes, $contlex);

#		my ($infl_text, $sem_text) = split(/-/, $contlex);

		# split e.g. ACCRA-fem
		$contlex =~ m/^([[:upper:]\-]*?)\-?([[:lower:]]*)$/;
		my $infl_text=$1;
		my $sem_text=$2;

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
			my $log = XML::Twig::Elt->new('log');
			$log->paste('last_child', $entry);
			if ($i > 0) { $lemma_2 = $lemma_text . "_" . $i; }
			else { $lemma_2 = $lemma_text }
			$lemma_2 =~ s/[\^\#0]//g;
			$lemma_2 =~ s/ /_/g;
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
		my $log = XML::Twig::Elt->new('log');
		$log->paste('last_child', $entry);

		$entry->set_att('id', $lemma_text);

		$termc_entries{'empty'} = $entry;
	}

	for my $cont (@contlexes) {

#		my ($infl_text, $sem_text) = split(/-/, $cont);

		$cont =~ m/^([[:upper:]\-]*?)\-?([[:lower:]]*)$/;
		my $infl_text=$1;
		my $sem_text=$2;
		
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
			
			my $id = $termc_entries{$key}->{'att'}->{'id'};
		  TERMS: {
			  # If there is no terms-entry with the same id
			  # add new element
			  my $curid = $id;
			  $curid =~ s/\_\d+$//;
			  if (! ${$term_entries{$mainlang}}{$curid}) { 
			
				  # If there was no terms entry with id or id_1, create new terms-entry.
				  for my $lang (@all_langs) {

					  my $entry = XML::Twig::Elt->new('entry');
					  my $log = XML::Twig::Elt->new('log');
					  $log->paste('last_child', $entry);
					  
					  $entry->set_att('id', $curid);
					  if ($sub) { $entry->set_att('type', "secondary"); }
					  if ($stem_text && ($stem_text ne $lemma_text)) {
						  my $stem = XML::Twig::Elt->new('stem');
						  $stem->set_text($stem_text);
						  $stem->paste('last_child', $entry);
					  }
					  # Add reference to the termc
					  my $senses = XML::Twig::Elt->new('senses');
					  my $sense = XML::Twig::Elt->new('sense');
					  $sense->set_att('ref', $id);
					  if($key ne "empty") {
						  $sense->set_att('sem', $key);
					  }
					  $sense->paste('last_child', $senses);
					  $senses->paste('last_child', $entry);
					  
					  # Alter termc entry by adding reference to terms
					  my $langentry = XML::Twig::Elt->new('langentry');
					  $langentry->set_att('lang', $lang);
					  my $include = XML::Twig::Elt->new('xi:include');
					  my $ref = 'terms-'.$lang.".xml#xpointer(//entry[\@id='".$curid."'])";
					  $include->set_att('href', $ref);
					  $include->paste('last_child', $langentry);
					  $langentry->paste('last_child', $termc_entries{$key});

					  ${$term_entries{$lang}}{$curid} = $entry;
					  
					  my $infl = XML::Twig::Elt->new('infl');
					  # Add inflection information only for the main language.
					  if ($lang eq $mainlang) {
						  $infl->set_att('lexc', $infl_text);
					  }
				      $infl->paste('last_child', ${$term_entries{$lang}}{$curid});
		          }
				  last TERMS;
			  }
			  # If there was already an element
			  # Add only inflection class and some references.
			  my $senses_elt;
			  my %sens_hash;
			  my @sens_array;
			  
			  for my $lang (@all_langs) {
				  
				  my $curentry = ${$term_entries{$lang}}{$curid};
				  if( $senses_elt = $curentry->first_child('senses')) {
					  @sens_array=$senses_elt->children;
					  for my $sens (@sens_array) { $sens_hash{$sens->{'att'}->{'ref'}} = 1; }
					  if (! $sens_hash{$id}) {
						  my $sense = XML::Twig::Elt->new('sense');
						  $sense->set_att('ref', $id);
						  $sense->set_att('sem', $key);
						  $sense->paste('last_child', $senses_elt);
						  
						  # Alter termc entry by adding reference to terms
						  my $langentry = XML::Twig::Elt->new('langentry');
						  $langentry->set_att('lang', $lang);
						  my $include = XML::Twig::Elt->new('xi:include');
						  my $ref = 'terms-'.$lang.".xml#xpointer(//entry[\@id='".$curid."'])";
						  $include->set_att('href', $ref);
						  $include->paste('last_child', $langentry);
						  $langentry->paste('last_child', $termc_entries{$key});
						  
					  }
				  }
			  }
			  
			  # Add inflection info only to the main language.
			  my $curentry = ${$term_entries{$mainlang}}{$curid};
			  if ($curentry->first_child('infl')) {
				  if($curentry->first_child('infl')->{'att'}->{'lexc'} ne $infl_text) {
					  @sens_array=$senses_elt->children;
					  if ( $#sens_array > 0 ) {
						  print "$curid\tadding multiple infl classes.\n";
					  }
					  my $infl = XML::Twig::Elt->new('infl');
					  $infl->set_att('lexc', $infl_text);		
					  $infl->paste('last_child', $curentry);
				  }
			  }
		  }	# TERMS
		}
	}
	
	for my $ent ( keys %termc_entries )	{
		$termc_entries{$ent}->print($FH1);
		$termc_entries{$ent}->DESTROY;
	}

	for my $ent ( sort { $a cmp $b } keys %{$term_entries{$mainlang}} ) {
		${$term_entries{$mainlang}}{$ent}->print($FH2);
		${$term_entries{$mainlang}}{$ent}->DESTROY;
	}
	undef %{$term_entries{$mainlang}};

	for my $lang (@other_langs) {
		my $fh=$outfiles{$lang};
		for my $ent ( sort { $a cmp $b } keys %{$term_entries{$lang}} ) {
			${$term_entries{$lang}}{$ent}->print($fh);
			${$term_entries{$lang}}{$ent}->DESTROY;
		}
		undef %{$term_entries{$lang}};
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

for my $lang (@other_langs) {
	my $fh=$outfiles{$lang};
	print $fh qq|\n</dict>|;
	close $outfiles{$lang};	
}

########################################################
# timestring: Prints date&time as an integer of the form:
# YYYYMMDDHHMMSS, ie 20050329145107
# This way we can do timestamp comparisons with less overhead.
sub timestring {
  my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)
  = localtime(time);
  $year = $year+1900;
  $mon++;            # 0-base -> 1-base
  $mon  = ( $mon  > 9) ? $mon  : "0$mon" ;
  $mday = ( $mday > 9) ? $mday : "0$mday" ;
  $hour = ( $hour > 9) ? $hour : "0$hour" ;
  $min  = ( $min  > 9) ? $min  : "0$min" ;
  $sec  = ( $sec  > 9) ? $sec  : "0$sec" ;
  return $year . $mon . $mday . $hour . $min . $sec;
}
