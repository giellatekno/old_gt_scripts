#!/usr/bin/perl -w
#
# Perl script for converting files in paratext to basic xml.
# xml-structure corresponds the corpus.dtd in the body section.
# The header section is not fully generated.
# The script skips most of the metainformation (comments etc.) and
# other tags. It can be modified to include whatever wanted.
#
# $Id$

use strict;
use open ':locale';
use encoding 'utf8';
#binmode STDOUT, ":utf8";

use File::Find;
use IO::File;
use File::Basename;
use Getopt::Long;
use XML::Twig;

my $outfile= "para.out";

my $dir;
my $language;
my $footnotes=0;
my $help;

GetOptions ("footnotes=s" => \$footnotes,
			"out=s" => \$outfile,
			"help" => \$help);

if ($help) {
	&print_usage;
	exit 1;
}


# Open file for printing out the summary.
my $FH1;
open($FH1,  ">$outfile");

my $out_twig = XML::Twig->new();
$out_twig->set_pretty_print('record');

# The xml specifications, name of dtd-file and root node.
print $FH1 qq|<?xml version='1.0'  encoding="UTF-8"?>|;
#print $FH1 qq|<!DOCTYPE dict PUBLIC "-//DIVVUN//DTD Proper Noun Dictionary V1.0//EN"|;
#print $FH1 qq|"http://www.giellatekno.uit.no/dtd/corpus.dtd">|;
print $FH1 qq|\n<document>|;

my $i=0;
my @text_array;

# First, remove or replace the obsolete markings,
# and store the contents to an array.
while(<>) {

	my $line = $_;
	$line =~ s/\r/\n/g;
	chomp $line;

	# Remove table of contents texts
	$line =~ s/^\\toc.*$//g;

	# Remove all the poetry markers
	$line =~ s/\\(q\d*|qr|qc|qs\*|qs|qac\*|qac|qm\d*)([ |\n])(.*)$/$3/g;
	# Replace blank line marker with newline.
	$line =~ s/\\b/\n/g;
	
	# Replace paragraph markers related to layout with plain 
	# marker \p.
	$line =~ s/\\(m|pmo|pm|pmc|pm|ps|pi\d*)([ |\n])/\\p$2/g;

	# Remove some paragraph markers related to layout
	$line =~ s/\\(mi|nb|cls_text|pc|pr|ph\d*)([ |\n])/$2/g;

	# Remove extra chapter numbers and some text
	$line=~ s/^\\(ca \d*|cp \d*)([ |\n])/$2/g;
	$line=~ s/^\\cl[^\\]*$//g;
	$line=~ s/^\\cd[^\\]*$//g;

	# Remove extra heading tags
	$line =~ s/^\\(ms|mr).*$//g;
	# Remove reference tags
	$line =~ s/^\\(sr|r|sp) .*$//g;

	# Remove footnotes
	if( $footnotes) {
		# remove just tags.
		$line =~ s/(\\f\*|\\fr|\\ft|\\fk|\\f)( |\n)/$2/g;
	}
	else {
		$line =~ s/\\f(.*?)\\f\*//g;
	}
	# Remove cross references
	$line =~ s/\\x(.*?)\\x\*//g;

	# Remove character style markings.
	$line =~ s/\\(nd|tl|bk|sig|pn|wj|k|ord)\*?//g;

	# Remove some special texts
	$line =~ s/\\sls.*?\\sls\*//g;
	$line =~ s/\\add.*?\\add\*//g;
	$line =~ s/\\lit.*?$//g;
	$line =~ s/\\fig.*?\\fig\*//g;

	# Remove extra verse markings
	if ($line !~ /\\v \d+/) {
		$line =~ s/(\\(va \d*|va\*|vp \d*|vp ))/\\v/g;
	} else {
		$line =~ s/(\\(va \d*|va\*|vp \d*|vp ))//g;
	}

	if($line && $line !~ /^\s*$/) { 
		push(@text_array, $line); 
	}
}

#open (FH, ">koe.para");
#print FH "@text_array";
#close FH;

# The cleaned text is processed and stored to an xml-tree,
# the fields that are available are filled according to corpus.dtd.

my $header = XML::Twig::Elt->new('header');
my $body = XML::Twig::Elt->new('body'); 

my $p;
my $ch;
my $book;
my $cur_text;
my $section;
my $size = $#text_array;

