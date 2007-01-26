#!/usr/bin/perl
#
# Script for converting different eol-conventions.
#
# $Id$

use strict;
use Getopt::Long;

use utf8;

my $fdata;

# no-break space
my $no_break = 160;
my $no_break2 = 8239;
my $no_break3 = 6527;
my $en_space = 8194;
my $em_space = 8195;

# conversion to mac / pc / unix
my $tostring = "\n";

my $unix;
my $mac;
my $pc;
my $tostring;
my $help;

GetOptions("unix" => \$unix,
		   "mac" => \$mac,
		   "pc" => \$pc,
		   "help" => \$help);

if($mac) { 	$tostring = "\r"; }
if($pc) { $tostring = "\r\n"; }
if(! $tostring ) { $tostring = "\n"; }

if ($help) {
        print <<HELP;
    Usage: convert_eol.pl [--unix|--mac|--pc] file [file ...]

HELP
	}

foreach my $file(@ARGV){
	if (open (FILE,$file) ) {
		read (FILE,$fdata,-s $file);

		$fdata =~ s/\r\n/\n/g;
		$fdata =~ s/\r/\n/g;
		$fdata =~ s/\n/$tostring/g;
		
		# remove no-break space
		my @unpacked = unpack("U*", $fdata);
		my $i=0;
		while ($unpacked[$i]) {
			my $byte = $unpacked[$i];
			if ($byte==$no_break || $byte==$no_break2 || $byte==$no_break3 ) {
				splice(@unpacked, $i, 1);
				next;
			}
			if ($byte==$em_space || $byte==$en_space) {
				$unpacked[$i]=32;
			}
			$i++;
		}
		$fdata = pack("U*", @unpacked);
		print $fdata;
	} else {
		warn ("File $file could not be read\n");
	}
}
