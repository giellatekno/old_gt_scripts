#!/usr/bin/perl -w

use strict;
use encoding 'utf-8';
use open ':utf8';
use File::Find;
use IO::File;
use Getopt::Long;
use samiChar::Decode;

my $use_decode; # use module Decode to decode the file. this is to be removed.
my $xsl_file; 
my $dir; # the directory where the search for files is done

GetOptions ("use-decode" => \$use_decode,
			"xsl=s" => \$xsl_file,
			"dir=s" => \$dir);
		   
my @files;

# Search the files in the directory $dir and process each one of them.
find (\&process_file, $dir) if -d $dir;
process_file ($ARGV[$#ARGV]) if -f $ARGV[$#ARGV];

sub process_file {
    my $file = $_;
    $file = shift (@_) if (!$file);

	print "Processing file $file...\n";
    return unless ($file =~ m/\.(doc|pdf|html)$/);
    return if (__FILE__ =~ $file);
    return if ($file =~ /[\~]$/);
	return if (-z $file);
    
    my $orig = File::Spec->rel2abs($file);
    my $int = $orig;
	$int =~ s/\.(doc|pdf|html)$/\.\L$1\.xml/i;
	
	IO::File->new($int, O_RDWR|O_CREAT) 
		or die "Couldn't open $int for writing: $!\n";

	# Conversion for word documents
	if ($file =~ /\.doc$/) {
		system("antiword -s -x db \"$orig\" | /usr/bin/xsltproc \"$xsl_file\" - > \"$int\"") == 0 
			or die "system failed: $?";
	}

	# Conversion for pdf documents	
	elsif ($file =~ /\.pdf$/) {
		my $html = "/usr/tmp/temporary.html";
		system("pdftotext -enc UTF-8 -nopgbrk -htmlmeta -eol unix \"$orig\" \"$html\"") == 0 
			or die "system failed: $?";
		&pdfclean($html, $int);
		
# Add this when ready
#  tidy --quote-nbsp no --add-xml-decl yes --enclose-block-text yes -asxml -utf8 -language sme file.html
#	| /usr/bin/xsltproc \"$xsl_file\" - > \"$int\"";
	}

	# Conversion for html documents	
	elsif ($file =~ /\.html$/) {
		system("tidy --quote-nbsp no --add-xml-decl yes --enclose-block-text yes -asxml -utf8 -language sme $file | /usr/bin/xsltproc \"$xsl_file\" - > \"$int\"") == 0
			or die "system failed: $?";
	}
	
	push (@files, $int);
}

# Check if the file contains characters that are wrongly
# utf-8 encoded and decode them.
for my $file (@files) {
	if ($use_decode) {
		my $coding = &guess_encoding($file, "sme");
		&decode_file($file, $coding, $file);
	}
}


sub pdfclean {

		my ($infile, $outfile) = @_;
		
		open (OUTFH, ">$outfile") or die "Cannot open file $outfile: $!";
		open (INFH, "$infile") or die "Cannot open file $infile: $!";

		my $number=0;
		my $string;
		while ($string = <INFH>) {
			
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
			$string =~ s/^([\d\.]+[A-ZÄÅÖÁŊČŦŽĐa-zöäåáčŧšđ\s]*)$/\n<\/p>\n<h>$1<\/h>\n<p>\n/;
			$number = 0;
			
			print(OUTFH $string); 
		}
		close (INFH);
		close (OUTFH);
}
