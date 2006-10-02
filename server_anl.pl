#!/usr/bin/perl -w
use strict;
use IO::Socket;
use Net::hostent; # for OO version of gethostbyaddr
use POSIX qw(:sys_wait_h);

# Module to communicate with program's user interfaces
use Expect;

my $PORT = 9000; # pick something not in use

my $lookup="lookup";
my $language;
my $fst;

my $server = IO::Socket::INET->new( Proto     => 'tcp',
								 LocalPort => $PORT,
								 Listen    => SOMAXCONN,
								 Reuse     => 1);

die "can't setup server" unless $server;
print "[Server $0 accepting clients]\n";

my $client;
while ($client = $server->accept()) {
	my $child = fork;
	if (!defined($child)) { warn "ERROR: Couldn't fork a process: $!\n"; } 
	if ($child) {
		# fork returned 0 nor undef
		# so this branch is parent
		close($client);
		next;
	}
	# otherwise serve the client.
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
					$exp_anl->expect(undef, '-re', '\r?\n\r?\n' );
					
					my $read_anl = $exp_anl->before();
					
					print $client "$read_anl\n\n";
				}
				else { print $client $r; }
			}
			print $client "end\n";
			print $client "String? \n";
		}
		print "client exiting..\n";
		close($client);

		# if no longer needed, do a soft_close to nicely shut down the command
		if($anl) { $exp_anl->soft_close(); }

	# exit the child
	exit 0;

exit;
}

close $server;
exit 0;

# remove dead children from the defunct list.
$SIG{CHLD} = sub {
	my $pid;
	do {
		$pid = waitpid -1, WNOHANG;
	} until $pid == -1;
};

# close connection and exit if timeout
$SIG{ALARM} = sub {
	warn "ERROR: Connection timed out\n";
	close($client) if defined $client;
	exit 1;
};

