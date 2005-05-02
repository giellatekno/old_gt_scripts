#!/usr/bin/perl -w

use strict;
use encoding 'utf-8';
use open ':utf8';
use File::Find;

undef $/;

find ( sub {
  return if(__FILE__ =~ $_);
  return if(! -f $_);
  return if("corp-utf8.txt" =~ $_);
  return if("corp-utf8-2.txt" =~ $_);

  open (FILE, "< $File::Find::name") or return;
  my $string = <FILE>;
  close (FILE);
  
  open (FILE, "< $File::Find::name") or return;
  
  my $args;
  
  print $string;

  if ($string =~ /[èÈ¼©]/){
     while(<FILE>) {
     	print "While!";
      	s/¹/đ/g;
		s/©/Đ/g;
		s/è/č/g;
		s/È/Č/g;
		s/¼/ž/g;
		s/¿/ŋ/g;
		s/º/š/g;
     }
#    $args = ("corp-utf8-2.txt");
  } else {
     while (<FILE>) {
     	print "While!";
    		s/„/č/g;
		s/˜/đ/g;
		s/¿/ž/g;
		s/ð/đ/g;
		s/‚/Č/g;
		s/¹/ŋ/g;
		s/ð/đ/g;
		s/‰/Đ/g;
		
		s/ð/đ/g;
		s/ç/č/g;
		s/Ç/Č/g;
		s/Ó/Š/g;
		s/ó/š/g;
		s/þ/ž/g;
		s/ñ/ŋ/g;
		s/Ñ/Ŋ/g;
		s/ý/ŧ/g;
		
		s/²/Š/g;
		s/³/š/g;
		s/¢/č/g;
		s/¡/Č/g;
		s/±/ŋ/g;
		s/ð/đ/g;
		s/ç/č/g;
		s/º/ž/g;
		s/¤/đ/g;
     }
#    $args = ("corp-utf8.txt");
  }

  close (FILE);

  print $string;
#  system ("sed -f $args $File::Find::name");
}, '.');

