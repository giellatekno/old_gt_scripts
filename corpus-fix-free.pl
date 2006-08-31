#!/usr/bin/perl
#
# Script for going through corpus files and removing
# non-free files from free-catalog. The script shouldn't be needed,
# since there are routines in convert2xml.pl to handle the directories.
# $Id$

use strict;
#use open ':locale';
#binmode STDOUT, ":utf8";
use XML::Twig;

my $corpdir="/usr/local/share/corp/bound/sme/facta";
#my $corpdir="/home/saara/samipdf/free";

my $files=`find $corpdir -type f  -name \"*.xml\"`;
my @file_a = split ("\n", $files);

my $rem_file="remove_non_free.sh";
open FH, $rem_file;

for my $file (@file_a) {
	print "$file\n";
	(my $freefile = $file) =~ s/\/bound/\/free/;
	next if (! -f $freefile);
	my $document = XML::Twig->new;
	if (! $document->safe_parsefile("$file")) {
		my $command = "rm -rf \"$freefile\"";
		print FH "$command\n";
		print STDERR "$file: Parsing the XML-file failed: $@\n";
		next;
	}

	my $license = "license";
	my $root = $document->root;
	my $header = $root->first_child('header');
	my $avail = $header->first_child('availability');
	$license = $avail->first_child->local_name;

	if ( $license !~ /free/ ) {
		print "$file: non free\n";
		my $command = "rm -rf \"$freefile\"";
		print FH "$command\n";
	}
}
close FH;
