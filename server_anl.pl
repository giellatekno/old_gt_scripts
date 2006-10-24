#!/usr/bin/perl -w
use strict;
use IO::Socket;
use Net::hostent; # for OO version of gethostbyaddr
use POSIX qw(:sys_wait_h);

# Module to communicate with program's user interfaces
use Expect;

my $PORT = 8080; # pick something not in use

my $lookup="lookup";
my $language;
my $fst;
my $lookup2cg="/usr/local/bin/lookup2cg";
my $end_of_dis="\<\"¶\"\>\n\t\"¶\"";

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
	chomp $action;
	my ($prep, $anl, $gen, $hyph, $dis, $para)=split(",", $action);
#	print "$prep, $anl, $gen, $hyph, $dis, $para ok\n";
	last if(! ($prep || $anl || $gen || $hyph || $dis || $para));


	my $language=<$client>;
	chomp $language;
	print "Setting language to $language.\n";
	print $client "Setting language to $language.\n";
	
	my $fst=<$client>;
	chomp $fst;
	if(! $fst || $fst =~ /^\s*$/ ) { 
		if ($gen) {
			$fst="/opt/smi/$language/bin/i$language.fst";
		}
		elsif($hyph) {
			$fst="/opt/smi/$language/bin/hyph-$language.fst";
		}
		else {
			$fst="/opt/smi/$language/bin/$language.fst";

		}
	}	
	print "Using fst: $fst.\n";
	print $client "Using fst: $fst\n";
	
	my $rle; 
	if ($dis) {
		$rle = <$client>;
		chomp $rle;
		if(! $rle || $rle =~ /^\s*$/ ) { $rle="/opt/smi/$language/bin/$language-dis.rle"; }	
		print "Using rle: $rle.\n";
		print $client "Using rle: $rle\n";
	}

	my $analyze;
	if($anl ||$hyph) { $analyze="$lookup -flags mbTT -utf8  $fst 2>/dev/null"; }
	if ($gen) { $analyze = "$lookup -flags mbTT -utf8  -d $fst 2>/dev/null"; }
	my $preprocess = "preprocess --abbr=/opt/smi/$language/bin/abbr.txt";
#	print "$analyze\n";
	my $disamb;
	if ($dis) {
		$disamb = "vislcg --quiet --grammar=$rle";
	}
	# create an Expect object by spawning another process
	my $exp_anl;
	if($anl || $gen || $hyph) {
		$exp_anl = Expect->spawn($analyze)
			or die "Cannot spawn $analyze: $!\n";
		$exp_anl->log_stdout(0);
	}
	my $exp_dis;
	my $exp_lo2cg;
	if($dis) {
		$exp_dis = Expect->spawn($disamb)
			or die "Cannot spawn $disamb: $!\n";
		$exp_dis->log_stdout(0);
	}
	
	print $client "String?\n";
	while ( <$client>) {
		last if (/quit/);

		my @input;
		my @results;
		my @dis_strings;

		if($prep) {
            # Remove the unsecure characters from the input.
			$_ =~ s/[;<>\*\|`&\$!\#\(\)\[\]\{\}:'"]/ /g; 

			my $result = `echo \"$_\" | $preprocess`;
			@input = split(/\n/, $result);
		}
		else { @input = split(/\n/, $_); }
		
		for my $r (@input) {
			if($anl || $hyph || $gen) {
				# send some string there:
				$exp_anl->send("$r\n");
				$exp_anl->expect(undef, '-re', '\r?\n\r?\n' );
				
				my $read_anl = $exp_anl->before();

				# Take away the original input.
				$read_anl =~ s/^.*?\n//;

				if($dis) { 
					push (@dis_strings, $read_anl);
				}
				else { print $client "$read_anl\n\n"; }
			}
			else { print $client $r; }
		}
		if($dis) { 
#			for my $string (@dis_strings) {
#				my $result = `echo \"$string\n\n\" | $lookup2cg`;
#				$exp_dis->send("$result\n");
#			}
			print "$end_of_dis\n\n";
			$exp_dis->send("$end_of_dis\n\n"); 
			$exp_dis->expect(1);
			my $read_dis = $exp_dis->clear_accum();
#			$read_dis =~ s/^.*\"\x{00B6}\"\n//m;
			print $client "$read_dis\n\n";
		}

		print $client "end\n";
		print $client "String? \n";
	}
	print "client exiting..\n";
	close($client);
	
	# if no longer needed, do a soft_close to nicely shut down the command
	if($exp_anl) { $exp_anl->soft_close(); }
	
	# exit the child
	exit 0;
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

