#!/usr/bin/perl -w

use strict;

use utf8;

binmode STDOUT;

# use Perl module XML::Twig for XML-handling
# http://www.xmltwig.com/
use XML::Twig;

my $mainlang = "sme";
my @other_langs = ("sme", "smj", "sma", "nor");
#my @other_langs = ("sme");

my $twig = XML::Twig->new;
$twig->set_pretty_print('record');

# Usage: 
# perl namelex2xml.pl
#
# Specify the $infile and $outfile to the files you want:

my $infile = "../".$mainlang."/src/propernoun-".$mainlang."-lex.txt";
#my $infile = "../smj/src/propernoun-smj-lex.txt";
#my $infile = "/home/saara/gt/script/prop-test.txt";
my $outfile = "terms-" . $mainlang . ".xml";
my $outfile_common = "termcenter.xml";

open (FH, "$infile") or die "Cannot open file $infile: $!";

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
	next if ($lang eq $mainlang);
	my $out = "terms-" . $lang . ".xml";
	my $fh_out;
	open($fh_out, ">$out");
	print $fh_out qq|<?xml version='1.0'  encoding="UTF-8"?>|;
	print $fh_out qq|\n<dict xmlns:xi="http://www.w3.org/2001/XInclude" last-update="$convtime">|;
	$outfiles{$lang} = $fh_out;
}

my @all_langs = @other_langs;
my %is_lang;
for (@all_langs) { $is_lang{$_} = 1 }
if (! $is_lang{$mainlang}) { push @all_langs, $mainlang }

# The root element.
my $dict = XML::Twig::Elt->new('dict');

my $line;
# Ignore the morphology part in this test version.
while( $line = <FH> ) {

	last if ($line =~ /^LEXICON ProperNoun$/ );
	}

