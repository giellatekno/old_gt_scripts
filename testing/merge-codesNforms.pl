#!/usr/bin/perl -w
#
# Purpose:
#
# To create a base file for making test cases by combining a tag list
# and a word form list. This way we only have to write the tag list once
# for each POS.
#
#	ARG1:	input file with inflectional tags
#	ARG2:	input file with inflected word forms, in the same order as the tags
#
# Output file:
#
# Field 1: the baseform of the word
# Field 2: a morphological tag
# Field 3: the word form(s) corresponding to the tag; in the case of
#          two or more alternative word forms, they are separated by
#          a comma ONLY (no space).
#
# This created file serves as input for further scripts creating test cases.
#
# Author: Sjur N. Moshagen
# Date:		$d
# Version:	$i

if (($file1, $file2) = @ARGV) {
	open (TAGFILE,   $file1) or die "Can't find file $file1: $!\n";
	open (WFORMFILE, $file2) or die "Can't find file $file2: $!\n";
} else {
	die "Too many files in input.\n";
}

chop (@codes  = <TAGFILE>);
chop (@wforms = <WFORMFILE>);

if (scalar(@codes) == scalar(@wforms )) {
	$baseform = $wforms[0];
	$i = 0;
	foreach $code (@codes) {
		print "$baseform\t$code\t$wforms[$i]\n";
		$i++;
	}
} else {
	print "Not the same numbers (of lines) of tags as wordforms!!!\n";
	print "Check both $file1 and $file2 for errors!!!\n";
	exit;
}

close TAGFILE;
close WFORMFILE;

