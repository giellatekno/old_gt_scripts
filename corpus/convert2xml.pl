#!/usr/bin/perl

use strict;
use Cwd;
use Encode;
use utf8;
use langTools::Converter;
use Getopt::Long;
use File::Find;

# options
my $shallow = 0;
my $debug = 0;
my $printfiles = 0;
GetOptions ("debug" => \$debug,
			"shallow" => \$shallow,
			"printfiles" => \$printfiles,
);

$langTools::Decode::Test = $debug;
	
# global variables
my $counter = 0;
my $errors = 0;

# error hash
my %error_hash = ();

main(\@ARGV, $debug);

sub main {
	my ($ref_to_argv, $debug) = @_;
	my $numArgs = $#{$ref_to_argv} + 1;

	if (sanity_check()) {
		print "Your dependencies aren't setup correctly.\n";
		print "Follow the instructions above to be able to use this program\n";
	} elsif ($numArgs > 0) {
		print "Processing files\n";
		foreach my $argnum (0 .. $#{$ref_to_argv}) {
			my $tmp = ${$ref_to_argv}[$argnum];
			if ( -d $tmp ) {
				File::Find::find( \&convertdoc, $tmp );
			} else {
				convertdoc($tmp);
			}
		}
		conclusion();
		if ($printfiles) {
			print_files();
		}
	} else {
		print_help();
	}
}

sub convertdoc {
	my $file = $_;
	$file = shift (@_) if (!$file);

	my $filename = Cwd::abs_path($file);
	my $error = 0;
	my $feedback;

	if (! ($filename =~ /(\.xsl$|\/\.svn|.DS_Store|.tmp$|~$|\.qxp$|\.indd$|\.psd$|\.writenow$|\.ps$|\.xls$|\.jpg$|\.docx$|\.odt$|\.js$|\.gif$|\.css$|\.png$)/ || -d $filename) ) {
		my $converter = langTools::Converter->new($filename, $debug);
		if (! ($shallow && -f $converter->getFinalName()) ) {
			$converter->redirect_stderr_to_log();
			$counter++;
			print STDERR "\n\n«$filename»\n";
			
			if (ref($converter->getPreconverter()) eq 'langTools::CantHandle') {
				$error = 1;
				push (@{$error_hash{"cant_handle"}}, $file);
			} elsif ($converter->makeXslFile()) {
				print STDERR "Conversion failed: Couldn't use " . $converter->getOrig() . ".xsl\n";
				$error = 1;
				push (@{$error_hash{"xsl"}}, $file);
			} elsif ($converter->convert2intermediatexml()) {
				print STDERR "Conversion failed: Couldn't convert " . $converter->getOrig() . " to intermediate xml format\n";
				$error = 1;
				push (@{$error_hash{"intermediate"}}, $file);
			} elsif ($converter->convert2xml()) {
				print STDERR "Conversion failed: Couldn't combine " . $converter->getOrig() . " and " . $converter->getOrig() . ".xsl\n";
				$error = 1;
				push (@{$error_hash{"convert2xml"}}, $file);
			} elsif ($converter->checklang()) {
				print STDERR "Conversion failed: Couldn't verify the lang of " . $converter->getOrig() . " based on dir and metadata\n";
				$error = 1;
				push (@{$error_hash{"checklang"}}, $file);
			} elsif ($converter->checkxml()) {
				print STDERR "Conversion failed: Wasn't able to make valid xml out of " . $converter->getOrig() . " after language verification\n";
				$error = 1;
				push (@{$error_hash{"checkxml_after_checklang"}}, $file);
			# Error markup conversion must be done before repairing characters, otherwise ¥ will be destrooyed
			} elsif ($filename =~ m/\.correct\./ and $converter->error_markup()) {
				print STDERR "Conversion failed: Wasn't able to make valid error markup out of " . $converter->getOrig() . "\n";
				$error = 1;
				push (@{$error_hash{"error_markup"}}, $file);
            } elsif ($filename =~ m/\.correct\./ and $converter->checkxml()) {
				print STDERR "Conversion failed: Wasn't able to make valid xml out of " . $converter->getOrig() . " after error markup addition\n";
				$error = 1;
				push (@{$error_hash{"checkxml_after_errormarkup"}}, $file);
			} elsif ($converter->character_encoding()) {
				print STDERR "Conversion failed: Wasn't able to set correct encoding of " . $converter->getOrig() . "\n";
				$error = 1;
				push (@{$error_hash{"character_encoding"}}, $file);
			} elsif ($converter->search_for_faulty_characters($converter->getInt())) {
				print STDERR "Conversion failed: Found faulty chars in " . $converter->getInt() . "(derived from " . $converter->getOrig() . ")\n";
				$error = 1;
				push (@{$error_hash{"faulty_chars"}}, $file);
			} elsif ($converter->text_categorization()) {
				print STDERR "Conversion failed: Wasn't able to identify the language(s) inside the text " . $converter->getOrig() . "\n";
				$error = 1;
				push (@{$error_hash{"text_categorization"}}, $file);
			} elsif ($converter->checkxml()) {
				print STDERR "Conversion failed: Wasn't able to make valid xml out of " . $converter->getOrig() . "\n";
				$error = 1;
				push (@{$error_hash{"checkxml_after_faulty"}}, $file);
			} else {
				$converter->move_int_to_converted();
				if (! $debug ) {
					$converter->remove_temp_files();
				}
			}
			if ($error) {
				$feedback = "|";
				$errors++;
				if (-f $converter->getFinalName()) {
					unlink($converter->getFinalName());
					print STDERR "Removed: " . $converter->getFinalName() . "\n";
				}
			} else {
				$feedback = ".";
			}
		
			unless ($converter->get_debug()) {
				print "$feedback";
				unless ( $counter % 50) {
					print " $counter\n";
				}
			}
		}
	}
}

sub sanity_check {
	my ($self) = @_;
	
	my $invalid_setup = 0;

	# This is the most important thing to set, exit right away if unset
	if ("$ENV{'GTHOME'}" eq "") {
		print "The environment variable GTHOME isn't set\n";
		print "Run the script gtsetup.sh found in the same\n";
		print "directory as this script.";
		$invalid_setup = 1;
	} else {
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

		if (!-f "/bin/readlink") {
			#This is not a Linux system, check for a usable readlink
			if(!-f "/opt/local/bin/greadlink") {
				print "You don't have the correct version of readlink.\n";
				print "Install it issuing the command:\n\n";
				print "sudo port install coreutils\n\n";
				$invalid_setup = 1;
			}
		}
	}
	return $invalid_setup;
}

sub print_files {
	foreach my $key (sort(keys %error_hash)) {
		print "$key\n";
		foreach my $name (@{$error_hash{$key}}) {
			print "\t$name\n";
		}
		print "\n";
	}
}

sub conclusion {
	print " $counter \nProcessing finished\n";
	print "$counter files processed, "; 
	
	if ($errors) {
		print "$errors errors among them\n";
		print "The errors were distributed like this:\n";
		foreach my $key (sort(keys %error_hash)) {
			print "$key ";
			my $percents = sprintf "%.0f", @{$error_hash{$key}}/$errors*100;
			print $percents, "% of errors\n";
		}
		print "To find which files caused the errors, do the command\n";
		print "grep \"Conversion failed\" tmp/*.log\n";
	} else {
		print "no errors encountered\n";
	}
}

sub print_help {
	print "Usage: convert2xml.pl [OPTIONS] [FILES|DIRS]\n";
	print "The available options:\n";
	print "    --debug    Print all the operations that are done when converting files to stderr\n";
	print "    --shallow  Convert only files that haven't been converted before\n";
}
