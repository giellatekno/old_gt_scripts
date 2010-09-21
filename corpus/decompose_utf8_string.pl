#!/usr/bin/perl

use strict;
use utf8;
use Unicode::Normalize;

while(<>) {
        print NFD($_);
}