#!/usr/bin/perl -w
use strict;

# Usage: corpus-search-words.pl --dir=<dir>
# Search for files and directories for paragraphs that do not match to 
# the specified language. Uses word models (the files LM/lang.wm) as
# source of words for that language.
#
# $Id$

use utf8;

use File::Find;
use File::Basename;
use XML::Twig;
use Getopt::Long;

my $help;
my $dir;
my $wmdir="/usr/local/share/corp/bin/LM";
my $lang;
my @languages=("eng","nno","nob","sme","fin","fkv","smj","sma","ger","swe" );
my %langs;
my $mainlang="sme";


GetOptions ("mainlang=s" => \$mainlang,
			"dir=s" => \$dir,
			"help" => \$help);

if ($help) {
	&print_help;
	exit;
}

for my $l (@languages) {
	
	my $word_file = $wmdir . "/" . $l . ".wm";
	if (! -f $word_file) {
		print "Could not find file $word_file\n";
	}
	open (FH, "<$word_file");
	
	my @words;
	while(<FH>) {

		chomp;
		next if (/^\#/);
		s/^\s*//;
		s/\s*$//;
		my ($num, $word) = split(/\s+/);
		if ($word && $word !~ /\W/ && length($word) > 2) { push (@{$langs{$l}}, $word); }
	}
	close FH;

}

# Search the files in the directory $dir and process each one of them.
if ($dir) {
	if (-d $dir) { find (\&process_file, $dir) }
	else { print "$dir Directory did not exit.\n"; }
}

# Process the file given in command line.
process_file (Encode::decode_utf8($ARGV[$#ARGV])) if -f $ARGV[$#ARGV];

my $mono;
sub process_file {
    my $file = $_;
    $file = shift (@_) if (!$file);

	return unless ($file =~ m/\.xml$/);

    $file = File::Spec->rel2abs($file);

	# Search with find gives some unwanted files which are silently
	# returned here.
    return if ($file =~ /[\~]$/);
	return if (-z $file);

	$mono=0;
	my @messages;
	my $document = XML::Twig->new(twig_handlers => { header => sub { take_mainlang(@_, \@messages); }, 
													 p => sub { find_words(@_, \@messages); } });
	if (! $document->safe_parsefile ("$file") ) {
		print STDERR "Parsing the XML-file $file failed: $@\n";
		return;
	}
	if(@messages) {
		print "$file\n", @messages;
	}	
}

sub take_mainlang {
	my ( $twig, $header, $file) = @_;
	
	my $mlang = $header->{'att'}->{'xml:lang'};

	if ($mainlang && $mlang && $mlang ne $mainlang) {
		print "$file\n";
		print "Warning: Main language $mainlang did not match xml:lang definition: $mlang\n";
		print "Using $mlang as main language.\n";
	}
	if ($mlang) {
		$mainlang = $mlang;
	}
	# Skip the file if marked as monolingual.
	if ($header->first_child('monolingual')) { $mono=1 };
}


sub find_words {
	my ( $twig, $para, $messages_aref) = @_;

	return if $mono;
	my $paralang = $para->{'att'}->{'xml:lang'};

	if(! $paralang) { $paralang = $mainlang; }

	my $text = $para->text;
	$text =~ s/^\n+//;
	$text =~ s/\n+$//;
	return if ($text =~ /^\s*[\W\d]*\s*$/);
	return if length($text) < 50;

	my @matched;
	for my $word (@{$langs{$paralang}}) {
		if ($text =~ /\b$word\b/ || $text =~ /\bucfirst($word)\b/) { push (@matched, $word); }
	}
#		if ($paralang ne $l && @matched) {
#			push @messages, "\"$l\" words \"@matched\" found from paragraph marked as \"$paralang\":\t$text\n";
#		}
	if (! @matched) {
		push @$messages_aref, "Paragraph contained no words for xml:lang \"$paralang\":\n\t$text\n\n";
	}
}

sub print_help {
	print << END;
Usage: corpus-wrong-lang.pl [OPTIONS] [FILE]
Search files for paragraphs that do not contain words 
associated to the specified language. Print to STDOUT.
The available options:
    --help            Print this help text and exit.
    --dir=<dir>       The directory where to search for files,
                      if not given, only FILE is processed.
    --mainlang=<lang> The assumed main language. If the file has
	                  different specification, produces a warning.
END
}
