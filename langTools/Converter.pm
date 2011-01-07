package langTools::Converter;
use strict;

sub new {
	my ($class) = shift;
	my $self = {
		_orig => shift,
		_test => shift,
		_orig_dir => "orig",
		_gtbound_dir => "converted",
		_bindir => "$ENV{'GTHOME'}/gt/script",
		_c_script => "/corpus",
	};
	$self->{_commonxsl} = $self->{_bindir} . $self->{_c_script} . "/common.xsl";
	$self->{_preprocxsl} = $self->{_bindir} . $self->{_c_script} . "/preprocxsl.xsl";
	$self->{_tmpdir} = "tmp";

	$self->{_file} = join ( '', map {('a'..'z')[rand 26]} 0..7 );

	bless $self, $class;
	return $self;
}

sub getOrig {
	my( $self ) = @_;
	return $self->{_orig};
}

sub getInt {
	my( $self ) = @_;
	(my $int = $self->{_orig}) =~ s/$self->{_orig_dir}/$self->{_gtbound_dir}/;
	return $int . ".xml";
}

sub getFile {
	my( $self ) = @_;
	return $self->{_file};
}

sub convert2xml {
	my( $self ) = @_;
	return 0;
}

sub makeXslFile {
	my( $self ) = @_;
	my $command = "xsltproc --novalid --stringparam commonxsl \"" . $self->{_commonxsl} . "\" \"" . $self->{_preprocxsl} . "\" \"" . $self->getOrig() . ".xsl" . "\" > \"" . $self->{_tmpdir} . "/" . $self->{_file} . ".xsl" . "\"";
	return $self->exec_com($command);
}

sub exec_com {
	my ( $self, $com ) = @_;

	if ($self->{_test}) {
		print STDERR "exec_com: $com\n";
	}
	
	my $result = system($com);
	if ($result != 0) {
		print STDERR "ERROR errors in $com: $!\n";
	}
	
	return $result;
}

1;
# package langTools::AvvirxmlConverter;
# use langTools::Converter;
# our @ISA = qw(Converter);
# 
# sub new {
# 	my ($class) = @_;
# 	my $self = $class->SUPER::new();
# 	$self = {
# 		_xsl => $self->{_bindir} . $self->{_c_script} . "/avvir2corpus.xsl",
# 	};
# 	bless $self, $class;
# 	return $self;
# }
# 
# sub getXsl {
# 	my( $self ) = @_;
# 	return $self->{_xsl};
# }
# 
# sub convert2xml {
# 	my( $self ) = @_;
# 	my $command = "xsltproc \"" . $self->getXsl() . "\" \"" . $self->getOrig() . "\" > \"" . $self->getInt() . "\"";
# 	exec_com($command, $self->{_file});
# }

