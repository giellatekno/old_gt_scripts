#!/usr/bin/perl
#
# add_error_marking.pl FILE 
#
# Perl-script for replaceing erorr§error markup with
# <error correct="error">erorr</error>
#
# $Id$

use strict;
use utf8;

while(<>) {

	my $newpara = $_;
	if ($newpara =~ /\x{00A7}/) {
		$newpara = handle_para($_);
	}
	print $newpara;
}

sub handle_para {
	my $para = shift @_;

	my $newpara;
	if ($para =~ m/^
		(.*?)            # match the text without corrections
		\s
		(<.*?>)?          # skip xml-tags.
		([^\s]*?)           # string before the error-correction separator
		\x{00A7}           # separator
		(                  # either
		\(.*?\)|         # string after separator, possible parentheses
		[^\s]*?\s         # string after separator, no parentheses
		)
		(.*)           # rest of the string.
		$/x ) {

		my $start = $1;
		my $tag = $2;
		my $error = $3;
		my $correct = $4;
		$error =~ s/\s$//g;
		my $rest = $5;

		(my $corr = $4) =~ s/\s?$//;
		$corr =~ s/[\(\)]//g;
		$newpara = $start;
		$newpara .= $tag . " <error correct=\"$corr\">$error</error> ";
		if ($rest =~ /\x{00A7}/) { $newpara .= handle_para($rest); }
		else { $newpara .= $rest; }
	}
	else { $newpara = $para; }
	return $newpara;
}
