#!/usr/bin/perl -w


# $result = `pdftotext -enc UTF-8 $ARGV[0] -`;

use strict;
use vars qw($opt_o $opt_p);
use Getopt::Std;

getopts('op');

my $num_pages;
my $x;
my $result;

if ($opt_o || $opt_p){
    $num_pages =  `pdfinfo $ARGV[0]|grep Pages:`;
    $num_pages =~ s/Pages://g;
    $num_pages =~ tr/ //s;
    print "$num_pages\n";
}

if ($opt_o){
    $x = 1;
} elsif ($opt_p){
    $x = 2;
} else {
    $x = 0;
}


$result = get_result($x);

#
$result = remove_garbage($result);
$result = utf8_to_xfst($result);
$result = ws2_to_xfst($result);
$result = mac_to_xfst($result);
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

    return lc($text);

}
    


sub utf8_to_xfst {
# convert the 7 sami letters encoded as
# utf-8
    #print "utf8";
    my ($text) = @_;

    $text =~ s/\xC3\xA1/\xE1/g; # a sharp
    $text =~ s/\xC5\xA1/s1/g;   # s caron
    $text =~ s/\xC5\xA7/t1/g;   # t stroke
    $text =~ s/\xC5\x8B/n1/g;   # eng
    $text =~ s/\xC4\x91/d1/g;   # d stroke
    $text =~ s/\xC5\xBE/z1/g;   # z caron
    $text =~ s/\xC4\x8D/c1/g;   # c caron
    $text =~ s/\xC3\x81/\xE1/g; # A sharp
    $text =~ s/\xC5\xA0/s1/g; # S caron
    $text =~ s/\xC5\xA6/t1/g; # T stroke
    $text =~ s/\xC5\x80/n1/g; # ENG
    $text =~ s/\xC4\x90/d1/g; # D stroke
    $text =~ s/\xC5\xBD/z1/g; # Z caron
    $text =~ s/\xC4\x8C/c1/g; # C caron

    return lc($text);
}

sub ws2_to_xfst {

# convert the 7 sami letters
# written on win9x, converted
# to utf-8

# This one is not complete
    my ($text) = @_;
    #print "ws2";
    $text =~ s/\xC2\xB7/\xE1/g; #a sharp
    $text =~ s/\xC2\xA1/\xE1/g; #A sharp
    $text =~ s/\xC3\xB6/s1/g; #s1
    $text =~ s/\xC3\xA4/s1/g; #S1
    $text =~ s/\xC3\x87/c1/g; #C1
    $text =~ s/\xC3\xB8/z1/g; #z1
    $text =~ s/\xC2\xBA/t1/g; #t1
    $text =~ s/\xC3\xB2/d1/g; #d1
    $text =~ s/\xC3\x91/c1/g; #c1

    return lc($text);
}

sub mac_to_xfst {
    my ($text) = @_;

# convert the 7 sami letters
# written on mac, converted
# to utf-8
    #print "mac";
    $text =~ s/\xC3\xA1/\xE1/g; # a sharp
    $text =~ s/\xC2\xA2\x45/c1/g;
    $text =~ s/\xE2\x88\x8F/c1/g;
    $text =~ s/\xE2\x88\x9E/d1/g;
    $text =~ s/\xCF\x80/d1/g;
    $text =~ s/\261/N1/g;
    $text =~ s/\xE2\x88\xAB/n1/g;
    $text =~ s/\xC2\xA5/s1/g;
    $text =~ s/\xC2\xAA/s1/g;
    $text =~ s/\xC2\xB5/T1/g;
    $text =~ s/\xC2\xBA/t1/g;
    $text =~ s/\267/Z1/g;
    $text =~ s/\xE2\x84\xA6/z1/g;


    return lc($text);
}

sub remove_garbage {
    # This one ought to remove numbers as well
    #print "remove";
    my ($text) = @_;

    $text =~ s/- //g;
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
