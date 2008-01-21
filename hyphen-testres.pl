#!/usr/bin/perl -w
#
# hyphen-testres.pl
# Combines hyphenator input and output to test results.
# The default input format is similar to typos.txt. 
# Output is only PLX (pl) output format at the moment.
# Prints to  an XML file.
#
# Based on speller-testres.pl
#
# Usage: hyphen-testres.pl -h
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
#my $applescript;
#my $hunspell;
#my $ccat;
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
			"pl|p" => \$polderland,
#			"mw|m" => \$applescript,
#			"hu|u" => \$hunspell,
			"version|v=s" => \$version,
			"date|e=s" => \$date,
#			"ccat|c" => \$ccat,
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

#if ($ccat) { read_ccat(); }
#else { read_typos(); }
read_typos();

if(! @originals) { exit;}

if ($polderland) { $input_type="pl"; read_polderland(); }
#elsif ($applescript) { $input_type="mw"; read_applescript(); }
else { print STDERR "$0: Give the speller output type: --pl\n"; exit; }

if ($print_xml) { print_xml_output(); }
else { print_output(); }

sub read_applescript {
	
	print STDERR "Reading AppleScript output from $output\n";
	open(FH, $output);

	my $i=0;
	my @suggestions;
	my @numbers;
	while(<FH>) {
		chomp;

		if (/Prompt\:/) {
			confess "Probably reading Polderland format, start again with option --pl\n\n";
		} 
		my ($orig, $error, $sugg) = split(/\t/, $_, 3);
		if ($sugg) { @suggestions = split /\t/, $sugg; }
		$orig =~ s/^\s*(.*?)\s*$/$1/;

		# Some simple adjustments to the input and output lists.
		# First search the output word from the input list.
		my $j = $i;
#		print "$originals[$j]{'orig'}\n";
		while($originals[$j] && $originals[$j]{'orig'} ne $orig) { $j++; }

		# If the output word was not found in the input list, ignore it.
		if (! $originals[$j]) {
			print STDERR "$0: Output word $orig was not found in the input list.\n";
			next;
		}
		# If it was found, mark the words in between.
		elsif ($originals[$j] && $originals[$j]{'orig'} eq $orig) {
			for (my $p=$i; $p<$j; $p++){ $originals[$p]{'error'} = "Error"; }
			$i=$j;
		}

		if ($originals[$i] && $originals[$i]{'orig'} eq $orig) {
			if ($error) { $originals[$i]{'error'} = $error; }
			else { $originals[$i]{'error'} = "not_known"; }
			$originals[$i]{'sugg'} = [ @suggestions ];
			$originals[$i]{'num'} = [ @numbers ];
		}
		$i++;
		}
	close(FH);
}



