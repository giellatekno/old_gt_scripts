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
#use open ':utf8';
#binmode STDOUT, ":utf8";
#binmode STDERR, ":utf8";
use utf8;
use File::Find;
use File::Copy;
use IO::File;
use File::Basename;
use Getopt::Long;
use Cwd;
use XML::Twig;
use samiChar::Decode;

my $no_decode = 0;
my $nolog = 0; 
my $convxsl = '';
my $dir = '';
my $tmpdir = ''; 
#my $tmpdir = '/home/saara/tmp'; 
my $no_hyph = 0; 
my $all_hyph = 0; 
my $noxsl = 0;
my $corpdir = "/usr/local/share/corp";
my $bindir = "/usr/local/share/corp/bin";
#my $bindir = "/home/saara/gt/script";
my $gtbound_dir = "bound";
my $gtfree_dir = "free";
my $orig_dir = "orig";
my $gt_gid = 50782; # group: bound
my $orig_gid = 50779; #group: corpus

my $docxsl = $bindir . "/docbook2corpus2.xsl";
my $htmlxsl = $bindir . "/xhtml2corpus.xsl";
my $xsltemplate = $bindir . "/XSL-template.xsl";

my $log_file;
my $language;
my $multi_coding=0;
my $upload=0;
my $test=0; #preserves temporary files and prints extra info.

# set the permissions for created files: -rw-rw-r--
#umask 0112;

# Some securing operations, add these to upload.cgi!
$ENV{'PATH'} = '/bin:/usr/bin:/usr/local/bin';
delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};

my $xsltproc="/usr/bin/xsltproc";

my $help;

GetOptions ("no-decode" => \$no_decode,
			"xsl=s" => \$convxsl,
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

my $tidy = "tidy -config $bindir/tidy-config.txt -quiet -asxml -language $language";
my $hyphenate = $bindir . "/add-hyph-tags.pl";
my $text_cat = $bindir . "/text_cat";
my $convert_eol = $bindir . "/convert_eol.pl";
my $paratext2xml = $bindir . "/paratext2xml.pl";
my $jpedal = "/home/saara/gt/script/corpus_call_jpedal.sh";
my $pdf2xml = "perl /home/saara/gt/script/pdf2xml.pl";

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
	my $time = `date +%m-%d-%H-%M`;
	chomp $time;
	$log_file = $tmpdir . "/" . $time . ".log";
	open STDERR, '>', "$log_file" or die "Can't redirect STDERR: $!";
	if (! $upload) {
		my $cnt = chown -1, $orig_gid, $log_file;	
		if ($cnt == 0) { print "ERROR: chgrp failed for $log_file.\n"};
		chmod 0770,$log_file;
	}
}

# Search the files in the directory $dir and process each one of them.
if ($dir) {
	if (-d $dir) { find (\&process_file, $dir) }
	else { print "$dir ERROR: Directory did not exit.\n"; }
}

