#!/usr/bin/perl -w

use strict;
use open ':locale';
use encoding 'utf8';
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

my $out_twig = XML::Twig->new();
$out_twig->set_pretty_print('record');

my $lang_elt;
my $langgenre_elt;
my $file_elt;
my $size;

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
	my $root = $levels[1];
	my $lang = $levels[2];
	my $genre = $levels[3];
	my $langgenre = $lang . "/" . $genre;

	$count{$root}{'count'} += 1;
	$count{$root}{$lang}{'count'} += 1;
	$count{$root}{$lang}{$genre}{'count'} += 1;

	$file_elt = XML::Twig::Elt->new('file');
	$size = XML::Twig::Elt->new('size'); 

	my $p_count;
	my $section_count;
	my $twig = XML::Twig->new(twig_handlers =>
							  { header => \&header,
								p  => sub { $p_count += 1; },
								section  => sub { $section_count += 1; },
							});
	if (! $twig->safe_parsefile("$file")) {
		print STDERR "$file: ERROR parsing the XML-file failed.\n";		  
	}
	
	my $p_count_elt = XML::Twig::Elt->new('pcount'); 
	my $section_count_elt = XML::Twig::Elt->new('sectioncount'); 
	$p_count_elt->set_text($p_count);
	$section_count_elt->set_text($section_count);
	$p_count_elt->paste( 'last_child', $size);
	$section_count_elt->paste( 'last_child', $size);

	$size->paste( 'last_child', $file_elt);

	my $filename = XML::Twig::Elt->new('filename');
	$filename->set_text($file);
	$filename->paste( 'last_child', $file_elt);

	# Create language and genre structure if needed
	if($count{$root}{$lang}{'count'} == 1) {
		if($lang_elt) {
			$lang_elt->print($FH1);
			$lang_elt->DESTROY;
			
		}
		$lang_elt = XML::Twig::Elt->new($lang);
	}
	
	if($count{$root}{$lang}{$genre}{'count'} == 1) {
		if ($langgenre_elt) {		
			$langgenre_elt->DESTROY;
		}
		
		$langgenre_elt = XML::Twig::Elt->new($genre);
		$langgenre_elt->paste( 'last_child', $lang_elt);
	}
	$file_elt->paste( 'last_child', $langgenre_elt);
}

# Copy relevant header fields to the summary
sub header {
	my ($t, $header) = @_;

	my $title2;
	my $title = $header->first_child('title');
	if( $title ) { $title2 = $title->copy;
				   $title2->paste( 'last_child', $file_elt);
			   }
	my $avail2;
	my $avail = $header->first_child('availability');
	if( $avail ) { $avail2 = $avail->copy;
				   $avail2->paste( 'last_child', $file_elt);
			   }
	my $wordcount2;
	my $wordcount = $header->first_child('wordcount');
	if($wordcount) { $wordcount2 = $wordcount->copy; 
					 $wordcount2->paste( 'last_child', $size);
				 }
	my $translated_from2;
	my $translated_from = $header->first_child('translated_from');
	if($translated_from) { $translated_from2 = $translated_from->copy;
						   $translated_from2->paste( 'last_child', $file_elt);
					   }

	my $multilingual2;
	my $multilingual = $header->first_child('multilingual');
	if($multilingual) { $multilingual2 = $multilingual->copy; 
						$multilingual2->paste( 'last_child', $file_elt);
					}

}
$lang_elt->print($FH1);
$lang_elt->DESTROY;

my $count_elt = XML::Twig::Elt->new('count');
for my $root (keys %count) {
	my $relt = XML::Twig::Elt->new('total');
	$relt->set_att('count', $count{$root}{'count'});

	for my $lang (keys %{$count{$root}}) {
		next if ($lang eq 'count');
		my $lelt = XML::Twig::Elt->new('language');
		$lelt->set_att('xml:lang', $lang);
		$lelt->set_att('count', $count{$root}{$lang}{'count'});
	
		for my $genre (keys %{$count{$root}{$lang}}) {
			next if ($genre eq 'count');
			my $gelt = XML::Twig::Elt->new('genre');
			$gelt->set_att('name', $genre);
			$gelt->set_att('count', $count{$root}{$lang}{$genre}{'count'});
			$gelt->paste('last_child', $lelt);
		}
		$lelt->paste('last_child', $relt);
	}
	$relt->paste('last_child', $count_elt);
}

$count_elt->print($FH1);
$count_elt->DESTROY;



print $FH1 qq|\n</summary>|;
close $FH1;


sub print_help {
	print"Usage: convert2xml.pl [OPTIONS] [FILES]\n";
	print "The available options:\n";
    print"    --dir=<dir>     The directory where to search for files.\n";
    print"                    If not given, only FILE is processed.\n";

}
