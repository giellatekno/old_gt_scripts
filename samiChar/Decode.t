use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use utf8;
use strict;
use Getopt::Long;


#
# Load the modules we are testing
#
BEGIN {
	use_ok('samiChar::Decode');
}
require_ok('samiChar::Decode');

my $debug = 0;
GetOptions ("debug" => \$debug);
$samiChar::Decode::Test = $debug;

my $file="jus.winsami2.txt";
my $outfile="jus.txt";
my $encoding;
my $language = "sme";

is($encoding = &guess_text_encoding($file, $outfile, $language), "WINSAMI2", "Check for correct encoding");
&decode_text_file($file, $encoding, $outfile);
file_exists_ok($outfile);

my $command = "diff $outfile jus.utf8.txt";
is(system($command), '0', "Check if the converterd infile is identical to test file");

$file = "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2003/bildetekst_lakselv.txt";
$outfile = File::Basename::basename($file);

is($encoding = &guess_text_encoding($file, $outfile, $language), "UTF8", "Check for correct encoding");
&decode_text_file($file, $encoding, $outfile);
file_exists_ok($outfile);

$command = "diff $outfile $file";
is(system($command), '0', "Check if infile is identical to test file");
