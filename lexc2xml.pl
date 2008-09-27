#!/usr/bin/perl -w
use strict;
use utf8;

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
my @multichars;

GetOptions ("lang|l=s" => \$lang);

#my $document = XML::Twig::Elt->new('document');
#$document->set_att('xml:lang', $lang);
#$document->set_pretty_print('record');

print "<document xml:lang =\"$lang\">\n";

while (<>) {
	chomp;

	$line = $_;

	if ($line =~ /LEXICON (\S*)/ && ($line !~ /^\s*\!/ && $line !~ /^[\!\n\r]/ )) {
		$in_multi = 0;
		if ($lexicon) {
			print "  </lexicon>\n";
		}
		$lexicon = $1;
#		$l = XML::Twig::Elt->new('lexicon');
#		$l->set_att('name', $lexicon);

		print "\n  <lexicon name=\"$lexicon\"";

		# Handling of entry comments, e.g compound information
		if ($line =~ /\!.*/) {
			my ($entr, $comments) = split (/\!/, $line);
			(my $new_comments = $comments) =~ s/\!//g;
			my @strings = split(/\s+/,$new_comments);
#			print "JEE @strings\n";
#			for my $t (@strings) {
#				if ($t =~ /\^C\^/) {
				if (grep (/\^C\^/, @strings)) {
#					$l->set_att('recursive', "yes");
					print " recursive=\"yes\"";
				}
#				if ($t =~ /SUB/) {
				if (grep (/SUB/, @strings)) {
#					$l->set_att('substandard', "yes");
					print " substandard=\"yes\"";
				}
				if (grep (/word/, @strings)) {
					print " type=\"word\"";
				}
				if (grep (/infl/, @strings)) {
					print " type=\"inflection\"";
				}
				if (grep (/der/, @strings)) {
					print " type=\"derivation\"";
				}
				if (grep (/comp/, @strings)) {
					print " type=\"compound\"";
				}

			print ">\n";

			for my $t (@strings) {
				if ($t =~ /\+/) {
					$t =~ s/\+//;
					if ($t =~ /Cmp/) {
						my $compcase = XML::Twig::Elt->new('compcase');
						$compcase->set_text($t);
#						$compcase->paste('last_child', $l);
						$compcase->print;
					}
					elsif ($t =~ /Left/) {
						my $compleft = XML::Twig::Elt->new('compleft');
						$compleft->set_text($t);
#						$compleft->paste('last_child', $l);
						$compleft->print;
					}
					elsif ($t =~ /None/ || $t =~ /First/ || $t =~ /Last/ || $t =~ /Middle/) {
						my $position = XML::Twig::Elt->new('position');
						$position->set_text($t);
#						$position->paste('last_child', $l);
						$position->print;
					}
				}
			}
		}

		else {
			print ">\n";
		}
#		$l->paste('last_child', $document);
	}

	elsif ($lexicon && ($line !~ /^\s*\!/ && $line !~ /^[\!\n\r]/ )) {
		my $entry = XML::Twig::Elt->new('entry');
		my $lemma;
		my $stem;
		my $cont;
		my $paste_entry;

		if ($line =~ /^\s{0,80}(\S+)\:(\S+)\s*(\S*)/) {
			$lemma = $1;
			$stem = $2;
			$cont = $3;
			$paste_entry = 1;

			$cont =~ s/;//;
		}
		elsif ($line =~ /^\s{0,80}(\S+)\:(\s*)(\S*)/) {
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

		if ($cont && $cont !~ /#/) { $entry->set_att('contclass', $cont); }
		if ($stem) {
			if ($stem =~ /[A-ZÅÆ]/) {
				$stem =~ s/(\%\^.*[A-Z])/<$1>/g;
				if ($stem !~ /<\%\^/) {
					$stem =~ s/([ÅÆA-Z][0-9]{0,2})/<$1>/g;
				}
#				for my $m (@multichars) {
#					print "$m";
#					$stem =~ s/$m//;
#				}
#				print "JEE $stem";

				my @tags = split /\>/, $stem;
				for my $t (@tags) {
					if ($t =~ /(\<.*)/) {
						my $tag = XML::Twig::Elt->new('stemtag');
						$tag->set_text($1 . ">");
						$tag->paste('last_child', $entry);
					}
				}
			}
			$entry->set_att('stem', $stem);
		}
		if ($lemma) {
#			if ($lemma !~ /\%\+/) {
				(my $lemma_att = $lemma) =~ s/\+.*//;
				if ($stem && $stem =~ /\+\/-/) {
					$entry->set_att('lemma', $stem);
				}
				elsif ($lemma_att =~ /\S+/) {
					$entry->set_att('lemma', $lemma_att);
				}
#			}
#			else {
#				(my $lemma_att = $lemma) =~ s/\(\%\+^\+*\)\+.*/$1/;
#				$entry->set_att('lemma', $stem);
#			}
		}

		if ($paste_entry) {

			if ($lemma && $lemma =~ /\+/) {
				$lemma =~ s/[^\+]*\+//;
				my @tags = split /\+/, $lemma;

				for my $t (@tags) {
					if ($t =~ /\S+/ && $t !~ /\/-/) {
#						$t =~ s/\%//;
						my $tag = XML::Twig::Elt->new('lemmatag');
						$tag->set_text($t);
						$tag->paste('last_child', $entry);
					}
				}
			}

			# Handling of entry comments, e.g compound information
			if ($line =~ /\!.*/) {
				my ($entr, $comments) = split (/\;/, $line);
				(my $new_comments = $comments) =~ s/\!//g;
				my @strings = split(/\s+/,$new_comments);
				#print "JEE @strings\n";
				for my $t (@strings) {
					if ($t =~ /\^C\^/) {
						$entry->set_att('recursive', "yes");
					}
					if ($t =~ /SUB/) {
						$entry->set_att('substandard', "yes");
					}
					elsif ($t =~ /\+/) {
						$t =~ s/\+//;
						if ($t =~ /Cmp/) {
							my $compcase = XML::Twig::Elt->new('compcase');
							$compcase->set_text($t);
							$compcase->paste('last_child', $entry);
						}
						elsif ($t =~ /Left/) {
							my $compleft = XML::Twig::Elt->new('compleft');
							$compleft->set_text($t);
							$compleft->paste('last_child', $entry);
						}
						elsif ($t =~ /None/ || $t =~ /First/ || $t =~ /Last/ || $t =~ /Middle/) {
							my $position = XML::Twig::Elt->new('position');
							$position->set_text($t);
							$position->paste('last_child', $entry);
						}
					}
				}
			}

#			$entry->paste('last_child', $l);
#			print "\n\t";
			$entry->set_pretty_print('record');
			$entry->print;
		}
	}

	elsif ($line =~ /Multichar_Symbols/) {
		$in_multi = 1;
	}
	elsif ($in_multi) {
		next;
		$line =~ s/!.*//;
		my @multichar = split(/\s/, $line);

		for my $symbol (@multichar) {
			if ($symbol =~ /\S/) {
				push (@multichars, $symbol);
				next;
				my $multichar = XML::Twig::Elt->new('multichar');
				$multichar->set_att('symbol', $symbol);
#				$multichar->paste('last_child', $document);
#				$multichar->DESTROY;
				print "\n\t";
				$multichar->print;
			}
		}
	}
}

print "\n  </lexicon>";
print "\n</document>\n";

#$document->print;
