#!/usr/bin/perl -w
use IO::Socket;
use Getopt::Long;

use strict;

# use xml parser in parameter list.
use XML::Twig;

# Simple command-line client for the server that does the analysis.
#
# Usage: client_anl.pl [OPTIONS]
#

my $language="sme";
my $analyze=0;
my $generate=0;
my $hyphenate=0;
my $preprocess=0;
my $disamb=0;
my $paradigm=0;
my $help;
my $fst;
my $rle;
my $xml=0;
my $param;
#my $PORT=9000;
my $PORT=8080;

# Allow combination of options, -pad
Getopt::Long::Configure ("bundling");
GetOptions ("lang|l=s" => \$language,
			"analyze|a" => \$analyze,
			"hyphenate|y" => \$hyphenate,
			"generate|g" => \$generate,
			"paradigm|r" => \$paradigm,
			"preprocess|p" => \$preprocess,
			"disamb|d" => \$disamb,
			"fst=s" => \$fst,
			"rle=s" => \$rle,
			"xml|x" => \$xml,
			"param=s" => \$param,
			"help" => \$help);

if ($help) {
	&print_help;
	exit 1;
}

my $remote = IO::Socket::INET->new(
								Proto    => "tcp",
								PeerAddr => "victorio.uit.no",
								PeerPort => $PORT,
								)
	or die "cannot connect to port 8080 at localhost";

$remote->autoflush(1);

my $welcome = <$remote>;
print $welcome;

# Read processing instructions from file.
my $parameters;

$param="/home/saara/gt/script/paras.xml";
if ($param) {
	open (FH, "<$param");
	while(<FH>) {
		$parameters .= $_;
	}
}

print $remote "$parameters";

# Take the confirmation of parameters, and possible error.
my $msg = <$remote>;
if ($msg =~ /ERROR/) { print STDERR $msg; exit; }

while(<STDIN>) {

	if (/quit|exit/) {
		print $remote "END_CLIENT\n";
		exit;
	}

	print $remote "$_";

	my $line = <$remote>;
	while ($line && $line !~ /END_REPLY/) {
		print "$line";
		$line = <$remote>;
	}
}

sub print_help {
	print << "END";
Usage: client_anl.pl [OPTIONS]
Call the analysis server and communicate with it. 
The available options:
    --help            Print this help text and exit.
    --lang=<lang>     Set language to <lang>.
    -l lang
    --analyze         Start the lookup-tool for analysis.
    -a      
    --hyphenate       Start the lookup-tool for hyphenation.
    -y      
    --generate        Start the lookup-tool for generation.
    -g      
    --paradigm        Start the lookup-tool for paradigm generation.
    -r      
    --preprocess      Preprocess all the input strings.
    -p
    --fst=<file>      Complete path to the lang.fst. The default is
                      the fst in opt-hierarchy.
END
}

	
