#!/usr/bin/perl -w
use strict;
use utf8;
binmode( STDIN, ':utf8' );
binmode( STDOUT, ':utf8' );
binmode( STDERR, ':utf8' );
use open 'utf8';


# corpus-analyze.pl [OPTIONS] [FILE]
#
# Perl script for analyzing corpus files for storing 
# to the grammatical corpus interface.
# --tags=<file_name>
# --output=<file_name> (default tmp.out)
# --add_sentences
# --only_add_sentences
#
# The input to the script consist of start and end tags, e.g 
# <document> ... </document> and inside them, a set of paragraphs in
# <p>-tags. Each paragraph is send to complete analysis and the 
# output stored to a separate file. The <s>-tags are assumed in input,
# but they can be added as well, with option --add_sentences. 
#
# It is possible to add <s>-tags with ids to the structure without
# analyzing the words, with option --only_add_sentences. 
# The parallel files are preprocessed with this option.
#
# Typical usage: 
# ccat --add-id docu.xml file.xml > file.tmp 
# corpus-analyze.pl --input=file.tmp
#
# $Id$

use XML::Twig;
use IPC::Open2;
use POSIX qw(locale_h);
use Getopt::Long;
use langTools::XMLStruct;
use langTools::Util;
use File::Basename;

my $tagfile;
my $lang="sme";

my $s_id=0;
my $p_num=0;
my $w_num=0;
my $add_sentences=0;
my $only_add_sentences=0;
my $tables=0;
my $lists=0;
my $all=0;
my $onelang=0;

my $infile;
my $outfile;
my $help;
Getopt::Long::Configure ("bundling");
GetOptions ("tags=s" => \$tagfile,
			"output=s" => \$outfile,
			"add_sentences|s" => \$add_sentences,
			"only_add_sentences|o" => \$only_add_sentences,
			"lang=s" => \$lang,
			"lists|l=s" => \$lists,
			"tables|t=s" => \$tables,
			"all|a" => \$all,
			"onelang" => \$onelang,
			"help|h" => \$help,
);

if ($help) {
	&print_help;
	exit 1;
}

#my $binpath="/opt/smi/$lang/bin";
my $binpath="/Users/saara/opt/smi/$lang/bin";
my $lookup2cg = "/usr/local/bin/lookup2cg";
#my $lookup = "/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup";
my $lookup = "/usr/local/bin/lookup";
my $vislcg = "/usr/local/bin/vislcg";
my  $corrtypos = $binpath . "/". "typos.txt";
my $cap = $binpath ."/" . "cap-" . $lang;
my $fst = $binpath ."/". $lang . ".fst";
my $abbr = $binpath ."/abbr.txt";
my $rle = $binpath ."/". $lang ."-dis.rle";
#my $preproc = "/usr/local/bin/preprocess";
my $preproc = "/Users/saara/gt/script/preprocess";

if(! $tagfile) { 
	$tagfile = "/Users/saara/opt/smi/$lang/bin/korpustags.$lang.txt";
}
if(! -f $tagfile) { 
	$tagfile = "/Users/saara/opt/smi/common/bin/korpustags.txt"; 
}
print "Using tags $tagfile\n";

my $host=`hostname`;

$vislcg .= " --grammar=$rle --quiet";
my $disamb = "$lookup2cg | $vislcg";

my $preprocess;
if( $lang =~ /(sme|smj|sma)/) { $preprocess = "$preproc --abbr=$abbr --corr=$corrtypos"; }
elsif ($lang =~ /nob/) { 
	$preprocess = "$preproc --abbr=$abbr";
}
else { $preprocess = "$preproc"; }
my $preprocess_break = "$preprocess --break='<<<'";


my $analyze = "$preprocess | $lookup -flags mbTT -utf8 -f $cap 2>/dev/null | $lookup2cg | $vislcg";

