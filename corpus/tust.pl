#!/usr/bin/perl -w

use strict;
use utf8;
use File::Find;
use Encode;
use Cwd;

my $dir = decode_utf8($ARGV[$#ARGV]);

get_dirs($dir);

sub get_dirs {
    my $thisdir = $_[0];
    opendir(orig_dir, $thisdir);
    my @dirs = readdir(orig_dir);
    closedir(orig_dir);

    my $length = @dirs;
    my $count = 0;

    foreach $dir (@dirs) {
        if ($dir =~ m/^\./) {
            delete $dirs[$count];
        }
        $count++
    }

    return @dirs;
}

sub process_file {
    if ((/\.xsl$/)) {
        my $xsl_file = decode_utf8(cwd()) . "/" . decode_utf8($_);
        my $tmp = $xsl_file . ".tmp";
    }
}

