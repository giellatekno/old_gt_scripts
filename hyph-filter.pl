#!/usr/bin/perl -w

use strict;

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
while(<>) {	
	
#	print;

	my @Analyses;
	my %forms;
	my %rated;
	
	my $word;
	my $hyph;
	my $compound = 0;
	my $max_boundary_count = 0;
	my $min_boundary_count = 5;
	my $max_comp_rate = 0;
	my $boundary_count;

	my @lines = split(/\n/, $_);
	if ($#lines == 0) { print; next; }
	for my $line (@lines) {
		# store word to a scalar and
		# analysis (=base form and tags) to an array
		my $analysis;
		($word, $hyph) = split(/\t/, $line, 2);

		if ($hyph) {
			#remove word boundary from the beginning of the word.
			$hyph =~ s/^\#//;
			( my $cleaned = $hyph ) =~ tr/[\#^]//d;

			next if ($word ne $cleaned);
			$forms{$hyph} = 1;
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

	unless( keys %forms) { print STDERR "No forms for $word\n"; }
 	
	# Print the output.
	for my $key (keys %forms) {
		print "$word\t$key\n\n";
	}
} # while
