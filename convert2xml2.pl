#!/usr/bin/perl

use strict;
use Cwd;
use Encode;
use utf8;
use langTools::Converter;
use Getopt::Long;

my $counter = 0;
my $errors = 0;
my $debug = 0;
GetOptions ("debug" => \$debug);

my $numArgs = $#ARGV + 1;
print "thanks, you gave me $numArgs files to process:\n";
my $filename = "problematic_files.txt";
open (FILE, ">>:encoding(utf8)", $filename );
foreach my $argnum (0 .. $#ARGV) {
	$counter++;

	if (convertdoc($ARGV[$argnum])) {
		print "|";
		$errors++;
	} else {
		print ".";
	}
	unless ( $counter % 50) {
		print " $counter\n";
	}
}
print "\n";
print FILE "$counter files processed, $errors errors among them\n\n";
close (FILE);

sub convertdoc {
	my( $filename ) = @_;
	my $error = 0;
	my $converter = langTools::Converter->new($filename, $debug);
	
	if ($converter->makeXslFile()) {
		print FILE "Couldn't use " . $self->getOrig() . ".xsl\n";
		$error = 1;
	} elsif ($converter->convert2intermediatexml()) {
		print FILE "Couldn't convert " . $self->getOrig() . " to intermediate xml format\n";
		$error = 1;
	} elsif ($converter->convert2xml()) {
		print FILE "Couldn't combine " . $self->getOrig() . " and " . $self->getOrig() . ".xsl\n";
		$error = 1;
	} elsif ($converter->checklang()) {
		print FILE "Couldn't set the lang of " . $self->getOrig() . "\n";
		$error = 1;
	} elsif ($converter->checkxml()) {
		print FILE "Wasn't able to make valid xml out of " . $self->getOrig() . "\n";
		$error = 1;
	} elsif ($converter->character_encoding()) {
		print FILE "Wasn't able to set correct encoding of " . $self->getOrig() . "\n";
		$error = 1;
	} elsif ($converter->search_for_faulty_characters()) {
		print FILE "Found faulty chars in " . $self->getOrig() . "\n";
		$error = 1;
	} elsif ($converter->checkxml()) {
		print FILE "Wasn't able to make valid xml out of " . $self->getOrig() . "\n";
		$error = 1;
	} else {
		$converter->move_int_to_converted();
	}
	return $error;
}
