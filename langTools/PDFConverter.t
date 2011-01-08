use strict;

use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use Cwd;

#
# Load the modules we are testing
#
BEGIN {
	use_ok('langTools::PDFConverter', "usage of package ok");
}
require_ok('langTools::PDFConverter');

#
# Set a file name, try to make an instance of our object
#
my @doc_names = ("fakecorpus/orig/sme/facta/callinravvagat.pdf");

foreach my $doc_name (@doc_names) {
	my $converter = langTools::PDFConverter->new($doc_name, 1);
	isa_ok($converter, 'langTools::PDFConverter', 'converter');

	isa_ok($converter, 'langTools::Preconverter', 'converter');

	is($converter->getOrig(), Cwd::abs_path($doc_name), "Check if path to the orig doc is  correct");

	file_exists_ok($converter->getTmpDir(), "Check if tmpdir exists");

	isnt($converter->convert2intermediate(), "", "Check if conversion to internal xml goes well and the filename is returned");
}