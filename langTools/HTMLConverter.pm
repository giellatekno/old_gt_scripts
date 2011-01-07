package langTools::HTMLConverter;

use langTools::Converter;
@ISA = ("langTools::Converter");

sub new {
	my ($class, $filename, $test) = @_;

	my $self = $class->SUPER::new($filename, $test);
	$self->{ _converter_xsl } = $self->{_corpus_script} . "/xhtml2corpus.xsl";
	$self->{_intermediate_xml2} = $self->getTmpDir() . "/" . $self->getTmpFilebase() . ".tmp2";
	$self->{_intermediate_xml} = $self->getTmpDir() . "/" . $self->getTmpFilebase() . ".tmp1";
	
	bless $self, $class;
	return $self;
}

sub getXsl {
	my( $self ) = @_;
	return $self->{_converter_xsl};
}

sub gettmp2 {
	my( $self ) = @_;
	return $self->{_intermediate_xml2};
}

sub tidyHTML {
	my( $self ) = @_;
	
	$command = "tidy -config " . $self->{_bindir} . "/tidy-config.txt -utf8 -asxml -quiet -output " . $self->gettmp2() . " " . $self->getOrig();
	return $self->exec_com($command);
}

sub convert2intermediate {
	my( $self ) = @_;

	my $command = "xsltproc \"" . $self->getXsl() . "\" \"" . $self->getOrig() . "\" > \"" . $self->getIntermediateXml() . "\"";
	return $self->exec_com($command);
}

1;
