#!/usr/bin/perl
use strict;
use encoding 'utf-8';
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
# $Id$

# permit named arguments
use Getopt::Long;

my $help;
my $all_hyphens = 0;

GetOptions ("all" => \$all_hyphens,
			"help" => \$help);

if ($help) {
	&print_usage;
	exit;
}


my %jadahje = ("ja" => 1,
			   "dahje" => 1,
			   "vai" => 1
			   );

my $HYPH = "<hyph\>";

# read one paragraph at the time:

my $end_hyphen = 0;
my $start_hyphen = 0;
my $previous_word = 0;

my @output;
my @final_output;

# Read line by line
while (<>) {

	chomp;
	# If empty line, print everything processed this far and
	# move to the next line.
	if (/^$/) {
		if (@final_output) {
			print "@final_output\n";
		}
		@final_output = "";
		@output = "";
		pop @output;
		next;
	}

	# split the line by space
	my @words = split;
	my $first_word = 1; 

	while (@words) {		

		my $word = shift @words;

		# Skip expressions which contain non-alphabetic chars or digits.
		# Skip also some other cases: Oarje-Finnmárkkus, pla-, ple- ja plipli,
		# "-pla  and other proper names.
		if ($word =~ /^\W/ || $word =~ /\d/ || $word =~ /\W-/ || $word =~ /-\W/ || $word =~ /^\p{IsUpper}/ ) {
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
		print "@final_output\n";
	}
	@final_output = @output;
	@output = "";
	pop @output;
}



sub print_usage {
	print "Usage: perl add_hyph_tags.pl [OPTIONS] FILES\n";
	print "Tag the hyphenation marks.\n";
	print "Options\n";
	print "--all     search the whole text for hyphenation points.\n";
    print "          The default is to search only the end of the lines.\n";
    print "--help    prints the help text and exit.\n";
}
