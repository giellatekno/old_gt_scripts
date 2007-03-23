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
			"xml|x" => \$print_xml,
			"forced|f" => \$forced,
			);

if ($help) {
	&print_help;
	exit 1;
}

if (! $input) { print "No input file specified.\n"; exit; }
if (! $output) { print "No speller output file specified.\n"; exit; }

if ($ccat) { read_ccat(); }
else { read_typos(); }

if ($polderland) { read_polderland(); }
elsif ($applescript) { read_applescript(); }
else { print "Give the speller output type: --Polderland or --AS\n"; exit; }

print_output();

sub read_polderland {
	
	print STDERR "Reading PLX output from $output\n";
	open(FH, $output);

	my $i=0;
	my @suggestions;
	while(<FH>) {
		chomp;
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

	open(FH2, $input);

	while(<FH2>) {
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
}

sub print_output {

	for my $rec (@originals) {
		my @suggestions;
		if ($rec->{'orig'}) { print "$rec->{'orig'} | "; }
		if ($rec->{'orig'}) { print "$rec->{'expected'} | "; }
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
--xml           Print output in xml. not yet in use.
-x
--forced        The speller was forced to make suggestions.
-f
END

}

