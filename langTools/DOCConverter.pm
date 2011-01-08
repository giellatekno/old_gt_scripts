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

	my $command = "antiword -s -x db \"" . $self->getOrig() . "\" > \"" . $self->gettmp2() . "\"";
	die("Wasn't able to convert " . $self->getOrig() . " to intermediate docbook") if $self->exec_com($command);

	$command = "xsltproc \"" . $self->getXsl() . "\" \"" . $self->gettmp2() . "\" > \"" . $self->gettmp1() . "\"";
	die("Wasn't able to convert " . $self->gettmp2() . " to intermediate xml format") if $self->exec_com($command);

	$command = "perl -pi -e \"s/\x{00B6}/<\\/p><p>/g\" \"" . $self->gettmp1() . "\"";
	die("Wasn't able to convert " . $self->gettmp1() . " to intermediate xml format") if $self->exec_com($command);

    return $self->gettmp1();
}