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

my $text = "Maid oÃ°Ã°a guolleÂ¹lájaid buktin sáhttá váikkuhit Ã¨ázádahkii";
is(&guess_encoding(undef, $language, \$text), "type07", "check for type07");

my $text = "Lasáhus Ä?áhce- ja kloahkkadivatnjuolggadusaide";
is(&guess_encoding(undef, $language, \$text), "type07", "check for type07");

$text = "geassemánu 12. 1987 nr. 56 Sámedikki ja eará sámi
                vuoigatvuoðaid birra1(oðða organiseren bargui sámi
                gielaid ovddas)";
is(&guess_encoding(undef, $language, \$text), "type09", "check for type09");

system("iconv -f latin1 -t utf8 $ENV{'GTFREE'}/orig/sme/laws/jus.txt > jus.txt");
is($encoding = &guess_encoding("jus.txt", $language), "type04", "Check for type04");

$language = "swe";
system("iconv -f latin1 -t utf8 $ENV{'GTBOUND'}/orig/swe/bible/bibeln-2.1/56.txt > 56.txt");
is($encoding = &guess_encoding("jus.txt", $language), "type04", "Check for type04");

$language = "nob";
system("iconv -f latin1 -t utf8 $ENV{'GTBOUND'}/orig/nob/news/MinAigi/2003/Eldre_rekrutt1.txt > Eldre_rekrutt1.txt");
is($encoding = &guess_encoding("Eldre_rekrutt1.txt", $language), "type06", "Check type06");

$language = "nob";
system("iconv -f latin1 -t utf8 $ENV{'GTBOUND'}/orig/nob/news/MinAigi/2003/alm_hagelaget.txt > alm_hagelaget.txt");
is($encoding = &guess_encoding("alm_hagelaget.txt", $language), "type06", "Check type06");

$language = "sme";
system("iconv -f latin1 -t utf8 $ENV{'GTBOUND'}/orig/sme/news/Assu/1997/A47-97/BESKJEDTEO-21.7.txt > BESKJEDTEO-21.7.txt");
is($encoding = &guess_encoding("BESKJEDTEO-21.7.txt", $language), "type06", "Check type06");

$language = "sme";
system("iconv -f latin1 -t utf8 $ENV{'GTBOUND'}/orig/sme/news/MinAigi/2004/094-04_Urfolk/__ordfører-_engelsk_tekst.txt > __ordfører-_engelsk_tekst.txt");
is($encoding = &guess_encoding("__ordfører-_engelsk_tekst.txt", $language),, "type06", "Check type06");
