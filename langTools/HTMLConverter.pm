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
	
	$command = "sed -e 's_<?xml:namespace.*?>__g' -e 's_<v:.*>__g' -e 's_<o:lock.*/>__g'  " . $self->getOrig() . " | tidy -config " . $self->{_bindir} . "/tidy-config.txt -utf8 -asxml -quiet > " . $self->gettmp2();
	return $self->exec_com($command);
}

sub convert2intermediate {
	my( $self ) = @_;

	my $error = 0;
	if ( $self->tidyHTML() == 512) {
		$error = 1;
	} else {
		my $command = "xsltproc --novalid \"" . $self->getXsl() . "\" \"" . $self->gettmp2() . "\" > \"" . $self->gettmp1() . "\"";
		if ( $self->exec_com($command) ) {
			$error = 1;
		}
	}
	return $error;
}

1;
