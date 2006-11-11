#!/usr/bin/perl -w 
#
# Move the file corp/orig/smj/bible/nt/lule_sami_new_testament.html
# to the project-internal bible format.
#
# $Id$

use strict;
use XML::Twig;

#my $file="/usr/local/share/corp/orig/smj/bible/nt/lule_sami_new_testament.html";
#my $file="/home/saara/lule_sami_new_testament.html";
my $file="/home/saara/lule_new.html";

my $document = XML::Twig->new;
if (! $document->safe_parsefile("$file")) {
	die "$file: Parsing the XML-file failed: $@\n";
}

$document->set_pretty_print('record');

my $root = $document->root;
my $head = $root->first_child('head');
my $body = $root->first_child('body');

$root->set_gi('document');
$root->del_att('xmlns');

$head->set_gi('header');
for my $h ($head->children) {
	if ($h->gi ne "title") { $h->delete; }
}


my $book;
my $chapter;
my $verse;
my $section;
for my $c ($body->children) {
	
	if ($c->gi eq 'h1') {
		if ($book) {
			if ($chapter) {
				if ($section) {
					if ($verse) { 
						$verse->paste('last_child', $chapter); 
						$verse->DESTROY;
						$verse=undef;
					}
					$section->paste('last_child', $chapter);
					$section->DESTROY;
					$section=undef;
				}
				$chapter->paste('last_child', $book);
				$chapter->DESTROY;
				$chapter=undef;
			}
			$book->paste('last_child', $body);
			$book->DESTROY;
			$book=undef;
		}
		$book=XML::Twig::Elt->new('book');
		my $title=$c->text;
		$book->set_att('title', $title);
		$c->delete;
		$book->set_gi('book');
	}

	if ($c->gi eq 'h2') {
		if ($chapter) {
			if ($section) {
				if ($verse) { 
					$verse->paste('last_child', $section); 
					$verse->DESTROY;
					$verse=undef;
				}
				$section->paste('last_child', $chapter);
				$section->DESTROY;
				$section=undef;
			}
			$chapter->paste('last_child', $book);
			$chapter->DESTROY;
			$chapter=undef;
		}
		$chapter=XML::Twig::Elt->new('chapter');
		my $title=$c->text;
		$chapter->set_att('title', $title);
		$c->delete;
		$chapter->set_gi('chapter');
	}

	if ($c->gi eq 'h3') {
		if ($section) {
			if ($verse) { 
				$verse->paste('last_child', $section); 
				$verse->DESTROY;
				$verse=undef;
			}
			if ($chapter) { $section->paste('last_child', $chapter); }
			else { print "error: no place to paste section.\n"; }
			$section->DESTROY;
			$section=undef;
		}
		$section=XML::Twig::Elt->new('section');
		$section->set_gi('section');
		my $title=$c->text;
		$section->set_att('title', $title);
		$c->delete;
	}

	if ($c->gi eq 'p') {
		if ($verse) { 
			if ($section) { $verse->paste('last_child', $section); }
			else { print STDERR "error: no place to paste verse. $verse->text\n"; }
			$verse->DESTROY;
			$verse=undef;
		}

		my $text = $c->text;
		$c->delete;
		
		next if (! $text);
		my @lines=split(/\n/, $text);
		my $number= scalar @lines;
		for my $l (@lines) {
			next if ($l =~ /^\s*$/);
			$l =~ s/^\s*//;
			my ($num, $t) = split(" ", $l, 2);
			my $verse = XML::Twig::Elt->new('verse');
			$verse->set_att('number', $num);
			$verse->set_text($t);
			if ($section) { $verse->paste('last_child', $section); }
			elsif ($chapter) { $verse->paste('last_child', $chapter); }
			else { print STDERR "error: no place to paste verse.\n$num $t\n"; }
			$verse->DESTROY;
			$verse=undef;
		}
	}
}
	
$document->print;