# package HTMLConverter;
# use Converter;
# our @ISA = qw(Converter);
# 
# sub new {
# 	my ($class) = @_;
# 	my $self = $class->SUPER::new();
# 	my $self = {
# 	};
# 	bless $self, $class;
# 	return $self;
# }
# 
# sub convert2xml {
# 	my $coding;
# 	if(! $noxsl) {
# 		my $document = XML::Twig->new;
# 		if (! $document->safe_parsefile("$xsl_file")) {
# 			carp "ERROR parsing the XSL-file failed: $@\n";
# 			return "ERROR";
# 		}
# 
# 		my $root = $document->root;
# 
# 		my $coding_elt = $root->first_child('xsl:variable[@name="text_encoding"]');
# 		if ($coding_elt) { 
# 			$coding = $coding_elt->{'att'}{'select'}; 
# 		}
# 	}
# 
# 	if (! $no_decode) {
# 		if (! $coding) { 
# 			$coding = &guess_text_encoding($orig, $tmp3, $language); 
# 		}
# 		my $error = &decode_text_file($orig, $coding, $tmp4);
# 		if ($error eq -1) { 
# 			return "ERROR"; 
# 		}
# 	}
# 
# 	$command = "$tidy -language $dir_lang \"$tmp4\" 2>&1 > \"$tmp3\"";
# 	if ($test) {
# 		print STDERR "exec_com: $command\n";
# 	}
# 	my $error = qx{$command};
# 	if ( $error =~ /Error/ ) {
# 		print "Error in tidy: $error\n";
# 		return "ERROR";
# 	}
# 
# 	$command = "/usr/bin/xsltproc \"$xsl\" \"$tmp3\" > \"$int\"";
# 	exec_com($command, $file);
# }
# 
# package PDFConverter;
# use Converter;
# our @ISA = qw(Converter);
# 
# sub new {
# 	my ($class) = @_;
# 	my $self = $class->SUPER::new();
# 	my $self = {
# 	};
# 	bless $self, $class;
# 	return $self;
# }
# 
# sub convert2xml {
# 	$command = "pdftotext -enc UTF-8 -nopgbrk -eol unix \"$orig\" - | sed -e 's/\x18//g'  -e 's/\xef\x83\xa0//' -e 's/\xef\x83\x9f//' -e 's/\xef\x81\xae//'  -e 's/\x04//' -e 's/\x07//' > \"$tmp3\"";
# 	exec_com($command, $file);
# 
# 	return convert_txt($file, $tmp3, $int, $xsl_file, \$no_decode_this_time_ref);
# }
# 
# package DOCConverter;
# use Converter;
# our @ISA = qw(Converter);
# 
# sub new {
# 	my ($class) = @_;
# 	my $self = $class->SUPER::new();
# 	my $self = {
# 	};
# 	bless $self, $class;
# 	return $self;
# }
# 
# convert2xml {
# 	$command = "antiword -s -x db \"$orig\" > \"$tmp3\"";
#     exec_com($command, $file);
#     $command = "xsltproc \"$xsl\" \"$tmp3\" > \"$int\"";
#     exec_com($command, $file);
#     $command = "perl -pi -e \"s/\x{00B6}/<\\/p><p>/g\" \"$int\"";
#     exec_com($command, $file);
# }
# 
# package RTFConverter;
# use Converter;
# our @ISA = qw(Converter);
# 
# sub new {
# 	my ($class) = @_;
# 	my $self = $class->SUPER::new();
# 	my $self = {
# 	};
# 	bless $self, $class;
# 	return $self;
# }
# 
# sub convert2xml {
# 	$command = "unrtf --html \"$orig\" > \"$tmp3\"";
# 	exec_com($command, $file);
# 
# 	return convert_html($file, $tmp3, $int, $xsl_file, $dir_lang);
# }
# 
# package ParatextConverter;
# use Converter;
# our @ISA = qw(Converter);
# 
# sub new {
# 	my ($class) = @_;
# 	my $self = $class->SUPER::new();
# 	my $self = {
# 	};
# 	bless $self, $class;
# 	return $self;
# }
# 
# package BibleConverter;
# use Converter;
# our @ISA = qw(Converter);
# 
# sub new {
# 	my ($class) = @_;
# 	my $self = $class->SUPER::new();
# 	my $self = {
# 	};
# 	bless $self, $class;
# 	return $self;
# }
# 
# package TextConverter;
# use Converter;
# our @ISA = qw(Converter);
# 
# sub new {
# 	my ($class) = @_;
# 	my $self = $class->SUPER::new();
# 	my $self = {
# 	};
# 	bless $self, $class;
# 	return $self;
# }
# 
# package SVGConverter;
# use Converter;
# our @ISA = qw(Converter);
# 
# sub new {
# 	my ($class) = @_;
# 	my $self = $class->SUPER::new();
# 	my $self = {
# 	};
# 	bless $self, $class;
# 	return $self;
# }
# 
# sub convert2xml {
# 	$command = "xsltproc \"$svgxsl\" \"$orig\" > \"$int\"";
# 	exec_com($command, $file);
# 
# 	return 0;
# }
# 
# package CorrectxmlConverter;
# use Converter;
# our @ISA = qw(Converter);
# 
# sub new {
# 	my ($class) = @_;
# 	my $self = $class->SUPER::new();
# 	my $self = {
# 	};
# 	bless $self, $class;
# 	return $self;
# }

