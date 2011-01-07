use strict;

use Test::More tests => 8;
use Test::Exception;

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
my $doc_name = "orig/sme/facta/psykiatriijavideo_nr_1_-_abc-company.doc";
ok(my $converter = langTools::Converter->new($doc_name, 0));

#
# Test if the original is the given file name
#
is($converter->getOrig(), "$doc_name");

#
# Check that the name of the converted file is correct
#
is($converter->getInt(), "converted/sme/facta/psykiatriijavideo_nr_1_-_abc-company.doc.xml");

#
# Check if the random file name is made and is of the expected length
#
is(length($converter->getFile()), '8');

#
# Check the return value of the function
#
is($converter->convert2xml, '0');

#
# Check the return value of the function
#
is($converter->makeXslFile(), '0');