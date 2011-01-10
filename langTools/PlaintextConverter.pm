package langTools::PlaintextConverter;
@ISA = ("langTools::Preconverter");
use langTools::Preconverter;

use samiChar::Decode;
use langTools::Corpus;

sub convert2intermediate {
	my( $self ) = @_;

	my $encoding = &guess_text_encoding($self->getOrig(), $self->gettmp1(), $self->getDoclang());
	
	if ($encoding) {
		if (&decode_text_file($self->getOrig(), $encoding, $self->gettmp2())) {
			die("Couldn't decode " . $self->getOrig() . " with encoding $encoding");
		}
		langTools::Corpus::txtclean($self->gettmp2(), $self->gettmp1(), $self->getDoclang());
	
	} else {
		langTools::Corpus::txtclean($self->getOrig(), $self->gettmp1(), $self->getDoclang());
	}
	
	
	if( $self->getTest() ){ 
		print "the intermediate doc is now in " . $self->gettmp1() . "\n";
	}
	$command = "perl -pi -e 's/\x14//g' " . $self->gettmp1();
	$self->exec_com($command);
	
	return $self->gettmp1();
}
1;
