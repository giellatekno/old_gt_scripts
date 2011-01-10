package langTools::Converter;
use langTools::AvvirXMLConverter;
use langTools::BibleXMLConverter;
use langTools::HTMLConverter;
use langTools::ParatextConverter;
use langTools::RTFConverter;
use langTools::DOCConverter;
use langTools::PlaintextConverter;
use langTools::PDFConverter;
use langTools::SVGConverter;

use strict;
use utf8;
use Carp qw(cluck carp);
use XML::Twig;
use File::Copy;

sub new {
	my ($class, $filename, $test) = @_;

	my $abs_path = Cwd::abs_path($filename);

	my $self = {};
	$self->{_test} = $test;
	$self->{_bindir} = "$ENV{'GTHOME'}/gt/script";
	$self->{_corpus_script} = $self->{_bindir} . "/corpus";
	$self->{_common_xsl} = $self->{_corpus_script} . "/common.xsl";
	$self->{_preproc_xsl} = $self->{_corpus_script} . "/preprocxsl.xsl";
	$self->{_xsltemplate} = $self->{_corpus_script} . "/XSL-template.xsl";
	my $preconverter = undef;
	if( $abs_path =~ /Avvir/ && $abs_path =~ /\.xml$/ ) {
		print "avvir\n";
		$preconverter = langTools::AvvirXMLConverter->new($filename, $test);
	} elsif( $abs_path =~ /\.bible\.xml$/ ) {
		print "bible.xml\n";
		$preconverter = langTools::BibleXMLConverter->new($filename, $test);
	} elsif( $abs_path =~ /\.html\?id=\d*/ || $abs_path =~ /\.html$/ || $abs_path =~ /\.htm$/ ) {
		print "html\n";
		$preconverter = langTools::HTMLConverter->new($filename, $test);
	} elsif( $abs_path =~ /\.ptx$/ ) {
		print "ptx\n";
		$preconverter = langTools::ParatextConverter->new($filename, $test);
	} elsif( $abs_path =~ /\.rtf$/ ) {
		print "rtf\n";
		$preconverter = langTools::RTFConverter->new($filename, $test);
	} elsif( $abs_path =~ /\.doc$/ ) {
		print "doc\n";
		$preconverter = langTools::DOCConverter->new($filename, $test);
	} elsif( $abs_path =~ /\.txt$/ ) {
		print "plaintext\n";
		$preconverter = langTools::PlaintextConverter->new($filename, $test);
	} elsif( $abs_path =~ /\.pdf$/ ) {
		print "pdf\n";
		$preconverter = langTools::PDFConverter->new($filename, $test);
	} elsif( $abs_path =~ /\.svg$/ ) {
		print "svg\n";
		$preconverter = langTools::SVGConverter->new($filename, $test);
	} else {
		die("unable to handle $filename\n");
	}
	die("Preconverter is undefined") unless $self->{_preconverter} = $preconverter;
	$self->{_intermediate_xml} = $preconverter->convert2intermediate();
	$self->{_tmpfile_base} = $preconverter->getTmpFilebase();
	$self->{_orig_file} = $preconverter->getOrig();
	$self->{_tmpdir} = $preconverter->getTmpDir();

	bless $self, $class;

	return $self;
}

sub getOrig {
	my( $self ) = @_;
	return $self->{_orig_file};
}

sub getInt {
	my( $self ) = @_;
	(my $int = $self->getOrig()) =~ s/\/orig\//\/converted\//;
	return $int . ".xml";
}

sub getTmpFilebase {
	my( $self ) = @_;
	return $self->{_tmpfile_base};
}

sub getCommonXsl {
	my( $self ) = @_;
	return $self->{_common_xsl};
}

sub getPreprocXsl {
	my( $self ) = @_;
	return $self->{_preproc_xsl};
}

sub getTmpDir {
	my( $self ) = @_;
	return $self->{_tmpdir};
}

sub getMetadataXsl() {
	my( $self ) = @_;
	return $self->{_metadata_xsl};
}

sub getIntermediateXml {
	my( $self ) = @_;
	return $self->{_intermediate_xml};
}

sub getXslTemplate {
	my( $self ) = @_;
	return $self->{_xsltemplate};
}

sub makeXslFile {
	my( $self ) = @_;
	$self->{_metadata_xsl} = $self->getTmpDir() . "/" . $self->getTmpFilebase() . ".xsl";

	my $command = undef;
	
	if ( -e $self->getOrig() . ".xsl" ) {
		$command = "xsltproc --novalid --stringparam commonxsl " . $self->getCommonXsl() . " " . $self->getPreprocXsl() . " " . $self->getOrig() . ".xsl" . " > " . $self->getMetadataXsl();
	} else {
		$command = "xsltproc --novalid --stringparam commonxsl " . $self->getCommonXsl() . " " . $self->getPreprocXsl() . " " . $self->getXslTemplate() . " > " . $self->getMetadataXsl();
	}
	
	return $self->exec_com($command);
}

