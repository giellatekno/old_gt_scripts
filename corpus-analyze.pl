#!/usr/bin/perl -w
use strict;

# corpus-analyze.pl
#
# Perl script for analyzing corpus files for storing 
# to the grammatical corpus interface.
# The input to the script consist of start and end tags, e.g 
# <document> ... </document> and inside them, a set of paragraphs in
# <p>-tags. Each paragraph is send to complete analysis and the 
# output stored to a separate file. The sentences are surrounded with
# <s>-tags. 
#
# Typical usage: ccat --add-id docu.xml | corpus-analyze.pl
#
# $Id$

use XML::Twig;
binmode STDOUT, ":utf8";

use IPC::Open2;
use open ':utf8';

use POSIX qw(locale_h);

my $lang="sme";
my $binpath="/opt/smi/$lang/bin/";

my $fst = $binpath ."/". $lang .".fst";
my $abbr = $binpath ."/abbr.txt";
my $rle = $binpath ."/". $lang ."-dis.rle";
my $preproc = "/usr/local/bin/preprocess";
my $lookup2cg = "/usr/local/bin/lookup2cg";

my $analyze = "$preproc --abbr=$abbr | lookup -d -flags mbTT -utf8 $fst | $lookup2cg | vislcg --grammar=$rle --quiet";

# Read input to a string.
my $string;
while(<>) {
	$string .= $_;
}

my $document = XML::Twig->new(twig_handlers => {  'p' => sub { analyze_para(@_); } });

if (! $document->safe_parse ($string)) {
	print STDERR "Couldn't parse file: $@";
}
open (FH, ">:utf8", "out.tmp") or die "Cannot open $!";
$document->set_pretty_print('indented');
$document->print( \*FH);
$document->purge;
close(FH);



sub analyze_para {
	my ($twig, $para) = @_;
	
	my @answers;
	
	my $text = $para->text;
	$text =~ s/\n/ /g;

	my $pid = open2(\*R,\*W, $analyze); 
	$pid || die "did not work as expected:$!"; 

	binmode R, ':utf8';
	binmode W, ':utf8';

	print W "$text\n";
	close W;
	while( my $answer = <R>) { push (@answers, $answer); }

	# Add <s> tags and format output.
	my @analyzed;
	my $ans;
	my @prev_s;
	while(@answers) {
		$ans = shift @answers;
		$ans =~ s/(\"<|>\")//g;
		push @prev_s, $ans;
		
		if ($ans =~ /\"[\.\?\!]\"/) {
			my $s = XML::Twig::Elt->new( 's');
			$s->set_content(@prev_s);
			@prev_s = "";
			pop @prev_s;
			push (@analyzed, $s);
			next;
		}
	}
	if(@prev_s) {
		my $s = XML::Twig::Elt->new( 's');
		$s->set_content(@prev_s);
		@prev_s = "";
		pop @prev_s;
		push (@analyzed, $s);
	}
	$para->set_content(@analyzed);
}
