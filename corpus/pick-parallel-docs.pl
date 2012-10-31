#!/usr/bin/perl
use warnings;
use strict;

use Cwd;
use File::Copy;
use File::Path;
use Getopt::Long;

use XML::XPath;
use XML::XPath::XMLParser;

#
# main prog
#

my $quiet = 0;
GetOptions ("quiet" => \$quiet, );

# (1) quit unless we have the correct number of command-line args
my $num_args = $#ARGV + 1;
if ($num_args != 1) {
  print "\nUsage: pick-parallel-docs.pl filename\n";
  print "Typical usacase is:\n";
  print "find \$GTFREE/converted/sme -name \*.xml -exec pick-parallel-docs.pl {} \;";
  print "This command finds all .xml files in \$GTFREE/converted/sme and checks if the file has a parallel file\n";
  print "If it finds a parallel file and the mainfile and the parallel file fills the criteria, the file are copied to \$GTFREE/prestable/converted\n";
  exit;
}

my $f = $ARGV[0];
if (-e $f) {
    my $abs_path = Cwd::abs_path($f);
    my $pdoc_path = get_paralleldoc($abs_path, "nob");
    if ( -e $pdoc_path) {
        check_and_copy_files($abs_path, $pdoc_path);
    } else {
        if ($quiet) {
            print "|";
        } else {
            die "$pdoc_path doesn't exist\n";
        }
    }
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
    
    return $mainlang;
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
    my @nodelist = $xp->find('//wordcount')->get_nodelist;
    my @wordcounts = map($_->string_value, @nodelist);
    
    return $wordcounts[0];
}

sub copy_file_to_prestable {
    my ($file_to_copy) = @_;
    (my $to_file = $file_to_copy) =~ s/\/converted\//\/prestable\/converted\//;
    my $parallel_path = substr($to_file, 0, rindex($to_file, "/"));
    if (! -e $parallel_path) {
        File::Path::mkpath($parallel_path);
    }
    if (! $quiet) {
        print " $to_file ";
    }
    File::Copy::copy($file_to_copy, $to_file) or die "Copy failed: $!";
}

sub copy_file_to_wrongratio {
    my ($file_to_copy) = @_;
    (my $to_file = $file_to_copy) =~ s/\/converted\//\/wrongratio\/converted\//;
    my $parallel_path = substr($to_file, 0, rindex($to_file, "/"));
    if (! -e $parallel_path) {
        File::Path::mkpath($parallel_path);
    }
    if (! $quiet) {
        print " $to_file ";
    }
    File::Copy::copy($file_to_copy, $to_file) or die "Copy failed: $!";
}

sub check_and_copy_files {
    my ($abs_path, $pdoc_path) = @_;
    
    if ($pdoc_path ne $abs_path and -e $pdoc_path) {
        my $pabs_path = get_paralleldoc($pdoc_path, "sme");
        if ($pabs_path eq $abs_path) {
            my $abs_path_wordcount = get_wordcount($abs_path);
            if ($abs_path_wordcount > 30) {
                my $pdoc_path_wordcount = get_wordcount($pdoc_path);
                my $ratio = $abs_path_wordcount/$pdoc_path_wordcount*100;
            
                if ($ratio > 73 and $ratio < 110) {
                    if ($quiet) {
                        print ".";
                    } else {
                        print "\nRatio is $ratio ";
                        print "Copying files";
                    }
                    copy_file_to_prestable($abs_path);
                    copy_file_to_prestable($pdoc_path);
                    if (!$quiet) {
                        print "\n";
                    }
                } else {
                    if ($quiet) {
                        print "|";
                    } else {
                        print STDERR "\nWrong ratio $ratio, $abs_path: $abs_path_wordcount $pdoc_path: $pdoc_path_wordcount\n";
                        copy_file_to_wrongratio($abs_path);
                        copy_file_to_wrongratio($pdoc_path);
                    }
                }
            } else {
                if ($quiet) {
                    print "/";
                } else {
                    print STDERR "\nToo low wordcount $abs_path_wordcount, $abs_path\n";
                }
            }
        }
    }
}
