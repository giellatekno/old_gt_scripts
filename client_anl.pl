#!/usr/bin/perl -w
use IO::Socket;
use Getopt::Long;

# Simple command-line client for the server that does the analysis.
#
# Usage: client_anl.pl [OPTIONS]
#

my $language="sme";
my $analyze=0;
my $preprocess=0;
my $disamb=0;
my $help;
my $fst;

# Allow combination of options, -pad
Getopt::Long::Configure ("bundling");
GetOptions ("lang|l=s" => \$language,
			"analyze|a" => \$analyze,
			"preprocess|p" => \$preprocess,
			"fst=s" => \$fst,
			"help" => \$help);

if ($help) {
	&print_help;
	exit 1;
}

$remote = IO::Socket::INET->new(
								Proto    => "tcp",
								PeerAddr => "victorio.uit.no",
								PeerPort => "9000",
								)
	or die "cannot connect to daytime port at localhost";

$remote->autoflush(1);

my $welcome = <$remote>;
print $welcome;

my $msg;
if( $preprocess | $analyze ) {
	print $remote "$preprocess,$analyze\n";
}
else {
#	print "Select preprocess,analyze\n";
#	my $action = <STDIN>;
#	while ($action !~ /analyze|preprocess/) {
#		print "Select preprocess,analyze\n";
#	}
#	if($action =~ /preprocess/) { $preprocess=1; }
#	if($action =~ /analyze/) { $analyze=1; }
	print $remote "0,1\n";
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
	print "fst is not readable, give new one or newline\n";
	$fst = <STDIN>;
}

if (! $fst) { print $remote "\n"; }
else { print $remote "$fst\n"; }
$msg=<$remote>;
print $msg;

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
    --preprocess      Preprocess all the input strings.
    -p
    --fst=<file>      Complete path to the lang.fst. The default is
                      the fst in opt-hierarchy.
END
}

	
