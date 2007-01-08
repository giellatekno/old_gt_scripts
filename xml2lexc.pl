#!/usr/bin/perl -w
use strict;

# Perl script for converting xml files to lexc format.
#
# Usage:
# xml2lexc.pl --output=propernoun-sme-lex.txt terms-sme.xml
#
# $Id$

# use Perl module XML::Twig for XML-handling
# http://www.xmltwig.com/
use XML::Twig;

# permit named arguments
use Getopt::Long;

my $output;  #e.g. propernoun-sme-lex.txt
my $help = '';

GetOptions ("output=s" => \$output,
			"help" => \$help,
			);
if ($help) {
	print_help();
	exit 1;
}

my $xml_file;
if ( -f $ARGV[$#ARGV]) { $xml_file = $ARGV[$#ARGV];  }
else { die "Error: no xml-file given\n"; }
if (!$output) { print "No output file specified.\n"; $output = "out.tmp"; }
else { print "Writing to $output..\n"; }

open (FH, ">$output");

# Print start definitions.
print_start($xml_file);

# Create an XML tree for the lexicon
my $twig = XML::Twig->new(
						  TwigHandlers => {
							  entry => sub { generate_lexc(@_); $_->delete; },}
						  );
# Parse the xml-file
if (! $twig->safe_parsefile("$xml_file")) {
	die "Error: parsing the XML-file $xml_file failed: $@\n"; 
}
$twig->purge;


sub generate_lexc {
	my($twig, $entry) = @_;	

	# Get the values of the fields.
	my $lemma_text="";
	if ($entry->{'att'}{'id'}) {
		$lemma_text = $entry->{'att'}{'id'};
	}
	else { die "No id for entry\n"; }
	my $stem_text="";
	if ($entry->first_child('stem')) {
		$stem_text = $entry->first_child( 'stem')->text;
		$stem_text =~ s/\s*$//g;
	}
	my $lexc_text = "";
	if (my $infl = $entry->first_child('infl')) {
		$lexc_text = $infl->{'att'}->{'lexc'};
	}

	if ($stem_text) { print FH "$lemma_text:$stem_text $lexc_text \;\n"; }
	else { print FH "$lemma_text $lexc_text \;\n"; }
}


sub print_start{

	my ($xml_file) = @_;
	
	print FH <<END;
! ==========================================================================
!                     Proper noun lexicon                           
! ========================================================================== 
! Automatically generated from $xml_file by script xml2lexc.pl
! DO NOT EDIT!


LEXICON ProperNoun

END
}


sub print_help {
	print <<END;
Usage: xml2lexc.pl [OPTIONS] FILE
The available options:
    --output=<file> name of the lexicon file
    --help          this help and exit
END
};


