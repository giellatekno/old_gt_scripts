#!/usr/bin/perl

# From http://beta.visl.sdu.dk/cg3_howto.pdf:
# "condenses VISLCG3 output to one-line cohorts"
# Also does some reformatting.

# $bindir = dir of niceline.pl
my ($bindir) = $0 =~ /^(.*)\/.*/;

eval(require "$bindir/niceline.subs.pl");
if ($@) {
    print "Couldn't load niceline.subs.pl!\n";
    return -1;
}

while(<>) {
    print Niceline($_);
}
