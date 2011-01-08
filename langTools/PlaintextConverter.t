use strict;

use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use Cwd;

#
# Load the modules we are testing
#
BEGIN {
	use_ok('langTools::PlaintextConverter', "usage of package ok");
}
require_ok('langTools::PlaintextConverter');

#
# Set a file name, try to make an instance of our object
#
my @doc_names = ("fakecorpus/orig/sme/laws/nac1-1994-24.txt");

foreach my $doc_name (@doc_names) {
	my $converter = langTools::PlaintextConverter->new($doc_name, 0);
	isa_ok($converter, 'langTools::PlaintextConverter', 'converter');

	isa_ok($converter, 'langTools::Preconverter', 'converter');

	is($converter->getOrig(), Cwd::abs_path($doc_name), "Check if path to the orig doc is  correct");

	file_exists_ok($converter->getTmpDir(), "Check if tmpdir exists");

	isnt($converter->convert2intermediate(), "", "Check if conversion to internal xml goes well and the filename is returned");
}
