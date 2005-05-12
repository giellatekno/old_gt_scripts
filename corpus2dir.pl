#!/usr/bin/perl -w

use utf8;
use strict;
use encoding 'utf-8';
use open ':utf8';
use XML::Twig;
use File::Find;
use File::Spec;
#use IO::File;
#use Getopt::Long;

my $publisher;
my $person;
my $year;
my $title;
my $TEMP_DIR = "../tmp/";
my $PROJECT = "gt";

mkdir ("$TEMP_DIR", 0755) unless -d $TEMP_DIR;
$TEMP_DIR = File::Spec->rel2abs($TEMP_DIR);

find ( sub {
    return if -d;
    return unless ($_ =~ /\.int\.xml/);

    my $manual_xsl = File::Spec->rel2abs($_);
    $manual_xsl =~ s/\.int\.xml/\.xsl/i;

    if (-e $manual_xsl) {
    	my $temp_file = "$TEMP_DIR/$_";

    	system "xsltproc --novalid \"$manual_xsl\" $_ > \"$temp_file\"";
    
	   my $lang;
	   my $document = XML::Twig->new(twig_handlers =>
                                  {'document' => sub { $lang = $_->{'att'}->{'xml:lang'}}} );
                                  
        $document->parsefile ($temp_file);
	   $document->purge;

        my $xmlfile = XML::Twig->new(twig_roots =>
                                 {'document/header' => \&process_header } );

    	$xmlfile->parsefile ($temp_file);

	   my $int = File::Spec->rel2abs($_);
	   if ($publisher) {
    	   	   $int =~ s/sme\/int\/.*/$lang\/$PROJECT\/$publisher\/$year\/$title\.xml/;
       }
       
       elsif ($person) {
           $int =~ s/sme\/int\/.*/$lang\/$PROJECT\/$person\/$year\/$title\.xml/;
       }
       
       else {
       		print STDERR "Unable to process file $int";
       }

	   my $intdir;
	   my $volume;
	   my $file;
	   ($volume, $intdir, $file) = File::Spec->splitpath($int);
	   my @dirs = File::Spec->splitdir($intdir);
        my $dirpath = "";
        for my $dir (@dirs) {
            $dirpath = $dirpath . $dir . "/";
#            print $dirpath . "\n";
    	   mkdir ("$dirpath", 0755) unless -d $dirpath;
        }

	   system ("mv \"$TEMP_DIR/$_\" \"$int\"");
    }
}, '.');

rmdir ("$TEMP_DIR");

sub process_header
{
    my ($twig, $header) = @_;

    $publisher = $header->first_child('publChannel')->first_child_text('publisher');

    $person = $header->first_child('author')->first_child('person')->{'att'}->{'name'};

    $year = $header->first_child_text('year');
    $title = $header->first_child_text('title');

    $twig->purge;
}
