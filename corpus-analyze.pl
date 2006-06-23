#!/usr/bin/perl -w
use strict;

# corpus-analyze.pl
#
# Perl script for analyzing corpus files for storing 
# to the grammatical corpus interface.
# --tags=<file_name>
# --input=<file_name> (default STDIN)
# --output=<file_name> (default tmp.out)
#
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
use Getopt::Long;

my $lang="sme";
my $binpath="/opt/smi/$lang/bin";

my $cap = $binpath ."/". "cap-" . $lang;
my $fst = $binpath ."/". $lang . ".fst";
my $abbr = $binpath ."/abbr.txt";
my $rle = $binpath ."/". $lang ."-dis.rle";
my $preproc = "/usr/local/bin/preprocess";
my $lookup2cg = "/usr/local/bin/lookup2cg";
my $tagfile = "/usr/tmp/gt/cwb/korpustags.txt";
my $corrtypos="/home/trond/bin/corrtypos.pl";
my $s_id=0;

my $infile;
my $outfile="out.tmp";
GetOptions ("tags=s" => \$tagfile,
            "input=s" => \$infile,
			"output=s" => \$outfile);

my $ifh;
if ($infile) {
	open ($ifh, "< $infile") or die "Can't open $infile: $!";
}
else { $ifh = 'STDIN'; }

my $analyze = "$preproc --abbr=$abbr --fst=$fst | $corrtypos | lookup -flags mbTT -utf8 -f $cap | $lookup2cg | vislcg --grammar=$rle --quiet";
print STDERR $analyze;

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

my $document = XML::Twig->new(twig_handlers => {  'p' => sub { analyze_para(@_);
														   keep_encoding => 1 } });

if (! $document->safe_parse ($string)) {
	print STDERR "Couldn't parse file: $@";
}
open (FH, ">:utf8", "$outfile") or die "Cannot open $!";
$document->set_pretty_print('record');
$document->print( \*FH);
$document->purge;
close(FH);

sub analyze_para {
	my ($twig, $para) = @_;
	
	my @answers;

	my $cohort_rec;
	my @tokens;

	$para->set_asis;

	my $text = $para->text;
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
	add_sentence(\@tokens, \%tags, $para);
}

# Subroutine to add <s> tags and print out the result.
sub add_sentence {
	my ($tokens_aref, $tags_href, $para) = @_;
	
	my @sentences;

	# create an XML-element for a new sentence.
	my $sentence = XML::Twig::Elt->new('s');
	$sentence->set_att('id', $s_id++);

	while (my $token_rec = shift @$tokens_aref) {

		# Create a new XML-element for the token
		my $token = XML::Twig::Elt->new('w');
		if(! $sentence) { 
			$sentence = XML::Twig::Elt->new('s');
			$sentence->set_att('id', $s_id++);
		}
		$token->paste('last_child', $sentence);

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
		}  # end while readings

		if ($token_rec->{WORD} =~ /^[$SENT_DELIM]$/) {
			push @sentences, $sentence;
			undef $sentence;
		}
	} # end while tokens

	if($sentence) {
		push @sentences, $sentence;
	}
	$para->set_content(@sentences);
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
