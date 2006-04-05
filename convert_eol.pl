#!/usr/bin/perl
#
# Script for converting different eol-conventions.
#
# $Id$

use strict;
use open ':utf8';
use encoding 'utf8';

my $fdata;

# no-break space
my $no_break = 160;

# conversion to mac / pc / unix
my $tostring = "\n";
if ($ARGV[0] =~ /-unix/i)
{
	$tostring = "\n";
	shift;
}
if ($ARGV[0] =~ /-pc/i)
{
	$tostring = "\r\n";
	shift;
}
if ($ARGV[0] =~ /-mac/i)
{
	$tostring = "\r";
	shift;
}
if ($#ARGV < 0) {
        die ("Usage  $0  [-unix|-mac|-pc]
        file [file ....]\n");
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
			if ($byte == $no_break) {
				splice(@unpacked, $i, 1);
				next;
			}
			$i++;
		}
		$fdata = pack("U*", @unpacked);
		print $fdata;
	} else {
        warn ("File $file could not be read\n");
	}
}
