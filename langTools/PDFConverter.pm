package langTools::PDFConverter;

use langTools::Corpus;
use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub convert2intermediate {
	my( $self ) = @_;

	my $error = 0;
	my $command = "pdftotext -enc UTF-8 -nopgbrk -eol unix \"" . $self->getOrig() . "\" - > \"" . $self->gettmp2() . "\"";

	if ($self->exec_com($command)) {
		print STDERR "Couldn't convert pdf to plaintext\n";
		$error = 1;
	} else {
		langTools::Corpus::txtclean($self->gettmp2(), $self->gettmp1(), "");
	}

	return $error;
}

1;
