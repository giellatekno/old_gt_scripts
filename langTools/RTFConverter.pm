package langTools::RTFConverter;

use langTools::Preconverter;
@ISA = ("langTools::Preconverter");

sub new {
    my ( $class, $filename, $test ) = @_;

    my $self = $class->SUPER::new( $filename, $test );
    $self->{_converter_xsl} = $self->{_corpus_script} . "/xhtml2corpus.xsl";

    bless $self, $class;
    return $self;
}

sub getXsl {
    my ($self) = @_;
    return $self->{_converter_xsl};
}

sub convert2intermediate {
    my ($self) = @_;

    my $error = 0;
    my $command =
      "unrtf --nopict --html " . $self->getOrig() . " > " . $self->gettmp1();
    if ( $self->exec_com($command) ) {
        print STDERR "Couldn't convert rtf doc to html\n";
        $error = 1;
    }
    else {
        $command =
            "tidy -config "
          . $self->{_bindir}
          . "/tidy-config.txt -utf8 -asxml -quiet "
          . $self->gettmp1() . " > "
          . $self->gettmp2();
        if ( $self->exec_com($command) == 512 ) {
            print STDERR "Couldn't tidy rtfhtml\n";
            $error = 1;
        }
        else {
            $command =
                "xsltproc --novalid \""
              . $self->getXsl() . "\" \""
              . $self->gettmp2()
              . "\" > \""
              . $self->gettmp1() . "\"";
            if ( $self->exec_com($command) ) {
                print STDERR "Wasn't able to convert "
                  . $self->getOrig()
                  . " to intermediate xml format\n";
                $error = 1;
            }
        }
    }

    return $error;
}

1;
