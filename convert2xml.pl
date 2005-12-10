#!/usr/bin/perl -w
#
# convert2xml.pl
# Perl script for converting doc-, html- and pdf-files to xml-format
# The default directory for searching the files and storing the converted
# xml-files is /usr/local/share/corp. The file that is given to the script
# is expected to be in the corpus hierarchy, under subdirectory orig. 
# The converted file is created to the corresponding subdirectory gt.
#
# Log files are generated to subdirectory tmp, and the xsl-files are by default
# found under the subdirectory bin. It is possible to change the corpus directory
# but the underlying hierarchy should exists.
#
#
# Version $Id$

use strict;
use encoding 'utf-8';
use open ':utf8';
use File::Find;
use IO::File;
use File::Basename;
use Getopt::Long;
use Cwd;
use samiChar::Decode;

sub print_help {
	print"Usage: convert2xml.pl [OPTIONS] [FILES]\n";
	print "The available options:\n";
	print"    --xsl=<file>    The xsl-file which is used in the conversion.\n";
    print"                    If not specified, the default values are used.\n";
    print"    --dir=<dir>     The directory where to search for converted files.\n";
    print"                    If not given, only FILE is processed.\n";
    print"    --tmpdir=<dir>  The directory where the log and other temporary files are stored.\n";
    print"    --corpdir=<dir> The corpus directory, default is /usr/local/share/corp.\n";
    print"    --use-decode    Whether the character decoding is used or not.\n";
    print"                    This option is for testing.\n";
    print"    --help          Print this message and exit.\n";
};

my $use_decode = 1;
my $xsl_file = '';
my $dir = '';
my $tmpdir = ''; 
my $corpdir = "/usr/local/share/corp";
my $docxsl = "/usr/local/share/corp/bin/docbook2corpus.xsl";
my $htmlxsl = "/usr/local/share/corp/bin/xhtml2corpus.xsl";

my $xsltproc="/usr/bin/xsltproc";
my $tidy = "tidy --quote-nbsp no --add-xml-decl yes --enclose-block-text yes -asxml -utf8 -quiet -language sme";

my $language = "sme";
my $help;

dGetOptions ("use-decode" => \$use_decode,
			"xsl=s" => \$xsl_file,
			"dir=s" => \$dir,
			"tmpdir=s" => \$tmpdir,
			"corpdir=s" => \$corpdir,
			"lang=s" => \$language,
			"help" => \$help);

if ($help) {
	&print_help;
	exit 1;
}

if (! $corpdir || ! -d $corpdir) {
	die "Error: could not find corpus directory.\nSpecify corpdir as command line.\n";
}

# A log file is created for each file, it contains the executed commands
# and redirected STDERR of these commands.
if(! $tmpdir || ! -d $tmpdir) {
	$tmpdir = $corpdir . "/tmp";
    if (! -d $tmpdir) {
        die "Error: could find directory for log files.\nSpecify tmpdir as command line.\n";
    }
}

# Search the files in the directory $dir and process each one of them.
if ($dir) {
	find (\&process_file, $dir) if -d $dir;
}
process_file ($ARGV[$#ARGV]) if -f $ARGV[$#ARGV];

sub process_file {
    my $file = $_;
    $file = shift (@_) if (!$file);

    return unless ($file =~ m/\.(doc|pdf|html)$/);
    return if (__FILE__ =~ $file);
    return if ($file =~ /[\~]$/);
	return if (-z $file);
    
    my $orig = File::Spec->rel2abs($file);
    (my $int = $orig) =~ s/orig/gt/;
	$int =~ s/\.(doc|pdf|html)$/\.\L$1\.xml/i;

	# Redirect STDERR to log files.
	$file =~ s/.*[\/\\](.*)/$1/;
	my $log_file = $tmpdir . "/" . $file . ".log";
	open STDERR, '>>', "$log_file" or die "Can't redirect STDERR: $!";
	
	IO::File->new($int, O_RDWR|O_CREAT) 
		or die "Couldn't open $int for writing: $!\n";

	# Conversion of word documents
	if ($file =~ /\.doc$/) {
		my $xsl;
		if ($xsl_file) { $xsl = $xsl_file; }
		else { $xsl = $docxsl; }
		print STDERR "/usr/local/bin/antiword -s -x db \"$orig\" | /usr/bin/xsltproc \"$xsl\" - > \"$int\"\n";
		system("/usr/local/bin/antiword -s -x db \"$orig\" | /usr/bin/xsltproc \"$xsl\" - > \"$int\"") == 0 
			or die "system failed: $?";
	}

	# Conversion of xhtml documents
	if ($file =~ /\.html$/) {
		my $xsl;
		if ($xsl_file) { $xsl = $xsl_file; }
		else { $xsl = $htmlxsl; }
		print STDERR "$tidy \"$orig\" | xsltproc \"$xsl\" - > \"$int\"\n";
		system("$tidy \"$orig\" | xsltproc \"$xsl\" - > \"$int\"") == 0
			or die "system failed: $?";
	}

	# Conversion of pdf documents	
	elsif ($file =~ /\.pdf$/) {
		my $xsl;
		if ($xsl_file) { $xsl = $xsl_file; }
		else { $xsl = $htmlxsl; }
		my $html = $tmpdir . "/" . $file . ".tmp";
		print STDERR "pdftotext -enc UTF-8 -nopgbrk -htmlmeta -eol unix \"$orig\" \"$html\"\n";
		system("pdftotext -enc UTF-8 -nopgbrk -htmlmeta -eol unix \"$orig\" \"$html\"") == 0 
			or die "system failed: $?";
		&pdfclean($html);
		print STDERR "$tidy \"$html\" | xsltproc \"$xsl\" -  > \"$int\"\n";
		system("$tidy \"$html\" | xsltproc \"$xsl\" -  > \"$int\"") == 0
			or die "system failed: $?";
	}

# Check if the file contains characters that are wrongly
# utf-8 encoded and decode them.
		if ($use_decode) {
			my $coding = &guess_encoding($int, $language);
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
