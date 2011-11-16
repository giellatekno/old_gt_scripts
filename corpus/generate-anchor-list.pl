#!/usr/bin/perl -w

use strict;

# Usage: 
# generate-anchor-list.pl --lang1=lg1 --lang2=lg2  FILE
#
# Generate paired anchor lisit for languages lg1 and lg2.
# Output line format e.g. njukčamán* / mars
# Source file is given command line, the format is tailored for
# the file gt/common/src/anchor.txt.

# permit named arguments
use Getopt::Long;

my $help;
my $infile;
my $lang1;
my $lang2;
my $outdir = "";

GetOptions ("lang1=s" => \$lang1,
			"lang2=s" => \$lang2,
			"outdir=s" => \$outdir,
			"help" => \$help);

if ($help) {
	&print_usage;
	exit;
}

if(!($lang1 && $lang2)) {
	print "Specify options --lang1=language and --lang2=language.\n";
	exit;
}

if ($outdir) { $outdir .= "/"; }

# @ARGV now contains input files
my $num_args = $#ARGV + 1;

if ($num_args < 1) {
    print "Specify one or more input files\n";
    exit;
} else {
    my $outfile=$outdir . "anchor-" . $lang1 . $lang2 . ".txt";

    my @languages=("eng", "nob", "sme", "fin", "smj", "sma" );
    my %langs;

    open (FH2, ">$outfile") or die "Could not open $outfile";
    print "Generating anchor word list to $outfile ...\n";

    foreach my $infile (@ARGV) {
        print "infile $infile\n";
        open (FH, "<$infile") or die "ERROR: Could not open $infile";

        while(<FH>) {

            chomp;
            next if (/^\#/);
            next if (/^\&/);
            my @words = split("/");
            for my $lang (@languages) {
                if (@words) { 
                    my $word = shift @words;
                    $word =~ s/^\s+//;
                    $word =~ s/\s+$//;
                    $langs{$lang} = $word;
                }
            }
            if ($langs{$lang1} && $langs{$lang2}) {
                print FH2 $langs{$lang1}, " / ", $langs{$lang2}, "\n";
            }	
            
        }
    
        close FH;        
        
    }

    close FH2;
}

sub print_usage {
	
	print << 'END' ;
Usage: generate-anchor-list.pl --lang1=lg1 --lang2=lg2 FILE

Generate paired list of anchor words from file FILE which
contains the anchor words for different languages.
The output is printed to file anchor-lg1lg2.txt

Options:
       	--lang1=lg1       First language in the word list.
       	--lang2=lg2       Second language in the word list.
       	--outdir=<dir>    The output directory.
       	--help            Print this help text and exit.
END
}
 
