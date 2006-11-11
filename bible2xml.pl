#!/usr/bin/perl -w 
#
# Convert bible texts to the project's xml-format.
# The xml-format of the bible text is specified in bible.dtd.
# The verse numbers are dropped and titles are moved to p-elements
# with type "title". Chapters and other subsections are change to
# section-elements.
#
# $Id$

use strict;
use XML::Twig;
use Getopt::Long;

my $file="/home/saara/koe.xml";
my $outfile="/home/saara/koe_out.xml";

GetOptions ("out=s" => \$outfile,
			);

if ( -f $ARGV[$#ARGV]) { $file = $ARGV[$#ARGV]; }
else { print STDERR "ERROR in bible2xml.pl: No input file given.\n"; exit; }

my $document2 = XML::Twig::Elt->new('document');
my $body=XML::Twig::Elt->new('body');

my $document = XML::Twig->new(twig_handlers => { 
	header => sub { set_header(@_); },
	book => sub { process_book(@_); },
});

if (! $document->safe_parsefile ("$file")) {
	print STDERR "$file parsing the XML-file failed: $@\n";
	exit;
}

$body->paste('last_child', $document2);

open (FH, ">:utf8", "$outfile") or die "Cannot open $outfile $!";
$document2->set_pretty_print('indented');
$document2->print( \*FH);
close(FH);

sub set_header {
	my ( $twig, $header) = @_;
	$header->cut;
	$header->paste('last_child', $document2);
}

sub process_book {
	my ( $twig, $book) = @_;

	my $text = $book->{'att'}->{'title'};
	my $p = XML::Twig::Elt->new('p');
	$p->set_att('type', 'title');
	$p->set_text($text);
	$p->paste('last_child', $body);

	for my $chapter ($book->children) {
		my $section = XML::Twig::Elt->new('section');
		
		my $text = $chapter->{'att'}->{'title'};
		my $p = XML::Twig::Elt->new('p');
		$p->set_att('type', 'title');
		$p->set_text($text);
		$p->paste('first_child', $section);

		for my $se ($chapter->children) {
			if ($se->gi eq 'verse') { process_verse($section, $se);  next; }
			process_section($section, $se);
		}
		$chapter->delete;
		$section->paste('last_child', $body);
	}
}

sub process_verse {
	my ($parent, $verse) =  @_;

	my $p = XML::Twig::Elt->new('p');
	my $text = $verse->text;
	$p->set_text($text);
	$p->paste('last_child', $parent);
	$verse->delete;	

}

sub process_section {
	my ( $parent, $s) =  @_;
	
	my $section = XML::Twig::Elt->new('section');
	if (my $title = $s->{'att'}->{'title'}) {
		my $p = XML::Twig::Elt->new('p');
		$p->set_att('type', 'title');
		$p->set_text($title);
		$p->paste('first_child', $section);
	}
	for my $verse ($s->children('verse')) {
		process_verse($section, $verse);
	}

	$s->delete;
	$section->paste('last_child', $parent);
}	
