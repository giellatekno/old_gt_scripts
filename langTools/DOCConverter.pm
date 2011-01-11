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
			$command = "perl -CS -pi -e 's/\x{00B6}/<\\/p><p>/g' \"" . $self->gettmp1() . "\"";
			$self->exec_com($command);
		}
	}

	return $error;
}
