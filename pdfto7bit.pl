#!/usr/bin/perl -w

# This program uses the utilities pdftotext and pdfinfo from the
# xpdf package.

# $result = `pdftotext -enc UTF-8 $ARGV[0] -`;

use strict;
use vars qw($opt_o $opt_e);
use Getopt::Std;

getopts('eo');

my $num_pages;
my $os="";
my $x;
my $result;

# find number of pages in the document
if ($opt_o || $opt_e){
    $num_pages =  `pdfinfo $ARGV[0]|grep Pages:`;
    $num_pages =~ s/Pages://g;
    $num_pages =~ tr/ //s;
    $os = `pdfinfo $ARGV[0]|grep Distiller`;
#    print "$num_pages\n";
    print "$os\n";
}

if ($opt_o){
    $x = 1;
} elsif ($opt_e){
    $x = 2;
} else {
    $x = 0;
}


$result = get_result($x);

#
$result = remove_garbage($result);

if ( rindex($os, "Macintosh") >= 0 ){
    print "os if\n";
    $result = mac_to_xfst($result);
} else {    
    print "else...\n";
    $result = utf8_to_xfst($result);
    $result = ws2_to_xfst($result);
    
}

print $result;

sub get_result {
    my ($y) = @_;
    my $text = "";

    #print "inne i myres\n";
    if ($y) {
	#print "y def\n";
	while( $y < $num_pages ){
	    #print "y er $y\n";
	    $y += 2;
	    $text = $text . `pdftotext -raw -enc UTF-8 -f $y -l $y $ARGV[0] -`;
	}
    } else {
	$text = `pdftotext -raw -enc UTF-8 $ARGV[0] -`;
    }
    print "get_result\n";
    return $text;

}



sub utf8_to_xfst {
# convert the 7 sami letters encoded as
# utf-8
    #print "utf8";
    my ($text) = @_;

     $text =~ s/á/\xE1/g; # a sharp
     $text =~ s/š/s1/g;   # s caron
     $text =~ s/ŧ/t1/g;   # t stroke
     $text =~ s/ŋ/n1/g;   # eng
     $text =~ s/đ/d1/g;   # d stroke
     $text =~ s/ž/z1/g;   # z caron
     $text =~ s/č/c1/g;   # c caron
     $text =~ s/Á/\xE1/g; # A sharp
     $text =~ s/Š/s1/g; # S caron
     $text =~ s/Ŧ/t1/g; # T stroke
     $text =~ s/Ŋ/n1/g; # ENG
     $text =~ s/Đ/d1/g; # D stroke
     $text =~ s/Ž/z1/g; # Z caron
     $text =~ s/Č/c1/g; # C caron

    return lc($text);
}

sub ws2_to_xfst {

# convert the 7 sami letters
# written on win9x, converted
# to utf-8
# eng seems to vanish?

# This one is not complete
    my ($text) = @_;
    print "ws2";
    $text =~ s/·/\xE1/g; #a sharp
    $text =~ s/¡/\xE1/g; #A sharp
    $text =~ s/ä/S1/g; #S1
    $text =~ s/ö/s1/g; #s1
    $text =~ s/Ç/C1/g; #C1
    $text =~ s/ø/z1/g; #z1
    $text =~ s/º/t1/g; #t1
    $text =~ s/ò/d1/g; #d1
    $text =~ s/Ñ/c1/g; #c1

    return lc($text);
}

sub mac_to_xfst {
    my ($text) = @_;

# convert the 7 sami letters
# written on mac, converted
# to utf-8
    #print "mac";
    $text =~ s/á/\xE1/g; # a sharp
    $text =~ s/Á/\xE1/g; # A sharp
    $text =~ s/¢/C1/g;
    $text =~ s/∏/c1/g;
    $text =~ s/∞/D1/g;
    $text =~ s/π/d1/g;
    $text =~ s/±/N1/g;
    $text =~ s/∫/n1/g;
    $text =~ s/¥/S1/g;
    $text =~ s/ª/s1/g;
    $text =~ s/µ/T1/g;
    $text =~ s/º/t1/g;
    $text =~ s//Z1/g;
    $text =~ s/Ω/z1/g;


    return lc($text);
}

sub remove_garbage {
    my ($text) = @_;

    $text =~ s/-\n//g;
    $text =~ s/ /\n/g;
    $text =~ s/\)//g;
    $text =~ s/\(//g;
    $text =~ s/\///g;
    $text =~ s/\?//g;
    $text =~ s/%//g;
    $text =~ s/\.\.//g;
#    $text =~ s///g;
    $text =~ s/sek //g;
#    $text =~ s/b\.//g;
#    $text =~ s/c\.//g;
#    $text =~ s/y\.//g;
#    $text =~ s/ km //g;
#    $text =~ s/..//g;
#    $text =~ s/nr//g;
#   $text =~ s/ kr //g;
    $text =~ s/&nbsp\;//g;
    $text =~ s/\x0c//g;
    $text =~ s/\xC3\xAC//g;
    $text =~ s/\xC3\xAE//g;
    $text =~ s/\xC2\xA9//g;
    $text =~ s/\342\200\242//g;
    $text =~ s/\d//g;
#    $text =~ s/\W//g;
  

    return lc($text);
}
