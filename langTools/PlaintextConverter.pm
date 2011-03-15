package langTools::PlaintextConverter;
@ISA = ("langTools::Preconverter");
use langTools::Preconverter;

use samiChar::Decode;
use langTools::Corpus;

sub convert2intermediate {
	my( $self ) = @_;

	my $error = 0;
	
	if (-s $self->getOrig() == 0) {
		print STDERR "PlaintextConverter::convert2intermediate: " . File::Basename::basename($self->getOrig()) . " is an empty file\n";
		$error = 1;
	} else {
		my $encoding = &guess_text_encoding($self->getOrig(), $self->gettmp1(), $self->getDoclang());
		
		if ($encoding == -1) {
			print STDERR "Couldn't guess encoding\n";
			$error = 1;
		} elsif ($encoding) {
			if (&decode_text_file($self->getOrig(), $encoding, $self->gettmp2())) {
				print STDERR "Couldn't decode " . $self->getOrig() . " with encoding $encoding\n";
				$error = 1;
			} else {
				langTools::Corpus::txtclean($self->gettmp2(), $self->gettmp1(), $self->getDoclang());
			}
		} else {
			langTools::Corpus::txtclean($self->getOrig(), $self->gettmp1(), $self->getDoclang());
		}
		
		unless ( $error ) {
			$self->clean_doc();
		}
	}
	return $error;
}

sub clean_doc {
	my ($self) = @_;
	
	my %replacements = (
		"\x0" => "",
		"\x1" => "",
		"\x3" => "",
		"\x8" => "",
		"\x14" => "");
	
	open(FH, "<:encoding(utf8)", $self->gettmp1()) or die "clean_doc: Cannot open " . $self->gettmp1() . "$!";
	my @file = <FH>;
	close(FH);

	open(FH, ">:encoding(utf8)", $self->gettmp1()) or die "clean_doc: Cannot open " . $self->gettmp1() . "$!";
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
