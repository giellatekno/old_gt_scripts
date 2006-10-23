
package langTools::XMLstruct;

binmode STDOUT, ":utf8";
use open ':utf8';
use Getopt::Long;
use File::Basename;
use strict;
use warnings;
use strict;

use XML::Twig;

use Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK);

$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA         = qw(Exporter);

@EXPORT = qw(&preprocess2xml &dis2xml &analyzer2xml &hyph2xml &gen2xml &xml2preprocess &xml2words &xml2dis);
@EXPORT_OK   = qw(&process_paras);


# Store the vislcg or lookup2cg output
# to xml-structure.
sub dis2xml {
	my ($text) = @_;

	my $w;
	my $output=XML::Twig::Elt->new('output');

	my @input = split(/\n/, $text);
	for my $out (@input) {

		# ignore empty lines
		next if $out =~ /^\s*$/;
		chomp $out;
		# Test the start of the cohort.
		if ($out =~ /^\"</) {
			# Save the cohort from last round.
			if ($w) {
				$w->paste('last_child', $output); 
				$w->DESTROY;
				undef $w;
			}
			# Read the word and go to next line.
			$out =~ s/^\"<(.*)?>\".*$/$1/;
			$w = XML::Twig::Elt->new('w');
			$w->set_att('form', $out);
			next;
		}

		# If not at the start of the cohort, 
		# read the analysis line
		# Create a new XML element for each reading.
		my $reading = XML::Twig::Elt->new('reading');
		
		$out =~ s/^\s+//;
		my ($lemma, $analysis) = split(/\s/, $out, 2);

		$lemma =~ s/\"//g;
		$reading->set_att('lemma', $lemma);
		if ($analysis) {
			$analysis =~ tr/ /+/;
			$reading->set_att('analysis', $analysis); 

		}
		$reading->paste('last_child', $w); 
	}
	if ($w) { $w->paste('last_child', $output); }

	return $output;
}

# Convert the xml-output of analyzator or lookup2cg to
# vislcg input.
sub xml2dis {
	my ($xml) = @_;

	my $string;
	my $twig = XML::Twig->new;
	if (! $twig->parse ($xml)) {
		print STDERR "Couldn't parse file $xml: $@";
	}
	my $root=$twig->root;
	my @words=$root->children;

	for my $word (@words) {
		$string .= "\"<" . $word->{'att'}->{'form'} . ">\"";		
		$string .= "\n";
		my @readings = $word->children;
		for my $r (@readings) {
			my $analysis = $r->{'att'}->{'analysis'};
			$analysis =~ s/\+/ /g;
			$string .= "\t" . "\"" . $r->{'att'}->{'lemma'} . "\"";
			$string .= " " . $analysis;
			$string .= "\n";
		}
	}
	return $string;
}

# Store analyzer output to xml-structure.
sub analyzer2xml {
	my ($text) = @_;

	my $word;
	my $w;
	my $output=XML::Twig::Elt->new('output');

	my @input=split(/\n/, $text);
	for my $out (@input) {
		if ($out =~ /^\s*$/) {
			if ($w) {
				$w->set_att('form', $word);	
				$w->paste('last_child', $output);
				$w->DESTROY;
				undef $w;
				next;
			}
		}
		chomp $out;
		if (! $w) { $w=XML::Twig::Elt->new('w'); }
		
		my $line;
		($word, $line) = split(/\t/, $out, 2);

		my ($lemma, $analysis) = split(/\+/, $line, 2);
		$lemma =~ s/\s+$//;
		my $reading=XML::Twig::Elt->new('reading');
		$reading->set_att('lemma', $lemma);
		if ($analysis) { $reading->set_att('analysis', $analysis); }
		$reading->paste('last_child', $w);
		
	}
	if ($w) {
		$w->set_att('form', $word);	
		$w->paste('last_child', $output);
	}
	return $output;
}

# Convert xml-input of word list 
# to analyzer or hyphenator, or possibly generator.
sub xml2words {
	my ($xml) = @_;

	my $string;
	my $twig = XML::Twig->new;
	if (! $twig->parse ($xml)) {
		print STDERR "Couldn't parse file $xml: $@";
	}
	my $root=$twig->root;
	my @words=$root->children;

	for my $word (@words) {
		$string .= $word->{'att'}->{'form'};
		$string .= "\n";
	}
	return $string;
}
		
# Move hyphenator output to xml-structure.
sub hyph2xml {
	my ($text) = @_;
	
	my $w;
	my $word;
	my $output=XML::Twig::Elt->new('output');

	my @input=split(/\n/, $text);
	for my $out (@input) {
		if ($out =~ /^\s*$/) {
			if ($w) {
				$w->set_att('form', $word);	
				$w->paste('last_child', $output);
				$w->DESTROY;
				undef $w;
				next;
			}
		}
		chomp $out;

		my $hyph;
		($word, $hyph) = split(/\t/, $out, 2);

		if (! $w) { $w=XML::Twig::Elt->new('w'); }
		my $reading=XML::Twig::Elt->new('reading');
		$reading->set_att('hyph', $hyph);
		$reading->paste('last_child', $w);
	}
	if ($w) {
		$w->set_att('form', $word);	
		$w->paste('last_child', $output);
	}
	return $output;

}

