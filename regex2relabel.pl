#!/usr/bin/env perl

use warnings;

while (<>) {
  chomp;
  my ($target,$operator,$source)=split / /;
  $source =~ s/[,;%]//g;
  $target =~ s/^0$/\@_EPSILON_SYMBOL_@/;
  $target =~ s/[ %]//;
  print "$source\t$target\n";
}