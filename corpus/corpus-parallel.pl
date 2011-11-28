#!/usr/bin/perl

use utf8;
use strict;
use warnings;

use IO::File;
use File::Basename;
use Getopt::Long;
use XML::Twig;
use Carp qw(cluck croak);
use File::Copy;
use File::Path;
use File::Find;
use List::Util qw(min);

my $corpus_analyze = "$ENV{'GTHOME'}/gt/script/corpus/corpus-analyze.pl";

my $corpdir = "$ENV{'GTFREE'}";

my $host = `hostname`;

my $tmpdir = $corpdir . "/tmp";
my $lang1  = "sme";
my $lang2  = "nob";
my $list;
my $dir;
my %file_list;

my $help;
my $file;
my $files;
my $outdir;

GetOptions(
    "help"     => \$help,
    "files=s"  => \$files,
    "dir=s"    => \$dir,
    "lang1=s"  => \$lang1,
    "lang2=s"  => \$lang2,
    "list"     => \$list,
    "outdir=s" => \$outdir,
);

if ($help) {
    &print_help;
    exit 1;
}

if ( !$outdir ) { $outdir = $tmpdir; }

my $anchor_file = "$ENV{'GTFREE'}/anchor-" . $lang1 . $lang2 . ".txt";

# Search the files in the directory $dir and list the files
# that have parallel file.
if ($dir) {
    if ($list) {
        print STDERR "listing..\n";
        if ( -d $dir ) { find( \&list_files, $dir ) }
        else           { print "$dir ERROR: Directory did not exit.\n"; }

        for my $file ( sort keys %file_list ) {
            if ($lang2) {
                if ( $file_list{$file}{$lang2} ) {
                    print "$file";
                    print ",$file_list{$file}{$lang2}.xml";
                    print "\n";
                }
            }
            else {
                print "$file";
                for my $plang ( keys %{ $file_list{$file} } ) {
                    print ",$file_list{$file}{$plang}.xml";
                }
                print "\n";

            }
        }
    }
    else {
        if ( -d $dir ) { find( \&parallelize_text, $dir ) }
        else           { print "$dir ERROR: Directory did not exit.\n"; }
    }
}

elsif ($files) {
    my @input_files = split( ",", $files );
    for my $f (@input_files) {
        if ( -f $f ) { parallelize_text($f); }
    }
}
elsif ($file) { parallelize_text($file); }

# Process the file given in command line.
else { parallelize_text( Encode::decode_utf8( $ARGV[-1] ) ) if -f $ARGV[-1]; }

# Subroutine to take the parallel files for a file
# Routine examines xml-header of the file.
sub list_files {
    my $file = $_;
    if ( !-f $file ) {
        print STDERR "No such file: $file\n";
        return;
    }
    return if ( $file =~ /~$/ );

    my %para_files;

    my $full = File::Spec->rel2abs($file);
    ( my $path = $full ) =~ s/(.*)[\/\\].*/$1/;

    my $document = XML::Twig->new;
    if ( !$document->safe_parsefile("$file") ) {
        cluck "Parsing the XML-file failed: $file";
        return;
    }
    my $location;
    my $root   = $document->root;
    my $header = $root->first_child('header');
    next if ( !$header );
    my @parallel_texts = $header->children('parallel_text');
    for my $p (@parallel_texts) {
        my $plang     = $p->{'att'}->{'xml:lang'};
        my $para_file = $p->{'att'}->{'location'};
        if ($para_file) {
            ( my $para_path = $path ) =~ s/$lang1/$plang/o;
            $para_file = $para_path . "/" . $para_file;
            my $para_xml = $para_file . ".xml";
            if ( !-f $para_xml ) {
                if ( !$lang2 || $lang2 eq $plang ) {
                    print STDERR
                      "$file: Parallel file $para_xml does not exsist.\n";
                    next;
                }
            }
            $para_files{$plang} = $para_file;
        }
    }
    return if ( !%para_files );

    $file_list{$full} = {%para_files};

    return;
}

# The file and it's parallel counterpart are split to sentences,
# aligned and analyzed.
sub parallelize_text {
    my $file = $_;
    $file = shift(@_) if ( !$file );

    my $document = XML::Twig->new;
    if ( !$document->safe_parsefile("$file") ) {
        cluck "parsing the XML-file failed.\n";
        return;
    }

    # Find the parallel files for the document.
    my $location = find_parallel_location($document);
    if ( !$location ) {
        print "No parallel texts found for language $lang2.\n";
    } else {
        $file = File::Spec->rel2abs($file);
        my @full_paths = find_parallel_paths($file, $lang1, $lang2, $location);
        

        # Prepare files for further processing by
        # adding <s> tags and sentence ids.
        # The output goes to tmp.

        # Take only the file name without path.
        if ( $#full_paths > 0 ) {
            die "Cannot process more than one parallel file\n";
        }
        else {
            my $pfile = $full_paths[0];

            my $lang1_infile = divide_p_into_sentences($file);
            my $lang2_infile = divide_p_into_sentences($pfile);

            parallelize_files( $anchor_file, $lang1_infile, $lang2_infile );
            make_tmx( $file, $pfile, $lang1, $lang2 );
        }
    }
    return;
}

