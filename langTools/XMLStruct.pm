
package langTools::XMLStruct;

binmode STDOUT, ":utf8";
use open ':utf8';
use warnings;
use strict;

use XML::Twig;
use Carp qw(cluck);

use Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK);

$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA         = qw(Exporter);

@EXPORT = qw(&preprocess2xml &dis2xml &analyzer2xml &hyph2xml &gen2xml &xml2preprocess &xml2words &xml2dis $fst %dis_tools %action %prep_tools $language $xml_in $xml_out $args &process_paras &get_action);
@EXPORT_OK   = qw(&process_paras);

our ($fst, %dis_tools, %action, %prep_tools, $prep, $language, $args, $xml_in, $xml_out);

our %default_args = (
				   "dis" =>  "--quiet",
				   "anl" => "-flags -mbTT -utf8",
				   "gen" => "-flags -mbTT -utf8 -d",
				   "para" => "-flags -mbTT -utf8 -d",
				   "hyph" => "-flags -mbTT -utf8",
				   "prep" => "",
				   );

# Store the vislcg or lookup2cg output
# to xml-structure.
sub dis2xml {
	my ($text) = @_;

	my $w;
	my $output=XML::Twig::Elt->new('disamb');

	if (! $text) { 
		my $string = $output->sprint;
		$output->delete;		
		return $string;
	}

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
	
	my $string = $output->sprint;
	$output->print;
	$output->delete;

	return $string;
}

