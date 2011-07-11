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
	'daesn\'$daesnie' => 'error daesn\' daesnie',
	'1]§Ij' => 'error 1] Ij',
	'væ]keles§(væjkeles)' => 'error væ]keles væjkeles',
	'smávi-§smávit-' => 'error smávi- smávit-',
	'CD:t§CD:at' => 'error CD:t CD:at',
	'DNB-feaskáris§(DnB-feaskáris)' => 'error DNB-feaskáris DnB-feaskáris',
	'boade§boađe' => 'error boade boađe',
	'2005’as§2005:s' => 'error 2005’as 2005:s',
	'NSRii§NSR:ii' => 'error NSRii NSR:ii',
	'Nordkjosbotn\'ii§Nordkjosbotnii' => 'error Nordkjosbotn\'ii Nordkjosbotnii',
	'nourra$(a,meta|nuorra)' => 'errorort nourra a meta nuorra',
	'(Nieiddat leat nuorra)£(a,spred,nompl,nomsg,agr|Nieiddat leat nuorat)' => 'errormorphsyn Nieiddat leat nuorra a spred nompl nomsg agr Nieiddat leat nuorat',
	'(riŋgen nieidda lusa)¥(x,pph|riŋgen niidii)' => 'errorsyn riŋgen nieidda lusa x pph riŋgen niidii',
	'ovtta¥(num,redun| )' => 'errorsyn ovtta num redun  ',
	'dábálaš€(adv,adj,der|dábálaččat)' => 'errorlex dábálaš adv adj der dábálaččat',
	'(Nieiddat leat nourra$(adj,meta|nuorra))£(adj,spred,nompl,nomsg,agr|Nieiddat leat nuorat)' => 'errormorphsyn Nieiddat leat nourra adj spred nompl nomsg agr Nieiddat leat nuorat',
	'(guokte ganddat§(n,á|gánddat))£(n,nump,gensg,nompl,case|guokte gándda)' => 'errormorphsyn guokte ganddat n nump gensg nompl case guokte gándda',
	'(leat (okta máná)£(n,spred,nomsg,gensg,case|okta mánná))£(v,v,sg3prs,pl3prs,agr|lea okta mánná)' => 'errormorphsyn leat okta máná v v sg3prs pl3prs agr lea okta mánná',
);

foreach (sort (keys % question_answer)) {
	my @answer = langTools::Corpus::error_parser($_);
	my $twig = $answer[1];
	
	my @a;
	if ($twig->name eq 'error') {
		@a = ($twig->name, $twig->text, $twig->{'att'}->{'correct'});
	} elsif ($twig->name eq 'errorort') {
		@a = ($twig->name, $twig->text, $twig->{'att'}->{'pos'}, $twig->{'att'}->{'errtype'}, $twig->{'att'}->{'correct'});
	} elsif ($twig->name eq 'errormorphsyn') {
		@a = ($twig->name, $twig->text, $twig->{'att'}->{'pos'}, $twig->{'att'}->{'const'}, $twig->{'att'}->{'cat'}, $twig->{'att'}->{'orig'}, $twig->{'att'}->{'errtype'}, $twig->{'att'}->{'correct'});
	} elsif ($twig->name eq 'errorsyn') {
		@a = ($twig->name, $twig->text, $twig->{'att'}->{'pos'}, $twig->{'att'}->{'errtype'}, $twig->{'att'}->{'correct'});
	} elsif ($twig->name eq 'errorlex') {
		@a = ($twig->name, $twig->text, $twig->{'att'}->{'pos'}, $twig->{'att'}->{'origpos'}, $twig->{'att'}->{'errtype'}, $twig->{'att'}->{'correct'});
	}
	is(join(' ', @a), $question_answer{$_}, "Error markup");
}
