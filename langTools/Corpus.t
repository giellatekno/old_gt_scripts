use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use Test::Deep;
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
	'jne.$(adv,typo|jna.)' => '<errorort correct="jna." errtype="typo" pos="adv">jne.</errorort>',
	'(šaddai$(verb,conc|šattai) ollu áššit)£(verb,fin,pl3prs,sg3prs,tense|šadde ollu áššit)' => '<errormorphsyn cat="pl3prs" const="fin" correct="šadde ollu áššit" errtype="tense" orig="sg3prs" pos="verb"><errorort correct="šattai" errtype="conc" pos="verb">šaddai</errorort> ollu áššit</errormorphsyn>',
	'daesn\'$daesnie' => '<errorort correct="daesnie">daesn\'</errorort>',
	'1]§Ij' => '<error correct="Ij">1]</error>',
	'væ]keles§(væjkeles)' => '<error correct="væjkeles">væ]keles</error>',
	'smávi-§smávit-' => '<error correct="smávit-">smávi-</error>',
	'CD:t§CD:at' => '<error correct="CD:at">CD:t</error>',
	'DNB-feaskáris§(DnB-feaskáris)' => '<error correct="DnB-feaskáris">DNB-feaskáris</error>',
	'boade§boađe' => '<error correct="boađe">boade</error>',
	'2005’as§2005:s' => '<error correct="2005:s">2005’as</error>',
	'NSRii§NSR:ii' => '<error correct="NSR:ii">NSRii</error>',
	'Nordkjosbotn\'ii§Nordkjosbotnii' => '<error correct="Nordkjosbotnii">Nordkjosbotn\'ii</error>',
	'nourra$(a,meta|nuorra)' => '<errorort correct="nuorra" errtype="meta" pos="a">nourra</errorort>',
	'(Nieiddat leat nuorra)£(a,spred,nompl,nomsg,agr|Nieiddat leat nuorat)' => '<errormorphsyn cat="nompl" const="spred" correct="Nieiddat leat nuorat" errtype="agr" orig="nomsg" pos="a">Nieiddat leat nuorra</errormorphsyn>',
	'(riŋgen nieidda lusa)¥(x,pph|riŋgen niidii)' => '<errorsyn correct="riŋgen niidii" errtype="pph" pos="x">riŋgen nieidda lusa</errorsyn>',
	'ovtta¥(num,redun| )' => '<errorsyn correct=" " errtype="redun" pos="num">ovtta</errorsyn>',
	'dábálaš€(adv,adj,der|dábálaččat)' => '<errorlex correct="dábálaččat" errtype="der" origpos="adj" pos="adv">dábálaš</errorlex>',
	'(Nieiddat leat nourra$(adj,meta|nuorra))£(adj,spred,nompl,nomsg,agr|Nieiddat leat nuorat)' => '<errormorphsyn cat="nompl" const="spred" correct="Nieiddat leat nuorat" errtype="agr" orig="nomsg" pos="adj">Nieiddat leat <errorort correct="nuorra" errtype="meta" pos="adj">nourra</errorort></errormorphsyn>',
	'(guokte ganddat§(n,á|gánddat))£(n,nump,gensg,nompl,case|guokte gándda)' => '<errormorphsyn cat="gensg" const="nump" correct="guokte gándda" errtype="case" orig="nompl" pos="n">guokte <error correct="gánddat">ganddat</error></errormorphsyn>',
	'(leat (okta máná)£(n,spred,nomsg,gensg,case|okta mánná))£(v,v,sg3prs,pl3prs,agr|lea okta mánná)' => '<errormorphsyn cat="sg3prs" const="v" correct="lea okta mánná" errtype="agr" orig="pl3prs" pos="v">leat <errormorphsyn cat="nomsg" const="spred" correct="okta mánná" errtype="case" orig="gensg" pos="n">okta máná</errormorphsyn></errormorphsyn>',
	'ráhččamušaid¢(noun,mix|rahčamušaid)' => '<errorortreal pos="noun" errtype="mix" correct="rahčamušaid">ráhččamušaid</errorortreal>',
);

# Another kind of error:
# This input:
# gitta Nordkjosbotn'ii$Nordkjosbotnii (mii lea ge nordkjosbotn$Nordkjosbotn sámegillii? Muhtin, veahket mu!) gos
# gives this output:
# gitta <errorort correct="Nordkjosbotnii">Nordkjosbotn'ii</errorort>  mii lea ge <errorort correct="Nordkjosbotn">nordkjosbotn</errorort> gos
# should have been:
# gitta <errorort correct="Nordkjosbotnii">Nordkjosbotn'ii</errorort> (mii lea ge <errorort correct="Nordkjosbotn">nordkjosbotn</errorort> sámegillii? Muhtin, veahket mu!) gos

foreach (sort (keys % question_answer)) {
	my @answer = langTools::Corpus::error_parser($_);
	my $twig1 = $answer[1];
	my $twig2 = XML::Twig::Elt->parse($question_answer{$_});
	delete $twig2->{'twig'};
	cmp_deeply($twig1, $twig2, "Error markup");

# 	say Dumper($twig1);
# 	say Dumper($twig2);
}
