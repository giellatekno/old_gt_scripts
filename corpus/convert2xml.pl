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
GetOptions ("debug" => \$debug,
			"shallow" => \$shallow);
$samiChar::Decode::Test = $debug;
	
# global variables
my $counter = 0;
my $errors = 0;

# error hash
my %error_hash = ( 
	"xsl" => 0,
	"intermediate" => 0,
	"convert2xml" => 0,
	"checklang" => 0,
	"checkxml_after_checklang" => 0,
	"character_encoding" => 0,
	"faulty_chars" => 0,
	"checkxml_after_faulty" => 0,
	"text_categorization" => 0,
	"add_error_markup" => 0);

main(\@ARGV, $debug);

sub main {
	my ($ref_to_argv, $debug) = @_;
	my $numArgs = $#{$ref_to_argv} + 1;
	print "Processing files\n";
	foreach my $argnum (0 .. $#{$ref_to_argv}) {
		my $tmp = ${$ref_to_argv}[$argnum];
		if ( -d $tmp ) {
			File::Find::find( \&convertdoc2, $tmp );
		} else {
			convertdoc($tmp);
		}
	}
	conclusion();
}

sub convertdoc2 {
	my ($tmp) = $_;
	convertdoc($tmp);
}

sub convertdoc {
	my ($filename) = Cwd::abs_path(@_);
	my $error = 0;
	my $feedback;

	if (! ($filename =~ /(\.xsl$|\/\.svn|.DS_Store|.tmp$|~$|\.qxp$|\.indd$|\.psd$|\.writenow$|\.ps$|\.xls$|\.jpg$|\.docx$|\.odt$|\.js$|\.gif$|\.css$|\.png$)/ || -d $filename) ) {
		my $converter = langTools::Converter->new($filename, $debug);
		if (! ($shallow && -f $converter->getFinalName()) ) {
			$converter->redirect_stderr_to_log();
			$counter++;
			print STDERR "\n\n«$filename»\n";
			if ($converter->makeXslFile()) {
				print STDERR "Conversion failed: Couldn't use " . $converter->getOrig() . ".xsl\n";
				$error = 1;
				$error_hash{"xsl"}++;
			} elsif ($converter->convert2intermediatexml()) {
				print STDERR "Conversion failed: Couldn't convert " . $converter->getOrig() . " to intermediate xml format\n";
				$error = 1;
				$error_hash{"intermediate"}++;
			} elsif ($converter->convert2xml()) {
				print STDERR "Conversion failed: Couldn't combine " . $converter->getOrig() . " and " . $converter->getOrig() . ".xsl\n";
				$error = 1;
				$error_hash{"convert2xml"}++;
			} elsif ($converter->checklang()) {
				print STDERR "Conversion failed: Couldn't set the lang of " . $converter->getOrig() . "\n";
				$error = 1;
				$error_hash{"checklang"}++;
			} elsif ($converter->checkxml()) {
				print STDERR "Conversion failed: Wasn't able to make valid xml out of " . $converter->getOrig() . "\n";
				$error = 1;
				$error_hash{"checkxml_after_checklang"}++;
			} elsif ($converter->character_encoding()) {
				print STDERR "Conversion failed: Wasn't able to set correct encoding of " . $converter->getOrig() . "\n";
				$error = 1;
				$error_hash{"character_encoding"}++;
			} elsif ($converter->add_error_markup()) {
				print STDERR "Conversion failed: Wasn't able to make valid xml out of " . $converter->getOrig() . "\n";
				$error = 1;
				$error_hash{"add_error_markup"}++;
			} elsif ($converter->search_for_faulty_characters($converter->getInt())) {
				print STDERR "Conversion failed: Found faulty chars in " . $converter->getInt() . "(derived from " . $converter->getOrig() . ")\n";
				$error = 1;
				$error_hash{"faulty_chars"}++;
			} elsif ($converter->text_categorization()) {
				print STDERR "Conversion failed: Wasn't able to categorize the language(s) inside the text " . $converter->getOrig() . "\n";
				$error = 1;
				$error_hash{"text_categorization"}++;
			} elsif ($converter->checkxml()) {
				print STDERR "Conversion failed: Wasn't able to make valid xml out of " . $converter->getOrig() . "\n";
				$error = 1;
				$error_hash{"checkxml_after_faulty"}++;
			} else {
				$converter->move_int_to_converted();
				if (! $debug ) {
					$converter->remove_temp_files();
				}
			}
			
			if ($error) {
				$feedback = "|";
				$errors++;
			} else {
				$feedback = ".";
			}
			
			unless ($converter->get_debug()) {
				print $feedback;
				unless ( $counter % 50) {
					print " $counter\n";
				}
			}
		}
	}
}

sub conclusion {
	print " $counter \nProcessing finished\n";
	print "$counter files processed, "; 
	
	if ($errors) {
		print "$errors errors among them\n";
		print "The errors were distributed like this:\n";
		foreach my $key (keys %error_hash) {
			print "$key $error_hash{$key} ";
			my $percents = sprintf "%.0f", $error_hash{$key}/$errors*100;
			print $percents, "% of errors\n";
		}
		print "To find which files caused the errors, do the command\n";
		print "grep \"Conversion failed\" tmp/*.log\n";
	} else {
		print "no errors encountered\n";
	}
}
