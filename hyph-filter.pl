#!/usr/bin/perl -w

use strict;

use utf8;

# hyph-filter.pl 
# Perls script for cleaning the hyphenator output.
# - reads one cohort at the time
# - compares the hyphenated word to the orignal, disregarding ^ and #:
# -- deletes forms that do not correspond to the input string
# - uniques the final set
# - removes all but the readings with the least word boundaries
# and prints what is left (it should normally be only one form)
#
# $Id$

# set reading to paragraph mode.
$/ = "";

# Read while not eol
INPUT:
	while(<>) {	
	
		chomp;
		my %lines;
		@lines{split(/\n/, $_)} = ();
		
		my %forms;
		
		my $word;
		my $hyph;

		for my $line (keys %lines) {
			chomp;

			($word, $hyph) = split(/\t/, $line);
			next if (! $hyph);

			if (scalar(keys %lines) == 1) { # and $word eq $hyph && $line !~ /\+\?/) {
				$line =~ s/\s*\+\?//;
				print $line; 
				print "\n\n"; 
				next INPUT; 
			}

			#remove word boundaries
			$hyph =~ tr/\#//;

			# take the upper case and lower case forms.
			my $uc = ucfirst($hyph);
			my $lc = lcfirst($hyph);

			# Take hyphenation point count.
			my $count = ($hyph =~ tr/^//);

			# remove all the other wb:s
			( my $cleaned = $hyph ) =~ tr/[^]//d;
			
		  TEST: {
			  if ($word eq $cleaned) { $forms{$hyph} = $count; last TEST; }
			  
			  ( my $ucfirst = $uc ) =~ tr/[^]//d;
			  if ($ucfirst eq $word) { $forms{$uc} = $count; last TEST; }

			  ( my $lcfirst = $lc ) =~ tr/[^]//d;
			  if ($lcfirst eq $word) { $forms{$lc} = $count; last TEST; }
			  
			  #If gone this far, then move forward.
			  next;
		  }
		}
		unless( %forms) { print STDERR "No forms for $word\n"; }
		
		# Print the output.
		for my $key (sort { $forms{$b} <=> $forms{$a}} keys %forms) {
			print "$word\t$key\n";
			last;
		}
		print "\n";
	} # while
