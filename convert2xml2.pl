#!/usr/bin/perl

use strict;
use Cwd;
use Encode;
use utf8;
use langTools::Converter;
use Getopt::Long;
use File::Find;

my $counter = 0;
my $errors = 0;

my $debug = 0;
GetOptions ("debug" => \$debug);

main(\@ARGV, $debug);

sub main {
	my ($ref_to_argv, $debug) = @_;
	my $numArgs = $#{$ref_to_argv} + 1;
	print "thanks, you gave me $numArgs files to process:\n";
	my $filename = "problematic_files.txt";
	open (FILE, ">>:encoding(utf8)", $filename );
	foreach my $argnum (0 .. $#{$ref_to_argv}) {
		my $tmp = ${$ref_to_argv}[$argnum];
		if ( -d $tmp ) {
			File::Find::find( \&convertdoc2, $tmp );
		} else {
			convertdoc($tmp);
		}
	}
	print " $counter \nProcessing finished\n";
	print "$counter files processed, $errors errors among them\n\n";
	close (FILE);
}
sub convertdoc2 {
	my ($tmp) = Cwd::abs_path($_);
	convertdoc($tmp);
}

sub convertdoc {
	my ($filename) = Cwd::abs_path(@_);
	my $error = 0;

	if (! ($filename =~ /(\.xsl$|\/\.svn)/ || -d $filename) ) {
		print "«$filename»\n";

		$counter++;
		my $converter = langTools::Converter->new($filename, $debug);
		
		if ($converter->makeXslFile()) {
			print FILE "Couldn't use " . $converter->getOrig() . ".xsl\n";
			$error = 1;
		} elsif ($converter->convert2intermediatexml()) {
			print FILE "Couldn't convert " . $converter->getOrig() . " to intermediate xml format\n";
			$error = 1;
		} elsif ($converter->convert2xml()) {
			print FILE "Couldn't combine " . $converter->getOrig() . " and " . $converter->getOrig() . ".xsl\n";
			$error = 1;
		} elsif ($converter->checklang()) {
			print FILE "Couldn't set the lang of " . $converter->getOrig() . "\n";
			$error = 1;
		} elsif ($converter->checkxml()) {
			print FILE "Wasn't able to make valid xml out of " . $converter->getOrig() . "\n";
			$error = 1;
		} elsif ($converter->character_encoding()) {
			print FILE "Wasn't able to set correct encoding of " . $converter->getOrig() . "\n";
			$error = 1;
		} elsif ($converter->search_for_faulty_characters()) {
			print FILE "Found faulty chars in " . $converter->getOrig() . "\n";
			$error = 1;
		} elsif ($converter->checkxml()) {
			print FILE "Wasn't able to make valid xml out of " . $converter->getOrig() . "\n";
			$error = 1;
		} else {
			$converter->move_int_to_converted();
			if (! $debug ) {
				$converter->remove_temp_files();
			}
		}
		
		if ($error) {
			print "|";
			$errors++;
		} else {
			print ".";
		}
		unless ( $counter % 50) {
			print " $counter\n";
		}
	}
}
