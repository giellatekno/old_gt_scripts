package langTools::RTFConverter;

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

sub convert2intermediate {
	my( $self ) = @_;

	my $command = "unrtf --nopict --html " . $self->getOrig() . " | tidy -config " . $self->{_bindir} . "/tidy-config.txt -utf8 -asxml -quiet > " . $self->gettmp2();
# 	die("Couldn't convert rtf doc to html") if 
	$self->exec_com($command);
	
	$command = "xsltproc \"" . $self->getXsl() . "\" \"" . $self->gettmp2() . "\" > \"" . $self->gettmp1() . "\"";
	die("Wasn't able to convert " . $self->getOrig() . " to intermediate xml format") if $self->exec_com($command);
	
	return $self->gettmp1();
}

1;
