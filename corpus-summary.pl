#!/usr/bin/perl -w

use strict;
use open ':locale';
binmode STDOUT, ":utf8";

use File::Find;
use IO::File;
use File::Basename;
use Getopt::Long;
use XML::Twig;

my %summary;
my %count;

my $corpdir = "/home/saara/samipdf";

my $dir;
my $language;
my $help;
my $outfile="summary.tmp";

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

my $out_twig = XML::Twig->new( output_encoding => "utf8");
$out_twig->set_pretty_print('record');

my $lang_elt;
my $langgenre_elt;
my $prev_lang = "";

# The xml specifications, name of dtd-file and root node.
print $FH1 qq|<?xml version='1.1'  encoding="UTF-8"?>|;
print $FH1 qq|<!DOCTYPE dict PUBLIC "-//DIVVUN//DTD Proper Noun Dictionary V1.0//EN"|;
print $FH1 qq|"http://www.divvun.no/dtd/prop-noun-dict-v10.dtd">|;
print $FH1 qq|\n<summary>|;


if ($language) { $dir = $corpdir . "/$language"; }

# Search the files in the directory $dir and process each one of them.
if ($dir) {
	if (-d $dir) { find (\&process_file, $dir) }
	else { print "$dir ERROR: Directory did not exist.\n"; }
}
else {
# Process the file given in command line.
	process_file ($ARGV[$#ARGV]) if -f $ARGV[$#ARGV];
}

sub process_file {

    my $file = $_;
    $file = shift (@_) if (!$file);

	# Search with find gives some unwanted files which are silently
	# returned here.
    return unless ($file =~ m/\.xml$/);
    return if ($file =~ /[\~]$/);
	return if (-z $file);

	# Get different subdirectories under which the file lies.
    my $absfile = File::Spec->rel2abs($file);
	(my $relpath = $absfile ) =~ s/$corpdir//;
	$relpath =~ s/$file//;

	print "$absfile\n";

	my @levels = split ("/", $relpath);
	my $root = $levels[0];
	my $lang = $levels[2];
	my $genre = $levels[3];
	my $langgenre = $lang . "/" . $genre;

	$count{$root} += 1;
	$count{$lang} += 1;
	$count{$langgenre} += 1;

	# Copy file with free license to gtfree.
	my $twig = XML::Twig->new;
	if (! $twig->safe_parsefile("$file")) {
		print STDERR "$file: ERROR parsing the XML-file failed.\n";		  
	}

	my $root_elt = $twig->root;
	my $header = $root_elt->first_child('header');

	my $title2;
	my $title = $header->first_child('title');
	if( $title ) { $title2 = $title->copy; }
	else { $title2 = XML::Twig::Elt->new('title'); }

	my $avail2;
	my $avail = $header->first_child('availability');
	if( $avail ) { $avail2 = $avail->copy; }
	else { $avail2 = XML::Twig::Elt->new('availability'); }

	my $wordcount2;
	my $wordcount = $header->first_child('wordcount');
	if($wordcount) { $wordcount2 = $wordcount->copy; }
	else { $wordcount2 = XML::Twig::Elt->new('wordcount'); }

	$twig->purge;

	my $file_elt = XML::Twig::Elt->new('file');
	$avail2->paste( 'last_child', $file_elt);
	$title2->paste( 'last_child', $file_elt);
	$wordcount2->paste( 'last_child', $file_elt);

	if($count{$lang} == 1) {
		if($lang_elt) {
			$lang_elt->print($FH1);
			$lang_elt->DESTROY;
		}
		$lang_elt = XML::Twig::Elt->new($lang);
	}
	
	if($count{$langgenre} == 1) {
		if ($langgenre_elt) {		
			$langgenre_elt->DESTROY;
		}

		$langgenre_elt = XML::Twig::Elt->new($genre);
		$langgenre_elt->paste( 'last_child', $lang_elt);
	}

	$file_elt->paste( 'last_child', $langgenre_elt);
}

$lang_elt->print($FH1);
$lang_elt->DESTROY;

for my $key (keys %count) {
	print "$key: $count{$key}\n";
}

print $FH1 qq|\n</summary>|;


sub print_help {
	print"Usage: convert2xml.pl [OPTIONS] [FILES]\n";
	print "The available options:\n";
    print"    --dir=<dir>     The directory where to search for files.\n";
    print"                    If not given, only FILE is processed.\n";

}
