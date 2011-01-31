package langTools::PlaintextConverter;
@ISA = ("langTools::Preconverter");
use langTools::Preconverter;

use samiChar::Decode;
use langTools::Corpus;

sub convert2intermediate {
	my( $self ) = @_;

	my $error = 0;
	my $encoding = &guess_text_encoding($self->getOrig(), $self->gettmp1(), $self->getDoclang());
	
	if ($encoding == -1) {
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
	
	
	if( $self->getTest() ){ 
		print "the intermediate doc is now in " . $self->gettmp1() . "\n";
	}
	$self->clean_doc();
	return $error;
}
sub clean_doc {
	my ($self) = @_;
	
	my %replacements = (
		"\x0" => "",
		"\x1" => "",
		"\x14" => "");
	
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
