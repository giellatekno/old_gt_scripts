#!/usr/bin/perl
use strict;
use warnings;

use Encode qw( decode FB_QUIET );
use Getopt::Long;

binmode STDIN, ':bytes';
binmode STDOUT, ':encoding(UTF-8)';


my $out;
my $help;

GetOptions ("help" => \$help);

if ($help) {
	&print_help;
	exit 1;
}

while ( <> ) {
  $out = '';
  while ( length ) {
    # consume input string up to the first UTF-8 decode error
    $out .= decode( "utf-8", $_, FB_QUIET );
    # consume one character; all octets are valid Latin-1
    $out .= decode( "iso-8859-1", substr( $_, 0, 1 ), FB_QUIET ) if length;
  }
  print $out;
}  
  
sub print_help {
	print << 'END';
	
Usage: cat file | perl repair-utf8.pl | ...

The file repairs mixed Latin1 and UTF-8, turns everything into UTF-8
The code and the background for it is explained here:
http://plasmasturm.org/log/416/
END

  
  
}