my $SENT_DELIM = qq|.!?|;
my $LEFT_QUOTE = qq|<([{«‹“‘|;
						 
# Read the tags
my %tags;
my %tmptags;
if (! $only_add_sentences) {
	&read_tags($tagfile, \%tmptags);
	for my $class (keys %tmptags) {
		for my $tag (@{$tmptags{$class}}) { $tags{$class}{$tag}=1; }
	}
}
						 
# Process the file given in command line.
if ( -f $ARGV[$#ARGV]) { $infile = $ARGV[$#ARGV]; }
if ($infile && ! $outfile) { $outfile = "out.tmp"; }

my($id, $directories, $suffix) = fileparse($outfile);
$id =~ s/\.(.*)+$//;
print "$id\n";
				 
my $document;

my $OFH;						 
open ($OFH, ">$outfile");
print $OFH qq|<?xml version='1.0'  encoding="UTF-8"?>|;
print $OFH qq|\n<!DOCTYPE document PUBLIC "-//UIT//DTD Corpus V1.0//EN" "http://giellatekno.uit.no/dtd/corpus.dtd">\n|;
print $OFH qq|<document id="$id">|;

$document = XML::Twig->new(twig_handlers => {  
	'header' => sub { $_->set_pretty_print("record"); $_->print($OFH); }
});

if (! $document->safe_parsefile ($infile)) {
	print STDERR "Couldn't parse file $infile: $@";
}

print $OFH qq|<body>|;

if (! $only_add_sentences) { print "** Analyzing $infile:\n$analyze\n"; }
else { 	print "** Preprocessing $infile:\n$preprocess_break\n"; }
						 

PARSE: {
	 if(($tables && $lists) | $all) {
	 if ($only_add_sentences) {
		 $document = XML::Twig->new(twig_handlers => {  
			 'p' => sub { add_sentences(@_);
						  keep_encoding => 1 } }
									);
		 last PARSE;
	 }
	 $document = XML::Twig->new(twig_handlers => { 
		 'p' => sub { analyze_para(@_); 
					  keep_encoding => 1 } }
								);
	 last PARSE;
 }
	 if (! $tables && ! $lists) {
		 if ($only_add_sentences) {
			 $document = XML::Twig->new(twig_handlers => { 
			 'header'=> sub { $_->set_pretty_print('indented'); $_->print(\*OFH); print OFH qq|\n<body>|; },
				 'table' => sub{ $_->delete; },
				 'list' => sub{ $_->delete; },
				 'p' => sub { add_sentences(@_); },
				keep_encoding => 1 });
			 last PARSE;
		 }
		 $document = XML::Twig->new(twig_handlers => { 
			 'header'=> sub { $_->set_pretty_print('indented'); $_->print(\*OFH); print OFH qq|\n<body>|; },
			 'table' => sub{ $_->delete; },
			 'list' => sub{ $_->delete; },
			 'p' => sub { analyze_para(@_); },
			 keep_encoding => 1 });
		 last PARSE;
	 } 
	 if ($tables && ! $lists) {
		 if ($only_add_sentences) {
			 $document = XML::Twig->new(twig_handlers => {  
				 'list' => sub{ $_->delete; },
				 'table' => sub { $_->erase; },
				 'row' => sub { $_->erase; },
				 'p' => sub { add_sentences(@_);
							  keep_encoding => 1 } });	
			 last PARSE;
		 }
		 $document = XML::Twig->new(twig_handlers => {  
			 'list' => sub{ $_->delete; },
			 'table' => sub { $_->erase; },
			 'row' => sub { $_->erase; },
			 'p' => sub { analyze_para(@_);
						  keep_encoding => 1 } });	
		 last PARSE;

	 }
	 if (! $tables && $lists) {
		 if ($only_add_sentences) {
			 $document = XML::Twig->new(twig_handlers => {  
				 'table' => sub{ $_->delete; },
				 'list' => sub { $_->erase; },
				 'p' => sub { add_sentences(@_);
							  keep_encoding => 1 } });	
			 last PARSE;
		 }
		 $document = XML::Twig->new(twig_handlers => {  
			 'table' => sub{ $_->delete; },
			 'list' => sub { $_->erase; },
			 'p' => sub { analyze_para(@_);
						  keep_encoding => 1 } });	
		 last PARSE;
	 }
  } # end of PARSE

if (! $document->safe_parsefile ($infile)) {
	print STDERR "Couldn't parse file: $@";
}

print $OFH "\n</body>";
print $OFH "\n</document>";
close $OFH;

my $error = system("xmllint --valid --encode UTF-8 --noout \"$outfile\"");
if ($error) { print STDERR "ERROR: $error\n"; }


####### subroutines from here on ########

sub add_sentences {
	my ($twig, $para) = @_;

	my @answers;

	for my $c ($para->children('error')) {
		my $correct = $c->{'att'}->{'correct'};
		$c->set_text($correct);
	}

	if($onelang && $para->{'att'}->{'xml:lang'}) {
		my $paralang = $para->{'att'}->{'xml:lang'};
		if ( $paralang ne $lang) {
			$para->delete;
			return;
		}
	}

	$para->set_asis;
	my $text = $para->text;

	for my $c ($para->children) { $c->delete; }

	$text =~ s/\n/ /g;
	
	my $pid = open2(\*R,\*W, $preprocess_break); 
	$pid || die "did not work as expected:$!"; 

	binmode R, ':utf8';
	binmode W, ':utf8';

	print W "$text\n";
	close W;
	while( my $answer = <R>) { push (@answers, $answer); }
	close R;

	waitpid $pid, 0 ;	

	my $sentence;
	my @words;
	my $ans;
	my @prev_sent;
	my $sentence_end = 0;

  WORDS:
	for $ans (@answers) {
		chomp $ans;

		# ignore empty lines
		next WORDS if $ans =~ /^\s*$/;
		$ans =~ s/\s*$//;
		$ans =~ s/^\s*//;

		# Add lonely punctuation to the end of the previous sentence.
		if ($ans !~ /\w/ && $ans !~ /^[$SENT_DELIM]$/ && $ans !~ /<<</ && $ans !~ /[$LEFT_QUOTE\p{Pd}]/) {
			push (@words, $ans);
			push (@words, " ");
			next;
		}
		# Change too long capitalized strings to small letters.
		if ($ans =~ /\b.*?[\p{isUpper}]{18,}.*?\b/) {
			$ans = ucfirst(lc($ans));
		}

		if ($sentence_end) {
			$sentence->set_content(@prev_sent, @words);
			$sentence->paste('last_child', $para);
			$sentence->DESTROY;
			$sentence=undef;
			@words=undef;
			pop @words;
			@prev_sent=undef;
			pop @prev_sent;

			$sentence_end = 0;
		}

		push (@words, $ans);
		push (@words, " ");

		if (! $sentence) {
			# create an XML-element for a new sentence.
			$sentence = XML::Twig::Elt->new('s');
			my $id = $id . "_s" . $s_id++;
			$sentence->set_att('id', $id);
		}

		# Skip empty sentences.
		if ($ans =~ /^[$SENT_DELIM]$/ || $ans =~ /<<</) {
			if ($ans =~ /<<</) { pop @words; pop @words; }
			my $string = join ("", @words);
			if($string !~ /\w/) {
				push(@prev_sent, @words);
				undef @words;
				next;
			}
			$sentence_end=1;
		}
	}
	if ($ans) { push (@words, $ans); }

	# Skip empty sentences.
	if(@words && $#words<3 && $words[0] =~ /^[\W\s]*$/) {
		print "Empty: @words\n";
		$para->set_pretty_print("record");
		$para->print($OFH);
		$para->delete;
		return;
	}

	if (@words) {
		if (! $sentence) {
			# create an XML-element for a new sentence.
			$sentence = XML::Twig::Elt->new('s');
			my $sid = $id . "_s" . $s_id;
			$sentence->set_att('id', $sid);
			$s_id++;
		}

		$sentence->set_content(@prev_sent, @words);
		undef @prev_sent;
		$sentence->paste('last_child', $para);
	  }
	
	$para->set_pretty_print("record");
	$para->print($OFH);
	$para->delete;
}

sub analyze_para {
	my ($twig, $para) = @_;

	for my $c ($para->children('error')) {
		my $correct = $c->{'att'}->{'correct'};
		$c->set_text($correct);
	}

	if (! $para->{'att'}->{'id'}) { 
		my $pid = $id . "_p" . $p_num++;
		$para->set_att('id', $pid);
	}
	my @sent = $para->children;
	if (@sent) {
		for my $s (@sent) {
			my $id = $s->{'att'}->{'id'};
			if ($id) { print "$id "; }
			analyze_sent($s);
		}
	}
	$para->set_pretty_print("record");
	$para->print($OFH);
	$para->delete;
}

sub analyze_sent {
	my $sent = shift @_;

	my $disambiguated;
	
	my $cohort_rec;
	my @tokens;

	$sent->set_asis;

	my $text = $sent->text;
	$text =~ s/\n/ /g;
	
	#print "TEXT $text";
	my $pid = open2(\*R,\*W, $analyze); 
	$pid || die "did not work as expected:$!";

	binmode R, ':utf8';
	binmode W, ':utf8';

	print W "$text\n";
	close W;
	while( my $answer = <R>) { $disambiguated .= $answer; }
	close R;

	waitpid $pid, 0 ;
	
	#print $disambiguated;
	my $token = dis2corpus_xml($disambiguated, \%tags, \$w_num, $id);
	
	my @children = $token->cut_children;
	$sent->set_content(@children); 
}


sub print_help {
	print << "END";
Analyzes and modifies corpus files with xml-structure.
Usage: corpus-analyze.pl [OPTIONS] [FILE]
--help               Print this help text and exit.
--tags               Location of the file korpustags.txt
--output=<file>      The file for output.
--add_sentences      Add <s>-tags to the file during the analysis.
                     Use with files which are not aligned.
--only_add_sentences Adds <s> tags using preprocessor and abbr.txt
                     Does not analyze.
--lang=<lang>        The main language of the document. The language
                     defines the path to the tools.
END

}

