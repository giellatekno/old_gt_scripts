package langTools::Preconverter;
use strict;
use File::Basename;
use File::Path;
use Cwd;
use utf8;
use Carp qw(cluck carp);
use XML::Twig;
use Encode;

sub new {
	my ($class, $filename, $test) = @_;

	my $abs_path = Encode::decode_utf8(Cwd::abs_path($filename));
	if (! -e $filename) {
		print "$filename: file doesn't exist\n";
		die("$filename: file doesn't exist");
	}
	unless ($abs_path =~ m/orig\//) {
		print "$abs_path: filename must exist inside a corpus directory\n";
		die("$abs_path: filename must exist inside a corpus directory") ;
	}

	my $self = {};
	$self->{_orig_file} = $abs_path;
	$self->{_test} = $test;
	$self->{_bindir} = "$ENV{'GTHOME'}/gt/script";
	$self->{_corpus_script} = $self->{_bindir} . "/corpus";
	$self->{_tmpfile_base} = join ( '', map {('a'..'z')[rand 26]} 0..7 );

	my @values = split("/orig/", $abs_path);
	$self->{_tmpdir} = $values[0] . "/tmp";
	if ( ! -e $self->{_tmpdir} ) {
		File::Path::mkpath($self->{_tmpdir});
	}
	@values = split("/", $values[1]);
	$self->{_doclang} = $values[0];

	bless $self, $class;

	$self->{_intermediate_xml2} = $self->getTmpDir() . "/" . $self->getTmpFilebase() . ".tmp2";
	$self->{_intermediate_xml} = $self->getTmpDir() . "/" . $self->getTmpFilebase() . ".tmp1";

	return $self;
}

sub getTest {
	my( $self ) = @_;
	return ($self->{_test});
}

sub getOrig {
	my( $self ) = @_;
	return $self->{_orig_file};
}

sub getTmpFilebase {
	my( $self ) = @_;
	return $self->{_tmpfile_base};
}

sub getTmpDir {
	my( $self ) = @_;
	return $self->{_tmpdir};
}

sub gettmp1 {
	my( $self ) = @_;
	return $self->{_intermediate_xml};
}

sub gettmp2 {
	my( $self ) = @_;
	return $self->{_intermediate_xml2};
}

sub getDoclang {
	my( $self ) = @_;
	return $self->{_doclang};
}

sub exec_com {
	my ( $self, $com ) = @_;

	my $result = system($com);
	if ($self->{_test}) {
		print STDERR $self->getOrig() . " exec_com: $com\n";
		if ($result != 0 ) {
			print STDERR "Errnr: $result. Errmsg: $!\n";
		}
	}

	return $result;
}

sub check_dependencies {
	my ($self) = @_;
	
	my $invalid_setup = 0;

	if (qx{which antiword} eq "") {
		print "Didn't find antiword\n";
		print "Install it on Mac by issuing the command\n\n";
		print "sudo port install antiword\n\n";
		print "For Linux, issue one of these commands:\n";
		print "Ubuntu/Debian: sudo apt-get install antiword\n";
		print "Fedora/Red Hat/CentOS: sudo yum install antiword\n";
		print "SUSE: sudo zypper install antiword\n\n";
		$invalid_setup = 1;
	}
	if (qx{which xsltproc} eq "") {
		print "Didn't find xsltproc\n";
		print "Install it on Mac by issuing the command\n\n";
		print "sudo port install libxslt\n\n";
		print "For Linux, issue one of these commands:\n";
		print "Ubuntu/Debian: sudo apt-get install xsltproc\n";
		print "Fedora/Red Hat/CentOS: sudo yum install libxslt\n";
		print "SUSE: sudo zypper install libxslt\n\n";
		$invalid_setup = 1;
	}
	if (qx{which tidy} eq "") {
		print "Didn't find tidy\n";
		print "Install it on Mac by issuing the command\n\n";
		print "sudo port install tidy\n\n";
		print "For Linux, issue one of these commands:\n";
		print "Ubuntu/Debian: sudo apt-get install tidy\n";
		print "Fedora/Red Hat/CentOS: sudo yum install tidy\n";
		print "SUSE: sudo zypper install tidy\n\n";
		$invalid_setup = 1;
	}
	if (qx{which pdftotext} eq "") {
		print "Didn't find pdftotext\n";
		print "Install it on Mac by issuing the command\n\n";
		print "sudo port install poppler\n\n";
		print "For Linux, issue one of these commands:\n";
		print "Ubuntu/Debian: sudo apt-get install poppler-utils\n";
		print "Fedora/Red Hat/CentOS: sudo yum poppler-utils\n";
		print "SUSE: sudo zypper install poppler-utils\n\n";
		$invalid_setup = 1;
	}
	if (qx{which xmllint} eq "") {
		print "Didn't find xmllint\n";
		print "Install it on Mac by issuing the command\n\n";
		print "sudo port install libxml2\n\n";
		print "For Linux, issue one of these commands:\n";
		print "Ubuntu/Debian: sudo apt-get install libxml2-utils\n";
		print "Fedora/Red Hat/CentOS: sudo yum install libxml2\n";
		print "SUSE: sudo zypper install libxml2\n\n";
		$invalid_setup = 1;
	}
	if (qx{which unrtf} eq "") {
		print "Didn't find unrtf\n";
		print "Install it on Mac by issuing the command\n\n";
		print "sudo port install unrtf\n\n";
		print "For Linux, issue one of these commands:\n";
		print "Ubuntu/Debian: sudo apt-get install unrtf\n";
		print "Fedora/Red Hat/CentOS: sudo yum install unrtf\n";
		print "SUSE: sudo zypper install unrtf\n\n";
		$invalid_setup = 1;
	}

	if ("$ENV{'GTHOME'}" eq "") {
		print "The environment variable GTHOME isn't set\n";
		print "Run the script gtsetup.sh found in the same\n";
		print "directory as this script.";
		$invalid_setup = 1;
	}

	if (!-f "/bin/readlink") {
		#This is not a Linux system, check for a usable readlink
		if(!-f "/opt/local/bin/greadlink") {
			print "You don't have the correct version of readlink.\n";
			print "Install it issuing the command:\n\n";
			print "sudo port install coreutils\n\n";
			$invalid_setup = 1;
		}
	}

	if ($invalid_setup) {
		exit(-1);
	}
}

1;
