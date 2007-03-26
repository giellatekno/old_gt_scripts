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
		(.*?)              # match the text without corrections
		\b
		([^\s]*)           # string before the error-correction separator
		\x{00A7}           # separator
		(                  # either
		\(.*?\)|         # string after separator, possible parentheses
		[^\s]*?\s         # string after separator, no parentheses
		)
		(.*)            # rest of the string.
		$/x ) {

		$newpara = $1;
		my $error = $2;
		my $rest = $4;

		(my $corr = $3) =~ s/\s?$//;
		$corr =~ s/[\(\)]//g;
		$newpara .= "<error correct=\"$corr\">$error</error> ";
		if ($rest) { $newpara .= handle_para($rest); }
	}
	return $newpara;
}
