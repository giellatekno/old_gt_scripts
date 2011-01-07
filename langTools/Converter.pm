package langTools::Converter;
use strict;
use File::Basename;
use File::Path;
use Cwd;
use utf8;

sub new {
	my ($class, $filename, $test) = @_;

	my $abs_path = Cwd::abs_path($filename);
	die("$filename: file doesn't exist") unless (-e $filename);
	die("$abs_path: filename must exist inside a corpus directory") unless $abs_path =~ m/orig\//;

# 	my ($fname, $directories, $suffix) = File::Basename::fileparse($abs_path);
# 	print "fileparse: b $fname b $directories  b $suffix b\n";
	my $self = {};
	$self->{_orig_file} = $abs_path;
	$self->{_test} = $test;
	$self->{_bindir} = "$ENV{'GTHOME'}/gt/script";
	$self->{_corpus_script} = $self->{_bindir} . "/corpus";
	$self->{_common_xsl} = $self->{_corpus_script} . "/common.xsl";
	$self->{_preproc_xsl} = $self->{_corpus_script} . "/preprocxsl.xsl";
	$self->{_tmpfile_base} = join ( '', map {('a'..'z')[rand 26]} 0..7 );

	my @values = split("/orig/", $abs_path);
	$self->{_tmpdir} = $values[0] . "/tmp";
	if ( ! -e $self->{_tmpdir} ) {
		File::Path::mkpath($self->{_tmpdir});
	}

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

sub makeXslFile {
	my( $self ) = @_;
	$self->{_metadata_xsl} = $self->getTmpDir() . "/" . $self->getTmpFilebase() . ".xsl";

	my $command = "xsltproc --novalid --stringparam commonxsl " . $self->getCommonXsl() . " " . $self->getPreprocXsl() . " " . $self->getOrig() . ".xsl" . " > " . $self->getMetadataXsl();
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

1;
