package langTools::AvvirXMLConverter;

use langTools::Converter;
@ISA = ("langTools::Converter");

sub new {
	my ($class, $filename, $test) = @_;

	my $self = $class->SUPER::new($filename, $test);
	$self->{ _converter_xsl } = $self->{_corpus_script} . "/avvir2corpus.xsl";

	bless $self, $class;
	return $self;
}

sub getXsl {
	my( $self ) = @_;
	return $self->{_converter_xsl};
}

sub convert2intermediate {
	my( $self ) = @_;

	$self->{_intermediate_xml} = $self->getTmpDir() . "/" . $self->getTmpFilebase() . ".tmp1";
	my $command = "xsltproc \"" . $self->getXsl() . "\" \"" . $self->getOrig() . "\" > \"" . $self->getIntermediateXml() . "\"";
	return $self->exec_com($command);
}

1;
