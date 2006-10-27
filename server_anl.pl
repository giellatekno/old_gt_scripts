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
use Net::hostent; # for OO version of gethostbyaddr
use POSIX qw(:sys_wait_h);

use XML::Twig;
# Module to communicate with program's user interfaces
use Expect;
# Module that contains the xml-formatting and some utility functions.
use langTools::XMLStruct;
use langTools::Util;

my $PORT = 8080; # pick something not in use

my $lookup="lookup";
my %paradigms;
my $lookup2cg="/usr/local/bin/lookup2cg";
my $end_of_dis="\<\"¶\"\>\n\t\"¶\"";
my $tagfile="/home/saara/gt/cwb/korpustags.txt";
my $exp_anl;
my $exp_dis;
my $exp_lo2cg;
my $preprocess;

my $server = IO::Socket::INET->new( Proto     => 'tcp',
								 LocalPort => $PORT,
								 Listen    => SOMAXCONN,
								 Reuse     => 1);

die "can't setup server" unless $server;
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
		my $error = process_paras($paras);
		if ($error) { print $client "ERROR $error\n"; last CLIENT; }
		else { print $client "\n"; }
		
		print "Setting language to $language.\n";
		print "Using fst: $fst.\n";
		if ($action{'dis'}) { print "Using rle: $dis_tools{'rle'}.\n"; }

		# Initialize different tools according to the parameters.
		# Start the expect objects: exp_anl and dis_anl if requested.
		init_tools();
				
		# Start processing client input
		while ( <$client>) {
			#next if (/^\s*$/);
			last CLIENT if (/quit|exit/);
			
			# call xml-functions to parse the input if xml_in
			# call preprocessor if requested.
			my $line = process_input($_);
			
			my $analysis = analyze_input($line);
			print $client $analysis, "\n";

			my $output;
			if($action{'dis'}) { 
				my $result = disambiguate($analysis);
				if ($xml_out) { $output = dis2xml($result); }
				else { $output = $result; }
				print $client $result, "\n";
			}
			
			print $client "end\n";
		}
		print "client exiting..";
		close($client);
		
		# if no longer needed, do a soft_close to nicely shut down the command
		if($exp_anl) { $exp_anl->soft_close(); }
		print "ready\n";
		
		# exit the child
		exit 0;
	}

close $server;
exit 0;


sub process_input {
	my $line = $_;

	if($action{'prep'}) {
		if ($xml_in) { $line = xml2preprocess($line); }
		
		#print "LINE $line\n";
		# Remove the unsecure characters from the input.
		$line =~ s/[\;\<\>\*\|\`\&\$\!\#\(\)\[\]\{\}\:\'\"]/ /g; 
		
		$line = `echo \"$line\" | $preprocess`;
					#print "LINE2 $line\n";
		
		return $line;
	}
	if ($xml_in) {
		if ($action{'anl'} || $action{'hyph'} || $action{'gen'} || $action{'para'}) { 
			$line = xml2words($_);
		}
		elsif ($action{'dis'}) {  $line = xml2dis($_); }
	}
	return $line;
} 

sub analyze_input {
	my $input = shift @_;

	my $analysis;
	my $output;

	if($action{'anl'} || $action{'hyph'} || $action{'gen'}) {
		$analysis = call_analyze($exp_anl, $input);
		if ($analysis =~ /ERROR/) { return $analysis; }
		
		if ($action{'dis'}) { last ANALYZE; }
		if ($xml_out) {
				if ($action{'anl'}) { $output = &analyzer2xml($analysis); }
				elsif ($action{'hyph'}) { $output = &hyph2xml($analysis); }
				elsif ($action{'gen'}) { $output = &gen2xml($analysis); }
			}
		else { $output = $analysis; }
		
		return $output;
	}
	if ($action{'para'}) {
		#print "line: $input\n";
		$analysis = generate_paradigm($exp_anl, $input);
		if ($analysis =~ /ERROR/) { return $analysis; }
		
		if ($xml_out) { $output = gen2xml($analysis,1); }
		else { $output = $analysis; };
		return $output;
	}
}

sub init_tools {

	my $analyze;
	my $disamb;

	if($action{'anl'} ||$action{'hyph'}) { 
		$analyze="$lookup $args $fst 2>/dev/null"; 
	}
	if ($action{'gen'} || $action{'para'}) { 
		$analyze = "$lookup $args $fst 2>/dev/null"; 
	}
	if ($action{'prep'}) {
		if ($prep_tools{'fst'}) { 
			$preprocess = "preprocess --abbr=$prep_tools{'abbr'} --fst=$prep_tools{'fst'}"; 
		}
		else { $preprocess = "preprocess --abbr=$prep_tools{'abbr'}"; }
	}
		
	if ($action{'dis'}) { $disamb = "vislcg $dis_tools{'args'} --grammar=$dis_tools{'rle'}"; }

		# generate tag lists for the paradigms
		my %taglist;
		if ($action{'para'}) { generate_taglist (undef, $tagfile, \%paradigms) };
		
		# create an Expect object of fst
		if($action{'anl'} || $action{'gen'} || $action{'hyph'} || $action{'para'}) {
			$exp_anl = Expect->spawn($analyze)
				or die "Cannot spawn $analyze: $!\n";
			$exp_anl->log_stdout(0);
		}
		# create an Expect object of vislcg

		if($action{'dis'}) {
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
	my ($exp_anl, $line) = @_;

	if (! $line || $line =~ /^\s*$/ ) { return; }

	my @input=split(/\n/, $line);
	my $output;

	for my $r (@input) {
		#print "r $r\n";
		my ( $word, $pos) = split(/\s+/, $r);
		if ( !$pos ) { return "ERROR: $line"; }

		for my $a ( @{$paradigms{$pos}} ) {
			my $string = "$word+$a";
			#print "string $string\n";
			my $analysis = call_analyze($exp_anl, $string);
			chomp $analysis;
			next if ($analysis =~ /\+\?/);
			$output .= $analysis;
		}
	}
	return $output;
}

sub call_analyze {
	my ($exp_anl, $line) = @_;
	
	# send some string there:
	my @input=split(/\n/, $line);
	my $output;
	for my $r (@input) {
		$exp_anl->send("$r\n");
		$exp_anl->expect(undef, '-re', '\r?\n\r?\n' );
		
		my $read_anl = $exp_anl->before();
	
		# Take away the original input.
		$read_anl =~ s/^.*?\n//;
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

