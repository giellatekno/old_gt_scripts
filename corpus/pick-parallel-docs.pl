#!/usr/bin/perl
use warnings;
use strict;

use Cwd;
use File::Copy;
use File::Path;
use XML::XPath;
use XML::XPath::XMLParser;

#
# main prog
#

# (1) quit unless we have the correct number of command-line args
my $num_args = $#ARGV + 1;
if ($num_args != 1) {
  print "\nUsage: pick-parallel_docs.pl filename\n";
  exit;
}

my $f = $ARGV[0];
if (-e $f) {
    my $abs_path = Cwd::abs_path($f);
    my $pdoc_path = get_paralleldoc($abs_path, "nob");
    check_and_copy_files($abs_path, $pdoc_path);
} else {
    die "$f doesn't exist\n";
}

#
# main prog ends
#

#
# Subroutines
#
sub get_mainlang {
    my ($xp) = @_;
    
    my @nodelist = $xp->find('//document')->get_nodelist;
    my $mainlang = $nodelist[0]->findvalue('@xml:lang', $nodelist[0])->value;
}

sub get_paralleldoc {
    my ($abs_path, $preferred_lang) = @_;

    my $parallel_doc = $abs_path;
    my $xp = XML::XPath->new(filename => $abs_path);
    my $mainlang = get_mainlang($xp);
    
    foreach my $node ($xp->find('//parallel_text')->get_nodelist) {
        my $filename = $node->findvalue('@location', $node)->value;
        my $lang = $node->findvalue('@xml:lang', $node)->value;
        if ($lang eq $preferred_lang) {
            $parallel_doc =~ s/\/$mainlang\//\/$lang\//;
            $parallel_doc = substr($parallel_doc, 0, rindex($parallel_doc, "/") + 1) . $filename . ".xml";
        }
    }
    
    return $parallel_doc;
}

sub get_wordcount {
    my ($doc_path) = @_;
    
    my $xp = XML::XPath->new(filename => $doc_path);
    my $mainlang = get_mainlang($xp);
    return `ccat -l $mainlang -a $doc_path | wc -l`;
}

sub copy_file_to_prestable {
    my ($file_to_copy) = @_;
    my $to_file = $file_to_copy;
    $to_file =~ s/\/converted\//\/prestable\//;
    my $parallel_path = $to_file;
    $parallel_path =~ substr($parallel_path, 0, rindex($parallel_path, "/"));
    if (! -e $parallel_path) {
        File::Path::mkpath($parallel_path);
    }
    File::Copy::copy($file_to_copy, $to_file) or die "Copy failed: $!";
}

sub check_and_copy_files {
    my ($abs_path, $pdoc_path) = @_;
    
    if ($pdoc_path ne $abs_path and -e $pdoc_path) {
        my $abs_path_wordcount = get_wordcount($abs_path);
        if ($abs_path_wordcount > 30) {
            my $pdoc_path_wordcount = get_wordcount($pdoc_path);
            my $ratio = $abs_path_wordcount/$pdoc_path_wordcount*100;
        
            if ($ratio > 90 and $ratio < 110) {
                print "Copying files $abs_path, $pdoc_path\n";
                copy_file_to_prestable($abs_path);
                copy_file_to_prestable($pdoc_path);
            }
        }
    }
}
