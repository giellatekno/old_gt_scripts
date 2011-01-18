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
my $doc_name = "$ENV{'GTBOUND'}/orig/sme/facta/RidduRiđđu-aviissat/Riddu_Riddu_avis_TXT.200910.svg";
ok(my $converter = langTools::Preconverter->new($doc_name, 0));

isnt($converter->getDoclang(), "", "Check if doclang is empty");

#
# Test if the original is the given file name
#
is($converter->getOrig(), Encode::decode_utf8(Cwd::abs_path($doc_name)));

#
# Check if the random file name is made and is of the expected length
#
is(length($converter->getTmpFilebase()), '8');

