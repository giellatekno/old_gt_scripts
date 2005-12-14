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

sub process_file {
    my $file = $_;
    $file = shift (@_) if (!$file);
	
	# Check the file name for taintedness
	# This is actually already done in upload.cgi
	if ($file =~ /^([\/-\@\w.]+)$/) {
		$file = $1; # $data now untainted
    } 
	else {
		print STDERR "$file: ERROR: Bad data in file name.\n";
		return;
	}
	# Search with find gives some unwanted files which are silently
	# returned here.
    return unless ($file =~ m/\.(doc|pdf|html)$/);
    return if ($file =~ /[\~]$/);
    return if (__FILE__ =~ $file);
	return if (-z $file);

    my $orig = File::Spec->rel2abs($file);
    (my $int = $orig) =~ s/orig/gt/;
	$int =~ s/\.(doc|pdf|html)$/\.\L$1\.xml/i;

	# Take only the file name without path.
	$file =~ s/.*[\/\\](.*)/$1/;
	
	IO::File->new($int, O_RDWR|O_CREAT) 
		or die "Couldn't open $int for writing: $!\n";

	my $command;

	# Conversion of word documents
	if ($file =~ /\.doc$/) {
		my $xsl;
		if ($xsl_file) { $xsl = $xsl_file; }
		else { $xsl = $docxsl; }
		$command = "/usr/local/bin/antiword -s -x db \"$orig\" | /usr/bin/xsltproc \"$xsl\" - > \"$int\"";
		print STDERR "$command\n"; 
		system($command) == 0 
			or print STDERR "$file: ERROR system failed\n";
	}
	
	# Conversion of xhtml documents
	if ($file =~ /\.html$/) {
		my $xsl;
		if ($xsl_file) { $xsl = $xsl_file; }
		else { $xsl = $htmlxsl; }
		$command = "$tidy \"$orig\" | xsltproc \"$xsl\" - > \"$int\"";
		print STDERR "$command\n";
		system($command) == 0
			or print STDERR "$file: ERROR system failed\n";
	}

	# Conversion of pdf documents	
	elsif ($file =~ /\.pdf$/) {
		my $xsl;
		if ($xsl_file) { $xsl = $xsl_file; }
		else { $xsl = $htmlxsl; }
		my $html = $tmpdir . "/" . $file . ".tmp";
		$command = "pdftotext -enc UTF-8 -nopgbrk -htmlmeta -eol unix \"$orig\" \"$html\"";
		print STDERR $command, "\n";
		system($command) == 0 
			or print STDERR "$file: ERROR system failed \n";
		&pdfclean($html);
		$command = "$tidy \"$html\" | xsltproc \"$xsl\" -  > \"$int\"";
		print STDERR $command;
		system($command) == 0
			or print STDERR "$file: ERROR system failed\n";
	}

	if (! $nolog) {
		open FH, $log_file;
		while (<FH>) {
			print "$_\n" if (/ERROR/ && /$file/);
		}
	}
	
	
# Check if the file contains characters that are wrongly
# utf-8 encoded and decode them.
	if (! $no_decode) {
		my $coding = &guess_encoding($int, $language);
		&decode_file($int, $coding, $int);
	}
}

sub pdfclean {

		my $file = shift @_;
		
		if (! open (INFH, "$file")) {
			print STDERR "$file: ERROR system failed $!";
			return;
			}

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

sub print_help {
	print"Usage: convert2xml.pl [OPTIONS] [FILES]\n";
	print "The available options:\n";
	print"    --xsl=<file>    The xsl-file which is used in the conversion.\n";
    print"                    If not specified, the default values are used.\n";
    print"    --dir=<dir>     The directory where to search for converted files.\n";
    print"                    If not given, only FILE is processed.\n";
    print"    --tmpdir=<dir>  The directory where the log and other temporary files are stored.\n";
    print"    --nolog         Print error messages to screen, not to log files.\n";
    print"    --corpdir=<dir> The corpus directory, default is /usr/local/share/corp.\n";
    print"    --no-decode     Do not decode the characters.\n";
    print"    --help          Print this message and exit.\n";
};

my $no_decode = 0;
my $nolog = 0; 
my $xsl_file = '';
my $dir = '';
my $tmpdir = ''; 
my $corpdir = "/usr/local/share/corp";
my $docxsl = "/usr/local/share/corp/bin/docbook2corpus.xsl";
my $htmlxsl = "/usr/local/share/corp/bin/xhtml2corpus.xsl";

my $log_file;

# Some securing operations, add these to upload.cgi!
$ENV{'PATH'} = '/bin:/usr/bin:/usr/local/bin';
delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};

my $xsltproc="/usr/bin/xsltproc";
my $tidy = "tidy --quote-nbsp no --add-xml-decl yes --enclose-block-text yes -asxml -utf8 -quiet -language sme";

my $language = "sme";
my $help;

GetOptions ("no-decode" => \$no_decode,
			"xsl=s" => \$xsl_file,
			"dir=s" => \$dir,
			"tmpdir=s" => \$tmpdir,
			"corpdir=s" => \$corpdir,
			"nolog" => \$nolog,
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
        die "Error: could find directory for temporary and log files.\nSpecify tmpdir as command line.\n";
    }
}

# Redirect STDERR to log files.	
if (! $nolog) {
	my ($sec,$min,$hour,$mday,$mon,@rest) = localtime(time);
	$log_file = $tmpdir . "/" . $mon . "-" . $mday . "-" . $hour . "-" . $min . ".log";
	open STDERR, '>', "$log_file" or die "Can't redirect STDERR: $!";
}

# Search the files in the directory $dir and process each one of them.
if ($dir) {
	if (-d $dir) { find (\&process_file, $dir) }
	else { print "$dir ERROR: Directory did not exist.\n"; }
}

# Process the file given in command line.
process_file ($ARGV[$#ARGV]) if -f $ARGV[$#ARGV];


close STDERR;




