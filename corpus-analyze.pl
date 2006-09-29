#!/usr/bin/perl -w
use strict;

# corpus-analyze.pl
#
# Perl script for analyzing corpus files for storing 
# to the grammatical corpus interface.
# --tags=<file_name>
# --input=<file_name> (default STDIN)
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
# Typical usage: ccat --add-id docu.xml | corpus-analyze.pl
#
# $Id$

use XML::Twig;
binmode STDOUT, ":utf8";
use IPC::Open2;
use open ':utf8';
use POSIX qw(locale_h);
use Getopt::Long;

my $lang="sme";
my $s_id=0;
my $add_sentences=0;
my $only_add_sentences=0;
my $tagfile = "/usr/tmp/gt/cwb/korpustags.txt";

my $infile;
my $outfile="out.tmp";
GetOptions ("tags=s" => \$tagfile,
            "input=s" => \$infile,
			"output=s" => \$outfile,
			"add_sentences" => \$add_sentences,
			"only_add_sentences" => \$only_add_sentences,
			"lang=s" => \$lang,
);

my $binpath="/opt/smi/$lang/bin";

my $cap = $binpath ."/". "cap-" . $lang;
my $fst = $binpath ."/". $lang . ".fst";
my $abbr = $binpath ."/abbr.txt";
my $rle = $binpath ."/". $lang ."-dis.rle";
my $preproc = "/usr/local/bin/preprocess";
my $lookup2cg = "/usr/local/bin/lookup2cg";
my $corrtypos="/home/trond/bin/corrtypos.pl";
my $lookup="/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup";
my $vislcg="/opt/xerox/bin/vislcg";

my $ifh;
if ($infile) {
	open ($ifh, "< $infile") or die "Can't open $infile: $!";
}
else { $ifh = 'STDIN'; }

my $analyze = "$preproc --abbr=$abbr --fst=$fst | $corrtypos | $lookup -flags mbTT -utf8 -f $cap | $lookup2cg | $vislcg --grammar=$rle --quiet";

my $preprocess = "$preproc --abbr=$abbr --fst=$fst";

my $SENT_DELIM = qq|.!?|;

# Read the tags
my %tags;
&read_tags(\%tags);

##### Start processing the input 
# Read input to a string.
my $string;
while(<$ifh>) {
	$string .= $_;
}

if(! $string) { exit; }

my $document;

# Do not analyze, only add <s>-tags.
if ($only_add_sentences) {
	$document = XML::Twig->new(twig_handlers => {  'p' => sub { add_sentences(@_);
																keep_encoding => 1 } });
	if (! $document->safe_parse ($string)) {
		print STDERR "Couldn't parse file: $@";
	}
}
# Otherwise analyze each para and add sentences
elsif ( $add_sentences) {
    print STDERR $analyze;
	$document = XML::Twig->new(twig_handlers => {  'p' => sub { analyze_block(@_, "para");
																   keep_encoding => 1 } });	
	if (! $document->safe_parse ($string)) {
		print STDERR "Couldn't parse file: $@";
	}
}
# Otherwise analyze each sentence
else {
    print STDERR $analyze;
	$document = XML::Twig->new(twig_handlers => {  's' => sub { analyze_block(@_, "sentence");
																   keep_encoding => 1 } });
	if (! $document->safe_parse ($string)) {
		print STDERR "Couldn't parse file: $@";
	}
}


open (FH, ">:utf8", "$outfile") or die "Cannot open $!";
$document->set_pretty_print('record');
$document->print( \*FH);
$document->purge;
close(FH);


