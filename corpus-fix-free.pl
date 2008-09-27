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

use Getopt::Long;

my $corpdir="/usr/local/share/corp/";
my $lang="sme";
my $rem_file="remove_non_free.sh";

GetOptions ("corpdir=s" => \$corpdir,
			"lang=s" => \$lang,
			"rem_file=s" => \$rem_file,
			);

my $freedir="$corpdir/free/$lang";

my $files=`find $freedir -type f  -name \"*.xml\"`;
my @file_a = split ("\n", $files);

open FH, ">$rem_file";

print "Going through files in free-catalog.\n";
print "Printing commands to file: $rem_file\n";

for my $file (@file_a) {
	(my $boundfile = $file) =~ s/\/free/\/bound/;

	(my $origfile = $file) =~ s/\/free/\/orig/;
	$origfile =~ s/\.xml//;
	if (! -f $origfile) {
		print "$file: missing original file\n";
		my $command = "rm -rf \"$file\"";
		print FH "$command\n";
		next;
	}
	my $document = XML::Twig->new;
	if (! $document->safe_parsefile("$file")) {
		my $command = "rm -rf \"$file\"";
		print FH "$command\n";
		print "$file: Parsing the XML-file failed: $@\n";
		next;
	}

	my $license = "license";
	my $root = $document->root;
	my $header = $root->first_child('header');
	my $avail = $header->first_child('availability');
	$license = $avail->first_child->local_name;

	if ( $license !~ /free/ ) {
		print "$file: non free\n";
		my $command = "rm -rf \"$file\"";
		print FH "$command\n";
		next;
	}
}


close FH;
