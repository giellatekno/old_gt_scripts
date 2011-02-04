package langTools::CorrectXMLConverter;
@ISA = ("langTools::Preconverter");
use langTools::Preconverter;

use samiChar::Decode;
use langTools::Corpus;

sub convert2intermediate {
	my( $self ) = @_;

	my $error = 0;

	if (-f $self->getOrig()) {
		copy($self->getOrig(), $self->getInt());
	else {
		$error = 1;
	}
	
	return $error;
}

1;
