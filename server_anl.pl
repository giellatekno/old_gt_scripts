#!/usr/bin/perl -w
use strict;
use IO::Socket;
use Net::hostent; # for OO version of gethostbyaddr

use Expect;

my $PORT = 9000;# pick something not in use

my $server = IO::Socket::INET->new( Proto     => 'tcp',
								 LocalPort => $PORT,
								 Listen    => SOMAXCONN,
								 Reuse     => 1);

die "can't setup server" unless $server;
print "[Server $0 accepting clients]\n";

my $lookup="lookup";
my $language;
my $fst;
my $timeout=0.15;

while (my $client = $server->accept()) {
	$client->autoflush(1);
	print $client "Welcome to $0;\n";
	my $hostinfo = gethostbyaddr($client->peeraddr);
	printf "[Connect from %s]\n", $hostinfo ? $hostinfo->name : $client->peerhost;

	my $action=<$client>;
	my ($prep, $anl)=split(",", $action);

	my $language=<$client>;
	chomp $language;
	print "Setting language to $language.\n";
	print $client "Setting language to $language.\n";

	my $fst=<$client>;
	chomp $fst;
	if(! $fst || $fst =~ /^\s*$/ ) { $fst="/opt/smi/$language/bin/$language.fst"; }	
	print "Using fst: $fst.\n";
	print $client "Using fst: $fst\n";

	my $analyze = "$lookup -flags mbTT -utf8  $fst";
	my $preprocess = "preprocess --abbr=/opt/smi/$language/bin/abbr.txt";

    # create an Expect object by spawning another process
	my $exp_anl;
	if($anl) {
		$exp_anl = Expect->spawn($analyze)
			or die "Cannot spawn $analyze: $!\n";
		$exp_anl->log_stdout(0);
	}

	print $client "String?\n";
	while ( <$client>) {
		last if (/quit/);

		my @input;
		my @results;
		if($prep) {
			my $result = `echo \"$_\" | $preprocess`;
			@input = split(/\n/, $result);
		}
		else { push (@input, $_); }
		for my $r (@input) {
			if($anl) {
				# send some string there:
				$exp_anl->send("$r\n");
				$exp_anl->expect($timeout);
				
				my $read_anl = $exp_anl->clear_accum();
				print $client $read_anl;
			}
			else { print $client $r; }
		}
		print $client "end\n";
		print $client "String? \n";
	}
	print "client exiting..\n";
    # if no longer needed, do a soft_close to nicely shut down the command
	if($anl) { $exp_anl->soft_close(); }
	exit;
}
