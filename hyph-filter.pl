#!/usr/bin/perl -w

# Short script to removed hyphenated words that do not correspond to the input
# string, barring the hyphenation and word boundary marks.
# It removes ^# from the input hyphenated string, and compares with the original
# and then print out the hyphenated one if the comparison is true.

while (<>) {
  chomp;
  my ($orig, $hyph) = split (/\s+/);
  if ( $hyph ) {
    $cleaned = $hyph;
    $cleaned =~ s/[#^]//g;
    if ($orig eq $cleaned) {
      print "$hyph\n";
    }
  }
}
