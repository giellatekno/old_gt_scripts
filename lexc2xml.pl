#!/usr/bin/perl -w
use strict;

# use Perl module XML::Twig for XML-handling
# http://www.xmltwig.com/
use XML::Twig;


my $lexc_file;
my $line;
my $lexicon;
my $l;

my $document = XML::Twig::Elt->new('document');
$document->set_pretty_print('record');

while (<>) {
	chomp;

	$line = $_;

	if ($line =~ /^LEXICON (\S*)/) {
		$lexicon = $1;
		$l = XML::Twig::Elt->new('lexicon');
		$l->set_att('name', $lexicon);
		$l->paste('last_child', $document);
	}

	elsif ($l && ($line !~ /^\s*\!/ && $line !~ /^[\!\n\r]/ )) {
		if ($line =~ /(\S*)\:(\S*)\s*(\S*)/) {
			my $lemma = $1;
			my $stem = $2;
			my $cont = $3;

			if ($cont !~ /\s/) {
				$cont =~ s/;//;
				my $entry = XML::Twig::Elt->new('entry');
				$entry->set_att('w', $lemma);
				$entry->set_att('s', $stem);
				$entry->set_att('c', $cont);
				$entry->paste('last_child', $l);
			}
		}
		elsif ($line =~ /^\s{0,80}(\S*)\s*;/) {
			my $cont = $1;
			$cont =~ s/;//;
			my $entry = XML::Twig::Elt->new('entry');
			$entry->set_att('c', $cont);
			$entry->paste('last_child', $l);
		}
		elsif ($line =~ /^\s{0,80}(\S*)\s*(\S*)/) {
			my $lemma = $1;
			my $cont = $2;

			if ($cont !~ /\s*/) {
				$cont =~ s/;//;
				my $entry = XML::Twig::Elt->new('entry');
				$entry->set_att('w', $lemma);
				$entry->set_att('c', $cont);
				$entry->paste('last_child', $l);
			}
		}
	}
}

$document->print;
