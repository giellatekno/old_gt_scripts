#!/usr/bin/perl -w 
#
# Temprary script for 
# moving the file corp/orig/smj/bible/nt/north_sami_html.html
# to the project's bible format.
#
# $Id$

use strict;
use XML::Twig;

#my $file="/usr/local/share/corp/orig/sme/bible/nt/north_sami_html.html";
#my $file="/home/saara/lule_sami_new_testament.html";
my $file="/home/saara/koe.html";

my $document = XML::Twig->new;
if (! $document->safe_parsefile("$file")) {
	die "$file: Parsing the XML-file failed: $@\n";
}

my $root = $document->root;
my $head = $root->first_child('head');
my $body = $root->first_child('body');

$root->set_gi('document');
$root->del_att('xmlns');

$head->set_gi('header');
for my $h ($head->children) {
	if ($h->gi ne "title") { $h->delete; }
}

my $document2=XML::Twig::Elt->new('document');
$document2->set_pretty_print('record');
my $head2 = XML::Twig::Elt->new('head');
$head2->paste('first_child', $document2);

my $body2 = XML::Twig::Elt->new('body');


my $book;
my $chapter;
my $verse;
my $section;
my $current;

my $num;
my $full_text;

for my $c ($body->children) {

	if ($c->gi eq 'h2') {
		my $text = $c->text;
		
		# If the same title occurs again.
		next if ($current && $current eq $text);
		$current = $text;
		if ($book) {
			if ($chapter) {
				if ($section) {
					if ($verse) { 
						$verse->set_text($full_text);
						$full_text="";
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
			$book->paste('last_child', $body2);
			$book->DESTROY;
			$book=undef;
		}
		$book=XML::Twig::Elt->new('book');
		my $title=$c->text;
		$book->set_att('title', $title);
		$c->delete;
		$book->set_gi('book');
	}

	if ($c->gi eq 'h3') {
		my $title=$c->text;

	  KAPITTEL: {
		  last KAPITTEL if ($title !~ /Kapittel/);
			  if ($chapter) {
				  if ($section) {
					  if ($verse) { 
						  $verse->set_text($full_text);
						  $full_text="";
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
		  $chapter->set_att('title', $title);
		  $c->delete;
	  }
	} # end of KAPITTTEL

	if ($c->gi eq 'table') {
		my $tr=$c->first_child('tr');
		$c->delete;
		my $td=$tr->first_child('td');
		$tr->delete;
		for my $p ($td->children) { 

			if ($p->gi eq 'h3') {
				my $title=$p->text;
				$p->delete;
				if ($section) {
					if ($verse) { 
						$verse->set_text($full_text);
						$full_text="";
						$verse->paste('last_child', $section); 
						$verse->DESTROY;
						$verse=undef;
					}
					if ($chapter) { $section->paste('last_child', $chapter); }
					else { print STDERR "error: no place to paste section.\n"; next; }
					$section->DESTROY;
					$section=undef;
				}
				$section=XML::Twig::Elt->new('section');
				$section->set_gi('section');
				$section->set_att('title', $title);
				next;
			}

			if ($p->gi eq 'p' || $p->gi eq 'P') {
				if ($verse) { 
					if ($section) { $verse->paste('last_child', $section); }
					else { print STDERR "error: no place to paste verse. $verse->text\n"; }
					$verse->DESTROY;
					$verse=undef;
				}
				
				my @verses=$p->children;

				for my $a (@verses) {
					
					if ($a->gi eq 'a') {
						$num = $a->{'att'}->{'name'};
						#print STDERR "$num\n";
						next;
					}	
					my $t = $a->text;
					next if ( $t =~ /^\s*$/ || $t =~ /^\d*$/);
					$t =~ s/^\s*//;
					$t =~ s/\n/ /g;
					$t =~ s/ +/ /g;
					if ($num) {
						if ($verse) {
							$verse->set_text($full_text);
							$full_text="";
							if ($section) { $verse->paste('last_child', $section); }
							elsif ($chapter) { $verse->paste('last_child', $chapter); }
							else { print STDERR "error: no place to paste verse.\n$num $t\n"; }

						}
						$verse = XML::Twig::Elt->new('verse');
						$verse->set_att('number', $num);
					}
					$full_text .= " $t";
					$num=undef;
					$a->delete;
				}

				if ($verse) {
					$verse->set_text($full_text);
					$full_text="";
					if ($section) { $verse->paste('last_child', $section); }
					elsif ($chapter) { $verse->paste('last_child', $chapter); }
					else { print STDERR "error: no place to paste verse.\n$num"; }
					$verse->DESTROY;
					$verse=undef;
				}
			}
		}
		$td->delete;
	}
	$c->delete;
}

if ($book) {
	if ($chapter) {
		if ($section) {
			if ($verse) { 
				$verse->set_text($full_text);
				$full_text="";
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
	$book->paste('last_child', $body2);
	$book->DESTROY;
	$book=undef;
}
	
$body2->paste('last_child', $document2);
$document2->print;
