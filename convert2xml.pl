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
use open ':locale';
binmode STDOUT, ":utf8";
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
#my $corpdir = "/home/saara/samipdf";
my $bindir = "/usr/local/share/corp/bin";
#my $bindir = "/home/saara/gt/script";
my $gtbound_dir = "gtbound";
my $gtfree_dir = "gtfree";
my $orig_dir = "orig";
my $gt_gid = 503; # group: cvs
my $orig_gid = 50779; #group: corpus

my $docxsl = $bindir . "/docbook2corpus2.xsl";
my $htmlxsl = $bindir . "/xhtml2corpus.xsl";
my $xsltemplate = $bindir . "/XSL-template.xsl";

my $log_file;
my $language;
my $multi_coding=0;
my $upload=0;

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
my $convert_eol = $bindir . "/convert_eol.pl";
my $paratext2xml = $bindir . "/paratext2xml.pl";

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
		my $cnt = chown -1, $orig_gid, $log_file;	
		if ($cnt == 0) { print "ERROR: chgrp failed for $log_file.\n"};
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
	return unless ($file =~ m/\.(doc|pdf|html|ptx)$/);
    return if ($file =~ /[\~]$/);
    return if (__FILE__ =~ $file);
	return if (-z $file);

    my $orig = File::Spec->rel2abs($file);
    (my $int = $orig) =~ s/$orig_dir/$gtbound_dir/;
	$int =~ s/\.(doc|pdf|html|ptx)$/\.\L$1\.xml/i;
    (my $intfree = $int) =~ s/\/$gtbound_dir/\/$gtfree_dir/;

	# Take only the file name without path.
	$file =~ s/.*[\/\\](.*)/$1/;

	if(-f $int && ! -w $int) {
		print "$file: ERROR: permission denied to $int. STOP.\n";
		print STDERR "$file: ERROR: permission denied to $int. STOP.\n";
		return;
	}
	
	my $tmp3 = $tmpdir . "/" . $file . ".tmp3";
	IO::File->new($int, O_RDWR|O_CREAT) 
		or die "Couldn't open $int for writing: $!\n";

	# Conversion of word documents
	if ($file =~ /\.doc$/) {
		my $xsl;
		if ($xsl_file) { $xsl = $xsl_file; }
		else { $xsl = $docxsl; }
		$command = "/usr/local/bin/antiword -s -x db \"$orig\" > $tmp3";
		exec_com($command, $file);
		$command = "/usr/bin/xsltproc \"$xsl\" $tmp3 > \"$int\"";
		exec_com($command, $file);
	}
	
	# Conversion of xhtml documents
	if ($file =~ /\.html$/) {
		my $xsl;
		if ($xsl_file) { $xsl = $xsl_file; }
		else { $xsl = $htmlxsl; }
		$command = "$tidy \"$orig\" > $tmp3";
		exec_com($command, $file);

		$command = "/usr/bin/xsltproc \"$xsl\" $tmp3 > \"$int\"";
		exec_com($command, $file);

	}
	
	# Conversion of pdf documents	
	elsif ($file =~ /\.pdf$/) {
		my $xsl;
		if ($xsl_file) { $xsl = $xsl_file; }
		else { $xsl = $htmlxsl; }
		my $html = $tmpdir . "/" . $file . ".tmp3";
		$command = "pdftotext -enc UTF-8 -nopgbrk -htmlmeta -eol unix \"$orig\" \"$html\"";
		exec_com($command, $file);

		# If there were severe errors in pdftotext, the html file is not created.
		if(! -f $html) {
			print "$file: no pdftotext output. STOP.\n";
			return;			
		}
		&pdfclean($html);
		$command = "$tidy \"$html\" | xsltproc \"$xsl\" -  > \"$int\"";
		exec_com($command, $file);

		# remove temporary files unless testing.
		if (! $test) {
			$command = "rm -rf \"$html\"";
			exec_com($command, $file);
		}
	}

	# Conversion of paratext documents
	if ($file =~ /\.ptx$/) {
		$command = "$paratext2xml $orig --out=$int";
		exec_com($command, $file);
	}

	if(! -f $int || -z $int ) {
		print "$file: ERROR: First conversion step from original failed. \n$int is empty. STOP.\nSee $log_file for details.\n";
		print STDERR "$file: ERROR: First conversion step from original failed. \n$int is empty. STOP.\n";
		return;
	}

	# end of line conversion.
	my $tmp1 = $tmpdir . "/" . $file . ".tmp1";
	my $command = "$convert_eol $int > $tmp1";
	exec_com($command, $file);
	copy ($tmp1, $int) ;

	# Remove temporary file unless testing.
	if (! $test) {
		exec_com("rm -rf $tmp1", $file);
		exec_com("rm -rf $tmp3", $file);
	}
	
	# hyphenate the file
	if (! $no_hyph && $file !~/\.pdf/ ) {
		if ($all_hyph) {
			$command = "$hyphenate --all --infile=\"$int\" --outfile=\"$int\"";
		}
		else {
			$command = "$hyphenate --infile=\"$int\" --outfile=\"$int\"";		}
		exec_com($command, $file);
	}

	# Check if the file contains characters that are wrongly
	# utf-8 encoded and decode them.
  ENCODING: {
	  if (! $no_decode) {
		  &read_char_tables;
		  # guess encoding and decode each paragraph at the time.
		  if( $multi_coding ) {
			  my $document = XML::Twig->new(twig_handlers => { p => sub { call_decode(@_); } });
			  if (! $document->safe_parsefile ("$int") ) {
				  print STDERR "Encoding: $int: ERROR parsing the XML-file failed.\n";
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
				  my $error = &decode_file($int, $coding, $int);
				  if ($error){ print STDERR $error; }
			  }

			  # Document title is generally wrongly encoded, check that separately.
			  # Not in use.
			  my $notitle = 1;
			  if (! $notitle) {
				PARSE_TITLE: {
					my $document = XML::Twig->new(twig_handlers => {title => sub { call_decode_title(@_); }}
												  );
					if (! $document->safe_parsefile ("$int")) {
						print STDERR "Title: $int: ERROR parsing the XML-file failed.\n";
						last PARSE_TITLE;
					}
					open (FH, ">$int") or print STDERR "$file: ERROR cannot open file $!";
					$document->set_pretty_print('record');
					$document->print( \*FH);

				} # PARSE_TITLE
			  }
		  }
	  }
  } # ENCODING
	if(! $upload) {
		my $cnt = chown -1, $gt_gid, $int;
		if ($cnt == 0) { print STDERR "$file: ERROR: chgrp failed for $int.\n"};
		chmod 0660, $int;
	}

	if (! $noxsl) {
		# Execute the file specific .xsl-script.
		# Copy it from template, if not exist.
		my $xsl_file = $orig . ".xsl";
		my $xsl_vfile = $orig . ".xsl,v";
		if(! -f $xsl_file && ! -f $xsl_vfile ) {
			copy ($xsltemplate, $xsl_file) 
				or print STDERR "ERROR: copy failed ($xsltemplate $xsl_file)\n";

			my $cnt = chown -1, $orig_gid, $xsl_file;
			if ($cnt == 0) { print STDERR "$file: ERROR: chgrp failed for $xsl_file.\n"};

			$command = "ci -t-\"file specific xsl-script, created in convert2xml.pl\" -q -i \"$xsl_file\"";
			exec_com($command, $file);
		}

		$command = "co -q $xsl_file";
		exec_com($command, $file);

		my $tmp = $tmpdir . "/" . $file . ".tmp";
		$command = "xsltproc --novalid \"$xsl_file\" \"$int\" > \"$tmp\"";
		exec_com($command, $file);

		# Validate the xml-file unless web upload.
		if(! $upload) {
			$command = "xmllint --valid --encode UTF-8 --noout \"$tmp\"";
			exec_com($command, $file);
		}
		copy ($tmp, $int) 
			or print STDERR "ERROR: copy failed ($tmp $int)\n";

		# Remove temporary file unless testing.
		if (! $test) {
			$command = "rm -rf \"$tmp\"";
			exec_com($command, $file);
		}

		if ( -f $xsl_vfile) {
			$command = "rm -rf \"$xsl_file\" ";
			exec_com($command, $file);
		}
		else {
			$command = "ci -t-\"xsl-script commit by convert2xml.pl\" -q \"$xsl_file\" \"$xsl_vfile\" ";
			exec_com($command, $file);
		}
	}

	if (! $upload) {
		my $lmdir = $bindir . "/LM";
		my $command = "$text_cat -x -d $lmdir $int";
		exec_com($command, $file);
	}

	if (! $upload) {
	  COPYFREE: {
		  # Copy file with free license to gtfree.
		  my $document = XML::Twig->new;
		  if (! $document->safe_parsefile("$int")) {
			  print STDERR "Copyfree: $int: ERROR parsing the XML-file failed: $@\n";		  
			  last COPYFREE;
		  }
		  
		  my $license = "free";
		  my $root = $document->root;
		  my $header = $root->first_child('header');
		  my $avail = $header->first_child('availability');
		  $license = $avail->first_child->local_name;
		  
		  if ( $license =~ /free/ ) {
			  if(-f $intfree && ! -w $intfree) {
				  print STDERR "$file: ERROR permission denied $intfree.\n";
				  last COPYFREE;
			  }
			  copy ($int, $intfree) 
				  or print STDERR "ERROR: copy failed ($int $intfree)\n";

			  my $cnt = chown -1, $gt_gid, $intfree;
			  if ($cnt == 0) { print STDERR "$file: ERROR: chgrp failed for $intfree.\n"};

			  chmod 0664, $intfree;
			  
		  }
		  else {
			  $command = "rm -rf \"$intfree\"";
			  exec_com($command, $file);
		  }
		  $document->purge;
	  } # COPYFREE
	}

	# Print log message in case of fatal ERROR
	if (! $nolog) {
		open FH, $log_file;
		while (<FH>) {
			if ($_ =~ /ERROR/ && $_ =~ /$file/ && $_ !~ /tidy/ && $_ !~ /chgrp/ ) {
				print "See file $log_file: $_\n" 
				}
		}
	}
}

sub exec_com {
	my ($com, $file) = @_;

	if ($test) {
		print STDERR "$com\n";
	}
	system($com) == 0 
			or print STDERR "$file: ERROR errors in $com. \n";
}


# Decode false utf8-encoding for text paragraph.
sub call_decode {
	my ( $twig, $para ) = @_;

	my $text = $para->text;
	&decode_para($language, \$text);
	$para->set_text($text);
}

# Decode false utf8-encoding for titles.
# Not in use.
sub call_decode_title {
	my ( $twig, $title ) = @_;

	my $text = $title->text;
	&decode_title($language, \$text);
	$title->set_text($text);
}

sub pdfclean {

		my $file = shift @_;
		
		if (! open (INFH, "$file")) {
			print STDERR "$file: ERROR open failed: $!. ";
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




