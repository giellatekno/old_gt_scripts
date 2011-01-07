package langTools::HTMLConverter;

use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub new {
	my ($class, $filename, $test) = @_;

	my $self = $class->SUPER::new($filename, $test);
	$self->{ _converter_xsl } = $self->{_corpus_script} . "/xhtml2corpus.xsl";
	
	bless $self, $class;
	return $self;
}

sub getXsl {
	my( $self ) = @_;
	return $self->{_converter_xsl};
}

sub tidyHTML {
	my( $self ) = @_;
	
	$command = "tidy -config " . $self->{_bindir} . "/tidy-config.txt -utf8 -asxml -quiet -output " . $self->gettmp2() . " " . $self->getOrig();
	return $self->exec_com($command);
}

sub convert2intermediate {
	my( $self ) = @_;

	my $command = "xsltproc \"" . $self->getXsl() . "\" \"" . $self->getOrig() . "\" > \"" . $self->gettmp1() . "\"";
	die("Wasn't able to convert " . $self->getOrig() . " to intermediate xml format") if $self->exec_com($command);
	
	return $self->gettmp1();
}

1;