# Move generator output to xml-structure.
sub gen2xml {
	my ($text) = @_;
	
	my $w;
	my $lemma;
	my $analysis;
	my $output=XML::Twig::Elt->new('output');

	my @input=split(/\n/, $text);
	for my $out (@input) {
		if ($out =~ /^\s*$/) {
			if ($w) {
				$w->set_att('lemma', $lemma);	
				$w->set_att('analysis', $analysis);	
				$w->paste('last_child', $output);
				$w->DESTROY;
				undef $w;
				next;
			}
		}
		chomp $out;

		my $hyph;
		my ($line, $form) = split(/\t/, $out, 2);
		$form =~ s/^\s+//;

		($lemma, $analysis) = split(/\+/, $line, 2);

		if (! $w) { $w=XML::Twig::Elt->new('w'); }
		my $surface=XML::Twig::Elt->new('surface');
		$surface->set_att('form', $form);
		$surface->paste('last_child', $w);
	}
	if ($w) {
		$w->set_att('lemma', $lemma);	
		$w->set_att('analysis', $analysis);	
		$w->paste('last_child', $output);
	}
	return $output;

}


# Move preprocessor output  to xml-structure
sub preprocess2xml {
	my ($text) = @_;
	
	my $output=XML::Twig::Elt->new('output');
	my @input=split(/\n/, $text);

	for my $out (@input) {
		chomp $out;
		my $w=XML::Twig::Elt->new('w');
		$w->set_att('form', $out);
		$w->paste('last_child', $output);
	}
	return $output;
}

# preprocessor input read from xml-structure.
sub xml2preprocess {
	my $xml = shift @_;

	my $twig = XML::Twig->new;
	if (! $twig->parse ($xml)) {
		print STDERR "Couldn't parse file $xml: $@";
	}
	my $root=$twig->root;
	my $text=$root->text;
	return $text;
}

# Processing instructions are parsed
# from XML-structure.
sub process_paras() {
	my $parameters = shift @_;

	my $anl_fst;
	my $hyph_fst;
	my $gen_fst;
	my $prep_fst;
	my $prep_corr;
	my $prep_abbr;
	my $rle;

	my $document = XML::Twig->new;
	if (! $document->safe_parse ("$parameters") ) {
		print STDERR "Parsing the parameters $parameters failed.\n";
		return;
	}
	my $root = $document->root;
	my $language = $document->first_child('language');
	if(! $language) { print STDERR "No language specified.\n"; return; }
	my $xml_input = $document->first_child('xml_input');
	my $xml_output = $document->first_child('xml_output');
	my @actions = $root->children('action');
	my %tools;
	for my $act (@actions) {
		if ($act->{'att'}->{'tool'} == 'anl') {
			if ($act->{'att'}->{'fst'}) { $anl_fst=$act->{'att'}->{'fst'}; }
			else { $anl_fst="/opt/smi/$language/bin/$language.fst"; }
			next;
		}
		if ($act->{'att'}->{'tool'} == 'hyph') {
			if ($act->{'att'}->{'fst'}) { $hyph_fst=$act->{'att'}->{'fst'}; }
			else { $hyph_fst="/opt/smi/$language/bin/$language-hyph.fst"; }
			next;
		}
		if ($act->{'att'}->{'tool'} == 'gen') {
			if ($act->{'att'}->{'fst'}) { $gen_fst=$act->{'att'}->{'fst'}; }
			else { $gen_fst="/opt/smi/$language/bin/i$language.fst"; }
			next;
		}
		if ($act->{'att'}->{'tool'} == 'dis') {
			if ($act->{'att'}->{'rle'}) { $rle=$act->{'att'}->{'rle'}; }
			else { $rle="/opt/smi/$language/bin/$language-dis.fst"; }
			next;
		}
		if ($act->{'att'}->{'tool'} == 'prep') {
			if ($act->{'att'}->{'fst'}) { $rle=$act->{'att'}->{'fst'}; }
			else { $prep_fst="/opt/smi/$language/bin/$language.fst"; }
			if ($act->{'att'}->{'abbr'}) { $rle=$act->{'att'}->{'abbr'}; }
			else { $prep_abbr="/opt/smi/$language/bin/abbr.txt"; }
			if ($act->{'att'}->{'corr'}) { $rle=$act->{'att'}->{'corr'}; }
			else { $prep_corr="/opt/smi/$language/bin/corr.txt"; }
			next;
		}
	}
}

1;

__END__
