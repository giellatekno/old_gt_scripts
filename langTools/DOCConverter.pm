package langTools::DOCConverter;

use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub new {
	my ($class, $filename, $test) = @_;

	my $self = $class->SUPER::new($filename, $test);
	$self->{ _converter_xsl } = $self->{_corpus_script} . "/docbook2corpus2.xsl";

	bless $self, $class;
	return $self;
}

sub getXsl {
	my( $self ) = @_;
	return $self->{_converter_xsl};
}

sub convert2intermediate {
	my( $self ) = @_;

	my $error = 0;
	
	my $command = "antiword -s -x db \"" . $self->getOrig() . "\" > \"" . $self->gettmp2() . "\"";
	
	if ($self->exec_com($command)) {
		$error = 1;
	} else {
		$command = "xsltproc \"" . $self->getXsl() . "\" \"" . $self->gettmp2() . "\" > \"" . $self->gettmp1() . "\"";
		if ($self->exec_com($command)) {
			$error = 1;
		} else {
			$self->clean_doc();
		}
	}

	return $error;
}

sub clean_doc {
	my ($self) = @_;
	
	my %replacements = (
		"¶" => "<\/p><p>",
		"Ã¯" => "ï",
		"Ã…" => "Å",
		"Ã¦" => "æ",
		"Ã¡" => "á",
		"Ä‘" => "đ",
		"Å¡" => "š",
		"Ã¥" => "å",
		"ν " => " ");
	
	open(FH, "<:encoding(utf8)", $self->gettmp1()) or die "Cannot open " . $self->gettmp1() . "$!";
	my @file = <FH>;
	close(FH);

	open(FH, ">:encoding(utf8)", $self->gettmp1()) or die "Cannot open " . $self->gettmp1() . "$!";
	foreach my $string (@file) {
		foreach my $a (keys %replacements) {
			my $ii = Encode::decode_utf8($a);
			my $i = Encode::decode_utf8($replacements{$a});
			$string =~ s/$ii/$i/g;
		}
		print FH $string;
	}
	close(FH);
}

1;
