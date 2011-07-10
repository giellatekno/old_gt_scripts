use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use utf8;
use strict;
use Getopt::Long;
use warnings;

my @ccat_options = (
	'-a -c',
	'-a',
	'-c',
	'-C',
	'-lex',
	'-L',
	'-morphsyn',
	'-ort',
	'-p',
	'-S',
	'-syn',
	'-t',
	'-T',
);

foreach my $ccat_option (@ccat_options) {
	my $ending;
	if ($ccat_option eq '-C') {
		$ending = '-capital-c';
	} elsif ($ccat_option eq '-T') {
		$ending = '-capital-t';
	} else {
		$ccat_option =~ s/ /_/g;
		$ending = $ccat_option;
	}
	
	my $command = 'ccat ' . $ccat_option . ' example.correct.xml > example.correct._' . $ending . '.txt 2> /dev/null';
	print $command . "\n";
	system($command);
	$command = 'diff example.correct._' . $ending . '.txt example.correct.xml.ccat_' . $ending . '.test.txt > /dev/null';
	is(system($command), 0, 'is ' . $ccat_option . ' correct?');
}
