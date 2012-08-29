#!/usr/bin/perl -w
#
# Purpose:
#
# To create a file for testing paradigm generation by combining a tag list
# and a word (supposedly the base form).
#
#	ARG1:	input file with inflectional tags
#	ARG2:	the base form of the word we want to inflect
#
# Output file:
#
#	Baseform+tags for all tags given in the tag file
#	This can directly be given to xfst for word form generation
#
# Author: Sjur N. Moshagen
# Date:		$d
# Version:	$i

use utf8;
use Encode;

$baseform = "";
if (($file, $baseform) = @ARGV) {
	open (TAGFILE,   $file) or die "Can't find file $file: $!\n";
} else {
	print "Too many arguments in input! Usage is:\n";
	print "merge-codesNword.pl <FileWithCodes> <WordToInflect>.\n";
}

# print STDERR "Baseform: '$baseform'\n";
if ($baseform eq "") {
	print STDERR "*** Word to inflect not specified!\n";
	die "*** Please type: make n-para WORD=wordToInflect\n";
}

# The input string is interpreted as Latin1 although it is UTF-8, thus
# we decode it to get it right:
$baseform = Encode::decode_utf8($baseform);
print STDERR "*** Word decoded is: $baseform\n";

chop (@codes  = <TAGFILE>);

foreach $code (@codes) {
	print "$baseform$code\n";
# The following two lines are to add automatically v1, v2 tags to
# all codes in a code file. This is needed for lemmata such as tunealla in sme.
# This is not enough: there was not explicit requirement of v_n tag of different length,
# yet this is apparently the case. This should be solved in a different way, the more
# it strongly resembles the hid attribute used for smanob.

# These +v1 etc. tags shall be parametrized for use by dict only (separate folder)
# or eventually via the …not-dict fst.
# Todo: Flags in testing/Makefile for using different fst-s.

#	print "$baseform\+v1$code\n";
#	print "$baseform\+v2$code\n";
#	print "$baseform\+v3$code\n";
#	print "$baseform\+v4$code\n";
#	print "$baseform\+v5$code\n";
}

close TAGFILE;

