#!/usr/bin/perl -w

use strict;
use open ':locale';
use encoding 'utf8';
#binmode STDOUT, ":utf8";

use bytes;

use File::Find;
use IO::File;
use File::Basename;
use Getopt::Long;
use XML::Twig;

my $corpdir = "/usr/local/share/corp";
my $outfile= "para.out";

my $dir;
my $language;
my $help;

GetOptions ("dir=s" => \$dir,
			"corpdir=s" => \$corpdir,
			"lang=s" => \$language,
			"out=s" => \$outfile,
			"help" => \$help);

if ($help) {
	&print_help;
	exit 1;
}


# Open file for printing out the summary.
my $FH1;
open($FH1,  ">$outfile");

my $out_twig = XML::Twig->new();
$out_twig->set_pretty_print('record');

# The xml specifications, name of dtd-file and root node.
print $FH1 qq|<?xml version='1.1'  encoding="UTF-8"?>|;
#print $FH1 qq|<!DOCTYPE dict PUBLIC "-//DIVVUN//DTD Proper Noun Dictionary V1.0//EN"|;
#print $FH1 qq|"http://www.giellatekno.uit.no/dtd/corpus.dtd">|;
print $FH1 qq|\n<document>|;

my $i=0;
my @text_array;

my $header = XML::Twig::Elt->new('header');
$header->print($FH1);
$header->DESTROY;
my $body = XML::Twig::Elt->new('body'); 

# First, remove or replace the obsolete markings,
# and store the contents to an array.
while(<>) {

	my $line = $_;

	# Remove all the poetry markers
	$line =~ s/\\(q\d*|qr|qc|qs|qs\*|qac|qac*|qm\d*)//g;
	# Replace blank line marker with newline.
	$line =~ s/\\b/\n/g;
	

	# Replace paragraph markers related to layout with plain 
	# marker \p.
	$line =~ s/\\(m|pmo|pm|pmc|pm|pi\d*)/\\p/g;

	# Remove some paragraph markers related to layout
	$line =~ s/\\(mi|nb|cls_text|pc|pr|ph\d*)//g;

	# Remove extra chapter numbers and some text
	$line=~ s/^\\(ca \d*|cp \d*)//g;
	$line=~ s/^\\cl[^\\]*$//g;
	$line=~ s/^\\cd[^\\]*$//g;

	# Remove extra verse markings
	if ($line !~ /\\v \d+/) {
		$line =~ s/(\\(va \d*|va\*|vp \d*|vp| ))/\\v/g;
	} else {
		$line =~ s/(\\(va \d*|va\*|vp \d*|vp| ))//g;
	}

	# Remove extra heading tags
	$line =~ s/^\\(ms|mr).*$//g;
	# Remove reference tags
	$line =~ s/^\\(sr|r|sp).*$//g;

	# Remove footnotes
	$line =~ s/\\f(.*?)\\f\*//g;
	# Remove cross references
	$line =~ s/\\x(.*?)\\x\*//g;

	# Remove character style markings.
	$line =~ s/\\(nd|tl|bk|sig|pn|wj|k|ord)\*?//g;

	# Remove some special texts
	$line =~ s/\\sls.*?\\sls\*//g;
	$line =~ s/\\add.*?\\add\*//g;
	$line =~ s/\\lit.*?$//g;
	$line =~ s/\\fig.*?\\fig\*//g;

	if($line) { push(@text_array, $line); }
}

my $p;
my $size = $#text_array;
print $size;
while($i < $size && $text_array[$i]) {

	my $line=$text_array[$i];
	chomp $line;
	$line =~ s/\r//g;

	# Format chapter headings
	if ($line =~ /^\\c (\d+)(.*)$/) {
		$p = XML::Twig::Elt->new('p');
		$p->set_att('type', 'title');
		my $number = $1;
		my $text="";
		# skip other info related to chapter.
		if($text_array[$i+1] =~ /^\\s (.*)$/) {
			$text=$1;
			$text =~ s/\r//g;
			shift(@text_array);
		}
		$p->set_text("$number $text");
		$p->paste( 'last_child', $body);
		$i++;
		next;
	}

	# Format verses
	if ($line =~ /^\\p/) {
		if($p) {
			$p->print($FH1);
		}
		$p = XML::Twig::Elt->new('p');
		$p->set_att('type', 'text');
		$i++;
		next;
	}

	# Format verses
	if ($line =~ /^\\v (\d+)(.*)$/) {
#		my $verse = XML::Twig::Elt->new('verse');
#		$verse->set_att('number', $1);
		my $number = $1;
		my $text=$2;
		while($text_array[$i+1] && $text_array[$i+1] =~ /^[^\\]/) {
			$text . $text_array[$i+1];
			shift(@text_array);
		}
#		$verse->set_text($text);
#		$verse->paste( 'last_child', $p);
		$p->set_text("$number $text");
		$i++;
		next;
	}
	$i++;
}

$body->print($FH1);
$body->DESTROY;
