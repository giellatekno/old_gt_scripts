use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use strict;
use warnings;
use Cwd;
use Encode;
use utf8;
use Getopt::Long;
use XML::Twig;

#
# Load the modules we are testing
#
BEGIN {
	use_ok('langTools::Corpus');
}
require_ok('langTools::Corpus');

my $debug = 0;
GetOptions ("debug" => \$debug);
# $samiChar::Decode::Test = $debug;

my %question_answer = (
	'DNB-feaskáris§(DnB-feaskáris)' => 'error DNB-feaskáris DnB-feaskáris',
	'boade§boađe' => 'error boade boađe',
	'2005’as§2005:s' => 'error 2005’as 2005:s',
	'NSRii§NSR:ii' => 'error NSRii NSR:ii',
);

foreach (sort (keys % question_answer)) {
	my @answer = langTools::Corpus::error_parser($_);
	my $twig = $answer[1];
	my $a = $twig->name . " " . $twig->text . " " . $twig->{'att'}->{'correct'};
	is($a, $question_answer{$_}, "gaga");
}
