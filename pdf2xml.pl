#!/usr/bin/perl -w
use strict;

# pdf2xml.pl [OPTIONS]
# Perl script for converting JPedal output to our xml-format.
# The JPedal output files are read one at the time and the paragraphs
# are combined when there seems to be no paragraph break.
# The footnotes and indexes are excluded on the basis of the font size
# information which is either given as a command line option or read from 
# the xsl.file. The titles are recognized on the basis of font size and style
# if the information is available.
#
# $Id$


binmode STDOUT, ":utf8";
use File::Find;
use File::Copy;
use IO::File;
use File::Basename;
use Getopt::Long;
use XML::Twig;

my $dir;
my $file;
my $xslfile;
my $outfile;
my $help;
my %files;
my $main_sizes;
my $title_sizes;
my $title_styles;

GetOptions ("dir=s" => \$dir,
			"outfile=s" => \$outfile,
			"xslfile=s" => \$xslfile,
			"font_sizes=s" => \$main_sizes,
			"title_sizes=s" => \$title_sizes,
			"title_styles=s" => \$title_styles,
			"help" => \$help);

if ($help) {
	&print_help;
	exit 1;
}

if( $xslfile) {
	my $document = XML::Twig->new;
	if (! $document->safe_parsefile("$xslfile")) {
		print STDERR "Copyfree: $xslfile: ERROR parsing the XML-file failed: $!\n";		  
		last COPYFREE;
	}

	my $root = $document->root;

	my $main_font_elt = $root->first_child('xsl:variable[@name="main_sizes"]');
	$main_sizes = $main_font_elt->{'att'}{'select'};

	my $title_font_elt = $root->first_child('xsl:variable[@name="title_sizes"]');
	$title_sizes = $title_font_elt->{'att'}{'select'};

	my $title_style_elt = $root->first_child('xsl:variable[@name="title_styles"]');
	$title_styles = $title_style_elt->{'att'}{'select'};
}

# change comma to | to be used in regex.
$title_sizes =~ s/\,/\|/g;
$main_sizes =~ s/\,/\|/g;
$title_styles =~ s/\,/\|/g;
$title_sizes =~ s/\'//g;
$main_sizes =~ s/\'//g;
$title_styles =~ s/\'//g;


# Search the files in the directory $dir and process each one of them.
if ($dir) {
	if (-d $dir) { find (\&process_file, $dir) }
	else { print "$dir ERROR: Directory did not exit.\n"; }
}

# Process the file given in command line.
process_file ($ARGV[$#ARGV]) if -f $ARGV[$#ARGV];

sub process_file {
    my $file = $_;
    $file = shift (@_) if (!$file);
	return if ( $file !~ /xml/);

	# Take only the file name without path.
	$file =~ s/.*[\/\\](.*)/$1/;

	$file =~ s/.xml$//;
	$files{$file}=1;
}

my $FH;
open ($FH, ">$outfile") or print STDERR "$outfile: ERROR cannot open file $!";
print $FH qq|<?xml version="1.0" encoding="UTF-8"?>|;

my @paras;
my $first_para;
my @final_output;
my $outdocu = XML::Twig::Elt->new('document');
my $header = XML::Twig::Elt->new('header');
$header->paste('last_child', $outdocu);
my $body = XML::Twig::Elt->new('body');

my $title=0;

# The files are named according to the page number
# here they are sorted.
for my $key ( sort { $a <=> $b } keys %files ) {

	next if ($key !~ /^\d+$/);
	my $file = $dir . $key . ".xml";
#	print "$file\n";

	$first_para=1;

	my $document = XML::Twig->new(twig_handlers => { p => sub { handle_para(@_); } },
								  keep_spaces => 1,
								  pretty_print => 'record_c');
	if (! $document->safe_parsefile ("$file") ) {
		print STDERR "$file: ERROR parsing the XML-file failed. $@\n";
		exit;
	}
}

sub handle_para {
	my ($twig,$para) = @_;

	if($first_para) {
		if(@final_output) {
			my $cur_para = XML::Twig::Elt->new('p');
			$cur_para->set_content(@final_output);
			if($title) { $cur_para->set_att('type', "title"); }
			$title=0;
			$cur_para->paste('last_child', $body);
			@final_output=undef;
			pop @final_output;
		}
		$first_para=0;
	}
	
	# remove nodes with font smaller than the main font.
	my @font_nodes = $para->children('font');
	for my $font_n (@font_nodes) {
		my $style = $font_n->{'att'}->{'style'};
		next if (! $style);
		if ($style !~ /($main_sizes|$title_sizes)/) {
			$font_n->delete;
			next;
		}
	}
	# pick titles according to the font size.
	my @font_nodes2 = $para->children('font');
	for my $font_n (@font_nodes2) {
		my $style = $font_n->{'att'}->{'style'};
		next if (! $style);
		if(($style =~ /($title_sizes)/) and (! $title_styles or $style =~ /($title_styles)/)) {
			
			# If the para starts a title, print out the previous para.
			if (! $title && @final_output) {
				my $cur_para = XML::Twig::Elt->new('p');
				$cur_para->set_content(@final_output);
				if($title) { $cur_para->set_att('type', "title"); }
				$title=0;
				$cur_para->paste('last_child', $body);
				@final_output=undef;
				pop @final_output;
			}
			$title=1;
		}
		# If the para is not a title, print out the previous title.
		else{
			if ($title && @final_output) {
				my $cur_para = XML::Twig::Elt->new('p');
				$cur_para->set_content(@final_output);
				if($title) { $cur_para->set_att('type', "title"); }
				$title=0;
				$cur_para->paste('last_child', $body);
				@final_output=undef;
				pop @final_output;
			}
			$title=0;
		}
	}

	my $text=$para->text;
	return if ($text =~ /^\s*$/) ;
	$text =~ s/\n+/\n/;

	push (@final_output, $text);
	push (@final_output, " ");

	if($text =~ /\n/ && @final_output) {
		my $cur_para = XML::Twig::Elt->new('p');
		$cur_para->set_content(@final_output);
		if($title) { $cur_para->set_att('type', "title"); }
		$title=0;
		$cur_para->paste('last_child', $body);
		@final_output=undef;
		pop @final_output;
	}
	$para->DESTROY;
}

if(@final_output) {
	my $cur_para = XML::Twig::Elt->new('p');
	$cur_para->set_content(@final_output);
	$cur_para->paste('last_child', $body);
	@final_output=undef;
	pop @final_output;
}

$body->paste('last_child', $outdocu);
$outdocu->set_pretty_print('indented');
$outdocu->print($FH);
close $FH;

sub print_help {
	print << 'END';
Usage: pdf2xml.pl [OPTIONS] [FILE]
Convert JPedal output to our xml-format.
The available options:
    --help            Print this help text and exit.
    --dir=<dir>       Directory, where the JPedal output files are.
    --outfile=<file>  The name of the output xml-file.
    --xslfile=<file>  The name of the xsl-file where the font sizes are read.
    --main_sizes=..   The list of the main font sizes, e.g '12pt,14pt'.
    --title_sizes=..  The list of the title font sizes, e.g '12pt,14pt'.
    --title_styles=.. The list of the title styles which is used with the title sizes.

END
}