sub makeIntDir {
	my( $self ) = @_;
	if( ! -e File::Basename::dirname($self->getInt())) {
		File::Path::mkpath(File::Basename::dirname($self->getInt()));
	}
}

sub exec_com {
	my ( $self, $com ) = @_;

	if ($self->{_test}) {
		print STDERR $self->getOrig() . " exec_com: $com\n";
	}

	my $result = system($com);
	if ($result != 0) {
		print STDERR "Errnr: $result. Errmsg: $com: $!\n";
	}

	return $result;
}

sub convert2xml {
	my( $self ) = @_;

	$self->makeIntDir();

	my $command = "xsltproc \"" . $self->getMetadataXsl() . "\" \"" . $self->getIntermediateXml() . "\" > \"" . $self->getInt() . "\"";
	return $self->exec_com($command);
}

sub checkxml {
	my( $self ) = @_;
	
	my $command = "xmllint --valid --encode UTF-8 " . $self->getInt() . " > /dev/null";
	return $self->exec_com($command);
}

sub checklang {
	my( $self ) = @_;
	
	# Check the main language,  add if it is missing.
	my $tmp = $self->getInt();
	my $document = XML::Twig->new;
	if (! $document->safe_parsefile("$tmp")) {
		carp "ERROR parsing the XML-file «$tmp» failed ";
		return "1";
	}
	my $root = $document->root;
	my $mainlang = $root->{'att'}->{'xml:lang'};
	my $id = $root->{'att'}->{'id'};

	if(! $mainlang || $mainlang eq "unknown") {
		#print "setting language: $language \n";
		#$root->set_att('xml:lang', $language);
		# Setting language by using the directory path is a better 'guess' for documents lacking this piece of information
		$root->set_att('xml:lang', $self->{_preconverter}->getDoclang());
	}
	open(FH, ">$tmp") or die "Cannot open $tmp $!";
	$document->set_pretty_print('indented');
	$document->print(\*FH);

	return 0;
}

sub character_encoding {
	my ($self) = @_;
    #my ($file, $int, $no_decode_this_time) = @_;
	my $file = $self->getOrig();
	my $int = $self->getInt();
	my $no_decode_this_time = 0;
	my $no_decode = 0;
	my $multi_coding = 0;
	my $test = $self->getTest();
	my $language = $self->getDoclang();
    # Check if the file contains characters that are wrongly
    # utf-8 encoded and decode them.

    if (! $no_decode ) {
        &read_char_tables;
        # guess encoding and decode each paragraph at the time.
        if( $multi_coding ) {
            my $document = XML::Twig->new(twig_handlers => { p => sub { call_decode_para(@_); } });
            if (! $document->safe_parsefile ("$int") ) {
                carp "ERROR parsing the XML-file failed. STOP\n";
                return "ERROR";
            }
            if (! open (FH, ">$int")) {
                carp "ERROR cannot open file STOP";
                return "ERROR";
            }
            $document->set_pretty_print('indented');
            $document->print( \*FH);
        } else {
            # assume same encoding for the whole file.
            my $coding = &guess_encoding($int, $language, 0);
            if ($coding eq -1) {
                carp "ERROR Was not able to determine character encoding. STOP.";
                return "ERROR";
            }
            elsif ($coding eq 0) {
                if($test) { print STDERR "Correct character encoding.\n"; }
                if($file =~ /\.doc$/) {
                    # Document title in msword documents is generally wrongly encoded,
                    # check that separately.
                    my $d=XML::Twig->new(twig_handlers=>{
                        'p[@type="title"]'=> sub{call_decode_title(@_, $coding); },
                        'title'=>sub{call_decode_title(@_);}
                    }
                                         );
                    if (! $d->safe_parsefile ("$int") ) {
                        carp "ERROR parsing the XML-file failed.\n";
                        return "ERROR";
                    }
                    if (! open (FH, ">$int")) {
                        carp "ERROR cannot open file";
                        return "ERROR";
                    }
                    $d->set_pretty_print('indented');
                    $d->print( \*FH);
                }
                return 0;
            }
            # Continue decoding the file.
            if ($no_decode_this_time && $coding eq "latin6") { return 0; }
            if($test) { print STDERR "Character decoding: $coding\n"; }
            my $d=XML::Twig->new(twig_handlers=>{'p'=>sub{call_decode_para(@_, $coding);},
                                                 'title'=>sub{call_decode_para(@_, $coding);}
                                             }
                                 );
            if (! $d->safe_parsefile ("$int") ) {
                carp "ERROR parsing the XML-file failed.\n";
                return "ERROR";
            }
            if (! open (FH, ">$int")) {
                carp "ERROR cannot open file";
                return "ERROR";
            }
            $d->set_pretty_print('indented');
            $d->print( \*FH);
        }
    }
    return 0;
} 

1;
