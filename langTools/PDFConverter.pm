package langTools::PDFConverter;

use langTools::Corpus;
use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub convert2intermediate {
	my( $self ) = @_;

	my $command = "pdftotext -enc UTF-8 -nopgbrk -eol unix \"" . $self->getOrig() . "\" - > \"" . $self->gettmp2() . "\"";
	langTools::Corpus::txtclean($self->gettmp2(), $self->gettmp1(), "");
	die("Couldn't convert pdf to plaintext") if $self->exec_com($command);
	
	langTools::Corpus::txtclean($self->gettmp2(), $self->gettmp1(), "");
	
	return $self->gettmp1();
}

1;
