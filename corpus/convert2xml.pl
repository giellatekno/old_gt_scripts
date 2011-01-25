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
	print "Processing files\n";
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
}

sub convertdoc2 {
	my ($tmp) = Cwd::abs_path($_);
	convertdoc($tmp);
}

sub convertdoc {
	my ($filename) = Cwd::abs_path(@_);
	my $error = 0;
	my $feedback;

	if (! ($filename =~ /(\.xsl$|\/\.svn|.DS_Store|.tmp$)/ || -d $filename) ) {
		
		$counter++;
		my $converter = langTools::Converter->new($filename, $debug);
		$converter->redirect_stderr_to_log();
		print STDERR "«\n\n$filename»\n";
		if ($converter->makeXslFile()) {
			print STDERR "Conversion failed: Couldn't use " . $converter->getOrig() . ".xsl\n";
			$error = 1;
		} elsif ($converter->convert2intermediatexml()) {
			print STDERR "Conversion failed: Couldn't convert " . $converter->getOrig() . " to intermediate xml format\n";
			$error = 1;
		} elsif ($converter->convert2xml()) {
			print STDERR "Conversion failed: Couldn't combine " . $converter->getOrig() . " and " . $converter->getOrig() . ".xsl\n";
			$error = 1;
		} elsif ($converter->checklang()) {
			print STDERR "Conversion failed: Couldn't set the lang of " . $converter->getOrig() . "\n";
			$error = 1;
		} elsif ($converter->checkxml()) {
			print STDERR "Conversion failed: Wasn't able to make valid xml out of " . $converter->getOrig() . "\n";
			$error = 1;
		} elsif ($converter->character_encoding()) {
			print STDERR "Conversion failed: Wasn't able to set correct encoding of " . $converter->getOrig() . "\n";
			$error = 1;
		} elsif ($converter->search_for_faulty_characters()) {
			print STDERR "Conversion failed: Found faulty chars in " . $converter->getOrig() . "\n";
			$error = 1;
		} elsif ($converter->checkxml()) {
			print STDERR "Conversion failed: Wasn't able to make valid xml out of " . $converter->getOrig() . "\n";
			$error = 1;
		} else {
			$converter->move_int_to_converted();
			if (! $debug ) {
				$converter->remove_temp_files();
			}
		}
		
		
		if ($error) {
			$feedback = "|";
			$errors++;
		} else {
			$feedback = ".";
		}
		
		unless ($converter->get_debug()) {
			print $feedback;
			unless ( $counter % 50) {
				print " $counter\n";
			}
		}
	}
}

