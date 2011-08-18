#!/usr/bin/perl -w
use strict;
use utf8;
binmode STDOUT;

# add-version-info.pl
#
# Perl-script for adding the variable part of the Polderland speller
# version info easter egg.
#
# The variant part is:
# Julevsáme, beta 0.2, 2007-04-14	WI
#
# And the corresponding replace rules:
# /$Julevsáme$ $,$ <=>nu/ twin
# /beta$ $0$.$2$,$ <=>vv/ twin
# /$2$0$0$7$-$-$0$4$-$-$1$4<=>i$D/ twin
#
# The language is taken from an input parameter ($(GTLANG) in the makefile)
# The version string is taken from a file
# The date string is taken from a system call.
#
# $Id$
# $Revision$

# permit named arguments
use Getopt::Long;

my $help;
my $language;
my $versionfile;
my $revisionfile;
my $plxfile;
my $phonfile;
my $langstring = "Davvisámi";

my $date;

GetOptions ("lang=s"     => \$language,
			"version=s"  => \$versionfile,
			"date=s"     => \$date,
			"revision=s" => \$revisionfile,
			"plxfile=s"  => \$plxfile,
			"phonfile=s" => \$phonfile,
			"help"       => \$help);

#chop $date; # needed?

if ($help) {
	&print_usage;
	exit;
}

# Create the language string based on the input lang code
if ( $language eq 'sme' ) {
	$langstring = "Davvisámi, ";
}
elsif ( $language eq 'smj' ) {
	$langstring = "Julevsáme, ";
}
elsif ( $language eq 'sma' ) {
	$langstring = "Åarjelsaemien, ";
}
else {
	$langstring = "No language, ";
}

# Read the version info from the specified file
open (FH, "$versionfile") or die "Cannot open $versionfile $!";
	my @version = <FH>;
close(FH);
chop @version;
my $versionstring = $version[0] . ", ";

# Read the revision info from the specified file
open (FH, "$revisionfile") or die "Cannot open $revisionfile $!";
	my @revision = <FH>;
close(FH);
chop @revision;
my $revisionstring = "--" . $revision[0] ;

# Build the final PLX entry:
my $plxstring =
	$langstring .
	$versionstring .
	$date .
	$revisionstring . "	WI" ;

# Escape each of the correction rule strings:
my $corrdate = &correscape($date);
my $corrlang = &correscape($langstring);
my $corrversion = &correscape($versionstring);
my $corrrevision = &correscape($revisionstring);

# Create the final correction rules:
my $corrlangstring     = "/".$corrlang."<=>nuvv/	twin" ;
my $corrversionstring  = "/".$corrversion."<=>i\$Ds/	twin" ;
my $corrdatestring     = "/".$corrdate."<=>pel/	twin" ;
my $corrrevisionstring = "/".$corrrevision."<=>ler/	twin" ;

# Print the PLX entry to a file:
open (FH, ">$plxfile") or die "Cannot open $plxfile $!";
	print FH $plxstring . "\n" ;
close(FH);

# Print the correction rules to another file:
open (FH, ">$phonfile") or die "Cannot open $phonfile $!";
	print FH $corrlangstring     . "\n" ;
	print FH $corrversionstring  . "\n" ;
	print FH $corrdatestring     . "\n" ;
	print FH $corrrevisionstring . "\n" ;
close(FH);

# Escape subroutine:
sub correscape {
    my ($string) = @_;
    $string =~ s/([^a-z])/\$$1/g;
    return $string;
}

sub print_usage {
	print "Usage: add-version-info.pl [OPTIONS] FILES\n";
	print "Creates version info for Polderland spellers.\n";
	print "Options\n";
	print "--lang            the language for which to make the version info.\n";
	print "--version=<file>  the version string file.\n";
	print "--date=DATE       the date string.\n";
	print "--revision=<file> the svn revision string file.\n";
    print "--plxfile=<file>  the output file for the plx entry.\n";
    print "--phonfile=<file> the output file for the correction rule.\n";
    print "--help            prints the help text and exit.\n";
}
