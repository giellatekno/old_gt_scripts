#!/usr/bin/perl -w 
#
# Script for reading a plain-text input file,
# and produce one file with PLX (Polderland format) entries,
# and another file with spelling rules that triggers the display
# of the version info on a given trigger string.
#
# See sme/polderland/version*.txt for the target output formats
#
# $Id$

use strict;
use utf8;
use Getopt::Long;

my $lang = 'sme';
my $rel = 'beta1';
my $infile  ="common/polderland/version.txt";
my $plxfile = $lang . "/polderland/version-" . $lang . "-plx.txt";
my $phonfile= $lang . "/polderland/version-" . $lang . "-phon.txt";
my $help;

GetOptions ("lang=s" => \$lang,
			"rel=s" => \$rel,
			"infile=s" => \$infile,
			"plxfile=s" => \$plxfile,
			"phonfile=s" => \$phonfile,
			"help" => \$help);

if ($help) {
	&print_help;
	exit 1;
}


#open $infile or die "$infile: Could not open the file!\n";

my $time = `date +%Y-%m-%d`;

print $time;

sub print_help {
	print"Usage: convert-speller-version-info.pl [OPTIONS] [FILES]\n";
	print "The available options:\n";
	print"    --lang=<LANG>     The target language of the make command.\n";
    print"                      It corresponds to the TARGET make variable.\n";
    print"    --rel=<release>   The release string.\n";
    print"    --infile=<file>   The input data file.\n";
    print"    --plxfile=<file>  The PLX-formated output file.\n";
    print"    --phonfile=<file> The suggestion rules file.\n";
    print"    --help            Print this message and exit.\n";
};
