package langTools::ParatextConverter;

use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub convert2intermediate {
	my( $self ) = @_;

	my $command = $self->{_corpus_script} . "/paratext2xml.pl --out \"" . $self->gettmp2() . "\" \"" . $self->getOrig() . "\" > /dev/null" ;
	die("Wasn't able to convert " . $self->getOrig() . " to bible.xml format") if $self->exec_com($command);
	
	my $command = "bible2xml.pl --out \"" . $self->gettmp1() . "\" \"" . $self->gettmp2() . "\"";
	die("Wasn't able to convert " . $self->gettmp2() . " to intermediate xml format") if $self->exec_com($command);
	
	return $self->gettmp1();
}

1;
