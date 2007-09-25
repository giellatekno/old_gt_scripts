#!/usr/bin/perl -w
#
# server_anl.pl
#
# Server application for launching the xerox tools.
#
# actions: prep, anl, dis, hyph, gen, para
#
# $Id$

use strict;
use IO::Socket;
use Socket qw(:all);
use Net::hostent; # for OO version of gethostbyaddr
use POSIX qw(:sys_wait_h);

#binmode STDOUT, ":utf8";
#binmode STDIN, ":utf8";
#use utf8;

use XML::Twig;
# Module to communicate with program's user interfaces
use Expect;
# Module that contains the xml-formatting and some utility functions.
use langTools::XMLStruct;
use langTools::Util;

#my $PORT = 9000;
my $PORT = 8081;

my $lookup="lookup";
my %paradigms;
my $hyph_filter;
my $lookup2cg="/usr/local/bin/lookup2cg";
my $end_of_dis;
my %exp_anl;
my $exp_dis;
my $exp_lo2cg;
my $preprocess;

my $server = IO::Socket::INET->new( Proto     => 'tcp',
								 LocalPort => $PORT,
								 Listen    => SOMAXCONN,
								 Reuse     => 1);

die "can't setup server" unless $server;

defined(my $tcp = getprotobyname("tcp"))
	or die "Could not determine the protocol number for tcp";

setsockopt($server, $tcp, TCP_NODELAY, 1)
	or die "Could not change TCP_NODELAY socket option: $!";

print "[Server $0 accepting clients]\n";

my $client;
 CLIENT:
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
		
		# Read the xml-structure which contains the parameters.
		my $paras;
		my $start=<$client>;
		if ($start !~ /parameters/) { print $client "ERROR in parsing parameters\n"; last CLIENT; }
		chomp $start;
		$paras .= $start;
		while(<$client>) {
			chomp;
			$paras .= $_;
			last if /parameters/;
		}

		$paras =~ s/\n//g;
		$paras =~ s/\r//g;

		my $error = process_paras($paras);
		if ($error) { print $client "ERROR $error\n"; last CLIENT; }
		else { print $client ""; }
		
		print "Setting language to $language.\n";
		print "Using fsts:\n";
		for my $key (keys %action) {
			print "$action{$key}{'fst'}\n";
		}

		if ($action{'dis'}) { print "Using rle: $dis_tools{'rle'}.\n"; }

		# Initialize different tools according to the parameters.
		# Start the expect objects: exp_anl and dis_anl if requested.
		init_tools();
				
		# Start processing client input
		my $input;


	  CLIENT_REQUEST:
		while ( <$client>) {
			
			# read one line at the time
			s/\r//g;
			#next if (/^\s*$/);
			s/^\n+//;
			
			# if client is exiting
			last CLIENT if (/END_CLIENT/);
			
			# remove possible end request.
			s/END_REQUEST//g;
			  
			$input = $_;

			if (! $input) { next; }

			# Find the action to be done with this input
			my $act;
			if ($xml_in) { $act = get_action($input); }
			if ($act) {
				if ($act =~ /ERROR/) { print $client "$act\n END_REPLY\n"; $input=undef; next; } 
				if (! $action{$act}) { print $client "ERROR: not initialized: $act\n END_REPLY\n"; 
									   $input=undef; 
									   next; } 
			}
			elsif (! $act) {
				if ($action{'anl'}) { $act = "anl"; }
				elsif ($action{'gen'}) { $act = "gen"; }
				elsif ($action{'hyph'}) { $act = "hyph"; }
				elsif ($action{'para'}) { $act = "para"; }
				elsif ($action{'prep'}) { $act = "prep"; }
			}

			# call xml-functions to parse the input if xml_in
			# call preprocessor if requested.
			my $line = process_input($input, $act);

			my $output;
			if ($act eq "prep") { 
				if ($xml_out) { $output = preprocess2xml($line); }
				else { $output = $line; }
				print $client $output, "\n"; 
				print $client "END_REPLY\n";
				$input=undef;
				next;
			}
			
			my $analysis = analyze_input($line, $act);
			print $client $analysis, "\n";

			if($action{'dis'}) { 
				my $result = disambiguate($analysis);
				if ($xml_out) { $output = dis2xml($result); }
				else { $output = $result; }
				print $client $result, "\n";
			}
			
#			print $client "END_REPLY\n";
			$input=undef;
		}
		print "client exiting..";
		close($client);
		
		# if no longer needed, do a soft_close to nicely shut down the command
		if(%exp_anl) { 
			for my $exp (keys %exp_anl) { $exp->soft_close(); }
			}
		print "ready\n";
		
		# exit the child
		exit 0;
	}

close $server;
exit 0;


