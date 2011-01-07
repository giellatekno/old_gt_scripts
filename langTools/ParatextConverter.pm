package langTools::ParatextConverter;

use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub convert2intermediate {
	my( $self ) = @_;

	my $command = $self->{_corpus_script} . "/paratext2xml.pl --out \"" . $self->gettmp1() . "\" \"" . $self->getOrig() . "\"";
	die("Wasn't able to convert " . $self->getOrig() . " to intermediate xml format") if $self->exec_com($command);
	
	return $self->gettmp1();
}

1;
