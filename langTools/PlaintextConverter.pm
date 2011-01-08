package langTools::PlaintextConverter;

use langTools::Corpus;
use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub convert2intermediate {
	my( $self ) = @_;
	
	langTools::Corpus::txtclean($self->getOrig(), $self->gettmp1(), "");
	
	$self->gettmp1();
}

1;