sub process_input {
	my ($line, $act) = @_;

	if ($xml_in) { $line =~ s/\n//g; }

	if($act eq 'prep' || ($act eq "anl" && $action{'prep'})) {
		if ($xml_in) { $line = xml2preprocess($line); }
		
		#print "LINE $line\n";
		# Remove the unsecure characters from the input.
		$line =~ s/[\;\<\>\*\|\`\&\$\!\#\(\)\[\]\{\}\:\'\"]/ /g; 
		
		$line = `echo \"$line\" | $preprocess`;
		#print "LINE2 $line\n";
		
		return $line;
	}
	if ($xml_in) {
		if ($act =~ /anl|hyph|gen|para/) {
			$line = xml2words($line);
		}
		elsif ($action{'dis'}) {  $line = xml2dis($line); }
	}
	return $line;
} 

sub analyze_input {
	my ($input, $act) = @_;

	my $analysis;
	my $output;

	# Lookup call
	if($act =~ /anl|hyph|gen/) {

		$analysis = call_analyze($exp_anl{$act}, $input);
		if (! $analysis) { return; }
		if ($analysis =~ /ERROR/) { return $analysis; }

		# Filter hyphenations if requested.
		if ($act =~ 'hyph' && $action{'hyph'}{'filter'}) {
			#print "filtering\n";
			# Remove the unsecure characters from the input.
			$analysis =~ s/[\;\<\>\*\|\`\&\$\!\(\)\[\]\{\}\:\'\"]/ /g; 
			$analysis = `echo \"$analysis\" | $action{'hyph'}{'filter'}`;
		}
		# Format XML-output
		if ($xml_out) {
			if ($act eq 'anl') { $output = analyzer2xml($analysis); }
			elsif ($act eq 'gen') { $output = gen2xml($analysis); }
			elsif ($act eq 'hyph') { $output = hyph2xml($analysis); }
		}
		else { $output = $analysis; }
		
		return $output;
	}
	# Paradigm generator
	if ($act eq 'para') {
		#print "line: $input\n";
		$analysis = generate_paradigm($exp_anl{$act}, $input);
		if ($analysis && $analysis =~ /ERROR/) { return $analysis; }
		
		if ($xml_out) { $output = gen2xml($analysis,1); }
		else { $output = $analysis; };
		return $output;
	}
}

sub init_tools {
	
	my $analyze;
	my $analyze_gen;
	my $disamb;
	
	# Lookup-tools, start lookup-process for each tool.
	for my $tool (keys %action) {
		if($tool =~ /anl|gen|hyph|para/) {
			$analyze="$lookup $action{$tool}{'args'} $action{$tool}{'fst'} 2>/dev/null"; 
			$exp_anl{$tool} = Expect->spawn($analyze)
				or die "Cannot spawn $analyze: $!\n";
			$exp_anl{$tool}->log_stdout(0);
		}
	}
	# Paradigm generation, generate tag lists for the paradigms
	if ($action{'para'}) {
		generate_taglist($action{'para'}{'grammar'},$action{'para'}{'tags'},\%paradigms,$action{'para'}{'mode'});
		print "$action{'para'}{'grammar'}\n";
		print "$action{'para'}{'tags'}\n";
	}

	# Preprocessing, initialize command
	if ($action{'prep'}) {
		if ($prep_tools{'fst'}) { 
			$preprocess = "preprocess --abbr=$prep_tools{'abbr'} --fst=$prep_tools{'fst'}"; 
		}
		else { $preprocess = "preprocess --abbr=$prep_tools{'abbr'}"; }
	}
	# Disambiguation, start process for vislcg.
	if ($action{'dis'}) { 
		$disamb = "vislcg $dis_tools{'args'} --grammar=$dis_tools{'rle'}";
		$exp_dis = Expect->spawn($disamb)
			or die "Cannot spawn $disamb: $!\n";
		$exp_dis->log_stdout(0);
	}
}

sub disambiguate {
	my ($exp_dis, $input) = @_;

#			for my $string (@dis_strings) {
#				my $result = `echo \"$string\n\n\" | $lookup2cg`;
#				$exp_dis->send("$result\n");
#			}
	print "$end_of_dis\n\n";
	$exp_dis->send("$end_of_dis\n\n"); 
	$exp_dis->expect(1);
	my $read_dis = $exp_dis->clear_accum();
#			$read_dis =~ s/^.*\"\x{00B6}\"\n//m;
	return $read_dis;
}

sub generate_paradigm {
	my ($exp, $line) = @_;

	if (! $line || $line =~ /^\s*$/ ) { return; }

	my @input=split(/\n/, $line);
	my $output;

	for my $r (@input) {
		#print "r $r\n";
		$r =~ /^(.*)\s+(\w+)/;
		my $word=$1;
		my $pos=$2;
		if ( !$pos ) { return "ERROR: $line"; }

		for my $a ( @{$paradigms{$pos}} ) {
			$a =~ s/NACR/N+ACR/; 
			my $string = "$word+$a";
			#print "string $string\n";
			my $analysis = call_analyze($exp, $string);
			chomp $analysis;
			next if ($analysis =~ /\+\?/);
			$output =~ s/$word\+$pos/$word\x{00A7}$pos/g;
			print "OUTPUT $output\n";
			$output .= $analysis;
		}
	}
	return $output;
}

sub call_analyze {
	my ($exp, $line) = @_;
	
	# send some string there:
	my @input=split(/\n/, $line);
	my $output;
	for my $r (@input) {
		$exp->send("$r\n");
		$exp->expect(undef, '-re', '\r?\n\r?\n' );
		
		my $read_anl = $exp->before();
	
		# Take away the original input.
		$read_anl =~ s/^.*?\n//;
		# Replace extra newlines.
		$read_anl =~ s/\r\n/\n/g;
		$read_anl =~ s/\r//g;
		$output .= $read_anl . "\n\n";
	}
	return $output;
}

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

