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
	
	# sed -e 's_\303\245_\345_g == sed -e 's_Ã¥_å_g
	$command = "sed -e 's_<?xml:namespace.*?>__g' -e 's_<v:shapetype.*/v:shapetype>__g' -e 's_<v:shape.*/v:shape>__g'  " . $self->getOrig() . " | sed -e 's_<o:lock.*/o:lock>__g' -e 's_<o:p.*/o:p>__g' | tidy -config " . $self->{_bindir} . "/tidy-config.txt -utf8 -asxml -quiet | sed -e 's_\303\245_\345_g' > " . $self->gettmp2();
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
