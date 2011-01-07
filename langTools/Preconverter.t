use Test::More 'no_plan';
use Test::Exception;
use strict;
use Cwd;

#
# Load the modules we are testing
#
BEGIN {
	use_ok('langTools::Preconverter');
}
require_ok('langTools::Preconverter');

#
# Set a file name, try to make an instance of our object
#
my $doc_name = "fakecorpus/orig/sme/facta/psykiatriijavideo_nr_1_-_abc-company.doc";
ok(my $converter = langTools::Preconverter->new($doc_name, 0));

#
# Test if the original is the given file name
#
is($converter->getOrig(), Cwd::abs_path($doc_name));

#
# Check if the random file name is made and is of the expected length
#
is(length($converter->getTmpFilebase()), '8');

#
# Check the return value of the function
#
#is($converter->convert2xml, '0');
