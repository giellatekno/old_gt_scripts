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
my $file;
my $outfile;
my $encoding;
my $command;
my $language = "sme";

$file="$ENV{'GTFREE'}/orig/sme/laws/jus.txt";
$outfile = File::Basename::basename($file);
is($encoding = &guess_text_encoding($file, $outfile, $language), "WINSAMI2", "Check for correct encoding");
&decode_text_file($file, $encoding, $outfile);
file_exists_ok($outfile);

$command = "iconv -f utf8 -t winsami2 $outfile -o $outfile.test";
is(system($command), '0', "Check if converting from utf8 to original encoding goes well");
$command = "diff $outfile.test $file";
is(system($command), '0', "Check if infile is identical to test file");

$file = "$ENV{'GTBOUND'}/orig/sme/news/MinAigi/2003/bildetekst_lakselv.txt";
$outfile = File::Basename::basename($file);

is($encoding = &guess_text_encoding($file, $outfile, $language), "UTF8", "Check for correct encoding");
&decode_text_file($file, $encoding, $outfile);
file_exists_ok($outfile);

$command = "diff $outfile $file";
is(system($command), '0', "Check if infile is identical to test file");

$language = "swe";
$file = "$ENV{'GTBOUND'}/orig/swe/bible/bibeln-2.1/56.txt";
$outfile = File::Basename::basename($file);

is($encoding = &guess_text_encoding($file, $outfile, $language), "WINSAMI2", "Check for correct encoding");
&decode_text_file($file, $encoding, $outfile);
file_exists_ok($outfile);

$command = "iconv -f utf8 -t winsami2 $outfile -o $outfile.test";
is(system($command), '0', "Check if converting from utf8 to original encoding goes well");
$command = "diff $outfile.test $file";
is(system($command), '0', "Check if infile is identical to test file");

$language = "sme";
$file = "$ENV{'GTBOUND'}/orig/sme/news/avvir.no/avvir-article-998.txt";
$outfile = File::Basename::basename($file);

is($encoding = &guess_text_encoding($file, $outfile, $language), "UTF8", "Check for correct encoding");
&decode_text_file($file, $encoding, $outfile);
file_exists_ok($outfile);

$command = "iconv -f utf8 -t utf8 $outfile -o $outfile.test";
is(system($command), '0', "Check if converting from utf8 to original encoding goes well");
$command = "diff $outfile.test $file";
is(system($command), '0', "Check if infile is identical to test file");
