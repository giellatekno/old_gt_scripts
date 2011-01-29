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
		$self->clean_doc();
	}

	return $error;
}

sub clean_doc {
	my ($self) = @_;
	
	my %replacements = (
		"\x7" => "",
		"\x8" => "",
		"\x18" => "");
	
	open(FH, "<:encoding(utf8)", $self->gettmp1()) or die "Cannot open " . $self->gettmp1() . "$!";
	my @file = <FH>;
	close(FH);

	open(FH, ">:encoding(utf8)", $self->gettmp1()) or die "Cannot open " . $self->gettmp1() . "$!";
	foreach my $string (@file) {
		foreach my $a (keys %replacements) {
			my $ii = Encode::decode_utf8($a);
			my $i = Encode::decode_utf8($replacements{$a});
			$string =~ s/$ii/$i/g;
		}
		print FH $string;
	}
	close(FH);
}

1;
