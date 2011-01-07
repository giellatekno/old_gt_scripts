use strict;

use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use Cwd;

#
# Load the modules we are testing
#
BEGIN {
	use_ok('langTools::BibleXMLConverter', "usage of package ok");
}
require_ok('langTools::BibleXMLConverter');

dies_ok( sub {langTools::BibleXMLConverter->new("fakecorpus/orig/tust.xml")}, "non-existent file");
dies_ok( sub {langTools::BibleXMLConverter->new("fakecorpus/avvir.xml")}, "existing file, filename doesn't contain orig in the path");
lives_ok( sub {langTools::BibleXMLConverter->new("fakecorpus/orig/avvir.xml")}, "existing file, filename contains orig in the path");

#
# Set a file name, try to make an instance of our object
#
my $doc_name = "fakecorpus/orig/sme/bible/ot/Salmmat__garvasat.bible.xml";
my $converter = langTools::BibleXMLConverter->new($doc_name, 0);
isa_ok($converter, 'langTools::BibleXMLConverter', 'converter');

is($converter->getOrig(), Cwd::abs_path($doc_name), "Check if path to the orig doc is  correct");

(my $int = $converter->getOrig()) =~ s/\/orig\//\/converted\//;
is($converter->getInt(), $int .".xml", "Check if path to the converted doc is computed correctly");

is($converter->getCommonXsl(), "$ENV{'GTHOME'}/gt/script/corpus/common.xsl", "Check if common.xsl is set");

is($converter->getPreprocXsl(), "$ENV{'GTHOME'}/gt/script/corpus/preprocxsl.xsl", "Check if preprocxsl.xsl is set");

file_exists_ok($converter->getTmpDir(), "Check if tmpdir exists");

is($converter->makeXslFile(), '0', "Check if we are able to make the tmp-metadata file");

is($converter->getXsl(), "$ENV{'GTHOME'}/gt/script/corpus/avvir2corpus.xsl", "Check if avvir2corpus.xsl is set");

is($converter->convert2intermediate(), '0', "Check if conversion to internal xml goes well");

is($converter->convert2xml(), '0', "Check if combination of internal xml and metadata goes well");