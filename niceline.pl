#!/usr/bin/perl

# From http://beta.visl.sdu.dk/cg3_howto.pdf:
# condenses output to one-line cohorts

# NB! Presently this script is useless, since we are missing the *.subs file.
# Sjur has written to Eckhard Bick and asked about getting the missing parts.

# $bindir = dir of niceline.pl
my ($bindir) = $0 =~ /^(.*)\/.*/;

eval(require "$bindir/niceline.pl.subs");
if ($@) {
    print "Couldn't load niceline.pl.subs!\n";
    return -1;
}

while(<>) {
    print Niceline($_);
}
