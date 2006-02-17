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
# $Revision$

use strict;
use encoding 'utf-8';
use open ':utf8';
use File::Find;
use File::Copy;
use IO::File;
use File::Basename;
use Getopt::Long;
use Cwd;
use samiChar::Decode;
use XML::Twig;

my $no_decode = 0;
my $nolog = 0; 
my $xsl_file = '';
my $dir = '';
my $tmpdir = ''; 
my $no_hyph = 0; 
my $all_hyph = 0; 
my $noxsl = 0;
my $corpdir = "/usr/local/share/corp";
my $bindir = "/usr/local/share/corp/bin";
my $docxsl = $bindir . "/docbook2corpus2.xsl";
my $htmlxsl = $bindir . "/xhtml2corpus.xsl";
my $xsltemplate = $bindir . "/XSL-template.xsl";

my $log_file;
my $language;
my $multi_coding=0;
my $upload=0;
my $cur_id=0; #variable is used in giving paragraphs their ids.

my $test=0; #preserves temporary files.

# set the permissions for created files: -rw-rw-r--
umask 0112;

# Some securing operations, add these to upload.cgi!
$ENV{'PATH'} = '/bin:/usr/bin:/usr/local/bin';
delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};

my $xsltproc="/usr/bin/xsltproc";

my $help;

GetOptions ("no-decode" => \$no_decode,
			"xsl=s" => \$xsl_file,
			"noxsl" => \$noxsl,
			"dir=s" => \$dir,
			"tmpdir=s" => \$tmpdir,
			"corpdir=s" => \$corpdir,
			"nolog" => \$nolog,
			"lang=s" => \$language,
			"no-hyph" => \$no_hyph,
			"all-hyph" => \$all_hyph,
			"multi-coding" => \$multi_coding,
			"upload" => \$upload,
			"help" => \$help);

if ($help) {
	&print_help;
	exit 1;
}

my %languages = (sme => 1, smj => 1, sma => 1, nno => 1, nob => 1, fin => 1, swe => 1,
				 eng => 1, oth => 1, );
# todo: This should create an error message.
if (! $language || ! $languages{$language}) { $language = "sme"; }

my $tidy = "tidy --quote-nbsp no --add-xml-decl yes --enclose-block-text yes -asxml -utf8 -quiet -language $language";
my $hyphenate = $bindir . "/add-hyph-tags.pl";
my $text_cat = $bindir . "/text_cat";

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

my $command;
# Redirect STDERR to log files.	
if (! $nolog) {
	my $time = `date +%b-%d-%H-%M`;
	chomp $time;
	$log_file = $tmpdir . "/" . $time . ".log";
	open STDERR, '>', "$log_file" or die "Can't redirect STDERR: $!";
	if (! $upload) {
		$command = "chgrp cvs \"$log_file\"";
		system($command) == 0
			or print STDERR "$log_file: ERROR chgrp failed\n";
	}
}

# Search the files in the directory $dir and process each one of them.
if ($dir) {
	if (-d $dir) { find (\&process_file, $dir) }
	else { print "$dir ERROR: Directory did not exist.\n"; }
}

