#!/usr/bin/perl -w

use strict;

# This script reads line by line, changes all a1's to 0xE1 etc.
# and finally prints the modified line

while (<STDIN>)
{
    s/a1/\xE1/g;
    s/c1/\xE8/g;
    s/d1/\xF0/g;
    s/n1/\xBf/g;
    s/s1/\xB9/g;
    s/t1/\xBC/g;
    s/z1/\xBE/g;
    print;
}

