#!/usr/bin/env perl

use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use utf8;
use strict;
use warnings;

#
# Get options
#
use Getopt::Long;

# options
my $debug = 0;
GetOptions( "debug" => \$debug, );

$langTools::Decode::Test = $debug;

#
# Load the modules we are testing
#
BEGIN {
    use_ok('langTools::Decode');
}
require_ok('langTools::Decode');

# test encoding of the following files
use langTools::Converter;

# filename with expected result
my %test_cases = (
    "$ENV{'GTFREE'}/orig/sme/admin/depts/other_files/273777-raportti_saami.pdf"
      => "0",
    "$ENV{'GTFREE'}/orig/sme/admin/sd/other_files/1999_1s.doc" => "type10",
);

foreach ( keys %test_cases ) {
    test_decode( $_, $test_cases{$_} );
}

#
# Subroutines
#

# Test the encoding of one file
sub test_decode {
    my ( $filename, $expected_result ) = @_;

    my $converter = langTools::Converter->new( $filename, $debug );
    $converter->getPreconverter();
    is( $converter->makeXslFile(),
        '0', "Check if we are able to make the tmp-metadata file" );
    is( $converter->convert2intermediatexml(), '0', "pdf to int xml" );
    is( $converter->convert2xml(),
        '0', "Check if combination of internal xml and metadata goes well" );
    my $text = $converter->get_doc_text();
    isnt( $text, '0', "extract text from xml" );
    my $language = $converter->getPreconverter()->getDoclang();
    is( &guess_encoding( undef, $language, \$text ),
        $expected_result, "the encoding" );
}
