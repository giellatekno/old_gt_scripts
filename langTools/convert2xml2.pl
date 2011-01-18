#!/usr/bin/perl

use strict;
use Cwd;
use Encode;
use utf8;
use langTools::Converter;


my $numArgs = $#ARGV + 1;
print "thanks, you gave me $numArgs command-line arguments:\n";
	open (FH, ">problematic_files.txt");

foreach my $argnum (0 .. $#ARGV) {
	
	if (convertdoc($ARGV[$argnum])) {
		print FH "$ARGV[$argnum]\n";
		print "|";
	} else {
		print ".";
	}
}
print "\n";
close (FH);

sub convertdoc {
	my( $filename ) = @_;
	my $error = 0;
	my $converter = langTools::Converter->new($filename);
	
	
	$filename = Encode::decode_utf8($filename);
	if ($converter->makeXslFile()) {
		print FH "Couldn't use $filename.xsl\n";
		$error = 1;
	} elsif ($converter->convert2intermediatexml()) {
		print FH "Couldn't convert $filename to intermediate xml format\n";
		$error = 1;
	} elsif ($converter->convert2xml()) {
		print FH "Couldn't combine $filename and $filename.xsl\n";
		$error = 1;
	} elsif ($converter->checklang()) {
		print FH "Couldn't set the lang of $filename\n";
		$error = 1;
	} elsif ($converter->checkxml()) {
		print FH "Wasn't able to make valid xml out of $filename\n";
		$error = 1;
	} elsif ($converter->character_encoding()) {
		print FH "Wasn't able to set correct encoding of $filename\n";
		$error = 1;
	} else {
		if (search_for_faulty_characters($converter->getInt())) {
			print FH "Found faulty chars in $filename\n";
			$error = 1;
		}
	}
	return $error;
}

sub search_for_faulty_characters {
	my( $filename ) = @_;
	
	my $error = 0;
	my $lineno = 0;
# 	print "opening $filename\n";
	if( !open (FH, "<:encoding(utf8)", $filename )) {
		print "Cannot open $filename\n";
		$error = 1;
	} else {
		while (<FH>) {
			$lineno++;
			# We are looking for (¥ª|Ω|π|∏ , but since we are running perl with
			# PERL_UNICODE=, we have to write the utf8 versions of them literally. 
			# If not, then lots of «Malformed UTF-8 character» will be spewed out.
			if ( $_ =~ m/(\xC2\xA5|\xC2\xAA|Ω|\xCF\x80|\xE2\x88\x8F)/) { 
				print "Failed at line: $lineno with line\n$_\n";
				$error = 1;
				last;
			}
		}
	}
	close(FH);
	return $error;
}
