#!/usr/bin/perl -w
use strict;
binmode STDOUT, ":utf8";

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
# processing is done by basic XML::Twig. header field is skipped.
# Some files may have hyphenation points divided between two paragraphs,
# they are taken into account as well. The paragraphs may contain emphasis
# or some other xml-formatting. Those are skipped for now.
#
# $Id$
# $Revision$

# permit named arguments
use Getopt::Long;
use XML::Twig;

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


my $document = XML::Twig->new(twig_handlers => { body => sub { add_tags(@_); } });
if (! $document->safe_parsefile ("$infile")) {
	print STDERR "add-hyph-tags.pl: parsing the XML-file failed: $@\n";
	exit;
}

open (FH, ">:utf8", "$outfile") or die "Cannot open $outfile $!";
$document->set_pretty_print('indented');
$document->print( \*FH);
$document->purge;
close(FH);

my @final_output;
my $prev_p;

sub add_tags {
	my ( $twig, $body) = @_;

	my @output;
	my $end_hyphen=0;
	my $start_hyphen=0;
	my $previous_word="";
	
	for my $p ($body->descendants) {
		my $type = $p->att('type');
		my $gi = $p->gi;
		if ( $gi ne "p"  || ! $p->contains_only_text || ($prev_p && $prev_p->gi ne $gi)) {
			if($prev_p) {
				if ($end_hyphen) {
					push(@final_output, @output);
					@output = "";
					pop @output;
					$previous_word .= "-";
					push (@final_output, $previous_word);

					$prev_p->set_content(@final_output);
					@final_output = "";
					pop @final_output;

					$end_hyphen = 0;
				}
				else {
					$prev_p=undef;
				}
			}
			next;
		}

		my $text = $p->text;

		my @lines = split (/\n+/, $text);
		for my $line (@lines) {

			# split the line by space
			my @words = split(/\s+/, $line);
			my $first_word = 1; 
			
			while (@words) {
				
				my $word = shift @words;
				chomp $word;

				# Skip expressions which contain non-alphabetic chars or digits.
				# cases like pla-, ple- ja plipli, "-pla
				# Proper names would be one class to be skipped, but not included here.
				if ($word =~ /^\W/ || $word =~ /\d/ || $word =~ /\W-/ || $word =~ /-\W/ || $word =~ /[<>]/) {
					if ($end_hyphen) {
						$previous_word .= "- ";
						push(@output, $previous_word);
						$end_hyphen = 0;
					}
					$word .= " ";
					push( @output, $word);
					$first_word = 0;
					next;
				}
				# If the previous token ends to a hyphen test the next word
				# if the current word is jadahje type or not the first
				# word at the line, put the hyphen back
				# and add the previous word to the output.
				if ($end_hyphen) {
					if (! $jadahje{$word}) {
						# otherwise join the two words with a tag. 
						if ($all_hyphens || $first_word) {
							my $hyph = XML::Twig::Elt->new( hyph => '#EMPTY');
							push (@output, ($previous_word, $hyph));
						}
					}
					else {
						$previous_word .=  "- ";
						push(@output, $previous_word);
					}
					$end_hyphen=0;
				}
				
				# If the word ends to a hyphen, remember it.
				if ($word =~ s/-+$//) { $end_hyphen = 1; }
				else { $end_hyphen = 0; }
				
				if ($all_hyphens && $word =~ /-/) {
					# Remember also the starting hyphens
					if ($word =~ s/^-//) { $start_hyphen = 1; }
					else { $start_hyphen = 0; }
					
					# If the option --all is specified, mark all the hyphens with a tag 
					# Replace all the other instances of hyphens

					my @pieces = split(/-/, $word);
					my $piece = shift @pieces;
					push (@output, $piece);
					while (@pieces) {
						my $hyph = XML::Twig::Elt->new( hyph => '#EMPTY');
						push (@output, $hyph);
						my $piece = shift @pieces;
						push (@output, $piece);
					}
					push (@output, " ");
					next;
				}
				
				# The word with end hyphen is examined at the next round.
				if (! $end_hyphen) {
					$word .= " ";
					push(@output, $word);
				}
				$previous_word = $word;
				$first_word = 0;
			}
			if (! $end_hyphen) {
				push(@final_output, @output);
				@output = "";
				pop @output;
			}
		}
		$prev_p=$p;
		if (! $end_hyphen && @final_output) {
			$prev_p->set_content(@final_output);
			@final_output = "";
			pop @final_output;
		}
	}
}



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