# Convert the xml-output of analyzator or lookup2cg to
# vislcg input.
sub xml2dis {
	my ($xml) = @_;

	my $string;
	my $twig = XML::Twig->new(keep_encoding => 1);
	if (! $twig->safe_parse ($xml)) {
		cluck("Couldn't parse xml");
		return Carp::longmess("Could not parse xml");
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
	$twig->delete;
	return $string;
}

# Store analyzer output to xml-structure.
sub analyzer2xml {
	my ($text) = shift @_;

	my $word;
	my $w;
	my $output=XML::Twig::Elt->new('analysis');
	$output->set_pretty_print('record');

	if (! $text) { 
		my $string = $output->sprint;
		$output->delete;		
		return $string;
	}

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

	my $string = $output->sprint;
	return $string;

}

# Convert xml-input of word list 
# to analyzer or hyphenator, or possibly generator.
sub xml2words {
	my ($xml) = @_;

	my $string;
	my $twig = XML::Twig->new(keep_encoding => 1);
	if (! $twig->safe_parse ($xml)) {
		cluck("Couldn't parse xml");
		return Carp::longmess("Could not parse xml");
	}
	my $root=$twig->root;
	if (!$root) {
	}
	my @words=$root->children;

	for my $word (@words) {
		if ($word->{'att'}->{'form'}) {
			$string .= $word->{'att'}->{'form'};
			$string .= "\n";
		}
	}

	$twig->dispose;
	return $string;
}
		
# Move hyphenator output to xml-structure.
sub hyph2xml {
	my ($text) = @_;
	
	my $w;
	my $word;
	my $output=XML::Twig::Elt->new('hyphenation');
	$output->set_pretty_print('record');

	if (! $text) { 
		my $string = $output->sprint;
		$output->delete;		
		return $string;
	}

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
	my $string = $output->sprint;
	$output->delete;

	return $string;
}

# Move generator output to xml-structure.
sub gen2xml {
	my ($text, $paradigm) = @_;

	my $w;
	my $lemma;
	my $analysis;
	my $output;
	if ($paradigm)
		{ $output=XML::Twig::Elt->new('paradigm'); }
	else
		{ $output=XML::Twig::Elt->new('generation'); }
	$output->set_pretty_print('record');

	if (! $text) { 
		my $string = $output->sprint;
		$output->delete;		
		return $string;
	}

	my @input=split(/\n/, $text);
	for my $out (@input) {
		if ($out =~ /^\s*$/) {
			if ($w) {
				$w->set_att('lemma', $lemma);
				if (! $paradigm) { $w->set_att('analysis', $analysis); }
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
		if ($paradigm) { $surface->set_att('analysis', $analysis); }
		$surface->set_att('form', $form);
		$surface->paste('last_child', $w);
	}
	if ($w) {
		$w->set_att('lemma', $lemma);	
		$w->set_att('analysis', $analysis);	
		$w->paste('last_child', $output);
	}

	my $string = $output->sprint;
	$output->delete;

	return $string;

}


# Move preprocessor output  to xml-structure
sub preprocess2xml {
	my ($text) = @_;
	
	my $output=XML::Twig::Elt->new('preprocess');
	$output->set_pretty_print('record');

	if (! $text) { 
		my $string = $output->sprint;
		$output->delete;		
		return $string;
	}

	my @input=split(/\n/, $text);

	for my $out (@input) {
		chomp $out;
		my $w=XML::Twig::Elt->new('w');
		$w->set_att('form', $out);
		$w->paste('last_child', $output);
	}
	my $string = $output->sprint;
	$output->delete;

	return $string;
}

# preprocessor input read from xml-structure.
sub xml2preprocess {
	my $xml = shift @_;

	my $twig = XML::Twig->new(keep_encoding => 1);
	if (! $twig->safe_parse ($xml)) {
		cluck("Couldn't parse xml.");
		return Carp::longmess("Could not parse xml");
	}
	my $root=$twig->root;
	my $text=$root->text;

	$root->delete;
	$twig->dispose;
	return $text;
}

sub get_action{
	my $line = shift @_;

	my $document = XML::Twig->new(keep_encoding => 1);
	if (! $document->safe_parse ("$line") ) {
		cluck("Could not parse parameters.");
		return Carp::longmess("ERROR Could not parse $line");
	}
	my $root = $document->root;
	my $action = $root->{'att'}->{'tool'};

	return $action;
}


# Processing instructions are parsed
# from XML-structure.
sub process_paras {
	my $parameters = shift @_;

	my $document = XML::Twig->new(keep_encoding => 1);
	if (! $document->safe_parse ("$parameters") ) {
		cluck("Could not parse parameters.");
		return Carp::longmess("Could not parse parameters: $parameters");
	}
	my $root = $document->root;
	my $lang = $root->first_child('lang');
	if (! $lang || ! $lang->text) {
		cluck("No language specified.");
		return Carp::longmess("No language specified: $parameters");
	}
	else { $language = $lang->text; }

	my %default_fsts = (
						"anl" => "/opt/smi/$language/bin/$language.fst",
						"hyph" => "/opt/smi/$language/bin/hyph-$language.fst",
						"gen" => "/opt/smi/$language/bin/i$language-norm.fst",
						"para" => "/opt/smi/$language/bin/i$language.fst",
						"prep" => "",
						);
		
	$xml_in = $root->first_child('xml_in');
	$xml_out = $root->first_child('xml_out');
	my @actions = $root->children('action');
	my %tools;
	for my $act (@actions) {
		my $tool = $act->{'att'}->{'tool'};
		my $tmp_fst = $act->{'att'}->{'fst'};
		my $tmp_args = $act->{'att'}->{'args'};
		my $rle = $act->{'att'}->{'rle'};
		my $abbr = $act->{'att'}->{'abbr'};
		my $corr = $act->{'att'}->{'corr'};
		my $filter = $act->{'att'}->{'filter'};
		my $filter_script = $act->{'att'}->{'filter_script'};
		my $mode = $act->{'att'}->{'mode'};

		if ($tool eq 'anl' || $tool eq 'hyph' || $tool eq 'gen' || $tool eq 'para') {
			if ($tmp_fst) { $action{$tool}{'fst'}=$tmp_fst; }
			else { $action{$tool}{'fst'} = $default_fsts{$tool}; }
			if ($tmp_args) { $action{$tool}{'args'}=$tmp_args; }
			else { $action{$tool}{'args'} = $default_args{$tool}; }
			if ($filter) { 
				$action{$tool}{'filter'} = 1;
				if ($filter_script) { $action{$tool}{'filter_script'} = $filter_script; }
			}
			if ($mode) { $action{$tool}{'mode'} = $mode; }
			next;
		}
		if ($tool eq 'dis') {
			$action{'dis'}=1;
			if ($rle) { $dis_tools{'rle'}=$rle; }
			else { $dis_tools{'rle'}="/opt/smi/$language/bin/$language-dis.fst"; }
			if ($tmp_args) { $dis_tools{'args'}=$tmp_args; }
			else { $dis_tools{'args'}=$default_args{'dis'}; }
			next;
		}
		if ($tool eq 'prep') {
			$action{'prep'}=1;
			if ($tmp_fst) { $prep_tools{'fst'} = $tmp_fst; }
			else { $prep_tools{'fst'}="/opt/smi/$language/bin/$language.fst"; }
			if ($abbr) { $prep_tools{'abbr'}=$abbr; }
			else { $prep_tools{'abbr'}="/opt/smi/$language/bin/abbr.txt"; }
			if ($corr) { $prep_tools{'corr'}=$corr; }
			else { $prep_tools{'corr'}="/opt/smi/$language/bin/corr.txt"; }
			if ($tmp_args) { $prep_tools{'args'}=$tmp_args; }
			else { $prep_tools{'args'}=$default_args{'dis'}; }
			next;
		}
	}
	if (! %action) {
		cluck("No action specified.");
		return Carp::longmess("No action specified $parameters");
	}
	return 0;
}

1;

__END__
