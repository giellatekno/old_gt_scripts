#!/usr/bin/perl -w
use strict;

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
binmode STDOUT, ":utf8";
use IPC::Open2;
use open ':utf8';
use POSIX qw(locale_h);
use Getopt::Long;
use langTools::XMLStruct;
use langTools::Util;

my $tagfile;
my $lang="sme";

my $binpath="/opt/smi/$lang/bin";
my $s_id=0;
my $p_num=0;
my $w_num=0;
my $add_sentences=0;
my $only_add_sentences=0;
my $tables=0;
my $lists=0;
my $all=0;

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
			"all|a=s" => \$all,
			"help|h" => \$help,
);

if ($help) {
	&print_help;
	exit 1;
}

my $lookup2cg = "/usr/local/bin/lookup2cg";
my $lookup = "/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup";
my $vislcg = "/opt/xerox/bin/vislcg";
my  $corrtypos = $binpath . "/". "typos.txt";
my $cap = $binpath ."/" . "cap-" . $lang;
my $fst = $binpath ."/". $lang . ".fst";
my $abbr = $binpath ."/abbr.txt";
my $rle = $binpath ."/". $lang ."-dis.rle";
my $preproc = "/usr/local/bin/preprocess";

if(! $tagfile) { $tagfile = "/opt/smi/common/bin/korpustags.txt"; }

my $host=`hostname`;
# If we are in G5
if ($host =~ /hum-tf4-ans142/) {
    $lookup="lookup";
    $vislcg="vislcg";
}

$vislcg .= " --grammar=$rle --quiet";
my $disamb = "$lookup2cg | $vislcg";

my $analyze = "$preproc | $lookup -flags mbTT -utf8 -f $cap 2>/dev/null | $lookup2cg | $vislcg";

my $preprocess;
if( $lang =~ /(sme|smj|sma)/) { $preprocess = "$preproc --abbr=$abbr --fst=$fst --corr=$corrtypos"; }
elsif ($lang =~ /nob/) { 
	$preprocess = "$preproc --abbr=$abbr";
}
else { $preprocess = "$preproc"; }

my $SENT_DELIM = qq|.!?|;

# Read the tags
my %tags;
&read_tags($tagfile, \%tags);

# Process the file given in command line.
if ( -f $ARGV[$#ARGV]) { $infile = $ARGV[$#ARGV]; }
if ($infile && ! $outfile) { $outfile = "out.tmp"; }  #$outfile=$infile . ".analyzed"; }

my $document;

# Do not analyze, only add <s>-tags.
if ($only_add_sentences) {
	$document = XML::Twig->new(twig_handlers => {  'p' => sub { add_sentences(@_);
																keep_encoding => 1 } });
	if (! $document->safe_parsefile ($infile)) {
		print STDERR "Couldn't parse file $infile: $@";
	}
}
# Otherwise analyze each para and add sentences
else {
    print STDERR "$analyze\n";
	open (FH, ">/Users/saara/koe.out");
    
  PARSE: {
      if(($tables && $lists) | $all) {
	      $document = XML::Twig->new(twig_handlers => {  
			  'p' => sub { analyze_para(@_); 
						   keep_encoding => 1 } });
	      last PARSE;
	  }
	  if (! $tables && ! $lists) {
		  $document = XML::Twig->new(twig_handlers => { 
			  'table' => sub{ $_->delete; },
			  'list' => sub{ $_->delete; },
			  'p' => sub { analyze_para(@_); },
			  keep_encoding => 1 });
		  last PARSE;
	  } 
	  if ($tables && ! $lists) {
		  $document = XML::Twig->new(twig_handlers => {  
			  'list' => sub{ $_->delete; },
			  'table' => sub { $_->erase; },
			  'row' => sub { $_->erase; },
			  'p' => sub { analyze_para(@_);
						   keep_encoding => 1 } });	
		  last PARSE;
	  }
	  if (! $tables && $lists) {
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
	
}

open (FH, ">:utf8", "$outfile") or die "Cannot open $!";
$document->set_pretty_print('record');
$document->print( \*FH);
$document->purge;
close(FH);

my $error = system("xmllint --valid --encode UTF-8 --noout \"$outfile\"");
if ($error) { print STDERR "ERROR: $error\n"; }


####### subroutines from here on ########

sub add_sentences {
	my ($twig, $para) = @_;

	my @answers;

	$para->set_asis;
	my $text = $para->text;

	for my $c ($para->children) {
		$c->delete;
	}

	$text =~ s/\n/ /g;
	
	my $pid = open2(\*R,\*W, $preprocess); 
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

  WORDS:
	for $ans (@answers) {
		chomp $ans;
		
		# ignore empty lines
		next WORDS if $ans =~ /^\s*$/;

		if (! $sentence) {
			# create an XML-element for a new sentence.
			$sentence = XML::Twig::Elt->new('s');
			my $id = "s" . $s_id++;
			$sentence->set_att('id', $id);
		}
		
		push (@words, $ans);
		push (@words, " ");

		# Skip empty sentences.
		if ($ans =~ /^[$SENT_DELIM]$/) {
			if($#words==1 && $words[0] =~ /^[\W\s]*$/) {
				next;
			}
			$sentence->set_content(@words);
			$sentence->paste('last_child', $para);
			$sentence->DESTROY;
			$sentence=undef;
			@words=undef;
			pop @words;
			next WORDS;
		}
	}
	if ($ans) { push (@words, $ans); }

	# Skip empty sentences.
	if($#words==1 && $words[0] =~ /^[\W\s]*$/) {
		return;
	}
	if (@words) {
		if (! $sentence) {
			# create an XML-element for a new sentence.
			$sentence = XML::Twig::Elt->new('s');
			$sentence->set_att('id', $s_id++);
		}
		$sentence->set_content(@words);
		$sentence->paste('last_child', $para);
	}
}

sub analyze_para {
	my ($twig, $para) = @_;

	if (! $para->{'att'}->{'id'}) { 
		my $id = "p" . $p_num++;
		$para->set_att('id', $id);
	}
	my @sent = $para->children;
	if (@sent) {
		for my $s (@sent) {
			my $id = $s->{'att'}->{'id'};
			if ($id) { print "$id "; }
			analyze_sent($s);
		}
	}
	$para->print(\*FH)
}

sub analyze_sent {
	my $sent = shift @_;

	my $disambiguated;
	
	my $cohort_rec;
	my @tokens;

	$sent->set_asis;

	my $text = $sent->text;
	$text =~ s/\n/ /g;
	
	#print $text;
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
	my $token = dis2corpus_xml($disambiguated, \%tags, \$w_num);
	
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

