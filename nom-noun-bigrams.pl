#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

use utf8;

# nom-noun-bigrams
# Perl-script for extracting pairs of nominative noun candidates.
# Outputs such pairs. No disambiguation is assumed, only the presence
# of a nominative tag in one of the analyses of the first word, and a
# noun (and adjective?) tag in one of the analyses of the second word.
#
# Input: 
# Dan     dat+Pron+Dem+Sg+Acc
# Dan     dat+Pron+Dem+Sg+Gen
#
# Output:
# "<Dan>"
#        "dat" Pron Dem Sg Acc
#        "dat" Pron Dem Sg Gen

$/ = "";
my $nomWord = "";
my $prevNomWord = "";

# Read while not eol
while(<>) {

    $prevNomWord = $nomWord;
    $nomWord = "";

    my $input = $_;
    my @lines = split(/\n/, $input);

    foreach my $line (@lines)  {

        my ($word, $analysis) = split(/\t/, $line);

        if ($analysis =~ /\+Nom/) {
            $nomWord = $word;
        }
        
        if (($analysis =~ /\+A\+/ || $analysis =~ /\+N\+/) && $prevNomWord ne "") {
            print "$prevNomWord $word\n";
            $prevNomWord = "";
        }
    }
}
