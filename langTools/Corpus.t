use Test::XML::Twig tests => 25;
use Test::More;
use strict;
use warnings;
use utf8;
use Getopt::Long;

use langTools::Corpus qw(add_error_markup);
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
	'<p>jne.$(adv,typo|jna.)</p>' => '<p><errorort correct="jna." errtype="typo" pos="adv">jne.</errorort></p>',
	'<p>(šaddai$(verb,conc|šattai) ollu áššit)£(verb,fin,pl3prs,sg3prs,tense|šadde ollu áššit)</p>' => '<p><errormorphsyn cat="pl3prs" const="fin" correct="šadde ollu áššit" errtype="tense" orig="sg3prs" pos="verb"><errorort correct="šattai" errtype="conc" pos="verb">šaddai</errorort> ollu áššit</errormorphsyn></p>',
	'<p>daesn\'$daesnie</p>' => '<p><errorort correct="daesnie">daesn\'</errorort></p>',
	'<p>1]§Ij</p>' => '<p><error correct="Ij">1]</error></p>',
	'<p>væ]keles§(væjkeles)</p>' => '<p><error correct="væjkeles">væ]keles</error></p>',
	'<p>smávi-§smávit-</p>' => '<p><error correct="smávit-">smávi-</error></p>',
	'<p>CD:t§CD:at</p>' => '<p><error correct="CD:at">CD:t</error></p>',
	'<p>DNB-feaskáris§(DnB-feaskáris)</p>' => '<p><error correct="DnB-feaskáris">DNB-feaskáris</error></p>',
	'<p>boade§boađe</p>' => '<p><error correct="boađe">boade</error></p>',
	'<p>2005’as§2005:s</p>' => '<p><error correct="2005:s">2005’as</error></p>',
	'<p>NSRii§NSR:ii</p>' => '<p><error correct="NSR:ii">NSRii</error></p>',
	'<p>Nordkjosbotn\'ii§Nordkjosbotnii</p>' => '<p><error correct="Nordkjosbotnii">Nordkjosbotn\'ii</error></p>',
	'<p>nourra$(a,meta|nuorra)</p>' => '<p><errorort correct="nuorra" errtype="meta" pos="a">nourra</errorort></p>',
	'<p>(Nieiddat leat nuorra)£(a,spred,nompl,nomsg,agr|Nieiddat leat nuorat)</p>' => '<p><errormorphsyn cat="nompl" const="spred" correct="Nieiddat leat nuorat" errtype="agr" orig="nomsg" pos="a">Nieiddat leat nuorra</errormorphsyn></p>',
	'<p>(riŋgen nieidda lusa)¥(x,pph|riŋgen niidii)</p>' => '<p><errorsyn correct="riŋgen niidii" errtype="pph" pos="x">riŋgen nieidda lusa</errorsyn></p>',
	'<p>ovtta¥(num,redun| )</p>' => '<p><errorsyn correct=" " errtype="redun" pos="num">ovtta</errorsyn></p>',
	'<p>dábálaš€(adv,adj,der|dábálaččat)</p>' => '<p><errorlex correct="dábálaččat" errtype="der" origpos="adj" pos="adv">dábálaš</errorlex></p>',
	'<p>(Nieiddat leat nourra$(adj,meta|nuorra))£(adj,spred,nompl,nomsg,agr|Nieiddat leat nuorat)</p>' => '<p><errormorphsyn cat="nompl" const="spred" correct="Nieiddat leat nuorat" errtype="agr" orig="nomsg" pos="adj">Nieiddat leat <errorort correct="nuorra" errtype="meta" pos="adj">nourra</errorort></errormorphsyn></p>',
	'<p>(guokte ganddat§(n,á|gánddat))£(n,nump,gensg,nompl,case|guokte gándda)</p>' => '<p><errormorphsyn cat="gensg" const="nump" correct="guokte gándda" errtype="case" orig="nompl" pos="n">guokte <error correct="gánddat">ganddat</error></errormorphsyn></p>',
	'<p>(leat (okta máná)£(n,spred,nomsg,gensg,case|okta mánná))£(v,v,sg3prs,pl3prs,agr|lea okta mánná)</p>' => '<p><errormorphsyn cat="sg3prs" const="v" correct="lea okta mánná" errtype="agr" orig="pl3prs" pos="v">leat <errormorphsyn cat="nomsg" const="spred" correct="okta mánná" errtype="case" orig="gensg" pos="n">okta máná</errormorphsyn></errormorphsyn></p>',
	'<p>ráhččamušaid¢(noun,mix|rahčamušaid)</p>' => '<p><errorortreal pos="noun" errtype="mix" correct="rahčamušaid">ráhččamušaid</errorortreal></p>',
	'<p>gitta Nordkjosbotn\'ii$Nordkjosbotnii (mii lea ge nordkjosbotn$Nordkjosbotn sámegillii? Muhtin, veahket mu!) gos</p>' => '<p>gitta <errorort correct="Nordkjosbotnii">Nordkjosbotn\'ii</errorort> (mii lea ge <errorort correct="Nordkjosbotn">nordkjosbotn</errorort> sámegillii? Muhtin, veahket mu!) gos</p>',
	'<p>(Bearpmahat$(noun,svow|Bearpmehat) earuha€(verb,v,w|sirre))£(verb,fin,pl3prs,sg3prs,agr|Bearpmehat sirrejit) uskki ja loaiddu.</p>' => '<p><errormorphsyn cat="pl3prs" const="fin" correct="Bearpmehat sirrejit" errtype="agr" orig="sg3prs" origpos="v" pos="verb"><errorort correct="Bearpmehat" errtype="svow" pos="noun">Bearpmahat</errorort> earuha</errormorphsyn> uskki ja loaiddu.</p>',
);


foreach (sort (keys % question_answer)) {
	test_twig_handler(
		\&add_error_markup,
		$_,
		$question_answer{$_},
		"Error markup");
}
