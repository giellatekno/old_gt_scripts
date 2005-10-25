#!/usr/bin/perl -w

use strict;
use encoding 'utf-8';
use open ':utf8';
use File::Find;
use IO::File;
use File::Basename;
use Getopt::Long;
use samiChar::Decode;

my $use_decode; # use module Decode to decode the file. this is to be removed.
my $xsl_file = '';  # The xsl-file, if it is not one of the default files.
my $dir; # the directory where the search for files is done

GetOptions ("use-decode" => \$use_decode,
			"xsl=s" => \$xsl_file,
			"dir=s" => \$dir);

my $xsltproc="/usr/bin/xsltproc";
my $tidy = "/usr/local/bin/tidy --quote-nbsp no --add-xml-decl yes --enclose-block-text yes -asxml -utf8 -quiet -language sme";

# Find the directory where the xsl-files are.
# (The same where this script is)
# This should be changed when the script is installed somewhere
# and the xsl-files get their permanent location.
my $script_dir = dirname __FILE__;
$script_dir = File::Spec->rel2abs($script_dir);
my $docxsl = $script_dir . "/docbook2corpus.xsl";
my $htmlxsl = $script_dir . "/xhtml2corpus.xsl";


# A log file is created for each file, it contains the executed commands
# and redirected STDERR of these commands.
# The log file is created to the same directory as the other files,
# the directory should perhaps be changed.
my $log_dir = $dir;

# Search the files in the directory $dir and process each one of them.
find (\&process_file, $dir) if -d $dir;
process_file ($ARGV[$#ARGV]) if -f $ARGV[$#ARGV];

sub process_file {
    my $file = $_;
    $file = shift (@_) if (!$file);

    return unless ($file =~ m/\.(doc|pdf|html)$/);
    return if (__FILE__ =~ $file);
    return if ($file =~ /[\~]$/);
	return if (-z $file);
    
    my $orig = File::Spec->rel2abs($file);
    my $int = $orig;
	$int =~ s/\.(doc|pdf|html)$/\.\L$1\.xml/i;

	# Redirect STDERR to log files.
	my $log_file = $log_dir . "/" . $file . ".log";
	open STDERR, '>', "$log_file" or die "Can't redirect STDERR: $!";
	
	IO::File->new($int, O_RDWR|O_CREAT) 
		or die "Couldn't open $int for writing: $!\n";

	# Conversion of word documents
	if ($file =~ /\.doc$/) {
		my $xsl;
		if ($xsl_file) { $xsl = $xsl_file; }
		else { $xsl = $docxsl; }
		print STDERR "antiword -s -x db \"$orig\" | /usr/bin/xsltproc \"$xsl\" - > \"$int\"\n";
		system("antiword -s -x db \"$orig\" | /usr/bin/xsltproc \"$xsl\" - > \"$int\"") == 0 
			or die "system failed: $?";
	}

	# Conversion of xhtml documents
	if ($file =~ /\.html$/) {
		my $xsl;
		if ($xsl_file) { $xsl = $xsl_file; }
		else { $xsl = $htmlxsl; }
		print STDERR "$tidy \"$orig\" | /usr/bin/xsltproc \"$xsl\" - > \"$int\"\n";
		system("$tidy \"$orig\" | /usr/bin/xsltproc \"$xsl\" - > \"$int\"") == 0
			or die "system failed: $?";
	}

	# Conversion of pdf documents	
	elsif ($file =~ /\.pdf$/) {
		my $xsl;
		if ($xsl_file) { $xsl = $xsl_file; }
		else { $xsl = $htmlxsl; }
		my $html = $dir . "/temporary.out";
		print STDERR "pdftotext -enc UTF-8 -nopgbrk -htmlmeta -eol unix \"$orig\" \"$html\"\n";
		system("pdftotext -enc UTF-8 -nopgbrk -htmlmeta -eol unix \"$orig\" \"$html\"") == 0 
			or die "system failed: $?";
		&pdfclean($html);
		print STDERR "$tidy \"$html\" | /usr/bin/xsltproc \"$xsl\" -  > \"$int\"\n";
		system("$tidy \"$html\" | /usr/bin/xsltproc \"$xsl\" -  > \"$int\"") == 0
			or die "system failed: $?";
	}

# Check if the file contains characters that are wrongly
# utf-8 encoded and decode them.
		if ($use_decode) {
			my $coding = &guess_encoding($int, "sme");
			&decode_file($int, $coding, $int);
        }
	close STDERR;
}



sub pdfclean {

		my $file = shift @_;
		
		open (INFH, "$file") or die "Cannot open file $file: $!";

		my $number=0;
		my $string;
		my @text_array;
		while ($string = <INFH>) {

			# Clean the <pre> tags
			next if ($string =~ /pre>/);
			# Leave  the line as is if it starts with html tag.
			if ($string =~ m/^\</) {
				push (@text_array,$string);
				next;
			}

			chomp $string;

			# This if-construction is for finding the line numbers 
			# (which generally are in their own line and even separated by empty lines
			# The text before and after the line number is connected.
			
			if ( $string =~ /^\s*$/) {
				if ($number==1) {
					next;
				}
				else {
					$string = "<\/p>\n<p>";
				}
			}
			if ($string =~ /^\d+\s*$/) {
				$number=1;
				next;
			}
			# Headers are guessed and marked
			# This should be done after the decoding to get the characters correctly.
			$string =~ s/^([\d\.]+[A-ZÄÅÖÁŊČŦŽĐa-zöäåáčŧšđ\s]*)$/\n<\/p>\n<h2>$1<\/h2>\n<p>\n/;
			$number = 0;
			
			push (@text_array, $string);
		}
		close (INFH);

		open (OUTFH, ">$file") or die "Cannot open file $file: $!";
		print(OUTFH @text_array); 
		close (OUTFH);
}
