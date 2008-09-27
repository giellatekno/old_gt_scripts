#!/usr/bin/perl -w

use strict;

# use Perl module XML::Twig for XML-handling
# http://www.xmltwig.com/
use XML::Twig;

my $language = "sme";

my $outfile = "Salmmat.xml";
my $infile = "/usr/local/share/corp/bound/sme/bible/ot/Salmmat-_garvasat_0203.doc.xml";

my $ch_num="01";

my $FH1;
open($FH1,  ">$outfile");

my $document = XML::Twig->new(twig_handlers => { body => \&body });
if (! $document->safe_parsefile ("$infile") ) {
	print STDERR "$infile: ERROR parsing the XML-file failed. $@\n";
}
$document->set_pretty_print('indented');
$document->print($FH1);

sub body {
	my ($t, $body) = @_;

	my $chapter;
	my @tables=$body->children;

	for my $table(@tables){
		print "table\n";
		my @rows=$table->children;
		$table->delete;

		for my $row (@rows) {
			my @ps=$row->children;
			$row->delete;

			if (! @ps) { next; }

			my $type = $ps[0]->text;
			my $number = $ps[1]->text;
			my $text = $ps[2]->text;
			
			$type =~ s/\s//g;
			$number =~ s/\s//g;

			my ($ch_n, $verse_n) = split(":", $number);
			
			if($ch_n == $ch_num) {
				if(! $chapter) {
					$chapter=XML::Twig::Elt->new('chapter');
					$chapter->set_att('number', $ch_n);
				}
				my $verse=XML::Twig::Elt->new('verse');
				$verse->set_att('number', $verse_n);
				$verse->set_text($text);
				$verse->paste('last_child', $chapter);
			}
			else {
				if($chapter) {
					$chapter->paste('last_child', $body);
				}
				$chapter=XML::Twig::Elt->new('chapter');
				$chapter->set_att('number', $ch_n);
				$ch_num=$ch_n;
				if ($type eq '3') {
					$chapter->set_att('title', $text);
				}
				else {
					my $verse=XML::Twig::Elt->new('verse');
					$verse->set_att('number', $verse_n);
					$verse->set_text($text);
					$verse->paste('last_child', $chapter);
				}
			}
		}
	}
}
