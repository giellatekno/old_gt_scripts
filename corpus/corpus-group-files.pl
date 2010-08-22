#!/usr/bin/perl -w

use strict;
use File::Find;
use File::Basename;
use XML::Twig;
use Getopt::Long;


my $number;
my $group=0;
my $preprocess=0;
my $analyze=0;
my $help;

Getopt::Long::Configure ("bundling");
GetOptions ("group|g" => \$group,
			"prep|p" => \$preprocess,
			"analyze|a" => \$analyze,
			"number|n=s" => \$number,
			"help|h" => \$help
);

if ($help) {
	&print_help;
	exit 1;
}


my $lang="sme";
my $tmpdir="/Users/hoavda/Public/corp/tmp";
my $corpdir="Users/hoavda/Public/corp/bound/$lang";
my $id="sme/news/MinAigi/2004-$number";
my $dir="/Users/hoavda/Public/corp/bound/sme/news/MinAigi/2004";
my $pattern="MinAigi\/2004\/$number";
my $title_name="MinAigi 2004 $number";
my $groupfile="/Users/hoavda/Public/corp/tmp/MinAigi-2004-$number.xml";
my $corpus_analyze="perl -I /Users/saara/gt/script /Users/saara/gt/script/corpus-analyze.pl --onelang --lang=sme";


my $header = XML::Twig::Elt->new('header');
my $title = XML::Twig::Elt->new('title');
$title->set_text($title_name);
$title->paste('last_child', $header);
my $genre = XML::Twig::Elt->new('genre');
$genre->set_text('news');
$genre->paste('last_child', $header);
my $author = XML::Twig::Elt->new('author');
my $unk = XML::Twig::Elt->new('unknown');
$unk->paste('last_child', $author);
$author->paste('last_child', $header);
my $year = XML::Twig::Elt->new('year');
$year->paste('last_child', $header);
my $metadata = XML::Twig::Elt->new('metadata');
$metadata->paste('last_child', $header);

# Search the files in the directory $dir and process each one of them.
if ($group) {
	open (OFH, ">$groupfile");
	print OFH qq|<?xml version='1.0'  encoding="UTF-8"?>|;
	print OFH qq|\n<!DOCTYPE document PUBLIC "-//UIT//DTD Corpus V1.0//EN" "http://giellatekno.uit.no/dtd/corpus.dtd">\n|;
	print OFH qq|\n<document id="$id" xml:lang="$lang">|;
	$header->set_pretty_print('indented');
	$header->print(\*OFH);
	print OFH qq|\n<body>|;
	if (-d $dir) { find (\&group_file, $dir); }
	else { print "$dir ERROR: Directory did not exit.\n"; }
}
# Process the file given in command line.
else { process_file (Encode::decode_utf8($ARGV[$#ARGV])) if -f $ARGV[$#ARGV]; }

sub process_file {

	(my $outfile = $groupfile) =~ s/\.xml/\.analyzed.xml/;
	(my $sentfile = $groupfile) =~ s/\.xml/\.sent.xml/;

	if ($preprocess) {
		my $command="$corpus_analyze --onelang --lang=$lang --output=$sentfile --only_add_sentences $groupfile";
		print "$command\n";
		if ( system($command) != 0 ) {  print STDERR "Analysis failed $!\n"; return; }
	}
	if ($analyze) {
		my $command="$corpus_analyze --onelang --lang=$lang --output=$outfile $sentfile";
		print "$command\n";
		if ( system($command) != 0 ) { print STDERR "Analysis failed $!\n"; return; }
	}
}


sub group_file {
    my $file = $_;
    $file = shift (@_) if (!$file);

	# Check the filename
	return unless ($file =~ m/\.xml$/);
	return if (! -f $file);

    my $real = File::Spec->rel2abs($file);

	return if ($real !~ /$pattern/o);
	print "$real\n";

	my $document = XML::Twig->new;
	if (! $document->safe_parsefile("$real")) {
		print "ERROR parsing the XML-file failed: $@\n";		  
		return;
	}
	
	my $root = $document->root;
	my $body = $root->first_child('body');
	for my $el ($body->children) {
		if($el->{'att'}->{'xml:lang'}) {
			my $paralang = $el->{'att'}->{'xml:lang'};
			if ( $paralang ne $lang) {
				$el->delete;
				next;
			}
		}
		$el->print(\*OFH);
	}
	$body->delete;
	$document->purge;
}

if ($group) {
print OFH qq|\n</body>|;
print OFH qq|\n</document>|;
close OFH;
}
