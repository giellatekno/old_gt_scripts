#!/usr/bin/perl -w

use strict;
use open ':locale';
use Text::Brew qw(distance);

# This script reads line by line, and calculates the editing operations
# needed to get from spelling error to correct form
# The input is of type:
# error<TAB>correct form

while (<STDIN>)
{
    chomp;
    my ($err, $corr) = split (/\t/);
    if ($corr) {
        my ($distance,$arrayref_edits)=distance($err,$corr);
        my $sequence=join", ",@$arrayref_edits;
#       print "The Brew distance for ($err,$corr) is $distance\n";
#       print "obtained with the edits: $sequence\n\n";
        print "$distance\t$err\t$corr\t";
        print "($sequence)\n";
    }
}

