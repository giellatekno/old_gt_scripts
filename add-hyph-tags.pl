#!/usr/bin/perl -w
use strict;
use encoding 'utf8';
use open ':utf8';


# add_hyph_tags.pl
#
# Perl-script for replacing hyphenation marks with <hyph\> -tags.
# The aim is to tag the hyphens that really mark hyphenation points, and
# leave other uses of hyphens, dashes etc. untouched.
# By default, hyphenation marks are expected only at the end of the line.
# Option --all will look for the hyphenation points from the whole text,
# there is still some heuristics used to recognize the "real" hyphens.
#
# The script is made for processing corpus files in xml-format. The xml
# processing is done by basic perl operations. header field is skipped.
# Some files may have hyphenation points divided between two paragraphs,
# they are taken into account as well.
#
# $Id$
# $Revision$

# permit named arguments
use Getopt::Long;

my $help;
my $all_hyphens = 0;
my $infile;
my $outfile;

if ( -f $ARGV[$#ARGV] ) {
	 $infile = $ARGV[$#ARGV]; 
	 $outfile = $infile . ".out";
 }

GetOptions ("all" => \$all_hyphens,
			"infile=s" => \$infile,
			"outfile=s" => \$outfile,
			"help" => \$help);

if ($help) {
	&print_usage;
	exit;
}

# Words that follow a hyphen without being hyphenated parts of a word.
# Add different languages here!
my %jadahje = ("ja" => 1,
			   "dahje" => 1,
			   "vai" => 1
			   );

my $HYPH = "<hyph/>";

my $end_hyphen = 0;
my $start_hyphen = 0;
my $previous_word = 0;
my $continue_para = 0;

my @output;
my @final_output;
my $header=0;

my @text_array;
open INFH, "$infile" or die "Could not open file $infile: $!" ;
while (<INFH>) {
	push (@text_array, $_);
}
close INFH;

open OUTFH, ">$outfile" or die "Could not open file $infile: $!" ;

# Read line by line
for (@text_array) {

	# skip header field
	if (?<header>?){ 
		print OUTFH "@final_output\n"; 
		@final_output = "";
		@output = "";
		pop @output;
		$header = 1; }
	if (?</header>?) {
		$header=0;
	}
	if ($header) { 
		print OUTFH;
		next;
	}

	chomp;
	# If empty line, print everything processed this far and
	# move to the next line.
	if (/^$/ && ! $continue_para) {
		if (@final_output) {
			print OUTFH "@final_output\n";
		}
		@final_output = "";
		@output = "";
		pop @output;
		next;
	}

	# If the paragraph ends to a hyphen, search the next paragraph
	# for the rest of the word.
	if ( /<\/p>/) {
		if ($end_hyphen) {
			$continue_para = 1;
			next;
		}
		else { $continue_para = 0; }
	}
	next if (/^\s*<p>\s*$/ && $continue_para);
	if (/^\s*<p>\w+/ && $continue_para) {
		print OUTFH "<p>\n";
		s/^<p>//;
	}

	# split the line by space
	my @words = split;
	my $first_word = 1; 

	while (@words) {		

		my $word = shift @words;

		# Skip expressions which contain non-alphabetic chars or digits.
		# cases like pla-, ple- ja plipli, "-pla
		# Proper names would be one class to be skipped, but not included here.
		if ($word =~ /^\W/ || $word =~ /\d/ || $word =~ /\W-/ || $word =~ /-\W/ || $word =~ /[<>]/) {
			if ($end_hyphen) {
				$previous_word .= "-";
				push (@output, $previous_word);
				$end_hyphen = 0;
			}
			push (@output, $word);
			$first_word = 0;
			next;
		}

		# If the previous token ends to a hyphen test the next word
		# if the current word is jadahje type or not the first
		# word at the line, put the hyphen back
		# and push the previous word to the output array.
		if ($end_hyphen) {
			if (! $jadahje{$word}) {
				# otherwise join the two words with a tag. 
				if ($all_hyphens || $first_word) {
					$word = $previous_word . $HYPH . $word;
				}
			}
			else {
				$previous_word = $previous_word . "-";
				push (@output, $previous_word);
				$end_hyphen = 0;
			}
		}

		# If the word ends to a hyphen, remember it.
		if ($word =~ s/-+$//) { $end_hyphen = 1; }
		else { $end_hyphen = 0; }

		if ($all_hyphens) {
			# Remember also the starting hyphens
			if ($word =~ s/^-//) { $start_hyphen = 1; }
			else { $start_hyphen = 0; }
			
			# If the option --all is specified, mark all the hyphens with a tag 
			# Replace all the other instances of hyphens
			$word = join ($HYPH,  split(/-/, $word));
 		
			# put back the start hyphen.
			if ($start_hyphen) {
				$word = "-" . $word;
			}
		}

		# The word with end hyphen is examined at the next round.
		if (! $end_hyphen) {
			push (@output, $word);
		}
		$previous_word = $word;
		$first_word = 0;
	}
		
	if (@final_output) {
		print OUTFH "@final_output\n";
	}
	@final_output = @output;
	@output = "";
	pop @output;
}

if (@final_output) {
	print OUTFH "@final_output\n";
}

close OUTFH;

sub print_usage {
	print "Usage: add-hyph-tags.pl [OPTIONS] FILES\n";
	print "Tag the hyphenation marks.\n";
	print "Options\n";
	print "--all            search the whole text for hyphenation points.\n";
    print "                 The default is to search only the end of the lines.\n";
    print "--infile=<file>  the input file.\n";
    print "--outfile=<file> output file.\n";
    print "--help           prints the help text and exit.\n";
}
