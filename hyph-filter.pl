#!/usr/bin/perl -w

use strict;
#binmode STDOUT, ":utf8";
#binmode STDIN, ":utf8";
#use utf8;

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

# change this to 1 when used with smi.cgi.
my $take_only_one=0;

# Read while not eol
INPUT:
	while(<>) {	
		my %forms;
		
		my $word;
		my $hyph;
		my $compound = 0;
		my $max_boundary_count = 0;
		my $min_boundary_count = 5;
		my $max_comp_rate = 0;
		my $boundary_count;
		
		chomp;
		my @lines = split(/\n/, $_);
		
		for my $line (@lines) {
			chomp;
			($word, $hyph) = split(/\t/, $line);

			if ($#lines == 0 and $word eq $hyph && $line !~ /\+\?/) {
				print; 
				print "\n\n"; 
				next INPUT; 
			}

			#remove word boundary from the beginning of the word.
			$hyph =~ s/^\#//;

			# take the upper case and lower case forms.
			my $uc = ucfirst($hyph);
			my $lc = lcfirst($hyph);
			
			# remove all the other wb:s
			( my $cleaned = $hyph ) =~ tr/[\#^]//d;
			
		  TEST: {
			  if ($word eq $cleaned) { $forms{$hyph} = 1; last TEST; }
			  
			  ( my $ucfirst = $uc ) =~ tr/[\#^]//d;
			  if ($ucfirst eq $word) { $forms{$uc} = 1; last TEST; }

			  ( my $lcfirst = $lc ) =~ tr/[\#^]//d;
			  if ($lcfirst eq $word) { $forms{$lc} = 1; last TEST; }
			  
			  #If gone this far, then move forward.
			  next;
		  }
			# Get the min and max boundary counts.
			my $boundary_count = ( $hyph  =~ tr/\#// );
			if ($boundary_count > $max_boundary_count) { $max_boundary_count = $boundary_count; }
			if ( $boundary_count < $min_boundary_count) { $min_boundary_count = $boundary_count; }
		}
		
	  RATE_COMP: {
		  # If there were no boundaries
		  last RATE_COMP if ( $max_boundary_count == 0 );
		  
		  # If the least amount of boundaries was 0,
		  # All the forms with # are removed.
		  if( $min_boundary_count == 0) {
			  for (keys %forms) { if (/\#/) { delete($forms{$_}); } }
			  last RATE_COMP;
		  }
		  # If there were more than one word boundary in each form,
		  # only preserve the form that has least word boundaries.
		  for (keys %forms) {
			  my $boundary_count = tr/\#//;
			  if ( $boundary_count > $min_boundary_count )
			  { delete($forms{$_}); }		  
		  }
	  } #RATE_COMP
		
		unless( %forms) { print STDERR "No forms for $word\n"; }
		
		# Print the output.
		for my $key (keys %forms) {
			print "$word\t$key\n";
			if($take_only_one) {
				last;
			}
		}
		print "\n";
	} # while