sub find_parallel_paths {
    my ( $file, $lang1, $lang2, $location ) = @_;
    
    my @full_paths;
    # The path to the original.
    # And path to parallel files.
    ( my $path      = $file ) =~ s/(.*)[\/\\].*/$1/;
    ( my $para_path = $path ) =~ s/$lang1/$lang2/o;

    my @para_files = split( ",", $location );
    for my $p (@para_files) {
        $p = $para_path . "/" . $p;
        if ( $p !~ /\.xml/ ) {
            $p = $p . ".xml";
        }
        push( @full_paths, $p );
    }
    
    return @full_paths;
}

sub find_parallel_location {
    my ( $twig ) = @_;
    
    my $location;
    my $root           = $twig->root;
    my $header         = $root->first_child('header');
    my @parallel_texts = $header->children('parallel_text');
    for my $p (@parallel_texts) {
        my $plang = $p->{'att'}->{'xml:lang'};
        next if ( $plang ne $lang2 );
        $location = $p->{'att'}->{'location'};
        last;
    }

    
    return $location;
}

sub calculate_base {
    my ( $file ) = @_;

    ( my $base = $file ) =~ s/.*[\/\\](.*).xml/$1/;
    return $base;
}

sub divide_p_into_sentences {
    my ( $file, $lang ) = @_;

    my $outfile = $outdir . "/" . calculate_base($file) . $lang . ".sent.xml";

    my $command =
"$corpus_analyze --all --output=\"$outfile\" --only_add_sentences --lang=$lang \"$file\"";
    print STDERR "$0: $command\n";
    if ( system($command) != 0 ) {
        die "errors in $command: $!\n";
    }
    else {
        return $outfile;
    }
}

sub parallelize_files {
    my ( $anchor_file, $infile1, $infile2 ) = @_;

    my $command = "tca2.sh $anchor_file $infile1 $infile2";

    print STDERR "$0: $command\n";
    if ( system($command) != 0 ) {
        die "errors in $command: $!\n";
    }
    else {
        return;
    }
}

sub make_tmx {
    my ( $file, $pfile, $lang1, $lang2 ) = @_;

    my @f1_data = open_tca2_output( calculate_base($file),  $lang1 );
    my @f2_data = open_tca2_output( calculate_base($pfile), $lang2 );

    my $body = XML::Twig::Elt->new("body");
    $body->set_pretty_print('indented');

    my $f1_length = @f1_data;
    for ( my $i = 0 ; $i < $f1_length ; $i++ ) {
        my $tu_elt = XML::Twig::Elt->new("tu");

        make_tuv( $f1_data[$i], $lang1 )->paste( 'last_child', $tu_elt );
        make_tuv( $f2_data[$i], $lang2 )->paste( 'last_child', $tu_elt );

        $tu_elt->paste( 'last_child', $body );
    }

    print_tmx_file( $body, calculate_base($file), $lang1, $lang2 );

    return;
}

sub open_tca2_output {
    my ( $base, $lang ) = @_;

    my $fh1;

    open( $fh1, "<:encoding(utf8)",
        $outdir . "/" . $base . $lang . ".sent_new.txt" )
      || die("Could not open file!");
    my @data = <$fh1>;
    close($fh1);

    return @data;
}

sub print_tmx_file {
    my ( $body, $base, $lang1, $lang2 ) = @_;

    my $FH1;
    if ( !-e $ENV{'GTFREE'} . "/prestable/tmx/" . $lang1 . $lang2 ) {
        File::Path::mkpath(
            $ENV{'GTFREE'} . "/prestable/tmx/" . $lang1 . $lang2 );
    }
    open(
        $FH1,
        " >:encoding(utf8)",
        $ENV{'GTFREE'}
          . "/prestable/tmx/"
          . $lang1
          . $lang2 . "/"
          . $base . ".tmx"
    );
    print_tmx_header( $FH1, $lang1 );
    $body->print($FH1);
    print $FH1 qq|</tmx>|, "\n";
    close($FH1);

    return;
}

sub make_tuv {
    my ( $sentence, $lang ) = @_;

    my $tuv_elt = XML::Twig::Elt->new("tuv");
    $tuv_elt->set_att( 'xml:lang', $lang );
    $sentence =~ s/<s id="[^ ]*">//g;
    $sentence =~ s/<\/s>//g;
    my $seg_elt = XML::Twig::Elt->new( "seg", $sentence );
    $seg_elt->paste( 'last_child', $tuv_elt );

    return $tuv_elt;
}

sub print_tmx_header {
    my ( $FH1, $lang ) = @_;

    print $FH1 qq|<?xml version='1.0'  encoding="UTF-8"?>|, "\n";
    print $FH1 qq|<tmx>|,                                   "\n";
    print $FH1 qq|<header|,                                 "\n";
    print $FH1 qq|    segtype="sentence"|,                  "\n";
    print $FH1 qq|    o-tmf="OmegaT TMX"|,                  "\n";
    print $FH1 qq|    adminlang="EN-US"|,                   "\n";
    print $FH1 qq|    srclang="$lang-NO"|,                  "\n";
    print $FH1 qq|    datatype="plaintext"|,                "\n";
    print $FH1 qq|    >|,                                   "\n";
    print $FH1 qq|</header>|,                               "\n";

    return;
}

sub print_help {
    print << "END";
Searches for parallel documents, aligns them and outputs them to tmx files.
Usage: corpus-parallel.pl [OPTIONS] [FILE]
--help                Print this help text and exit.
--files=<f1,f2,..>    List of input files separated by comma.
--dir=<dir>           The directory where the files are searched.        
--lang1=<lang>        The main language.
--lang2=<lang>        The language of the parallel document(s).
--list                List the parallel files, use with option --dir.
--outdir=<dir>        The directory where the output files are stored.
END

    return;
}