# Process the file given in command line.
process_file ($ARGV[$#ARGV]) if -f $ARGV[$#ARGV];

close STDERR;

sub process_file {
    my $file = $_;
    $file = shift (@_) if (!$file);

	my $no_decode_this_time = 0;
	print STDERR "$file\n";

	return unless ($file =~ m/\.(doc|pdf|html|ptx|txt)$/);
	if ( $file =~ m/[\;\<\>\*\|\`\&\$\(\)\[\]\{\}\'\"\?]/ ) {
		print STDERR "$file: ERROR. Filename contains special characters that cannot be handled. STOP\n";
		return;
	}
	return if (! -f $file);

	# Search with find gives some unwanted files which are silently
	# returned here.
    return if ($file =~ /[\~]$/);
    return if (__FILE__ =~ /$file/);
	return if (-z $file);
	
    my $orig = File::Spec->rel2abs($file);
    (my $int = $orig) =~ s/$orig_dir/$gtbound_dir/;
	$int =~ s/\.(doc|pdf|html|ptx|txt)$/\.\L$1\.xml/i;
    (my $intfree = $int) =~ s/\/$gtbound_dir/\/$gtfree_dir/;

	# Really small (text)files are not processed.
	# Small amount of data leads to problems in guessing the character coding.
	# The rm-commands are temporary and removed after the conversion is rerun.
	if ( -s $file < 200) {
		print STDERR "$file: ERROR. File is too small for processing. STOP\n";
		if( -f $int) { 
			$command = "rm -rf \"$int\"";
			exec_com($command, $file);
		}
		if( -f $intfree) { 
			$command = "rm -rf \"$intfree\"";
			exec_com($command, $file);
		}
		return;
	}

	# Take only the file name without path.
	$file =~ s/.*[\/\\](.*)/$1/;

	# Create the directory to gtbound if it does not exist.
	( my $dir =  $int )  =~ s/(.*)[\/\\].*/$1/;
	if (! -d $dir ) {
		my $command="mkdir -p \"$dir\"";
		exec_com($command, $file);
		my $cnt = chown -1, $gt_gid, $dir;
#		if ($cnt == 0) { print STDERR "$file: ERROR: chgrp failed for $dir.\n"};
		chmod 0770,$dir;
	}		

	if(-f $int && ! -w $int) {
		print "$file: ERROR: permission denied to $int. STOP.\n";
		print STDERR "$file: ERROR: permission denied to $int. STOP.\n";
		return;
	}


	my $xsl_file = $orig . ".xsl";
	my $xsl_vfile = $orig . ".xsl,v";
	if(! $noxsl) {
		# Prepare the xsl-file for further processing
		# Copy it from template, if not exist.
		if(! -f $xsl_file && ! -f $xsl_vfile ) {
			copy ($xsltemplate, $xsl_file) 
				or print STDERR "ERROR: copy failed ($xsltemplate $xsl_file)\n";
			
			my $cnt = chown -1, $orig_gid, $xsl_file;
#			if ($cnt == 0) { print STDERR "$file: ERROR: chgrp failed for $xsl_file.\n"};
			
			$command = "ci -t-\"file specific xsl-script, created in convert2xml.pl\" -q -i \"$xsl_file\"";
			exec_com($command, $file);
		}
		
		$command = "co -f -q \"$xsl_file\"";
		exec_com($command, $file);
	}
	# remove temporary files to get a clean start.
	my $tmpfiles = $tmpdir . "/" . $file . ".tmp*";
	$command = "rm -rf $tmpfiles";
	exec_com($command, $file);

	my $tmp3 = $tmpdir . "/" . $file . ".tmp3";
	IO::File->new($int, O_RDWR|O_CREAT) 
		or die "Couldn't open $int for writing: $!\n";

	# Conversion of word documents
	if ($file =~ /\.doc$/) {
		my $xsl;
		if ($convxsl) { $xsl = $convxsl; }
		else { $xsl = $docxsl; }
		$command = "/usr/local/bin/antiword -s -x db \"$orig\" > \"$tmp3\"";
		exec_com($command, $file);
		$command = "/usr/bin/xsltproc \"$xsl\" \"$tmp3\" > \"$int\"";
		exec_com($command, $file);
	}

	# Conversion of xhtml documents
	if ($file =~ /\.html$/) {
		my $xsl;
		if ($convxsl) { $xsl = $convxsl; }
		else { $xsl = $htmlxsl; }
		$command = "$tidy \"$orig\" > \"$tmp3\" 2>/dev/null";
		exec_com($command, $file);

		$command = "/usr/bin/xsltproc \"$xsl\" \"$tmp3\" > \"$int\"";
		exec_com($command, $file);

	}
	
	# Conversion of pdf documents	
	if ($file =~ /\.pdf$/) {
	  PDF: {
		  my $main_sizes;
		  my $title_sizes;
		  my $title_styles;
		  my $main_font_elt;
		  if(! $noxsl) {
			  my $document = XML::Twig->new;
			  if (! $document->safe_parsefile("$xsl_file")) {
				  print STDERR "Copyfree: $xsl_file: ERROR parsing the XML-file failed: $@\n";		  
				  last PDF;
			  }
			  
			  my $root = $document->root;
			  
			  $main_font_elt = $root->first_child('xsl:variable[@name="main_sizes"]');
			  if ($main_font_elt) { $main_sizes = $main_font_elt->{'att'}{'select'}; }
			  
			  my $title_font_elt = $root->first_child('xsl:variable[@name="title_sizes"]');
			  if ($title_font_elt) { $title_sizes = $title_font_elt->{'att'}{'select'}; }
			  
			  my $title_styles_elt = $root->first_child('xsl:variable[@name="title_styles"]');
			  if ($title_styles_elt) { $title_styles = $title_styles_elt->{'att'}{'select'}; }
		  }
		  if ($main_font_elt) {
			  
			  $command = "$jpedal $orig $tmpdir  1>/dev/null";
			  exec_com($command, $file);
			  
			  (my $base = $file ) =~ s/\.pdf//;
			  $command="find \"$tmpdir/$base\" -type f | xargs perl -pi -e \"s/\\&/\\&amp\\;/g\"";
			  exec_com($command, $file);
			  
			  $command = "$pdf2xml --dir=\"$tmpdir/$base/\" --outfile=\"$int\" --main_sizes=\"$main_sizes\" --title_sizes=\"$title_sizes\" --title_styles=\"$title_styles\"";
			  exec_com($command, $file);
			  
			  if( -z $int && ! $upload ) {
				  print "$file: no pdf2xml output. STOP.\n";
				  return;
			  }
			  last PDF;
		  }

		  my $xsl;
		  if ($convxsl) { $xsl = $convxsl; }
		  else { $xsl = $htmlxsl; }
		  my $html = $tmpdir . "/" . $file . ".tmp3";
		  $command = "pdftotext -enc UTF-8 -nopgbrk -htmlmeta -eol unix \"$orig\" \"$html\"";
		  exec_com($command, $file);
		  
		  # If there were severe errors in pdftotext, the html file is not created.
		  if(! -f $html && ! $upload ) {
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
	  } # end of PDF
	}

	# Conversion of paratext documents
	if ($file =~ /\.ptx$/) {
		$command = "$paratext2xml \"$orig\" --out=\"$int\"";
		exec_com($command, $file);
	}

	# Conversion of text documents
	# Simple html-tags are added in subroutine txtclean
	# and then converted to confront the corpus structure
	if ($file =~ /\.txt$/) {
		copy($orig,$int);
		my $tmp4 = $tmpdir . "/" . $file . ".tmp4";
	  ENCODING:
		if (! $no_decode && ! $no_decode_this_time ) {
			my $coding = &guess_text_encoding($int, $tmp4, $language);
			if ($coding eq 0) { 
				if ($test) { print STDERR "Correct character encoding.\n"; }
			}
			elsif( $coding eq -1 ) {
				print STDERR "Was not able to determine character encoding. STOP.\n";
				exec_com("rm -rf \"$int\"", $file);
				return;
			}
			else { 
				copy($int, $tmp4);
				if ($test) { print STDERR "Character decoding: $coding\n"; }
				my $error = &decode_text_file($tmp4, $coding, $int);
				if ($error){ print STDERR $error; }
				$no_decode_this_time=0;
			}
		}
		txtclean($int, $tmp4, $language);
		copy($tmp4,$int);
		if (! $test) { exec_com("rm -rf \"$tmp4\"", $file); }
	}

	if (! -f $int || -z $int ) {
		print "$file: ERROR: First conversion step from original failed. \n$int is empty. STOP.\nSee $log_file for details.\n";
		if (! $upload) {
			print STDERR "$file: ERROR: First conversion step from original failed. \n$int is empty. STOP.\n";
		}
		return;
	}

	# end of line conversion.
	my $tmp1 = $tmpdir . "/" . $file . ".tmp1";
	my $command = "$convert_eol \"$int\" > \"$tmp1\"";
	exec_com($command, $file);
	copy ($tmp1, $int) ;

	# Check if the file contains characters that are wrongly
	# utf-8 encoded and decode them.
  ENCODING: {
	if (! $no_decode && ! $no_decode_this_time ) {
		&read_char_tables;
		# guess encoding and decode each paragraph at the time.
		if( $multi_coding ) {
			my $document = XML::Twig->new(twig_handlers => { p => sub { call_decode_para(@_); } });
			if (! $document->safe_parsefile ("$int") ) {
				print STDERR "Encoding: $int: ERROR parsing the XML-file failed.\n";
				last ENCODING;
			}
			open (FH, ">$int") or print STDERR "$file: ERROR cannot open file $!";
			$document->set_pretty_print('indented');
			$document->print( \*FH);
		} else {
			# assume same encoding for the whole file.
			my $coding = &guess_encoding($int, $language, 0);
			if ($coding eq -1) { 
				print STDERR "Was not able to determine character encoding. STOP.\n";
				exec_com("rm -rf \"$int\"", $file);
				return;
			}
			elsif ($coding eq 0) { 
				if($test) { print STDERR "Correct character encoding.\n"; }
				if($file =~ /\.doc$/) {
					# Document title in msword documents is generally wrongly encoded, 
					# check that separately.
					my $d=XML::Twig->new(twig_handlers=>{'p[@type="title"]'=>sub{call_decode_title(@_, $coding);},
													   'title'=>sub{call_decode_title(@_);}
												 }
									   );
					if (! $d->safe_parsefile ("$int") ) {
						print STDERR "Encoding: $int: ERROR parsing the XML-file failed.\n";
						last ENCODING;
					}
					open (FH, ">utf8", "$int") or print STDERR "$file: ERROR cannot open file $!";
					$d->set_pretty_print('indented');
					$d->print( \*FH);
				}
				last ENCODING; 
			}
			# Continue decoding the file.
			if($test) { print STDERR "Character decoding: $coding\n"; }
			my $d=XML::Twig->new(twig_handlers=>{'p'=>sub{call_decode_para(@_, $coding);},
												 'title'=>sub{call_decode_para(@_, $coding);}
											 }
									   );
			if (! $d->safe_parsefile ("$int") ) {
				print STDERR "Encoding: $int: ERROR parsing the XML-file failed.\n";
				last ENCODING;
			}
			open (FH, ">$int") or print STDERR "$file: ERROR cannot open file $!";
			$d->set_pretty_print('indented');
			$d->print( \*FH);
		}
	}
	} #ENCODING


	# hyphenate the file
	if (! $no_hyph ) {
		if ($all_hyph) { $command = "$hyphenate --all --infile=\"$int\" --outfile=\"$tmp1\""; }
		else { $command = "$hyphenate --infile=\"$int\" --outfile=\"$tmp1\"";}
		exec_com($command, $file);
		copy ($tmp1, $int) ;
	}

	# Remove temporary file unless testing.
	if (! $test) {
		exec_com("rm -rf \"$tmp1\"", $file);
		exec_com("rm -rf \"$tmp3\"", $file);
	}

	if(! $upload) {
		my $cnt = chown -1, $gt_gid, $int;
#		if ($cnt == 0) { print STDERR "$file: ERROR: chgrp failed for $int.\n"};
		chmod 0660, $int;
	}

	if (! $noxsl) {
		# Execute the file specific .xsl-script.
		my $tmp = $tmpdir . "/" . $file . ".tmp";
		$command = "xsltproc --novalid \"$xsl_file\" \"$int\" > \"$tmp\"";
		exec_com($command, $file);

		# Validate the xml-file unless web upload.
		if(! $upload && ($file !~ /.ptx$/)) {
			$command = "xmllint --valid --encode UTF-8 --noout \"$tmp\"";
			if( exec_com($command, $file) != 0 ) {
				print STDERR "ERROR: not valid xml, removing $int.. STOP.\n";
				$command = "rm -rf \"$int\"";
				exec_com($command, $file);
				if (! $test) {
					$command = "rm -rf \"$tmp\"";
					exec_com($command, $file);
				}
				return;
			}
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
		my $command = "$text_cat -q -x -d $lmdir \"$int\"";
		exec_com($command, $file);
	}

	if (! $upload) {
	  COPYFREE: {
		  # Copy file with free license to gtfree.
		  my $document = XML::Twig->new;
		  if (! $document->safe_parsefile("$int")) {
			  if (-f $intfree) {
				  $command = "rm -rf \"$intfree\"";
				  exec_com($command, $file);
			  }

			  print STDERR "Copyfree: $int: ERROR parsing the XML-file failed: $@\n";		  
			  last COPYFREE;
		  }
		  
		  my $license = "license";
		  my $root = $document->root;
		  my $header = $root->first_child('header');
		  my $avail = $header->first_child('availability');
		  $license = $avail->first_child->local_name;
		  
		  if ( $license =~ /free/ ) {
			  if(-f $intfree && ! -w $intfree) {
				  print STDERR "$file: ERROR permission denied $intfree.\n";
				  last COPYFREE;
			  }
			  
			  # Create the directory to gtfree if it does not exist.
			  ( my $dir =  $intfree )  =~ s/(.*)[\/\\].*/$1/;
			  if (! -d $dir ) {
				  my $command="mkdir -p \"$dir\"";
				  exec_com($command, $file);
				  my $cnt = chown -1, $gt_gid, $dir;
#				  if ($cnt == 0) { print STDERR "$file: ERROR: chgrp failed for $dir.\n"};
				  chmod 0770,$dir;
			  }		

			  copy ($int, $intfree) 
				  or print STDERR "ERROR: copy failed ($int $intfree)\n";

			  my $cnt = chown -1, $gt_gid, $intfree;
#			  if ($cnt == 0) { print STDERR "$file: ERROR: chgrp failed for $intfree.\n"};

			  chmod 0664, $intfree;
			  
		  }
		  elsif (-f $intfree) {
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
	if ( system($com) != 0 ) { 
		print STDERR "$file: ERROR errors in $com: $!\n";
		return $?;
	}
	else { return 0; }
}


# Decode false utf8-encoding for text paragraph.
sub call_decode_para {
	my ( $twig, $para, $coding) = @_;

	my $text = $para->text;
	my $error = &decode_para($language, \$text, $coding);
	if ($error){ print STDERR $error; }

	$para->set_text($text);
}

# Decode false utf8-encoding for titles.
sub call_decode_title {
	my ( $twig, $title, $coding ) = @_;

	my $text = $title->text;

	if(!$coding) {
		my $error = &decode_para($language, \$text);
		if ($error){ print STDERR $error; }
	}

	my $error = &decode_title($language, \$text, $coding);
	if ($error){ print STDERR $error; }

	$title->set_text($text);
}

# Add prelimnary xml-structure for the text files.
sub txtclean {

    my ($file, $outfile, $lang) = @_;

	my $replaced = qq(\^\@\;|–&lt;|\!q|&gt);
	my $maxtitle=30;

    # Open file for printing out the summary.
	my $FH1;
	open($FH1,  ">$outfile");
	print $FH1 qq|<?xml version='1.0'  encoding="UTF-8"?>|, "\n";
	print $FH1 qq|<document xml:lang="$lang">|, "\n";

	# Initialize XML-structure
	my $twig = XML::Twig->new();
	$twig->set_pretty_print('indented');

	my $header = XML::Twig::Elt->new('header');
	my $body = XML::Twig::Elt->new('body');

	# Start reading the text
	# enable slurp mode
	local $/ = undef;
    if (! open (INFH, "$file")) {
        print STDERR "$file: ERROR open failed: $!. ";
        return;
    }

	my $text=0;
	my $notitle=1;

    while(my $string=<INFH>){

#		print "string: $string\n";
		$string =~ s/($replaced)//g;
		$string =~ s/\\//g;
		# remove all the xml-tags.
		$string =~ s/<.*?>//g;
		my @text_array;
		my $title;

		return if (! $string);
		# The text contains newstext tags:
		if ($string =~ /\@(.*?)\:/) {
			while ($string =~ s/(\@(.*?)\:[^\@]*)//) {
				push @text_array, $1;
			}
			for my $line (@text_array) {
				if ($line =~ /^\@(.*?)\:(.*?)$/) {
					my $tag = $1;
					my $text = $2;
					
					if ( $tag =~ /(tittel|m.titt)/ && $text ) {
						$text =~ s/[\r\n]+//;
						
						# If the title is too long, there is probably an error
						# and the text is treated as normal paragraph.
						if(length($text) > $maxtitle) {
							my $p = XML::Twig::Elt->new('p');
							$p->set_text($text);
							$p->paste('last_child', $body);
							next;
						}
						if ($notitle) {
							$title = XML::Twig::Elt->new('title');
							$title->set_text($text);
							$title->paste( 'last_child', $header);
							$notitle=0;
						}
						my $p = XML::Twig::Elt->new('p');
						$p->set_att('type', "title");
						$p->set_text($text);
						$p->paste('last_child', $body);
						next;
					}
					if ( $tag =~ /(tekst|ingress)/ ) {
						my $p = XML::Twig::Elt->new('p');
						$p->set_text($text);
						$p->paste('last_child', $body);
						next;
					}
					if ( $tag =~ /(byline)/ ) {
						my $a = XML::Twig::Elt->new('author');
						my $p = XML::Twig::Elt->new('person');
						$p->set_att('firstname', "");
						$p->set_att('lastname', "$text");
						$p->paste( 'last_child', $a);
						$a->paste( 'last_child', $header);
						next;
					}
					my $p = XML::Twig::Elt->new('p');
					$p->set_text($text);
					$p->set_att('type', "title");
					$p->paste('last_child', $body);
					next;
				}
				else { 
					print "Error: line did not match: $line\n"; 
					next; 
				}
			}
		}

		# The text does not contain newstext tags:
		else {
			$notitle=0;
			my $p_continues=0;
			my $p;
			
			my @text_array = split(/[\n\r]/, $string);
			for my $line (@text_array) {
				$line .= "\n";
				if (! $p ) {
					$p = XML::Twig::Elt->new('p');
					$p->set_text($line);
					$p_continues = 1;
					next;
				}
				if( $line =~ /^\s*\n/  ) {
					$p_continues = 0;
					next;
				}
				if($p_continues ) {
					my $orig_text = $p->text;
					$line = $orig_text . $line;
					$p->set_text($line);
				}
				else {
					$p->paste('last_child', $body);
					$p = XML::Twig::Elt->new('p');
					$p->set_text($line);
					$p_continues = 1;
				}
			}
		}
	}
	close INFH;
	$header->print($FH1);
	$body->print($FH1);

	print $FH1 qq|</document>|;
	close $FH1;
}

# routine for printing out header in the middle of processing
# used in subroutine txtclean.
sub printheader {
	my ($header, $fh) = @_;

	$header->print($fh);
	$header->DESTROY;
	print $fh qq|<body>|;

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

			$string =~ s/[\n\r]/ /;
			
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




