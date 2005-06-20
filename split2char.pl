#!/usr/bin/perl -w

#use bytes;  # non-UTF8-safe
use utf8; # UTF8-safe
            # Use one of them

while ($line = <>) {
    $line =~ s//\n/g;
    print $line;
}