# Process the file given in command line.
process_file ($ARGV[$#ARGV]) if -f $ARGV[$#ARGV];

close STDERR;

sub process_file {
    my $file = $_;
    $file = shift (@_) if (!$file);

	print STDERR "$file: $language\n";

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

	# Conversion of word documents
	if ($file =~ /\.doc$/) {
		my $xsl;
		if ($xsl_file) { $xsl = $xsl_file; }
		else { $xsl = $docxsl; }
		$command = "/usr/local/bin/antiword -s -x db \"$orig\" | /usr/bin/xsltproc \"$xsl\" - > \"$int\"";
		print STDERR "$command\n"; 
		system($command) == 0 
			or print STDERR "$file: ERROR antiword failed\n";
	}
	
	# Conversion of xhtml documents
	if ($file =~ /\.html$/) {
		my $xsl;
		if ($xsl_file) { $xsl = $xsl_file; }
		else { $xsl = $htmlxsl; }
		$command = "$tidy \"$orig\" | xsltproc \"$xsl\" - > \"$int\"";
		print STDERR "$command\n";
		system($command) == 0
			or print STDERR "$file: ERROR tidy failed\n";
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
			or print STDERR "$file: ERROR pdftotext failed \n";
		&pdfclean($html);
		$command = "$tidy \"$html\" | xsltproc \"$xsl\" -  > \"$int\"";
		print STDERR "$command\n";
		system($command) == 0
			or print STDERR "$file: ERROR tidy failed\n";
		# remove temporary files unless testing.
		if (! $test) {
			$command = "rm -rf \"$html\"";
			print STDERR "$command\n";
			system($command) == 0
				or print STDERR "$file: ERROR rm failed\n";
		}

	}
	if ($test) {
        # Intermediate temporary file for testing.
		my $tmp1 = $tmpdir . "/" . $file . ".tmp1";
		copy ($int, $tmp1) ;
	}

	# hyphenate the file
	if (! $no_hyph && $file !~/\.pdf/ ) {
		if ($all_hyph) {
			$command = "$hyphenate --all --infile=\"$int\" --outfile=\"$int\"";
		}
		else {
			$command = "$hyphenate --infile=\"$int\" --outfile=\"$int\"";		}
		print STDERR "$command\n";
		system($command) == 0
			or print STDERR "$file: ERROR hyphenate failed\n";
	}

	# Check if the file contains characters that are wrongly
	# utf-8 encoded and decode them.
  ENCODING: {
	  if (! $no_decode) {
		  &read_char_tables;
		  # guess encoding and decode each paragraph at the time.
		  if( $multi_coding ) {
			  my $document = XML::Twig->new(twig_handlers => { p => sub { call_decode(@_); } });
			  if ($document->safe_parsefile ("$int") == 0 ) {
				  print STDERR "$file: ERROR parsing the XML-file failed.\n";
				  last ENCODING;
			  }
			  open (FH, ">$int") or print STDERR "$file: ERROR cannot open file $!";
			  $document->set_pretty_print('record');
			  $document->print( \*FH);
		  } else {
			  # assume same encoding for the whole file.
			  my $coding = &guess_encoding($int, $language, 0);
			  if ($coding eq 0) { print STDERR "Correct character encoding.\n"; }
			  else { 
				  print STDERR "Character decoding: $coding\n";
				  &decode_file($int, $coding, $int);
			  }
		  }
	  }
  }
	if(! $upload) {
		$command = "chgrp cvs \"$int\"";
		system($command) == 0
			or print STDERR "$file: ERROR chgrp failed\n";
	}
	if (! $noxsl) {
		# Execute the file specific .xsl-script.
		# Copy it from template, if not exist.
		my $xsl_file = $orig . ".xsl";
		my $xsl_vfile = $orig . ".xsl,v";
		if(! -f $xsl_file && ! -f $xsl_vfile ) {
			copy ($xsltemplate, $xsl_file) 
				or print STDERR "ERROR: copy failed ($xsltemplate $xsl_file)\n";

			# Reformat the version information in the new xsl-file.
			open (FH, "+<$xsl_file");
			my @text_array = <FH> ;
			my @result_array;
			foreach my $line (@text_array){
				if ($line =~ /name\=\"current_version/) { $line =~ s/Revision/\$Revision\$/; }
				if ($line =~ /name\=\"template_version/) { $line =~ s/\$Revision(.*?)\$/$1/g; }
				push @result_array, $line;
			}
			seek (FH,0,0);
			print FH @result_array;
			truncate(FH, tell(FH));
			close(FH);

			$command = "chgrp cvs \"$xsl_file\" ";
			print STDERR "$command\n";
			system($command) == 0 
				or print STDERR "$file: ERROR chgrp failed \n";

			$command = "ci -t-\"file specific xsl-script, created in convert2xml.pl\" -q -i \"$xsl_file\"";
			print STDERR "$command\n";
			system($command) == 0
				or print STDERR "$file: ERROR version control failed \n";
		}
		$command = "co -q $xsl_file";
		print STDERR "$command\n";
		system($command) == 0
			or print STDERR "$file: ERROR checkout for the file $xsl_file failed. \n";
		my $tmp = $tmpdir . "/" . $file . ".tmp";

		$command = "xsltproc --novalid \"$xsl_file\" \"$int\" > \"$tmp\"";
		print STDERR "$command\n";
		system($command) == 0 
			or print STDERR "$file: ERROR xsltproc failed \n";

		copy ($tmp, $int) 
			or print STDERR "ERROR: copy failed ($tmp $int)\n";

		# Remove temporary file unless testing.
		if (! $test) {
			$command = "rm -rf \"$tmp\"";
			print STDERR "$command\n";
			system($command) == 0
				or print STDERR "$tmp: ERROR rm failed\n";
		}

		if ( -f $xsl_vfile) {
			$command = "rm -rf \"$xsl_file\" ";
			print STDERR "$command\n";
			system($command) == 0
				or print STDERR "$file: ERROR removal of working copy of $xsl_file failed \n";
		}
	}
#  LANGDETECT: {
#	  my $document = XML::Twig->new(twig_handlers => { p => sub { langdetect(@_, $language); } });
#	  if ($document->safe_parsefile ("$int") == 0) {
#		  print STDERR "$file: ERROR parsing the XML-file failed.\n";		  
#		  last LANGDETECT;
#	  }
#	  open (FH, ">$int") or print STDERR "$file: ERROR cannot open file $!";
#	  $document->set_pretty_print('record');
#	  $document->print( \*FH);
#	}
	# Print log message in case of fatal ERROR
	if (! $nolog) {
		open FH, $log_file;
		while (<FH>) {
			print "See file $log_file: $_\n" if (/ERROR/ && /$file/);
		}
	}
}

sub call_decode {
	my ( $twig, $para ) = @_;

	my $text = $para->text;
	&decode_para($language, \$text);
	$para->set_text($text);
}

sub langdetect {
	my ( $twig, $para, $language ) = @_;

	my $MINCHAR = 20;
	my $MAXCHAR = 100;
	my $lmdir = $bindir . "/LM";
	my $bestlang="";
	$cur_id++;

	my $text = $para->text;
	my $count = length($text);
	if ($count < $MINCHAR) {
		$bestlang = $language;
	}
	else {
		# take only a subset of the paragraph
		my $subtext = substr( $text, 0, $MAXCHAR);
		$subtext =~ s/\`//g;
		my $lang = `$text_cat -l -d $lmdir \"$subtext\"`;
		my $rest;
		($bestlang, $rest) = split (/ or /, $lang, 2);
		$bestlang =~ s/\n//;
		# Heuristics for deciding between different sami languges.
		# The default language is selected if none of the distinctive 
		# chars is found from the text.
		if ($bestlang =~/sm[aej]/) {
			$bestlang = $language;
			if ($text =~ /[áÁåÅäÄ]+/) {
				$bestlang = "smj";
			}
			if ($text =~ /[öÖï]+/) {
				$bestlang = "sma";
			}
			if ($text =~ /[áÁšŧžčđŋŊŽŠĐÁŠŦŦŽČ]+/) {
				$bestlang = "sme";
			}
		}
	}
	if ($bestlang ne $language) {
		$para->set_att( "xml:lang" => $bestlang );
	}
	$para->set_att( "id" => $cur_id );
}

sub pdfclean {

		my $file = shift @_;
		
		if (! open (INFH, "$file")) {
			print STDERR "$file: ERROR open failed $!";
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
    print"    --noxsl         Do not use file-specific xsl-template.\n";
    print"    --no-hyph       Do not add hyphen tags.\n";
    print"    --all-hyph      Add hyphen tags everywhere (default is at the end of the lines).\n";
    print"    --multi-coding  Document contains more than one different encodings, character \n";
    print"                    decoding is done paragraph-wise.\n";
    print"    --upload        Do conversion in the upload-directory. \n";
    print"    --help          Print this message and exit.\n";
};




