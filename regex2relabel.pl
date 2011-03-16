#!/usr/bin/env perl -w
while (<>) {
  chomp;
  my ($target,$operator,$source)=split / /;
  $source =~ s/[,;%]//g;
  $target =~ s/^0$/@ 0@/;
  $target =~ s/[ %]//;
  print "$source\t$target\n";
}