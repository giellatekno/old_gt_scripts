#!/usr/bin/perl -w
#
# speller-testres.pl
# Combines speller input and output to test results.
# The default input format is typos.txt. 
# Output is either PLX or AppleScript output format.
# Prints to STDOUT at the moment. XML-output is not implemented.
#
# Usage: speller-testres.pl -h
#
# $id:$

use strict;
use XML::Twig;

use Carp qw(cluck confess);
use File::stat;
use Time::localtime;
use File::Basename;
use Text::Brew qw(distance);

my $help;
my $input;
my $input_type;
my $output;
my $print_xml;
my $forced=0;
my $polderland;
my $applescript;
my $ccat;
my $out_file;
my $typos=1;
my $document;
my $version;
my $date;
my @originals;

use Getopt::Long;
Getopt::Long::Configure ("bundling");
GetOptions ("help|h" => \$help,
			"input|i=s" => \$input,
			"document|d=s" => \$document,
			"PLX|P" => \$polderland,
			"AS|A" => \$applescript,
			"version|v=s" => \$version,
			"date|a=s" => \$date,
			"ccat|c" => \$ccat,
			"typos|t" => \$typos,
			"output|o=s" => \$output,
			"xml|x=s" => \$print_xml,
			"forced|f" => \$forced,
			);

if ($help) {
	&print_help;
	exit 1;
}

if (! $input || ! -f $input) { print STDERR "$0: No input file specified.\n"; exit; }
if (! $output) { print STDERR "$0: No speller output file specified.\n"; exit; }

if ($ccat) { read_ccat(); }
else { read_typos(); }

if(! @originals) { exit;}

if ($polderland) { $input_type="PLX"; read_polderland(); }
elsif ($applescript) { $input_type="AS"; read_applescript(); }
else { print STDERR "$0: Give the speller output type: --PLX or --AS\n"; exit; }

if ($print_xml) { print_xml_output(); }
else { print_output(); }

sub read_applescript {
	
	print STDERR "Reading AppleScript output from $output\n";
	open(FH, $output);

	my $i=0;
	my @suggestions;
	while(<FH>) {
		chomp;

		if (/Prompt\:/) { 
			confess "Probably reading Polderland format, start again with option --PLX\n\n";
		} 
		my ($orig, $error, $sugg) = split(/\t/);
		if ($sugg) { @suggestions = split(", ", $sugg); }

		# Some simple adjustments to the input and output lists.
		# First search the output word from the input list.
		my $j = $i;
		print "$originals[$j]{'orig'}\n";
		while($originals[$j] && $originals[$j]{'orig'} ne $orig) { $j++; }

		# If the output word was not found from the input list, ignore it.
		if (! $originals[$j]) {
			print STDERR "$0: Output word $orig was not found from the input list.\n";
			next;
		}
		# If it was found later, remove the extra lines from the input list.
		elsif($j != $i) {
			my $k=$j-$i;
			if ($k>20) { next; }
			else {
				for (my $p=$i; $p<$j; $p++){
					$originals[$p]{'error'}="SplCor";
					$originals[$p]{'sugg'}=();
					#print STDERR "$0: Removing input word $originals[$p]{'orig'}.\n";
				}
				$i=$j;
			}
			
		}
		if ($originals[$i] && $originals[$i]{'orig'} eq $orig) {
			if ($error) { $originals[$i]{'error'} = $error; }
			else { $originals[$i]{'error'} = "not_known"; }
			$originals[$i]{'sugg'} = [ @suggestions ];
		}
		$i++
		}
	close(FH);
}


