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

  my $args;

  if ($string =~ /[èÈ¼©]/){
    $args = ("corp-utf8-2.txt");
  } else {
    $args = ("corp-utf8.txt");
  }

  system ("sed -f $args $File::Find::name");
}, '.');