sub add_sentences {
	my ($twig, $para) = @_;

	my @answers;

	$para->set_asis;
	my $text = $para->text;
	print "$text\n";

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
	print @answers;
  WORDS:
	for $ans (@answers) {
		chomp $ans;
		
		# ignore empty lines
		next WORDS if $ans =~ /^\s*$/;

		if (! $sentence) {
			# create an XML-element for a new sentence.
			$sentence = XML::Twig::Elt->new('s');
			$sentence->set_att('id', $s_id++);
		}
		
		push (@words, $ans);
		push (@words, " ");

		if ($ans =~ /^[$SENT_DELIM]$/) {
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

sub analyze_block {
	my ($twig, $block, $type) = @_;

	my @answers;

	my $cohort_rec;
	my @tokens;

	$block->set_asis;

	my $text = $block->text;
	print "$text\n";
	$text =~ s/\n/ /g;
	
	my $pid = open2(\*R,\*W, $analyze); 
	$pid || die "did not work as expected:$!"; 

	binmode R, ':utf8';
	binmode W, ':utf8';

	print W "$text\n";
	close W;
	while( my $answer = <R>) { push (@answers, $answer); }
	close R;

	waitpid $pid, 0 ;

  COHORTS:
	for my $ans (@answers) {

		# ignore empty lines
		next COHORTS if $ans =~ /^\s*$/;

		# Test the start of the cohort.
		if ($ans =~ /^\"</) {
		# Save the cohort from last round.
			if ($cohort_rec) {
				push @tokens, $cohort_rec;
				undef $cohort_rec;
			}
			# Read the word and go to next line.
			$cohort_rec->{WORD} = $ans;
			next COHORTS;
		}
		# If not at the start of the cohort, 
		# read the analysis line
		else {
			# store the line with Correct-tag to an array.
			push ( @ { $cohort_rec->{READING} }, $ans); 
			next COHORTS;
		}
	}
	if ($cohort_rec) {
		push @tokens, $cohort_rec;
	}
	add_structure(\@tokens, \%tags, $block, $type);
}

# Subroutine to add <s> tags and print out the result.
sub add_structure {
	my ($tokens_aref, $tags_href, $block, $type) = @_;

	my @sentences;
	my @tokens;
	my $sentence;

	while (my $token_rec = shift @$tokens_aref) {

		# Create a new XML-element for the token
		my $token = XML::Twig::Elt->new('w');
		if($type eq "para" && ! $sentence ) { 
			$sentence = XML::Twig::Elt->new('s');
			$sentence->set_att('id', $s_id++);
		}

		$token_rec->{WORD} =~ s/^\"<(.*)?>\".*$/$1/;
		chomp $token_rec->{WORD};
		$token->set_att('form', $token_rec->{WORD});

		while (my $correct = shift @{$token_rec->{READING}} ) {
		
			# Create a new XML element for each reading.
			my $reading = XML::Twig::Elt->new('reading');
			
			$correct =~ s/^\s+//;
			my ($base, @tag_list) = split(/\s/, $correct);
			$base =~ s/\"//g;

			# Remove ^ and # from lemma for now.
			$base =~ s/[\^\#]//g;

			# Process each tag and store them to XML attributes
			# for the reading.
			for my $tag (@tag_list) {
				for my $class (keys %$tags_href) {
					if ( exists $$tags_href{$class}{$tag} ) {
						# Store the tag to XML attribute of the reading
						$reading->set_att($class, $tag);		
					}
				}
			}
			# Store the base form to XML attributes of the token.
			$reading->set_att('lemma', $base);

			# Store the reading to child of the token in XML tree
			$reading->paste('last_child', $token);
		} # end while readings

		push (@tokens, $token);

		if ($type eq "para" && $token_rec->{WORD} =~ /^[$SENT_DELIM]$/) {
			$sentence->set_content(@tokens);
			push @sentences, $sentence;
			$sentence->DESTROY;
			$sentence=undef;
			@tokens=undef;
			pop @tokens;
		}

	} # end while tokens

	if($type eq "para") {
		if (@tokens) {
			$sentence->set_content(@tokens);
		}		
		if ($sentence) {
			push (@sentences, $sentence);
		}
		if (@sentences) {
			$block->set_content(@sentences);
		}
	}
	else { $block->set_content(@tokens); }
}

# Subroutine to read the morphological tags from a file
sub read_tags {
	my ($tags_href) = shift @_;

	# Read from tag file and store to an array.
	open TAGS, "< $tagfile" or die "Cant open the file: $!\n";
	my @tags;
	my $tag_class;
  TAG_FILE:
	while (<TAGS>) {
		chomp;
		next if /^\s*$/;
		next if /^%/;
		next if /^$/;

		if (s/^#//) {
			$tag_class = $_;
			for my $tag (@tags) {
				$$tags_href{$tag_class}{$tag} = 1;
			}
			undef @tags;
			pop @tags;
			next TAG_FILE;
		}
		my @tag_a = split (/\s+/, $_);
		unshift @tags, $tag_a[0];
 	}

	close TAGS;
}