sub read_polderland {

	print STDERR "$0: Reading Polderland output from $output\n";
	open(FH, $output) or die "Could not open file $output. $!";

	my $i=0;
	my $orig;
	my $reading=0;
	my @suggestions;
	my @numbers;

	while(<FH>) {
		my $line = $_;
		my ($orig, $hyphenated, $comment) = split(/\t/, $line);

		if ($line =~ /Suggestions:/) { $originals[$i]{'error'} = "SplErr" };

		if ($line =~ /Check returns/ || $line =~ /Getting suggestions/) {
			$reading=1;
			#Store the suggestions from the last round.
			if (@suggestions) {
				$originals[$i]{'sugg'} = [ @suggestions ];
				$originals[$i]{'num'} = [ @numbers ];
				$originals[$i]{'error'} = "SplErr";
				@suggestions = ();
				pop @suggestions;
				@numbers = ();
				pop @numbers;
				$reading = 0;
			}
			elsif (! $originals[$i]{'error'}) { $originals[$i]{'error'} = "SplCor"; }
			$i++;
			if ($line =~ /Check returns/) {
				$reading = 1;
				($orig = $line) =~ s/^.*?Check returns .* for \'(.*?)\'\s*$/$1/;
			}
			elsif (! $reading && $line =~ /Getting suggestions/) {
				$reading = 1;
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
				for (my $p=$i; $p<$j; $p++){
					$originals[$p]{'error'}="SplCor";
					$originals[$p]{'sugg'}=();
					pop @{ $originals[$p]{'sugg'} };
					#print STDERR "$0: Removing input word $originals[$p]{'orig'}.\n";
				}
				$i=$j;
			}
			next;
		}

		next if (! $orig);
		chomp $line;
		my ($num, $suggestion) = split(/\s+/, $line, 2);
		#print STDERR "$_ SUGG $suggestion\n";
		if ($suggestion) {
			push (@suggestions, $suggestion);
			push (@numbers, $num);
		}
	}
	close(FH);
	if ($orig) {
		#Store the suggestions from the last round.
		if (@suggestions) {
			$originals[$i]{'sugg'} = [ @suggestions ];
			$originals[$i]{'num'} = [ @numbers ];
			$originals[$i]{'error'} = "SplErr";
			@suggestions = ();
			pop @suggestions;
			@numbers = ();
			pop @numbers;
		}
		elsif (! $originals[$i]{'error'}) { $originals[$i]{'error'} = "SplCor"; }
	}
	$i++;
	while($originals[$i]) { $originals[$i]{'error'} = "SplCor"; $i++; }
}

