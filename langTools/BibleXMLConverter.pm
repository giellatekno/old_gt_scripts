package langTools::BibleXMLConverter;

use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub convert2intermediate {
	my( $self ) = @_;

	my $error = 1;
	my $command = "bible2xml.pl --out \"" . $self->gettmp1() . "\" \"" . $self->getOrig() . "\"";
	if ($self->exec_com($command)) {
		$error = 1;
	}

	return $error;
}

1;