while($i < $size && $text_array[$i]) {

	my $line=$text_array[$i];
	chomp $line;

	# Format header info
	# Since there is no standard order of the id-elements
	# they cannot be parsed.
#	if ($line =~ /^\\id (.*)$/) {
#	}

	if ($line =~ /^\\mt (.*)$/) {

		if($p) { $p->paste( 'last_child', $section); $p=undef; }
		if($section) { $section->paste( 'last_child', $ch); $p=undef; }
		if($ch) { $ch->paste( 'last_child', $book); $ch=undef; }
		if($book) { $book->paste( 'last_child', $body); $book=undef; }

		my $title = XML::Twig::Elt->new('title');
		my $text = $1;
		$title->set_text($text);
		$title->paste( 'last_child', $header);

		$book = XML::Twig::Elt->new('book');
		$book->set_att('title', $text);

		$i++;
		next;
	}

	# Format chapter headings.
	if ($line =~ /^\\c (\d+)(.*)$/) {

		if (! $section && $p) { my $tex = $p->text; print "$tex\n"; }
		if($p) { $p->paste( 'last_child', $section); $p=undef; }
		if($section) { $section->paste( 'last_child', $ch); $section=undef; }
		if($ch) { $ch->paste( 'last_child', $book); $ch=undef; }

		$ch = XML::Twig::Elt->new('chapter');
		my $number = $1;
		my $text="";
		# skip other info related to chapter.
		#if ($text_array[$i+1] =~ /^\\s (.*)$/) {
		#	$text = $1;
		#	shift(@text_array);
		#}
		#if( $text ) { $ch->set_att('title', $text); }
		$ch->set_att('number', $number);
		$i++;
		next;
	}

	# Format other headings.
	if ($line =~ /^\\(h|s)(\d*) (.*)$/) {

		start_new_section($2, $3);

		$i++;
		next;
	}

	# Format verses
	if ($line =~ /^\\p/) {
		start_new_real_para();
		$i++;
		next;
	}

	# Format verses. Our present xml-format does not have any 
	# element for verse, but it is possible to get the information
	# out in this block.
	if($line =~ /\\v/) {

		if(! $p) { $p = XML::Twig::Elt->new('p'); }
		if(! $section) { $section = XML::Twig::Elt->new('section'); }

		# sometimes a new verse starts in the middle of the line
		# the verse starting the line is taken care of here.
		my ($prev, $next) =  split(/\\v/, $line);
		if($prev) {
			if ($prev =~ /^\s*(\d+)(.*)$/) {
				my $verse = XML::Twig::Elt->new('verse');
				$verse->set_att('number', $1);
				if ($cur_text) { $cur_text .= " $2"; }
				else { $cur_text = $2; }
				$verse->set_text($cur_text);
				$cur_text=undef;
				$verse->paste( 'last_child', $p);
			}
		}

		if ($next =~ /^\s*(\d+)(.*)$/) {
			my $verse = XML::Twig::Elt->new('verse');
			$verse->set_att('number', $1);
			my $number = $1;
			if ($cur_text) { $cur_text .= " $2"; }
			else { $cur_text = $2; }
			while($text_array[$i+1] && $text_array[$i+1] !~ /^\\/) {
				chomp $text_array[$i+1];
				$cur_text .= "\n$text_array[$i+1]";
				shift(@text_array);
			}
			$verse->set_text($cur_text);
			$cur_text=undef;
			$verse->paste( 'last_child', $p);
		}
		$i++;
		next;
	}
	if ($line !~ /\\/) {
		# take the hanging text inside a verse.
		if($p) {
			$cur_text = $line ;
			#print "$cur_text\n";
			$i++;
			next;
		}
	}
	print "paratext2xml.pl: Line not included: $line\n";
	$i++;
}


$p->paste( 'last_child', $section);
$section->paste( 'last_child', $ch);
$ch->paste( 'last_child', $book);
$book->paste('last_child', $body);

$header->print($FH1);
$header->DESTROY;

$body->set_pretty_print('record');
$body->print($FH1);
$body->DESTROY;
print $FH1 qq|</document>|;

close $FH1;


sub start_new_section {
	my ($num, $text) = @_;

	if($p) { 
		if(! $section) { $section = XML::Twig::Elt->new('section'); }
		$p->paste( 'last_child', $section); $p=undef;
	}

	if($section) {
		if(! $ch) { my $tex= $p->text; print "$tex\n"; }
		$section->paste( 'last_child', $ch);
	}
	$section = XML::Twig::Elt->new('section');
	if ($num) { $section->set_att('number', $num); }
	if ($text) {$section->set_att('title', $text); }
}

sub start_new_real_para {

	if($p) {
		if(! $section) { $section = XML::Twig::Elt->new('section'); }
		$p->paste( 'last_child', $section);
	}
	$p = XML::Twig::Elt->new('p');
}


sub print_usage {
	print "Usage: paratext2xml.pl [OPTIONS] FILE\n";
	print "Convert paratext FILE to basic xml (roughly corpus.dtd).\n";
	print "Options:\n";
	print "\t--out=<file>  Name of the output file, default is para.out.\n";
	print "\t--nofoot      Do not include footnotes.\n";
    print "\t--help        Prints the help text and exit.\n";
}
