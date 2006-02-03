#!/usr/bin/perl

use strict;
use encoding 'utf-8';
use open ':utf8';

# sum-cg.pl
#
# Perl script for summarizing ambiguous analyzes.
# 1. For finding the expressions that are ambiguous and common.
# 2. For finding out, which grammatical analyzes are most ambiguous.
# 
# $Id$

# permit named arguments
use Getopt::Long;

my $help;
my $grammar;
my $print_words;

GetOptions ("help" => \$help,
			"grammar" => \$grammar,
			"words" => \$print_words,
			) ;

if ($help) {
	&print_usage;
	exit;
}

my $anal_count = 0;

# hash of hashes word -> base -> analyses
my %analyses;

my %cohorts;
my %count;

# whole group of analyses for a word.

# Read while not eol
my $word;
my $whole;

LINE : while(<>) {	
	next if (/^\s*$/);
	READING : {
		last READING if (/^\"</);
		if(/(\".*?\")(\s+.*)$/) {
			$whole .= $_;
			my $base = $1;
			my $analysis = $2;
			$anal_count += 1;
			$analyses{$base}{$analysis} = 1;
		}
		else { print "Line not recognized: $word, $_\n"; }
		next LINE;
	} # READING

	$count{$whole} += 1;
	$cohorts{$whole} = { %analyses };
	
	if ($whole && $anal_count == 1) {
		delete($cohorts{$whole});
		delete($count{$whole});
	}

	if (/^\"<.*?>\".*$/) {
		# Start with the new word
		$whole = $_;
		%analyses = ();
		$anal_count = 0;
	}
} # LINE


if ($grammar) {
	my %tags;
	my $amb ="";
	my $count_an=0;
	for my $cohort (keys %cohorts) {
		for my $base (keys % {$cohorts{$cohort}}) {
			for my $anal ( keys %{ $cohorts{$cohort}{$base} }){
				$amb .= "\n$anal";
				$count_an += 1;
			}
# The statistics are count for different cohorts.
			if ($count_an > 1) {
				$tags{$amb}{'number'} += 1;
				my $word = $cohort;
				$word =~ s/^\"<(.*?)>\".*$/$1/s;
				$tags{$amb}{$word} += 1;
				$amb = "";
			}
			$count_an = 0;
		}
	}
	for my $gram (sort { $tags{$b}{'number'} <=> $tags{$a}{"number"} } keys %tags) {
		print "$tags{$gram}{'number'}: ";
		if( $print_words) {
			for my $word (keys % { $tags{$gram} } ) {
				if($word ne 'number') {
					print "$word $tags{$gram}{$word} ";
				}
			}
		}
		print "$gram\n\n";
	}
}
else {
	for my $cohort (sort { $count{$b} <=> $count{$a} } keys %count) {
		print "$count{$cohort}\n";
		for my $base (keys % {$cohorts{$cohort}}) {
			print "$base\n";
		}
	}
}

sub print_usage {
	print "Usage: sum-cg [OPTIONS] FILE\n";
	print "Summarize cg-output.\n";
	print "Options\n";
	print "--grammar       Compare only grammatical analyzes.\n";
	print "--words         Print words associated with analyzes.\n";
    print "--help          Print the help text and exit.\n";
}

