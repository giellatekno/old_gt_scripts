#!/usr/bin/perl

# Perl script for converting filenames to NFC (precomposed unicode characters).
# Used in fixing decomposed unicode characters (NFD) produced by mac.
# Files are given to the script via STDIN.

use strict;
use utf8;

use File::Spec;

use Unicode::Normalize;

while(<>) {

	chomp;
    my $file = File::Spec->rel2abs($_);
	if ( -e "$_" ) {
#		print "Fixing $file..\n";
#		my $newname = NFC($file);  # Normalization Form C

		my $newname = 
		if ( "$file" ne "$newname" ) {
			if ( -e $newname ) {
				print "Cannot move $file:  $newname exists already\n";
				next;
			}
			print "mv $file $newname\n";
			my @args=("mv", "$file", "$newname");
#			system(@args) == 0
#				or print "Cannot move $file: $!";
		}
	}
}
