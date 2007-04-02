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

my $help;
my $input;
my $input_type;
my $output;
my $output_type;
my $print_xml;
my $forced=0;
my $polderland;
my $applescript;
my $ccat;
my $out_file;
my $typos=1;
my @originals;

use Getopt::Long;
Getopt::Long::Configure ("bundling");
GetOptions ("help|h" => \$help,
			"input|i=s" => \$input,
			"PLX|P" => \$polderland,
			"AS|A" => \$applescript,
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

if (! $input || ! -f $input) { print "No input file specified.\n"; exit; }
if (! $output) { print "No speller output file specified.\n"; exit; }

if ($ccat) { read_ccat(); }
else { read_typos(); }

if(! @originals) { exit;}

if ($polderland) { read_polderland(); }
elsif ($applescript) { read_applescript(); }
else { print "Give the speller output type: --Polderland or --AS\n"; exit; }

if ($print_xml) { print_xml_output(); }
else { print_output(); }

sub read_polderland {
	
	print STDERR "Reading PLX output from $output\n";
	open(FH, $output);

	my $i=0;
	my @suggestions;
	while(<FH>) {
		chomp;

		if (/Prompt\:/) { 
			print STDERR "Probably reading AppleScript format, start again with option --AS\n\n";
			return;
		} 
		my ($orig, $error, $sugg) = split(/\t/);
		if ($sugg) { @suggestions = split(", ", $sugg); }

		# Some simple adjustments to the input and output lists.
		# First search the output word from the input list.
		my $j = $i;
		while($originals[$j] && $originals[$j]{'orig'} ne $orig) { $j++; }

		# If the output word was not found from the input list, ignore it.
		if (! $originals[$j]) {
			print STDERR "Output word $orig was not found from the input list.\n";
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
					#print STDERR "Removing input word $originals[$p]{'orig'}.\n";
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


sub read_applescript {

	print STDERR "Reading AppleScript output from $output\n";
	open(FH, $output);

	while(<FH>) {
		last if (/Prompt/);
	}

	my $i=0;
	(my $orig = $_) =~ s/.*?Getting suggestions for (.*?)\.\.\.\s?$/$1/;

	while($originals[$i] && $originals[$i]{'orig'} ne $orig) {
		#print STDERR "Input and output mismatch, removing $originals[$i]{'orig'}.\n"; 			
		splice(@originals,$i,1);
	}

	my @suggestions;
	while(<FH>) {
		next if (/Suggestions:/);
		next if (/End of suggestions/);
		my $line = $_;
		if (/Getting suggestions/) {
			#Store the suggestions from the last round.
			if (@suggestions) {
				$originals[$i]{'sugg'} = [ @suggestions ];
				$originals[$i]{'error'} = "SplErr";
				@suggestions = ();
				pop @suggestions;
			}
			else {
				$originals[$i]{'sugg'} = ();
				$originals[$i]{'error'} = "SplCor";
			}
			$i++;
			($orig = $line) =~ s/^.*?Getting suggestions for (.*?)\.\.\.\s?$/$1/;
			# Some simple adjustments to the input and output lists.
			# First search the output word from the input list.
			my $j = $i;
			while($originals[$j] && $originals[$j]{'orig'} ne $orig) { $j++; }
			
			# If the output word was not found from the input list, ignore it.
			if (! $originals[$j]) {
				print STDERR "Output word $orig was not found from the input list.\n";
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
						#print STDERR "Removing input word $originals[$p]{'orig'}.\n";
					}
					$i=$j;
				}
			}
			next;
		}
		next if ($line =~ /Prompt/);
		next if (! $orig);
		my ($num, $suggestion) = split(/\s+/, $line);
		#print "$_ SUGG $suggestion\n";
		push (@suggestions, $suggestion);
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

	print "$input\n";
	open(FH, "<$input");

	while(<FH>) {
		chomp;
		next if (/^\#/);
		next if (/^\s*$/);
		my ($orig, $expected) = split(/\t+/);
		next if (! $orig );
		$orig =~ s/\s*$//;
		$expected =~ s/\s*$//;
		my $rec = {};
		$rec->{'expected'} = $expected;
		$rec->{'orig'} = $orig;
		push @originals, $rec;
	}
	close(FH);
}

sub print_xml_output {

	if (! $print_xml) {
		print "Specify the output file with option --xml=<file>\n";
	}
	my $FH1;
	open($FH1,  ">$print_xml");
	print $FH1 qq|<?xml version='1.0'  encoding="UTF-8"?>|;
	my $results = XML::Twig::Elt->new('results');
	$results->set_pretty_print('record');

	for my $rec (@originals) {
        my @suggestions;
		
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
		}
		if ($rec->{'error'}){ 
			my $error = XML::Twig::Elt->new('error'); 
			$error->set_text($rec->{'error'});
			$error->paste('last_child', $word);
		}
		if ($forced){ $word->set_att('forced', "yes"); }
		
		if ($rec->{'sugg'}) {

			my $suggestions = XML::Twig::Elt->new('suggestions'); 
			my @suggestions = @{$rec->{'sugg'}};

			for my $sugg (@suggestions) {
				my $suggestion = XML::Twig::Elt->new('suggestion');
				$suggestion->set_text($sugg);
				if ($sugg eq $rec->{'expected'}) {
					$suggestion->set_att('expected', "yes");
				}
				$suggestion->paste('last_child', $suggestions);
			} 
			my $i=0;
			while ($suggestions[$i] && $rec->{'expected'} ne $suggestions[$i]) { $i++; }
			if ($suggestions[$i]) { 
				my $position = XML::Twig::Elt->new('position');
				my $pos = $i+1;
				$position->set_text($pos);
				$position->paste('last_child', $word);
			}
			else {
				my $position = XML::Twig::Elt->new('position');
				my $pos=0;
				$position->set_text($pos);
				$position->paste('last_child', $word);
			}
			$suggestions->paste('last_child', $word);
		}
		$word->paste('last_child', $results);
	}

	$results->print($FH1);
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
--help          Print this help text and exit.
-h
--input=<file>  The original speller input.
-i <file>
--ccat          The input is from ccat, the default is typos.txt. not yet in use.
-c
--output=<file> The speller output.
-o <file>
--PLX           The speller output is in PLX-format.
-P
--AS            The speller output is in AplleScript-format.
-A
--xml=<file>    Print output in xml to file <file>.
-x
--forced        The speller was forced to make suggestions.
-f
END

}

