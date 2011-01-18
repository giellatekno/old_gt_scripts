use Test::More 'no_plan';
use Test::Exception;
use strict;
use Cwd;
use Encode;

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
my $doc_name = "$ENV{'GTFREE'}/orig/nob/admin/depts/retningslinjerforverneplanarbeid_sametinget.pdf";
ok(my $converter = langTools::Preconverter->new($doc_name, 1));

isnt($converter->getDoclang(), "", "Check if doclang is empty");

is($converter->getOrig(), Encode::decode_utf8(Cwd::abs_path($doc_name)), "Test if the original is the given file name");

is(length($converter->getTmpFilebase()), '8', "Check if the random file name is made and is of the expected length");

is($converter->isXslValid(), 0, "Check if metadata are valid");