sub read_polderland {

	print STDERR "$0: Reading Polderland output from $output\n";
	open(FH, $output) or die "Could not open file $output. $!";

	# Read until "Prompt"
	while(<FH>) { last if (/Prompt/); }

	my $i=0;
	my $line = $_;
	my $orig;

    if ($line =~ /Check returns/) { 	
		($orig = $line) =~ s/.*?Check returns .*? for \'(.*?)\'\s*$/$1/;
	}
	elsif ($line =~ /Getting suggestions/) {
		($orig = $line) =~ s/.*?Getting suggestions for (.*?)\.\.\.\s*$/$1/;
	}
	else { confess "could not read $output: $line"; }

	if (!$orig || $orig eq $line) { 
		confess "Probably wrong format, start again with --AS\n";
	}

	while($originals[$i] && $originals[$i]{'orig'} ne $orig) {
		#print STDERR "$0: Input and output mismatch, removing $originals[$i]{'orig'}.\n"; 			
		splice(@originals,$i,1);
	}

	my @suggestions;

	# variable to check whether the suggestions are already started.
	# this is because the line "check returns" may be missing.
	my $reading=0;
	while(<FH>) {

		$line = $_;
		next if ($reading && /Getting suggestions/);
		next if ($line =~ /End of suggestions/);

		if ($line =~ /Suggestions:/) { $originals[$i]{'error'} = "SplErr" };

		if ($line =~ /Check returns/ || $line =~ /Getting suggestions/) {
			#Store the suggestions from the last round.
			if (@suggestions) {
				$originals[$i]{'sugg'} = [ @suggestions ];
				$originals[$i]{'error'} = "SplErr";
				@suggestions = ();
				pop @suggestions;
				$reading = 0;
			}
			elsif (! $originals[$i]{'error'}) { $originals[$i]{'error'} = "SplCor"; }
			$i++;
			if ($line =~ /Check returns/) {
				$reading = 1;
				($orig = $line) =~ s/^.*?Check returns .* for \'(.*?)\'\s*$/$1/;
			}
			elsif (! $reading && $line =~ /Getting suggestions/) {
				($orig = $line) =~ s/^.*?Getting suggestions for (.*?)\.\.\.\s*$/$1/;
			}
			# Some simple adjustments to the input and output lists.
			# First search the output word in the input list.
			my $j = $i;
			while($originals[$j] && $originals[$j]{'orig'} ne $orig) { $j++; }
			
			# If the output word was not found in the input list, ignore it.
			if (! $originals[$j]) {
				cluck "WARNING: Output word $orig was not found in the input list.\n";
				$orig=undef;
				$i--;
				next;
			}
			# If it was found later, mark the intermediate input as correct.
			elsif($j != $i) {
				my $k=$j-$i;
				if ($k>20) { next; }
				else {
					for (my $p=$i; $p<$j; $p++){
						$originals[$p]{'error'}="SplCor";
						$originals[$p]{'sugg'}=();
						pop @{ $originals[$p]{'sugg'} };
						#print STDERR "$0: Removing input word $originals[$p]{'orig'}.\n";
					}
					$i=$j;
				}
			}
			next;
		}
		next if (! $orig);
		chomp $line;
		my ($num, $suggestion) = split(/\s+/, $line, 2);
		#print "$_ SUGG $suggestion\n";
		if ($suggestion) { push (@suggestions, $suggestion); }
	}
	close(FH);
	if ($orig) {
		#Store the suggestions from the last round.
		if (@suggestions) {
			$originals[$i]{'sugg'} = [ @suggestions ];
			$originals[$i]{'error'} = "SplErr";
			@suggestions = ();
			pop @suggestions;
		}
	}
}

