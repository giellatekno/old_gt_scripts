use strict;

use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use Cwd;

#
# Load the modules we are testing
#
BEGIN {
	use_ok('langTools::DOCConverter', "usage of package ok");
}
require_ok('langTools::DOCConverter');

#
# Set a file name, try to make an instance of our object
#
my $doc_name = "$ENV{GTFREE}/orig/sme/facta/psykiatriijavideo_nr_1_-_abc-company.doc";
my $converter = langTools::DOCConverter->new($doc_name, 0);
isa_ok($converter, 'langTools::DOCConverter', 'converter');

isa_ok($converter, 'langTools::Preconverter', 'converter');

is($converter->getOrig(), Cwd::abs_path($doc_name), "Check if path to the orig doc is  correct");

file_exists_ok($converter->getTmpDir(), "Check if tmpdir exists");

is($converter->getXsl(), "$ENV{'GTHOME'}/gt/script/corpus/docbook2corpus2.xsl", "Check if docbook2corpus.xsl is set");

isnt($converter->convert2intermediate(), "", "Check if conversion to internal xml goes well and the filename is returned");
