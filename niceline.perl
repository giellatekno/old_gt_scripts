#!/usr/bin/perl

my ($bindir) = $0 =~ /^(.*)\/.*/;

eval(require "$bindir/niceline.perl.subs");
if ($@) {
    print "Couldn't load niceline.perl.subs!\n";
    return -1;
}

while(<STDIN>) {
    print Niceline($_);
}
