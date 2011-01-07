package langTools::ParatextConverter;

use langTools::Converter;
@ISA = ("langTools::Converter");

sub new {
	my ($class, $filename, $test) = @_;

	my $self = $class->SUPER::new($filename, $test);

	bless $self, $class;
	return $self;
}

sub convert2intermediate {
	my( $self ) = @_;

	$self->{_intermediate_xml} = $self->getTmpDir() . "/" . $self->getTmpFilebase() . ".tmp1";
	my $command = $self->{_corpus_script} . "/paratext2xml.pl --out \"" . $self->getIntermediateXml() . "\" \"" . $self->getOrig() . "\"";
	return $self->exec_com($command);
}

1;
