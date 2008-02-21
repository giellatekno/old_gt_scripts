#!/usr/bin/perl -w
use strict;

# use Perl module XML::Twig for XML-handling
# http://www.xmltwig.com/
use XML::Twig;
use Getopt::Long;


my $lexc_file;
my $line;
my $lexicon;
my $l;
my $in_multi;
my $lang;

GetOptions ("lang|l=s" => \$lang);

my $document = XML::Twig::Elt->new('document');
$document->set_att('xml:lang', $lang);
$document->set_pretty_print('record');

while (<>) {
	chomp;

	$line = $_;

	if ($line =~ /^LEXICON (\S*)/) {
		$in_multi = 0;
		$lexicon = $1;
		$l = XML::Twig::Elt->new('lexicon');
		$l->set_att('name', $lexicon);

		# Handling of entry comments, e.g compound information
		if ($line =~ /\!.*/) {
			my ($entr, $comments) = split (/\!/, $line);
			(my $new_comments = $comments) =~ s/\!//g;
			my @strings = split(/\s+/,$new_comments);
			#print "JEE @strings\n";
			for my $t (@strings) {
				if ($t =~ /\+/) {
					my $compound = XML::Twig::Elt->new('compound');
					$compound->set_text($t);
					$compound->paste('last_child', $l);
				}
				if ($t =~ /\^C\^/) {
					$l->set_att('r', "yes");
				}
				if ($t =~ /SUB/) {
					$l->set_att('sub', "yes");
				}
			}
		}

		$l->paste('last_child', $document);
	}

	elsif ($l && ($line !~ /^\s*\!/ && $line !~ /^[\!\n\r]/ )) {
		my $entry = XML::Twig::Elt->new('entry');
		my $lemma;
		my $stem;
		my $cont;
		my $paste_entry;

		if ($line =~ /(\S+)\:(\S+)\s*(\S*)/) {
			$lemma = $1;
			$stem = $2;
			$cont = $3;
			$paste_entry = 1;

			$cont =~ s/;//;
		}
		elsif ($line =~ /(\S+)\:(\s*)(\S*)/) {
			$lemma = $1;
			$stem = $2;
			$cont = $3;
			$paste_entry = 1;

			$cont =~ s/;//;
		}
		elsif ($line =~ /(\s+)\:(\S+)\s*(\S*)/) {
			$lemma = $1;
			$stem = $2;
			$cont = $3;
			$paste_entry = 1;

			$cont =~ s/;//;
		}
		elsif ($line =~ /^\s{0,80}(\S*)\s*;/) {
			$cont = $1;
			$cont =~ s/;//;
			$paste_entry = 1;
		}
		elsif ($line =~ /^\s{0,}(\S*)\s*(\S*)\s*;/) {
			$lemma = $1;
			$cont = $2;
			$paste_entry = 1;

			$cont =~ s/;//;
		}

		if ($cont) { $entry->set_att('c', $cont); }
		if ($stem) { $entry->set_att('s', $stem); }
		if ($lemma) { $entry->set_att('w', $lemma); }

		if ($paste_entry) {

			# Handling of entry comments, e.g compound information
			if ($line =~ /\!.*/) {
				my ($entr, $comments) = split (/\;/, $line);
				(my $new_comments = $comments) =~ s/\!//g;
				my @strings = split(/\s+/,$new_comments);
				#print "JEE @strings\n";
				for my $t (@strings) {
					if ($t =~ /\^C\^/) {
						$entry->set_att('r', "yes");
					}
					if ($t =~ /SUB/) {
						$entry->set_att('sub', "yes");
					}
					elsif ($t =~ /\+/) {
						my $compound = XML::Twig::Elt->new('compound');
						$compound->set_text($t);
						$compound->paste('last_child', $entry);
					}
				}
			}

			$entry->paste('last_child', $l);
		}
	}

	elsif ($line =~ /Multichar_Symbols/) {
		$in_multi = 1;
	}
	elsif ($in_multi) {
		$line =~ s/!.*//;
		my @multichars = split(/\s/, $line);

		for my $symbol (@multichars) {
			if ($symbol =~ /\S/) {
				my $multichar = XML::Twig::Elt->new('multichar');
				$multichar->set_att('symbol', $symbol);
				$multichar->paste('last_child', $document);
				$multichar->DESTROY;
			}
		}
	}
}

$document->print;
