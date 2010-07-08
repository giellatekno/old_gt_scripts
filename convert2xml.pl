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
use utf8;
use File::Basename;
use File::Copy;
use File::Find;
use File::Path;
use File::Spec;
use File::stat;
use IO::File;
use Getopt::Long;
use Cwd;
use XML::Twig;
use samiChar::Decode;
use langTools::Corpus;
use Carp qw(cluck carp);
use Encode;

sub test_setup {
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

test_setup();

my $no_decode = 0;
my $nolog = 0; 
my $convxsl = '';
my $dir = '';
my $tmpdir = ''; 
my $no_hyph = 0; 
my $all_hyph = 0; 
my $noxsl = 0;
my $corpdir;
my $bindir = "$ENV{'GTHOME'}/gt/script";
my $textcatdir = "$ENV{'GTHOME'}/tools/lang-guesser";
#my $bindir = "/home/saara/gt/script";
my $gtbound_dir = "converted";
my $orig_dir = "orig";
my $goldstandard_orig_dir = "goldstandard" ;
my $gt_gid = 50782; # group: bound
my $orig_gid = 50779; #group: corpus

my $commonxsl   = $bindir . "/common.xsl";
my $preprocxsl  = $bindir . "/preprocxsl.xsl";
my $docxsl      = $bindir . "/docbook2corpus2.xsl";
my $htmlxsl     = $bindir . "/xhtml2corpus.xsl";
my $svgxsl      = $bindir . "/svg2xml.xsl";
my $xsltemplate = $bindir . "/XSL-template.xsl";

my $log_file;
my $language;
my $multi_coding=0;
my $upload=0;
my $test=0; #preserves temporary files and prints extra info.
my $readlink;

if (-f "/bin/readlink") {
	$readlink = "/bin/readlink";
} else {
	$readlink = "/opt/local/bin/greadlink";
}
# set the permissions for created files: -rw-rw-r--
#umask 0112;

# Some securing operations, add these to upload.cgi!
$ENV{'PATH'} = '/opt/local/bin:/bin:/usr/bin:/usr/local/bin';
delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};

my $xsltproc="/usr/bin/xsltproc";

my $help;

GetOptions ("no-decode" => \$no_decode,
			"xsl=s" => \$convxsl,
			"noxsl" => \$noxsl,
			"tmpdir=s" => \$tmpdir,
			"corpdir=s" => \$corpdir,
			"nolog" => \$nolog,
			"lang=s" => \$language,
			"no-hyph" => \$no_hyph,
			"all-hyph" => \$all_hyph,
			"multi-coding" => \$multi_coding,
			"upload" => \$upload,
			"test" => \$test,
			"help" => \$help);

if ($help) {
	&print_help;
	exit 1;
}

my %languages = (sme => 1,
				 smj => 1,
				 sma => 1,
				 nno => 1,
				 nob => 1,
				 fin => 1,
				 fkv => 1,
				 swe => 1,
				 eng => 1,
				 dan => 1,
				 kal => 1,
				 oth => 1
				 );
# todo: This should create an error message.
if (! $language || ! $languages{$language}) { $language = "sme"; }

my $tidy = "tidy -config $bindir/tidy-config.txt -utf8 -quiet -asxml -language $language";
my $hyphenate = $bindir . "/add-hyph-tags.pl";
my $text_cat = $textcatdir . "/text_cat.pl";
my $convert_eol = $bindir . "/convert_eol.pl";
my $paratext2xml = $bindir . "/paratext2xml.pl";
my $jpedal = $bindir . "/corpus_call_jpedal.sh";
my $pdf2xml = $bindir . "/pdf2xml.pl";
my $bible2xml = $bindir . "/bible2xml.pl";