my $prev_word=undef;
my $prev_contlex_text;
my $prev_entry="";
my %infl_texts;
my $comment_text;
my $j=0;
my $new_line;

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

	if ($new_line) {
		# Replace space in multipart names temporarily with $.
		$new_line =~ s/% /\$/g;
		
		my ($prev_word, $prev_contlex_text) = split (/\s+/, $new_line, 2);
		$prev_word =~ s/\$/ /g;

		$new_line=undef;
	}

	chomp $line;
	# Replace space in multipart names temporarily with $.
	$line =~ s/% /\$/g;
	
	my ($word, $contlex_text) = split (/\s+/, $line, 2);
	$word =~ s/\$/ /g;

	# Take comment out
	my $comment;
	($contlex_text, $comment) = split(/\!/, $contlex_text);
	$contlex_text =~ s/\s?\;\s?$//;
	$contlex_text =~ s/^\s+//;
	if ($comment) { $comment_text .= $comment; $comment_text =~ s/SUB//g;}
	
	# something wrong
	if ( !$word || ! $contlex_text) {
		print STDERR "Line not included: $line\n";
		next FILE;
	}
	# first line or new word
	if (! $prev_word) { 
		$prev_word = $word;
		%infl_texts=();
		$comment_text=undef;
		$j=0;
		my ($real_word, $stem) = split(":", $word);
		if (!$stem) { $stem = $j++; }
		if ($comment) { ${$infl_texts{$contlex_text}}{$stem}=$comment; }
	else  { ${$infl_texts{$contlex_text}}{$stem} = 1; }
		next FILE;
    }
	# consequtive identical entries are collected
	if ($prev_word) {
		my ($real_prev_word, $prev_stem) = split(":", $prev_word);
		if (!$prev_stem) { $prev_stem = $j++; }
		my ($real_word, $stem) = split(":", $word);
		if (!$stem) { $stem = $j++; }
		if ($real_prev_word eq $real_word && ! eof ) {
			if ($prev_contlex_text) {
				if ($comment) { ${$infl_texts{$prev_contlex_text}}{$prev_stem}=$comment; }
			    else  { ${$infl_texts{$prev_contlex_text}}{$prev_stem}=1; }
		    }
		   if ($comment) { ${$infl_texts{$contlex_text}}{$stem}=$comment; }
           else  { ${$infl_texts{$contlex_text}}{$stem}=1; }
		   next FILE;
		}
	}
	# if the line starts a new word, store the line for next round
	$new_line = $line;

	my ($lemma_text, $stem_text) = split (/:/, $prev_word, 2);
	$prev_word=undef;

	# Find out all the semantic categories associated with this word.
	for my $cont ( keys %infl_texts ) {

		if (! $cont) { next; }
		
		# split e.g. ACCRA-fem
		$cont =~ m/^([[:upper:]\-]*?)\-?([[:lower:]]*)$/;
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
			if ($i > 0) { $lemma_2 = $lemma_text . "_" . $i; }
			else { $lemma_2 = $lemma_text }
			# The following cleaning should only be applied to the termc entry
			$lemma_2 =~ s/[\^\#0]//g;
			$lemma_2 =~ s/ /_/g;
			$entry->set_att('id', $lemma_2);
			#$entry->set_att('lemma', $lemma_text);

			my $sem = XML::Twig::Elt->new('sem');
			if ($key ne "empty") {
				my $sem_type = XML::Twig::Elt->new($key);
				$sem_type->paste('last_child', $sem);
			}
			$sem->paste('last_child', $entry);

			my $log = XML::Twig::Elt->new('log');
			$log->paste('last_child', $entry);
			$termc_entries{$key}{'entry'} = $entry;
			$termc_entries{$key}{'lemma'} = $lemma_text;
			$i++;
		}
	}
	# if there is no semantic category specified, create one termc entry.
	else {
		my $entry = XML::Twig::Elt->new('entry');
		my $log = XML::Twig::Elt->new('log');
		my $lemma = $lemma_text;
		$log->paste('last_child', $entry);

		# Why isn't this one cleaned as well, cf lines 172-173 above
		$lemma =~ s/[\^\#0]//g;
    	$lemma =~ s/ /_/g;
		$entry->set_att('id', $lemma);

		$termc_entries{'empty'}{'entry'} = $entry;
	}

    #Mark if there is only one inflection
    my $only_one_infl=0;
    if (scalar (keys %infl_texts == 1)){ $only_one_infl = 1; }

	for my $contlex (keys %infl_texts) {

		#Take different stems
		my @stems;
		for my $key (keys %{$infl_texts{$contlex}}) {
			push(@stems, $key);
        }

		$contlex =~ m/^([[:upper:]\-]*?)\-?([[:lower:]]*)$/;
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
			
			my $id = $termc_entries{$key}{'entry'}->{'att'}->{'id'};
			my $lemma = $termc_entries{$key}{'lemma'};
		  TERMS: {
			  # If there is no terms-entry with the same id
			  # add new element
			  my $curid = $lemma;
			  $curid =~ s/\_\d+$//;
			  if (! ${$term_entries{$mainlang}}{$curid}) { 
			
				  # If there was no terms entry with id or id_1, create new terms-entry.
				  for my $lang (@all_langs) {

					  my $entry = XML::Twig::Elt->new('entry');

					  my $infl = XML::Twig::Elt->new('infl');
					  # Add inflection information only for the main language.
					  if ($lang eq $mainlang or $lang eq 'smj') {
						  $infl->set_att('lexc', $infl_text);
                      for my $stem_text (@stems) {
	                      if ($stem_text !~ /^\d$/) {
							  my $stem = XML::Twig::Elt->new('stem');
							  $stem->set_text($stem_text);
							  
							  if ($infl_texts{$contlex}->{$stem_text} =~ /SUB/) { 
								  if (scalar(@stems) > 1) { $stem->set_att('type', "secondary"); }
								  elsif (! $only_one_infl) { $infl->set_att('type', "secondary"); }
								  else { $entry->set_att('type', "secondary"); }
							  }
							  $stem->paste('last_child', $infl);
						  }
                          elsif ($infl_texts{$contlex}->{$stem_text} =~ /SUB/) {
							  if(! $only_one_infl) { $infl->set_att('type', "secondary"); }
							  else { $entry->set_att('type', "secondary"); }
						  }
                      }
					  }


				      $infl->paste('last_child', $entry);
					  
					  $entry->set_att('id', $curid);

					  # Add reference to the termc
					  my $senses = XML::Twig::Elt->new('senses');
					  my $sense = XML::Twig::Elt->new('sense');
					  $sense->set_att('ref', $id);
					  if($key ne "empty") {
						  $sense->set_att('sem', $key);
					  }
					  $sense->paste('last_child', $senses);
					  $senses->paste('last_child', $entry);

                      # Add log and comment field.
					  my $log = XML::Twig::Elt->new('log');
                      if($comment_text) {
	                       my $comment = XML::Twig::Elt->new('comment');
	                       $comment->set_text($comment_text);
                           $comment->paste('last_child', $log);
                      }
					  $log->paste('last_child', $entry);
					  
					  # Alter termc entry by adding reference to terms
					  my $langentry = XML::Twig::Elt->new('langentry');
					  $langentry->set_att('lang', $lang);
					  my $include = XML::Twig::Elt->new('xi:include');
					  my $ref = 'terms-'.$lang.".xml#xpointer(//entry[\@id='".$curid."'])";
					  $include->set_att('href', $ref);
					  $include->paste('last_child', $langentry);
					  $langentry->paste('last_child', $termc_entries{$key}{'entry'});

					  ${$term_entries{$lang}}{$curid} = $entry;
					  
                  }
				  last TERMS;
              }
			  # If there was already an element
			  # Add only inflection class and some references.
			  my $senses_elt;
			  my %sens_hash;
			  my @sens_array;

		      # Add inflection info only to the main language.
			  my $curentry = ${$term_entries{$mainlang}}{$curid};
              my $notfound=1;
			  for my $curinfl ($curentry->children('infl')) {
				  if($curinfl->{'att'}->{'lexc'} eq $infl_text) {
					  $notfound = 0;
				  }  
			  }
              if ($notfound) {
                  #print "$curid\t adding multiple infl classes.\n";
                  my $infl = XML::Twig::Elt->new('infl');
                  $infl->set_att('lexc', $infl_text);
                  for my $stem_text (@stems) {
					  if ($stem_text !~ /^\d$/) {
						  my $stem = XML::Twig::Elt->new('stem');
						  $stem->set_text($stem_text);						  
						  if ($infl_texts{$contlex}->{$stem_text} =~ /SUB/) { 
							  if ($infl_texts{$contlex}->{$stem_text} =~ /SUB/) { 
								  if (scalar(@stems) > 1) { $stem->set_att('type', "secondary"); }
								  elsif (! $only_one_infl) { $infl->set_att('type', "secondary"); }
								  else { $curentry->set_att('type', "secondary"); }
							  }
							  $stem->paste('last_child', $infl);
						  }
                     }
                     elsif ($infl_texts{$contlex}->{$stem_text} =~ /SUB/) {
			    	     if(! $only_one_infl) { $infl->set_att('type', "secondary"); }
                         else { $curentry->set_att('type', "secondary"); }
                    } 
                 }
                $infl->paste('first_child', $curentry);
              }
			  
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
						  my $langentry= XML::Twig::Elt->new('langentry');
						  $langentry->set_att('lang', $lang);
						  my $include = XML::Twig::Elt->new('xi:include');
						  my $ref = 'terms-'.$lang.".xml#xpointer(//entry[\@id='".$curid."'])";
						  $include->set_att('href', $ref);
						  $include->paste('last_child', $langentry);
						  $langentry->paste('last_child', $termc_entries{$key}{'entry'});
						  
					  }
				  }
	
		  }	# TERMS
       }
    }
   }
	for my $ent ( keys %termc_entries )	{
		$termc_entries{$ent}{'entry'}->print($FH1);
		$termc_entries{$ent}{'entry'}->DESTROY;
	}

	for my $ent ( sort { $a cmp $b } keys %{$term_entries{$mainlang}} ) {
		${$term_entries{$mainlang}}{$ent}->print($FH2);
		${$term_entries{$mainlang}}{$ent}->DESTROY;
	}
	undef %{$term_entries{$mainlang}};

	for my $lang (@other_langs) {
		next if ($lang eq $mainlang);
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

$j=0;

my ($real_word, $stem) = split(":", $word);
if (!$stem) { $stem = $j++;}

%infl_texts=();
$comment_text=undef;
if ($comment) { $infl_texts{$contlex_text}{$stem}=$comment;}
else { $infl_texts{$contlex_text}{$stem}=1; }

}

print $FH1 qq|\n</dict>|;
close $FH1;

print $FH2 qq|\n</dict>|;
close $FH2;

for my $lang (@other_langs) {
	next if ($lang eq $mainlang);
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