sub read_typos {

	print STDERR "Reading typos from $input\n";
	open(FH, "<$input") or die "Could not open $input";

	while(<FH>) {
		chomp;
		next if (/^[\#\!]/);
		next if (/^\s*$/);
		s/[\#\!].*$//;
		my ($orig, $expected) = split(/\t+/);
		next if (! $orig );
		my $rec = {};
		# if the word starts with comma (,), 
		# the suggestions are forced.
		if ($orig =~ s/^\,//) { $rec->{'forced'} = 1; }
		$orig =~ s/\s*$//;
		if ($expected) {
			$expected =~ s/\s*$//;
			$rec->{'expected'} = $expected;
		}
		$rec->{'orig'} = $orig;
		push @originals, $rec;
	}
	close(FH);
}

sub print_xml_output {

	if (! $print_xml) {
		die "Specify the output file with option --xml=<file>\n";
	}
	my $FH1;
	open($FH1,  ">$print_xml");
	print $FH1 qq|<?xml version='1.0'  encoding="UTF-8"?>|;
	print $FH1 qq|<spelltestresult>|;

	# Print some header information
	my $header = XML::Twig::Elt->new('header');
	$header->set_pretty_print('record');

    # Get version info if it's available
    my $rec = $originals[0];
	if ($rec->{'orig'} eq "nuvviD") {
		cluck "INFO: nuvviD found.\n";
		shift @originals;
		if ($rec->{'sugg'}) {
			cluck "INFO: nuvviD contains suggestions.\n";
			my @suggestions = @{$rec->{'sugg'}};
			for my $sugg (@suggestions) {
				print "SUGG $sugg\n";
				if ($sugg && $sugg =~ /\, /) {
					$version = $sugg;
					cluck "INFO: Version string is: $version\n";
					last;
				}
			}
		} else {
			cluck "INFO: nuvviD contains NO suggestions.\n";
		}
	}

	# Print some header information
	my $tool = XML::Twig::Elt->new('tool');
	$tool->set_att('version', $version);
	$tool->set_att('type', $input_type);
	$tool->paste('last_child', $header);
	
	# what was the checked document
	my $docu = XML::Twig::Elt->new('document');
	if (!$document) { $document=basename($input); }
	$docu->set_text($document);
	$docu->paste('last_child', $header);

    # The date is the timestamp of speller output file if not given.
	my $date_elt = XML::Twig::Elt->new('date');
	if (!$date ) { 
		$date = ctime(stat($output)->mtime);
		#print "file $input updated at $date\n";
	}
	$date_elt->set_text($date);
	$date_elt->paste('last_child', $header);

	$header->print($FH1);

	# Start the results-section
	my $results = XML::Twig::Elt->new('results');
	$results->set_pretty_print('record');

	for my $rec (@originals) {
		
		my $word = XML::Twig::Elt->new('word'); 
		if ($rec->{'orig'}) { 
			my $original = XML::Twig::Elt->new('original'); 
			$original->set_text($rec->{'orig'});
			$original->paste('last_child', $word);
		}
		if ($rec->{'expected'}){ 
			my $expected = XML::Twig::Elt->new('expected'); 
			$expected->set_text($rec->{'expected'});
			$expected->paste('last_child', $word);
			my $distance=distance($rec->{'orig'},$rec->{'expected'},{-output=>'distance'});
			my $edit_dist = XML::Twig::Elt->new('edit_dist'); 
			$edit_dist->set_text($distance);
			$edit_dist->paste('last_child', $word);
		}
		if ($rec->{'error'}){ 
			my $error = XML::Twig::Elt->new('status'); 
			$error->set_text($rec->{'error'});
			$error->paste('last_child', $word);
		}
		if ($rec->{'forced'}){ $word->set_att('forced', "yes"); }
		
		if ($rec->{'error'} eq "SplErr") {
			my $suggestions_elt = XML::Twig::Elt->new('suggestions'); 
			my $sugg_count=0;
			if ($rec->{'sugg'}) { $sugg_count = scalar @{ $rec->{'sugg'}} };
			$suggestions_elt->set_att('count', $sugg_count);
			my $position = XML::Twig::Elt->new('position');
			my $pos=0;
			
			if ($rec->{'sugg'}) {
				
				my @suggestions = @{$rec->{'sugg'}};			
				for my $sugg (@suggestions) {
					next if (! $sugg);
					my $suggestion = XML::Twig::Elt->new('suggestion');
					$suggestion->set_text($sugg);
					if ($sugg eq $rec->{'expected'}) {
						$suggestion->set_att('expected', "yes");
					}
					$suggestion->paste('last_child', $suggestions_elt);
				} 
				my $i=0;
				while ($suggestions[$i] && $rec->{'expected'} ne $suggestions[$i]) { $i++; }
				if ($suggestions[$i]) { $pos = $i+1; }
			}
			$position->set_text($pos);
			$position->paste('last_child', $word);
			$suggestions_elt->paste('last_child', $word);
		}

		$word->paste('last_child', $results);
	}

	$results->print($FH1);
	print $FH1 qq|</spelltestresult>|;
	close($FH1);
}

sub print_output {


	for my $rec (@originals) {
		my @suggestions;
		if ($rec->{'orig'}) { print "$rec->{'orig'} | "; }
		if ($rec->{'expected'}) { print "$rec->{'expected'} | "; }
		if ($rec->{'error'}) { print "$rec->{'error'} | "; }
		print "$forced | ";
		if ($rec->{'sugg'}) {
			print "@{$rec->{'sugg'}} | ";
			my @suggestions = @{$rec->{'sugg'}};
			my $i=0;
			while ($suggestions[$i] && $rec->{'expected'} ne $suggestions[$i]) { $i++; }
			if ($suggestions[$i]) { print $i+1; }
		}
		print "\n";
	} 
}


sub print_help {
	print << "END";
Combines speller input and output.
Usage: speller-testres.pl [OPTIONS]
--help            Print this help text and exit.
-h
--input=<file>    The original speller input.
-i <file>
--document=<name> The name of the original speller input, if not the input file name.
-d <name>
--ccat            The input is from ccat, the default is typos.txt. not yet in use.
-c
--output=<file>   The speller output.
-o <file>
--PLX             The speller output is in PLX-format.
-P
--AS              The speller output is in AplleScript-format.
-A
--xml=<file>      Print output in xml to file <file>.
-x
--forced          The speller was forced to make suggestions.
-f
--version=<num>   Speller version information.
-v <num>
--date <date>     Date when the test was run, if not the output file timestamp.
-a
END

}