# We would like to compute where the corpus directory
# is automatically given the filename, because this is the
# most common usage. If the file is outside of the corpus
# tree, the user has to manually set the corpdir option
my $arg_to_process = Encode::decode_utf8($ARGV[$#ARGV]);
my $completepath = qx{ $readlink -f \"$arg_to_process\" };

if ($completepath =~ m/orig/) {
	my @pathparts = split(/orig/, $completepath);
	$corpdir = $pathparts[0];
}

if (! $corpdir || ! -d $corpdir) {
	print "Error: It seems that the file you are trying to\n";
	print "convert is not in a corpus directory. Please move\n";
	print "the file inside a corpus directory.\n\n";
	&print_help;
	exit 1;
}

# A log file is created for each file, it contains the executed commands
# and redirected STDERR of these commands.
if(! $tmpdir) {
	$tmpdir = $corpdir . "/tmp";
	if(! -d $tmpdir) {
		mkdir($tmpdir, 0770) || 
		die "Could not make the directory $tmpdir: $!\n";
	}
}

my $command;
# Redirect STDERR to log files.	
if (! $nolog) {
	my $time = `date +%m-%d-%H-%M`;
	chomp $time;
	$log_file = $tmpdir . "/" . $time . ".log";
	open STDERR, '>', "$log_file" or die "Can't redirect STDERR: $!";
}

# Search the files in the directory $dir and process each one of them.
if (-d $arg_to_process) {
	find (\&process_file, $arg_to_process)
} elsif (-f $arg_to_process) {
	my $error =  process_file ($arg_to_process) if $ARGV[$#ARGV];
	if ($error) { print_log($log_file, $arg_to_process); }
} else {
	print "ERROR: $arg_to_process doesn't exist\n";
	return "ERROR";
}

close STDERR;

sub process_file {
    my $file = $_;
    $file = shift (@_) if (!$file);

	my $no_decode_this_time = 0;
	print STDERR "$file\n";

	# Check the filename
	return unless ($file =~ m/\.(doc|pdf|html|ptx|txt|svg|bible\.xml|correct\.xml|correct\.xml,v)$/);
	if ( $file =~ m/[\;\<\>\*\|\`\&\$\(\)\[\]\{\}\'\"\?]/ ) {
		print STDERR "$file: ERROR. Filename contains special characters that cannot be handled. STOP\n";
		return "ERROR";
	}
	print "Considering conversion of " . decode_utf8($file) . "\n";


	# correct.xml is not converted.
	if ($file =~ /(correct\.xml|correct\.xml,v)/) { $noxsl=1; }

	# Search with find gives some unwanted files which are ignored
    return if ($file =~ /[\~]$/);
    return if (__FILE__ =~ /$file/);
	return if (-z $file);

	# The name and location of the resulting xml-file.
    my $orig = decode_utf8(cwd()) . "/" . $file;
    (my $int = $orig) =~ s/$orig_dir/$gtbound_dir/;
	$int =~ s/\.(doc|pdf|html|ptx|txt|svg)$/\.\L$1\.xml/i;
	(my $doc_id = $orig) =~ s/$corpdir\/$orig_dir\///;

	# Really small (text)files are not processed.
	# Small amount of data leads to problems in guessing the character coding.
	if (-f $file && -s $file < 200) {
		carp "$file: ERROR. File is too small for processing. STOP\n";
		return "ERROR";
	}

	# Take the basename of the file.
	$file =~ s/.*[\/\\](.*)/$1/;

	# Create the directory to gtbound if it does not exist.
	( my $dir =  $int )  =~ s/(.*)[\/\\].*/$1/;
	if (! -d $dir ) {
		mkpath($dir, 0770) ||
		die "Couldn't make $dir\n";
	}		

	# Check that the xml-file is available for writing.
	if(-f $int && ! -w $int) {
		print "$file: ERROR: permission denied to $int. STOP.\n";
		carp "$file: ERROR: permission denied to $int. STOP.\n";
		return "ERROR";
	}

	# convert the file if one of these conditions are met:
	# 1. if the xsl file doesn't exist
	# 2. if the converted file is older than the xsl file
	# 3. if the converted file doesn't exist

	my $do_convert = 0;

	my $xsl_file = $orig . ".xsl";
	if(! $noxsl) {
		# Copy it from template, if not exist.
		if(! -f $xsl_file) {
			copy ($xsltemplate, $xsl_file) 
				or print STDERR "ERROR: copy failed ($xsltemplate $xsl_file)\n";
			
			my $cnt = chown -1, $orig_gid, $xsl_file;
			if ($cnt == 0) { print STDERR "$file: ERROR: chgrp failed for $xsl_file.\n"};
			$do_convert = 1;
		}
	}

	if (-f $int) {
		my $xsl_time = stat($xsl_file)->mtime;
		my $int_time = stat($int)->mtime;
		if ($xsl_time > $int_time) {
			$do_convert = 1;
		}
	} else {
		$do_convert = 1;
	}

	if ($do_convert) {
		print "Converting " . decode_utf8($file) . "\n";

		# remove temporary files to get a clean start.
		remove_tmp_files($tmpdir, $file);

		##### Start conversion ############
		my $error;
		my $tmp0 = $tmpdir . "/" . $file . ".tmp0";

		# Process the file-specific xsl file to import the common.xsl file from $GTHOME:
		my $tmp = $xsl_file . ".tmp";
		$command = "xsltproc --novalid --stringparam commonxsl \"$commonxsl\" \"$preprocxsl\" \"$xsl_file\" > \"$tmp\"";
		exec_com($command, $file);
		$xsl_file = $tmp ;

		# Word documents
		if ($file =~ /\.doc$/) {
			$error = convert_doc($file, $orig, $tmp0);
		}

		# xhtml documents
		elsif ($file =~ /\.html$/) {
			$error = convert_html($file, $orig, $tmp0, $xsl_file);
		}

		# pdf documents
		elsif ($file =~ /\.pdf$/) {
			$error = convert_pdf($file, $orig, $tmp0, $xsl_file);
		}

		# paratext documents
		elsif ($file =~ /\.ptx$/) {
			$command = "$paratext2xml \"$orig\" --out=\"$tmp0\"";
			$error = exec_com($command, $file);
		}

		# bibles
		elsif ($file =~ /\.bible\.xml$/) {
			$command = "$bible2xml --out=\"$tmp0\" \"$orig\"";
			$error = exec_com($command, $file);
		}

		# Conversion of text documents
		elsif ($file =~ /\.txt$/) {
			$error = convert_txt($file, $orig, $tmp0, \$no_decode_this_time);
		}

		# Conversion of svg documents
		elsif ($file =~ /\.svg$/) {
			convert_svg($file, $orig, $tmp0, $xsl_file);
		}

		# Conversion of documents with error markup
		# Conversion of documents with manual error markup
		elsif ($file =~ /(\.correct\.xml|correct\.xml,v)$/) {
			# check out the file-specific xsl-file for processing
			my $corr_vfile = $orig . ",v";
			my $cnt = chown -1, $orig_gid, $file;
			print "$corr_vfile\n";
			if (! -f $corr_vfile) {
				$command = "ci -t-\"added under version control by convert2xml.pl\" -q -i \"$orig\"";
				exec_com($command, $file);
				my $cnt = chown -1, $orig_gid, $corr_vfile;
				if ($cnt == 0) { print STDERR "ERROR: chgrp failed for $orig.\n"};
			}

			# Check out the corr-file for editing.
			$command = "co -f -q \"$orig\"";
			if( exec_com($command, $file) != 0 ) {
				carp "ERROR cannot checkout file: $corr_vfile STOP";
				return "ERROR";
			}

			$int =~ s/\.correct//;
			my $tmp1 = $tmpdir . "/" . $file . ".tmp1";
			# Do extra formatting for prooftest-directory.
			my $document = XML::Twig->new(twig_handlers => { p => sub { add_error_markup(@_); } });
			if (! $document->safe_parsefile ("$orig") ) {
				carp "ERROR parsing the XML-file $orig failed. STOP\n";
				return "ERROR";
			}
			if (! open (FH, ">$tmp1")) {
				carp "ERROR cannot open file STOP";
				return "ERROR";
			}
			$document->set_pretty_print('indented');
			$document->print( \*FH);
			exec_com("cp \"$tmp1\" \"$tmp0\"", $file);

			print_log($log_file, $file);

		}
		else { $error = 1; }

		# If there were errors in the conversion, remove
		# the xml-file and proceed to the next file.
		if ($error || ! -f $tmp0 || -z $tmp0 ) {
			print "ERROR: First conversion step from original failed. STOP.\n";
			if ($log_file) { print "See $log_file for details.\n"; }
			if (! $upload) {
				carp "ERROR: First conversion step from original failed. STOP.\n";
			}
			if (! $test) { remove_tmp_files($tmpdir, $file); }
			return "ERROR";
		}
		elsif ($file =~ /(\.correct\.xml|correct\.xml,v)$/) {
			copy ($tmp0, $int);
			return 0;
		}

		# end of line conversion.
		my $tmp1 = $tmpdir . "/" . $file . ".tmp1";
		my $command = "$convert_eol \"$tmp0\" > \"$tmp1\"";
		exec_com($command, $file);
		copy ($tmp1, $tmp0) ;

		$error = character_encoding($file, $tmp0, $no_decode_this_time);
		if ($error) {
			if (! $test) { remove_tmp_files($tmpdir, $file); }
			return "ERROR";
		}

		# Run the file specific xsl-script.
		if (! $noxsl) {
			$error = file_specific_xsl($file, $orig, $tmp0, $xsl_file, $doc_id);
			if ($error) {
				if (! $test) { remove_tmp_files($tmpdir, $file); }
				return "ERROR";
			}
		}

		# Do extra formatting for prooftest-directory.
		if ($orig =~ /$goldstandard_orig_dir/) {
			my $document = XML::Twig->new(twig_handlers => { p => sub { add_error_markup(@_); } });
			if (! $document->safe_parsefile ("$tmp0") ) {
				carp "ERROR parsing the XML-file $tmp0 failed. STOP\n";
				return "ERROR";
			}
			if (! open (FH, ">$tmp1")) {
				carp "ERROR cannot open file STOP";
				return "ERROR";
			}
			$document->set_pretty_print('indented');
			$document->print( \*FH);
			$command = "cp \"$tmp1\" \"$tmp0\" ";
			exec_com($command, $file);
		}

		# hyphenate the file
		if (! $no_hyph ) {
			if ($all_hyph) { $command = "$hyphenate --all --infile=\"$tmp0\" --outfile=\"$tmp1\""; }
			else { $command = "$hyphenate --infile=\"$tmp0\" --outfile=\"$tmp1\"";}
			exec_com($command, $file);
			copy ($tmp1, $tmp0) ;
		}

		# Text categorization
		if (! $upload) {
			my $lmdir = $textcatdir . "/LM";
			my $command = "$text_cat -q -x -d $lmdir \"$tmp0\"";
			exec_com($command, $file);
		}

	#	# Validate the xml-file unless web upload.
	#	if(! $upload && ($file !~ /.ptx$/)) {
	#		$command = "xmllint --valid --encode UTF-8 --noout \"$int\"";
	#		if( exec_com($command, $file) != 0 ) {
	#			carp "ERROR: not valid xml. STOP.\n";
	#			return "ERROR";
	#		}
	#	}

		# If gone this far, copy the temporary file to the correct directory.
		exec_com("cp $tmp0 $int", $file);

		# chmod and chgrp the new xml-file.
		if(! $upload) {
			chmod 0660, $int;
		}

		# Remove temporary files unless testing.
		if (! $test) {
			remove_tmp_files($tmpdir, $file);
			# Also remove the temporary, file-specific xsl file:
        	$command = "rm -rf $xsl_file";
        	exec_com($command, $file);
		}

		print_log($log_file, $file);
		}
	return 0;
}

sub print_log {
	my ($log_file, $file) = @_;

# Print log message to STDOUT in case of fatal ERROR
	if (! $nolog) {
		open FH, $log_file;
		while (<FH>) {
			if ($_ =~ /ERROR/ && $_ =~ /$file/ && $_ !~ /tidy/ && $_ !~ /chgrp/ ) {
				print "See file $log_file: $_\n" 
				}
		}
	}
}


sub convert_doc {
	my ($file, $orig, $int) = @_;

	my $tmp3 = $tmpdir . "/" . $file . ".tmp3";

	my $xsl;
	if ($convxsl) { $xsl = $convxsl; }
	else { $xsl = $docxsl; }
	$command = "antiword -s -x db \"$orig\" > \"$tmp3\"";
	exec_com($command, $file);
	$command = "xsltproc \"$xsl\" \"$tmp3\" > \"$int\"";
	exec_com($command, $file);

	$command = "perl -pi -e \"s/\x{00B6}/<\\/p><p>/g\" \"$int\"";
	exec_com($command, $file);

	return 0;
}

sub convert_svg {
	my ($file, $orig, $int, $xsl_file) = @_;

	print STDERR "convert_svg $file, $orig\n";

	my $tmp0 = $tmpdir . "/" . $file . ".tmp0";
	my $tmp3 = $tmpdir . "/" . $file . ".tmp3";

	$command = "xsltproc \"$svgxsl\" \"$orig\" > \"$int\"";
	exec_com($command, $file);

	return 0;
}

sub convert_pdf {
	my ($file, $orig, $int, $xsl_file) = @_;
	
	my $main_sizes;
	my $title_sizes;
	my $title_styles;
	my $main_font_elt;
	my $col_num=1;
	my $lower;
	my $excluded;
	if(! $noxsl) {
		my $document = XML::Twig->new;
		if (! $document->safe_parsefile("$xsl_file")) {
			carp "ERROR parsing the XSL-file failed: $@\n";		  
			return "ERROR";
		}
		
		my $root = $document->root;
		
		$main_font_elt = $root->first_child('xsl:variable[@name="main_sizes"]');
		if ($main_font_elt) { $main_sizes = $main_font_elt->{'att'}{'select'}; }
		
		my $title_font_elt = $root->first_child('xsl:variable[@name="title_sizes"]');
		if ($title_font_elt) { $title_sizes = $title_font_elt->{'att'}{'select'}; }
		
		my $title_styles_elt = $root->first_child('xsl:variable[@name="title_styles"]');
		if ($title_styles_elt) { $title_styles = $title_styles_elt->{'att'}{'select'}; }

		my $column_elt = $root->first_child('xsl:variable[@name="columns"]');
		if ($column_elt) { $col_num = $column_elt->{'att'}{'select'}; }

		my $lower_elt = $root->first_child('xsl:variable[@name="lower"]');
		if ($lower_elt) { $lower = $lower_elt->{'att'}{'select'}; $lower =~ s/\'//g;}

		my $excluded_elt = $root->first_child('xsl:variable[@name="excluded"]');
		if ($excluded_elt) { $excluded = $excluded_elt->{'att'}{'select'}; $excluded =~ s/\'//g; }

	}
# 	if ($main_font_elt) {
# 		
# 		my $arguments="";
# 		(my $base = $file ) =~ s/\.pdf//;
# 
# 		$command = "rm -rf $tmpdir/$base/*";
# 		exec_com($command, $file);
# 		
# 		if ($col_num eq "'2'") { $arguments .= "-Dcol"; }
# 		if ($lower) { $arguments .= " -Dlower=$lower"; }
# 		if ($excluded) { $arguments .= " -Dexcl=$excluded"; }
# 		else { $arguments .=" -Dexcl=\"0\""; }
# 
# 		$command = "$jpedal $orig $tmpdir $arguments";
# 		my $error = exec_com($command, $file);
# 
# 		if ($error) { carp "$error"; return "ERROR"; }
# 
# 		$command="find \"$tmpdir/$base\" -type f | xargs perl -pi -e \"s/\\&/\\&amp\\;/g\"";
# 		exec_com($command, $file);
# 		
# 		$command = "$pdf2xml --dir=\"$tmpdir/$base/\" --outfile=\"$int\" --main_sizes=\"$main_sizes\" --title_sizes=\"$title_sizes\" --title_styles=\"$title_styles\"";
# 		exec_com($command, $file);
# 
# 
# 		#exit;
# 		if( -z $int && ! $upload ) {
# 			print "ERROR $file: no pdf2xml output. STOP.\n";
# 			return "ERROR";
# 		}
# 		return 0;
# 	}
	
	my $xsl;
	if ($convxsl) { $xsl = $convxsl; }
	else { $xsl = $htmlxsl; }
	my $html = $tmpdir . "/" . $file . ".tmp3";
	$command = "pdftotext -enc UTF-8 -nopgbrk -htmlmeta -eol unix \"$orig\" \"$html\"";
	exec_com($command, $file);
	
	# If there were severe errors in pdftotext, the html file is not created.
	if(! -f $html && ! $upload ) {
		print "$file: no pdftotext output. STOP.\n";
		return "ERROR";			
	}
	#&pdfclean($html);
	$command = "$tidy \"$html\" | xsltproc \"$xsl\" -  > \"$int\"";
	exec_com($command, $file);

	# remove temporary files unless testing.
	if (! $test) {
		$command = "rm -rf \"$html\"";
		exec_com($command, $file);
	}
	return 0;
}

sub convert_txt {
	my ($file, $orig, $int, $no_decode_this_time_ref) = @_;	

	copy($orig,$int);

	my $tmp4 = $tmpdir . "/" . $file . ".tmp4";
  ENCODING:
	if (! $no_decode && ! $$no_decode_this_time_ref ) {

		my $coding = &guess_text_encoding($int, $tmp4, $language);

		if ($coding eq 0) { 
			if ($test) { print STDERR "Correct character encoding.\n"; }
		}
		elsif( $coding eq -1 ) {
			carp "ERROR Was not able to determine character encoding. STOP.\n";
			return "ERROR";
		}
		else { 
			copy($int, $tmp4);
			if ($test) { print STDERR "Character decoding: $coding\n"; }
			my $error = &decode_text_file($tmp4, $coding, $int);
			if ($error eq -1){ return "ERROR"; }
			$$no_decode_this_time_ref=1;
		}
	}

	#return;
	# Simple html-tags are added in subroutine txtclean
	# and then converted to confront the corpus structure
	
	txtclean($int, $tmp4, $language);
	copy($tmp4,$int);

	return 0;
}

sub convert_html {
	my ($file, $orig, $int, $xsl_file) = @_;

	my $coding;
	if(! $noxsl) {
		my $document = XML::Twig->new;
		if (! $document->safe_parsefile("$xsl_file")) {
			carp "ERROR parsing the XSL-file failed: $@\n";		  
			return "ERROR";
		}
		
		my $root = $document->root;
		
		my $coding_elt = $root->first_child('xsl:variable[@name="text_encoding"]');
		if ($coding_elt) { $coding = $coding_elt->{'att'}{'select'}; }
	}

	my $tmp3 = $tmpdir . "/" . $file . ".tmp3";
	my $tmp4 = $tmpdir . "/" . $file . ".tmp4";

	if (! $no_decode) {
		if (! $coding) { $coding = &guess_text_encoding($orig, $tmp3, $language); }
		my $error = &decode_text_file($orig, $coding, $tmp4);
		if ($error eq -1){ return "ERROR"; }
	}
	if (! -f $tmp4) { copy($orig,$tmp4); }
	my $xsl;
	if ($convxsl) { $xsl = $convxsl; }
	else { $xsl = $htmlxsl; }
	$command = "$tidy \"$tmp4\" > \"$tmp3\"";
	exec_com($command, $file);

	$command = "/usr/bin/xsltproc \"$xsl\" \"$tmp3\" > \"$int\"";
	exec_com($command, $file);

	return 0;
}



# File specific xsl-script
sub file_specific_xsl {
	my ($file, $orig, $int, $xsl_file, $doc_id) = @_;

	# Execute the file specific .xsl-script.
	my $tmp = $tmpdir . "/" . $file . ".tmp";
	$command = "xsltproc --novalid --stringparam document_id \"$doc_id\" \"$xsl_file\" \"$int\" > \"$tmp\"";
	exec_com($command, $file);
	
	# Check the main language,  add if it is missing.
	my $document = XML::Twig->new;
	if (! $document->safe_parsefile("$tmp")) {
		carp "ERROR parsing the XML-file failed ";		  
		return "ERROR";
	}	
	my $root = $document->root;
	my $mainlang = $root->{'att'}->{'xml:lang'};
	my $id = $root->{'att'}->{'id'};

	if(! $mainlang || $mainlang eq "unknown") { 
# 		print "setting language: $language \n";
		$root->set_att('xml:lang', $language); 
	}
	open (FH, ">$int") or die "Cannot open $int $!";
	$document->set_pretty_print('indented');
	$document->print( \*FH);

	# Validate the xml-file unless web upload.
	if(! $upload && ($file !~ /.ptx$/)) {
		$command = "xmllint --valid --encode UTF-8 --noout \"$int\"";
		if( exec_com($command, $file) != 0 ) {
			carp "ERROR: not valid xml. STOP.\n";
			return "ERROR";
		}
	}
	return 0;
}


# Subroutine to execute system commands and handle return values.
sub exec_com {
	my ($com, $file) = @_;

	if ($test) {
		print STDERR "$com\n";
	}
	if ( system($com) != 0) { 
		print STDERR "$file: ERROR errors in $com: $!\n";
		return $?;
	}
	else { return 0; }
}

sub remove_tmp_files {
	my ($tmpdir, $file) = @_;

	my $tmpfiles = $tmpdir . "/" . $file . ".tmp*";
	$command = "rm -rf $tmpfiles";
	exec_com($command, $file);

	return 0;
}

sub character_encoding {
	my ($file, $int, $no_decode_this_time) = @_;

	# Check if the file contains characters that are wrongly
	# utf-8 encoded and decode them.

	if (! $no_decode ) {
		&read_char_tables;
		# guess encoding and decode each paragraph at the time.
		if( $multi_coding ) {
			my $document = XML::Twig->new(twig_handlers => { p => sub { call_decode_para(@_); } });
			if (! $document->safe_parsefile ("$int") ) {
				carp "ERROR parsing the XML-file failed. STOP\n";
				return "ERROR";
			}
			if (! open (FH, ">$int")) {
				carp "ERROR cannot open file STOP";
				return "ERROR";
			} 
			$document->set_pretty_print('indented');
			$document->print( \*FH);
		} else {
			# assume same encoding for the whole file.
			my $coding = &guess_encoding($int, $language, 0);
			if ($coding eq -1) { 
				carp "ERROR Was not able to determine character encoding. STOP.";
				return "ERROR";
			}
			elsif ($coding eq 0) { 
				if($test) { print STDERR "Correct character encoding.\n"; }
				if($file =~ /\.doc$/) {
					# Document title in msword documents is generally wrongly encoded, 
					# check that separately.
					my $d=XML::Twig->new(twig_handlers=>{
						'p[@type="title"]'=> sub{call_decode_title(@_, $coding); },
						'title'=>sub{call_decode_title(@_);}
					}
										 );
					if (! $d->safe_parsefile ("$int") ) {
						carp "ERROR parsing the XML-file failed.\n";
						return "ERROR";
					}
					if (! open (FH, ">$int")) {
						carp "ERROR cannot open file";
						return "ERROR";
					}
					$d->set_pretty_print('indented');
					$d->print( \*FH);
				}
				return 0;
			}
			# Continue decoding the file.
			if ($no_decode_this_time && $coding eq "latin6") { return 0; }
			if($test) { print STDERR "Character decoding: $coding\n"; }
			my $d=XML::Twig->new(twig_handlers=>{'p'=>sub{call_decode_para(@_, $coding);},
												 'title'=>sub{call_decode_para(@_, $coding);}
											 }
								 );
			if (! $d->safe_parsefile ("$int") ) {
				carp "ERROR parsing the XML-file failed.\n";
				return "ERROR";
			}
			if (! open (FH, ">$int")) {
				carp "ERROR cannot open file";
				return "ERROR";
			}
			$d->set_pretty_print('indented');
			$d->print( \*FH);
		}
	}
	return 0;
} 

# Decode false utf8-encoding for text paragraph.
sub call_decode_para {
	my ( $twig, $para, $coding) = @_;

	my $text = $para->text;
	my $error = &decode_para($language, \$text, $coding);

	$para->set_text($text);
	
	return 0;
}

# Decode false utf8-encoding for titles.
sub call_decode_title {
	my ( $twig, $title, $coding ) = @_;

	my $text = $title->text;

	if(!$coding) {
		my $error = &decode_para($language, \$text);
	}

	my $error = &decode_title($language, \$text, $coding);

	$title->set_text($text);

	return 0;
}


sub print_help {
	print"Usage: convert2xml.pl [OPTIONS] [FILES]\n";
	print "The available options:\n";
	print"    --xsl=<file>    The xsl-file which is used in the conversion.\n";
    print"                    If not specified, the default values are used.\n";
    print"    --tmpdir=<dir>  The directory where the log and other temporary files are stored.\n";
    print"    --nolog         Print error messages to screen, not to log files.\n";
    print"    --corpdir=<dir> The corpus directory. This is where\n";
    print"    the corpus is checked out	.\n";
    print"    --no-decode     Do not decode the characters.\n";
    print"    --noxsl         Do not use file-specific xsl-template.\n";
    print"    --no-hyph       Do not add hyphen tags.\n";
    print"    --all-hyph      Add hyphen tags everywhere (default is at the end of the lines).\n";
    print"    --multi-coding  Document contains more than one different encodings, character \n";
    print"                    decoding is done paragraph-wise.\n";
    print"    --upload        Do conversion in the upload-directory. \n";
    print"    --test          Don't delete temporary files, log more info.\n";
    print"    --help          Print this message and exit.\n";
};
