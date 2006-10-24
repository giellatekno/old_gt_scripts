#!/usr/bin/perl -w
use IO::Socket;
use Getopt::Long;

use strict;

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
			"help" => \$help);

if ($help) {
	&print_help;
	exit 1;
}

my $remote = IO::Socket::INET->new(
								Proto    => "tcp",
								PeerAddr => "victorio.uit.no",
								PeerPort => "8080",
								)
	or die "cannot connect to daytime port at localhost";

$remote->autoflush(1);

my $welcome = <$remote>;
print $welcome;

my $msg;
if( $preprocess | $analyze | $generate | $hyphenate |$disamb|$paradigm) {
	print $remote "$preprocess,$analyze,$generate,$hyphenate,$disamb,$paradigm\n";
}
else {
	print $remote "0,1,0,0,0,0\n";
}

while (! $language ) {
	print "Select language (sme, smj, sma)\n";
	$language = <STDIN>;
	if ($language !~ /sme|smj|sma/) { $language=undef; }
}

print $remote "$language\n";
$msg=<$remote>;
print $msg;

while ($fst && ! -f $fst) {
	print "$fst is not readable, give another one.\n";
	$fst = <STDIN>;
}

if (! $fst) { print $remote "\n"; }
else { print $remote "$fst\n"; }
$msg=<$remote>;
print $msg;

if ($disamb) {
	while ($rle && ! -f $rle) {
		print "$rle is not readable, give another one.\n";
		$rle = <STDIN>;
	}
	if (! $rle) { print $remote "\n"; }
	else { print $remote "$rle\n"; }
	$msg=<$remote>;
	print $msg;
}

while(<$remote>) {
	print;

	my $anl = <STDIN>;
	if (/quit|exit/) {
		print $remote $anl;
		exit;
	}
	print $remote $anl;
	my $line = <$remote>;
	while ($anl !~ /quit|exit/ && $line !~ /end/) {
		print $line;
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

	
