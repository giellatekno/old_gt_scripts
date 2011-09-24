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
#print STDERR "*** Word decoded is: $baseform\n";

chop (@codes  = <TAGFILE>);

foreach $code (@codes) {
	print "$baseform$code\n";
	print "$baseform\+v1$code\n";
	print "$baseform\+v2$code\n";
}

close TAGFILE;

