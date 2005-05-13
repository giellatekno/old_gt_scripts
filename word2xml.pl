#!/usr/bin/perl

use strict;
#use encoding 'utf-8';
use open ':utf8';
use File::Find;
use File::Spec;
use IO::File;
use Getopt::Long;

my $xsl_file;
GetOptions ("xsl=s" => \$xsl_file);

my @files;

find ( sub {
    if (-d) {
	my $orig = File::Spec->rel2abs($_);
	my $int = $orig;
	$int =~ s/orig/int/i;
	mkdir ("$int", 0755) unless -d $int;
	return;
    }
    return unless ($_ =~ /\.doc/);
    return if (__FILE__ =~ $_);
    return if ($_ =~ /[\~]$/);
    
    my $orig = File::Spec->rel2abs($_);
    my $int = $orig;
    $int =~ s/orig/int/i; 
    $int =~ s/.doc$/.int.xml/i;

    IO::File->new($int, O_CREAT) 
	or die "Couldn't open $int for writing: $!\n";

    system "antiword -s -x db \"$orig\" | xsltproc \"$xsl_file\" - > \"$int\"";

    push (@files, $int);

}, '.');

for my $file (@files) {
    open (FILE, $file) or die "Cannot open file $file: $!";

    my $string;
    my @outString;
    while ($string = <FILE>) {
	push (@outString, $string);
    }

    close FILE;
    open (FILE, $file) or die "Cannot open file $file: $!";

    if (@outString =~ /[èÈ¼©]/){
	undef (@outString);

	while ($string = <FILE>) {
	    $string =~ s/¹/đ/g;
	    $string =~ s/©/Đ/g;
	    $string =~ s/è/č/g;
	    $string =~ s/È/Č/g;
	    $string =~ s/¼/ž/g;
	    $string =~ s/¿/ŋ/g;
	    $string =~ s/º/š/g;

	    push (@outString, $string);
	}
    }
    else {
	undef (@outString);

	while ($string = <FILE>) {
	    $string =~ s/„/č/g;
	    $string =~ s/\˜/đ/g;
	    $string =~ s/¿/ž/g;
	    $string =~ s/ð/đ/g;
	    $string =~ s/‚/Č/g;
	    $string =~ s/¹/ŋ/g;
	    $string =~ s/ð/đ/g;
	    $string =~ s/‰/Đ/g;

	    $string =~ s/ð/đ/g;
	    $string =~ s/ç/č/g;
	    $string =~ s/Ç/Č/g;
	    $string =~ s/Ó/Š/g;
	    $string =~ s/ó/š/g;
	    $string =~ s/þ/ž/g;
	    $string =~ s/ñ/ŋ/g;
	    $string =~ s/Ñ/Ŋ/g;
	    $string =~ s/ý/ŧ/g;

	    $string =~ s/²/Š/g;
	    $string =~ s/³/š/g;
	    $string =~ s/¢/č/g;
	    $string =~ s/¡/Č/g;
	    $string =~ s/±/ŋ/g;
	    $string =~ s/ð/đ/g;
	    $string =~ s/ç/č/g;
	    $string =~ s/º/ž/g;
	    $string =~ s/¤/đ/g;

	    push (@outString, $string);
        }
    }

    open (OUTFILE, ">$file");
    print (OUTFILE @outString);
    close (OUTFILE);

    undef (@outString);
}


