#!/usr/bin/perl

# Perl script for converting string to NFC (precomposed unicode characters).
# Used in fixing decomposed unicode characters (NFD) produced by mac.

use open ':locale';
binmode STDOUT, ":utf8";

use Unicode::Normalize;

while(<>) {

	$NFC_string  = NFC($_);  # Normalization Form C
	print $NFC_string;

}
