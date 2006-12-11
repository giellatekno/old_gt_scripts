#!/usr/bin/perl

use strict;
use encoding 'utf-8';
use open ':utf8';

use locale;
# sum-cg.pl
#
# Perl script for summarizing ambiguous analyzes.
# 1. For finding the expressions that are ambiguous and common.
# 2. For finding out, which grammatical analyzes are most ambiguous.
# 
# $Id$

binmode STDERR, ":utf8";

# permit named arguments
use Getopt::Long;
use File::Find;
use File::Basename;
use Carp qw(cluck);

my $help;
my $grammar;
my $print_words;
my $string="";
my $dir;

GetOptions ("help" => \$help,
			"grammar" => \$grammar,
			"words" => \$print_words,
			"string=s" => \$string,
			"dir=s" => \$dir,
			) ;

if ($help) {
	&print_usage;
	exit;
}

my $anal_count = 0;
my %cohorts;
my %count;

# whole group of analyses for a word.

# Read while not eol
my $word;
my $whole;
my $base;

# Search the files in the directory $dir and process each one of them.
if ($dir) {
	if (-d $dir) { find (\&process_file, $dir) }
	else { cluck "Directory did not exist."; }
}

# Process the file given in command line.
process_file ($ARGV[$#ARGV]) if -f $ARGV[$#ARGV];

if ($grammar) {
	my %tags;
	my $amb ="";
	my $count_an=0;
	for my $cohort (keys %cohorts) {
		for my $base (keys % {$cohorts{$cohort}}) {
			for my $anal (keys %{ $cohorts{$cohort}{$base} }){
				$amb .= "\n$anal";
				$count_an += 1;
			}
            # The statistics are count for different cohorts.
			if ($count_an > 1) {
				$tags{$amb}{'number'} += $count{$cohort};
				my $word = $cohort;
				$word =~ s/^\"<(.*?)>\".*$/$1/s;
				$tags{$amb}{$word} += $count{$cohort};
			}
			$count_an = 0;
			$amb = "";
		}
	}
	for my $gram (sort { $tags{$b}{'number'} <=> $tags{$a}{'number'} } keys %tags) {
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
elsif ($string) {
	for my $cohort (sort { $count{$b} <=> $count{$a} } keys %count) {
		next if ($cohort !~ /$string/);
		print "$count{$cohort}\n";
		my $word = $cohort;
		$word =~ s/^(\"<.*?>\").*$/$1/s;
		print "$word\n";
		for my $base (keys % {$cohorts{$cohort}}) {
			for my $anal (keys %{ $cohorts{$cohort}{$base} }){
				print "\t$base";
				print "$anal\n";
			}
		}
	}
}
else {
	for my $cohort (sort { $count{$b} <=> $count{$a} } keys %count) {
		print "$count{$cohort}\n";
		my $word = $cohort;
		$word =~ s/^(\"<.*?>\").*$/$1/s;
		print "$word\n";
		for my $base (keys % {$cohorts{$cohort}}) {
			for my $anal (keys %{ $cohorts{$cohort}{$base} }){
				print "\t$base";
				print "$anal\n";
			}
		}
	}
}


sub process_file {

    my $file = $_;
    $file = shift (@_) if (!$file);

	my $no_decode_this_time = 0;

	return if (! -f $file);
	return if (-z $file);

	print STDERR "Processing file: $file\n";

	open(FH, $file);
	
	my $line;
	while(<FH>) {

		return if eof(FH);
		
		$line = $_;
		return if (! $line);

		next if ($line =~ /^\s*$/);

		# hash of hashes base -> analyses
		my %analyses;

		LINE :
			while ($line && $line !~ /^\"</) {
				if($line =~ /(\".*?\")(\s+.*)$/) {
					$base = $1;
					my $analysis = $2;
					$anal_count += 1;
					$analyses{$base}{$analysis} = 1;
				}
				else { print STDERR "Line not recognized: $word, $_\n"; }
				
				while(<FH>) {
					$line = $_;
					next if ($line =~ /^\s*$/);
					last LINE if eof(FH);
					next LINE;
				}
			} #end of LINE
		
		my %analyses_2;
		for my $ba (keys %analyses) {
			foreach my $key (sort keys %{$analyses{$ba}}) {
				$analyses_2{$ba}{$key} = 1;
				$whole .= $key;
			}
		}
		
		$count{$whole} += 1;
		$cohorts{$whole} = { %analyses_2 };
		
		if ($whole && $anal_count == 1) {
			delete($cohorts{$whole});
			delete($count{$whole});
		}

		if ($line =~ /^\"<.*?>\".*$/) {
			# Start with the new word
			$whole = $line;
			$anal_count = 0;
		} else { cluck "Error, $line in wrong place."; }

	} # LINE

	close FH;
}


sub print_usage {
	print "Usage: sum-cg [OPTIONS] FILE\n";
	print "Summarize cg-output.\n";
	print "Options\n";
	print "--dir=<dir>     Search files from directory <dir>.\n";
	print "--grammar       Compare only grammatical analyzes.\n";
	print "--words         Print words associated with analyzes.\n";
    print "--help          Print the help text and exit.\n";
}