sub read_typos {

	print STDERR "Reading correct hyphenations from file: $input\n";
	open(FH, "<$input") or die "Could not open $input";

	while(<FH>) {
		chomp;
		next if (/^[\#\!]/);
		next if (/^\s*$/);
		my ($testpair, $comment) = split(/\t[\#\!]\s*/);
		my ($orig, $expected) = split(/\t+/,$testpair);
		my $cleanorig = $orig;
		$cleanorig =~ s/[\^ ]//g ;
		print STDERR "\nClean original: $cleanorig\n";
		print STDERR "Original: $orig\n";
		print STDERR "Expected: $expected\n" if $expected;
		print STDERR "Comment:  $comment\n" if $comment;
		next if (! $orig );
		my $rec = {};
		$orig =~ s/\s*$//;
		$rec->{'orig'} = $cleanorig;
		$rec->{'hyphorig'} = $orig;
		if ($expected) {
			$expected =~ s/\s*$//;
			$rec->{'expected'} = $expected;
		} else {
			cluck "WARNING: \"$cleanorig\" does NOT contain a correct pattern.\n";
			next;
		}
		if ($comment) {
			$comment =~ s/\s*$//;
			$comment =~ s/^\s*//;
			# IF BUG ID: either numbers only, or numbers followed by whitespace,
			if ($comment =~ m/^[\#\!]*\d+$/  ||
			    $comment =~ m/^[\#\!]*\d+\s/ ) {
			    my $bugID = "";
			    my $restcomment = "";
			    if ($comment =~ m/\s+/ ) {
					($bugID, $restcomment) = split(/\s+/,$comment,2);
			    }
				$bugID =~ s/^[\#\!]//;
				$rec->{'bugID'} = $bugID;
				#print STDERR $bugID.".";
				$comment = $restcomment;
			}
			# If the comment was a bug ID only, there's no comment any more
			if ($comment) {
				$comment =~ s/^[-\!\# ]*//;
#				print STDERR $comment.".";
				$rec->{'comment'} = $comment;
			}
		}
		push @originals, $rec;
	}
	close(FH);
#	print STDERR " - end of bugs.\n";
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
	if ($rec->{'orig'} eq "nuvviD" || $rec->{'orig'} eq "nuvviDspeller") {
#		cluck "INFO: nuvviDspeller found.\n";
		shift @originals;
		if ($rec->{'sugg'}) {
#			cluck "INFO: nuvviDspeller contains suggestions.\n";
			my @suggestions = @{$rec->{'sugg'}};
			for my $sugg (@suggestions) {
				#print "SUGG $sugg\n";
				if ($sugg && $sugg =~ /\, /) {
					$version = $sugg;
#					cluck "INFO: Version string is: $version\n";
					last;
				}
			}
		} else {
#			cluck "INFO: nuvviDspeller contains NO suggestions.\n";
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

# The result records should be like:
# <word>
#  <orig>someword</orig>
#  <expected>so<missing>-</missing>me-word</expected>
#  <hyphenated>som<error>-</error>e-w<error>-</error>ord</hyphenated>
#  <relatedbug id="bugID">someComment</relatedbug>
# </word>
#
# The <missing> and <error> tags should be derived from INS and DEL tags
# given by Text::Brew when comparing expected and hyphenated.

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
		
		if ($rec->{'error'} && $rec->{'error'} eq "SplErr") {
			my $suggestions_elt = XML::Twig::Elt->new('suggestions'); 
			my $sugg_count=0;
			if ($rec->{'sugg'}) { $sugg_count = scalar @{ $rec->{'sugg'}} };
			$suggestions_elt->set_att('count', $sugg_count);
			my $position = XML::Twig::Elt->new('position');
			my $pos=0;
			my $near_miss_count = 0;
			if ($rec->{'suggnr'}) { $near_miss_count = $rec->{'suggnr'}; }
			if ($rec->{'sugg'}) {
				
				my @suggestions = @{$rec->{'sugg'}};			
				my @numbers;
				if ($rec->{'num'}) { @numbers =  @{$rec->{'num'}}; }
				for my $sugg (@suggestions) {
					next if (! $sugg);
					my $suggestion = XML::Twig::Elt->new('suggestion');
					$suggestion->set_text($sugg);
					if ($rec->{'expected'} && $sugg eq $rec->{'expected'}) {
						$suggestion->set_att('expected', "yes");
					}
					my $num;
					if (@numbers) { 
						$num = shift @numbers; 
						$suggestion->set_att('penscore', $num);
					}
					if ($near_miss_count > 0) {
						$suggestion->set_att('miss', "yes");
						$near_miss_count--;
					}

					$suggestion->paste('last_child', $suggestions_elt);
				} 
				my $i=0;
				if ($rec->{'expected'}) {
					while ($suggestions[$i] && $rec->{'expected'} ne $suggestions[$i]) { $i++; }
					if ($suggestions[$i]) { $pos = $i+1; }
				}
			}
			$position->set_text($pos);
			$position->paste('last_child', $word);
			$suggestions_elt->paste('last_child', $word);
		}
		if ($rec->{'tokens'}) {
			my @tokens = @{$rec->{'tokens'}};
			my $tokens_num = scalar @tokens;
			my $tokens_elt = XML::Twig::Elt->new(tokens=>{ count=>$tokens_num }); 
			for my $t (@tokens) {
				my $token_elt = XML::Twig::Elt->new('token', $t); 
				$token_elt->paste('last_child', $tokens_elt);
			}
			$tokens_elt->paste('last_child', $word);
		}
		if ($rec->{'bugID'}){ 
			my $bugID = XML::Twig::Elt->new('bug'); 
			$bugID->set_text($rec->{'bugID'});
			$bugID->paste('last_child', $word);
#			print STDERR ".";
		}
		if ($rec->{'comment'}){ 
			my $comment = XML::Twig::Elt->new('comment'); 
			$comment->set_text($rec->{'comment'});
			$comment->paste('last_child', $word);
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
			if ($rec->{'expected'}) {
				while ($suggestions[$i] && $rec->{'expected'} ne $suggestions[$i]) { $i++; }
				if ($suggestions[$i]) { print $i+1; }
			}
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
--pl             The speller output is in PLX-format.
-p
--mw              The speller output is in AppleScript-format.
-m
--hu              The speller output is in hunspell format.
-u
--xml=<file>      Print output in xml to file <file>.
-x
--forced          The speller was forced to make suggestions.
-f
--version=<num>   Speller version information.
-v <num>
--date <date>     Date when the test was run, if not the output file timestamp.
-e
END

}

