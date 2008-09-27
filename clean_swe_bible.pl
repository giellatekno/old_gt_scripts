#!/usr/bin/perl -w 
#
# Temprary script for 
# moving the file corp/orig/smj/bible/nt/north_sami_html.html
# to the project's bible format.
#
# $Id$

use strict;
use XML::Twig;

binmode STDERR, ":utf8";

#my $file="/usr/local/share/corp/orig/sme/bible/nt/north_sami_html.html";
#my $file="/home/saara/lule_sami_new_testament.html";
my $file="/home/saara/Ps.html";
#my $file="/home/saara/bible/sv_bible/swe_converted_version.html";

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
my $last_kap;
my $skip_two=0;

for my $c ($body->children) {

  P:
	for my $p ($c->children) {

		if ($skip_two) { $skip_two--; next P; }

		my $title = $p->text;
	
		my $class = $p->{'att'}->{'class'};

		# If Kap number is alone.
		if ((!$last_kap && $class =~ /Kapsiffrak/) || $title =~ /BOKEN/) {
			process_kap($p);
			$p->first_child->delete;
		} 
		$last_kap=0;
		
		if ($class =~ /Rubrikr/) {
			$title =~ s/^\s*//;
			$title =~ s/\n/ /g;
			$title =~ s/ +/ /g;

			my $sibling = $p->next_sibling;
			my $sibling_class = $sibling->{'att'}->{'class'};
			if ($sibling_class =~ /Kapsiffrak/) {
				process_kap($sibling);
				$sibling->first_child->delete;
				$last_kap=1;
			}
			
			# Rubrik starts a new section.
			if ($section) {
				if ($verse) { 
					$verse->set_text($full_text);
					$full_text="";
					$verse->paste('last_child', $section); 
					$verse->DESTROY;
					$verse=undef;
				}
				if (! $chapter) { $chapter=XML::Twig::Elt->new('chapter'); }
				$section->paste('last_child', $chapter);
				
			}
			#print STDERR "Ok\n";
			$section=XML::Twig::Elt->new('section');
			$section->set_att('title', $title);
			print STDERR "    $title\n";
			next P;
		} # end of Rubrik
		
		# Otherwise process the contents of p
	  SPAN:
		for my $span ($p->children) {
			
			my $text = $span->text;
			#$text =~ s/\&\#160\;//g;
			next if (!$text || $text =~ /^\s*$/);
			$text =~ s/^\s*//;
			#$text =~ s/\n/ /g;
			$text =~ s/ +/ /g;
			
			my $style = $span->{'att'}->{'style'};
			
			# If the font size is big, start a new book.
			if ($style && $style =~ /font-size\:18\.0pt/) {
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
				# check couple of next p:s for more book title.
				if ( my $sibling = $p->next_sibling) {
					my $sib_text = $sibling->text;
					if ($sib_text =~ /___/) {
						my $next_sib = $sibling->next_sibling;
						my $more_title=$next_sib->text;
						$more_title =~ s/\n\r/ /g;
						$more_title =~ s/ +/ /g;
						$text .= " $more_title";
						$skip_two = 2;
					}
				}
				
				$book=XML::Twig::Elt->new('book');
				$book->set_att('title', $text);
				print STDERR "$text\n";				  
				
				next P;
			} # end new BOOK

			# If font size is small start a new verse.
			  if ($style && $style =~ /font-size\:\s*10\.0pt/) {
				  $num = $span->text;
				  if ($verse) { 
					  $verse->set_text($full_text);
					  $full_text="";
					  if ($section) { $verse->paste('last_child', $section); }
					  else {print STDERR "No place to paste verse\n"; next;}
					  $verse->DESTROY;
					  $verse=undef;
				  }
				  $verse = XML::Twig::Elt->new('verse');
				  $verse->set_att('number', $num);
				  next SPAN;
			  }
			$full_text .= " $text";			
			$span->delete;
		  }
	  }
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


sub process_kap {
	my $p = shift @_;

	my $span = $p->first_child('span');
	my $kap_num = $span->text;
	
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
	$chapter->set_att('title', $kap_num);
	print STDERR "  $kap_num\n";
}

