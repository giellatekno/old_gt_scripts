use Test::More 'no_plan';
use Test::Exception;
use strict;
use Cwd;

#
# Load the modules we are testing
#
BEGIN {
	use_ok('langTools::Converter');
}
require_ok('langTools::Converter');

#
# Set a file name, try to make an instance of our object
#
my $doc_name = "fakecorpus/orig/sme/news/Avvir_xml-filer/Avvir_2008_xml-filer/s3_lohkki_NSR.article_2.xml";
ok(my $converter = langTools::Converter->new($doc_name, 0));

#
# Test if the original is the given file name
#
is($converter->getOrig(), Cwd::abs_path($doc_name));

(my $int = $converter->getOrig()) =~ s/\/orig\//\/converted\//;
is($converter->getInt(), $int .".xml", "Check if path to the converted doc is computed correctly");

is(length($converter->getTmpFilebase()), '8');

is($converter->getCommonXsl(), "$ENV{'GTHOME'}/gt/script/corpus/common.xsl", "Check if common.xsl is set");

is($converter->getPreprocXsl(), "$ENV{'GTHOME'}/gt/script/corpus/preprocxsl.xsl", "Check if preprocxsl.xsl is set");

isnt($converter->getDoclang(), "", "Check if doclang is empty");

is($converter->makeXslFile(), '0', "Check if we are able to make the tmp-metadata file");

is($converter->convert2xml(), '0', "Check if combination of internal xml and metadata goes well");

is($converter->checklang(), '0', "Check lang. If not set, set it");

is($converter->checkxml(), '0', "Check if the final xml is valid");
