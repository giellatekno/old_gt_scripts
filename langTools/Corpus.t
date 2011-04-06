use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use strict;
use warnings;
use Cwd;
use Encode;
use utf8;
use Getopt::Long;

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

my $document  = XML::Twig->new(twig_handlers => { p => sub { add_error_markup(@_); } });
$document->parse('<document><p type="text">— Sámit dat galggasedje§galggašedje duoddara badjel mearridit. Dan
  goittot oaivvildit buot boazosámit. Nu čielgasit vástideigga Mikkel
  Per Persen Sara ja bárdni Mikkel Isak Sára Áisaroaivvis gažaldahkii
  geain galggasii§galggašii leat vuoigatvuohta Finnmarkku§Finnmárkku
  duoddariidda, sámi álbmogis vai Norgga stáhtas.</p></document>');
$document->set_pretty_print('indented');
$document->print;

# $document  = XML::Twig->new(twig_handlers => { p => sub { add_error_markup(@_); } });
$document->parse('<document><p type="text">— Sámit dat galggasedje §galggašedje duoddara badjel mearridit. Dan
  goittot oaivvildit buot boazosámit. Nu čielgasit vástideigga Mikkel
  Per Persen Sara ja bárdni Mikkel Isak Sára Áisaroaivvis gažaldahkii
  geain galggasii§galggašii leat vuoigatvuohta Finnmarkku§Finnmárkku
  duoddariidda, sámi álbmogis vai Norgga stáhtas.</p></document>');
$document->set_pretty_print('indented');
$document->print;

# $document  = XML::Twig->new(twig_handlers => { p => sub { add_error_markup(@_); } });
$document->parse('<document><p type="text">— Sámit dat galggasedje§ galggašedje duoddara badjel mearridit. Dan
  goittot oaivvildit buot boazosámit. Nu čielgasit vástideigga Mikkel
  Per Persen Sara ja bárdni Mikkel Isak Sára Áisaroaivvis gažaldahkii
  geain galggasii§galggašii leat vuoigatvuohta Finnmarkku§Finnmárkku
  duoddariidda, sámi álbmogis vai Norgga stáhtas.</p></document>');
$document->set_pretty_print('indented');
$document->print;
  
# $document  = XML::Twig->new(twig_handlers => { p => sub { add_error_markup(@_); } });
$document->parse('<document><p type="text">— Sámit dat galggasedje § galggašedje duoddara badjel mearridit. Dan
  goittot oaivvildit buot boazosámit. Nu čielgasit vástideigga Mikkel
  Per Persen Sara ja bárdni Mikkel Isak Sára Áisaroaivvis gažaldahkii
  geain galggasii§galggašii leat vuoigatvuohta Finnmarkku§Finnmárkku
  duoddariidda, sámi álbmogis vai Norgga stáhtas.</p></document>');
$document->set_pretty_print('indented');
$document->print;

# $document  = XML::Twig->new(twig_handlers => { p => sub { add_error_markup(@_); } });
$document->parse('<document><p type="text">— Sámit dat galggasedje § galggašedje duoddara badjel mearridit. Dan
  goittot oaivvildit buot boazosámit. Nu čielgasit vástideigga Mikkel
  Per Persen Sara ja bárdni Mikkel Isak Sára Áisaroaivvis gažaldahkii
  geain galggasii§galggašii leat vuoigatvuohta Finnmarkku §Finnmárkku
  duoddariidda, sámi álbmogis vai Norgga stáhtas.</p></document>');
$document->set_pretty_print('indented');
$document->print;

# $document  = XML::Twig->new(twig_handlers => { p => sub { add_error_markup(@_); } });
$document->parse('<p>Dego máŋgga iežá suohkaniin ge unnu Gáivuona suohkana olmmošlohku. Eastadandihte$(n,cmp|Eastadan dihte) dan, lea suohkan mearridan plánastis deattuhit barggu ovdanahttiimiin$(v,mix|ovdánahttimiin), ealáhusovdanemiin$(n,á|ealáhusovdánemiin), nuoraiguin ja birasgáhttemiin. Dasa lassin bargá suohkan dan ala ahte (ovdanit$(v,á|ovdánit))€(v,v,der|ovdánahttit) iežas fálaldaga kvalitehta. Suohkan bargá maid regionála dásis, ea.ea. nuoraidprošeavttain.
</p>');
$document->set_pretty_print('indented');
$document->print;

$document->parse('<p>Riddu Riđđu Festivála lea sápmelaš kulturfestivála ja riikkaidgaskasaš álgoálbmotfestivála ja dat lea (álggahuvvon 1991)£(num,advl,locsg,nomsg,case|álggahuvvon 1991:s). Riddu Riđđu lea šaddan oktan (daid njunuš kulturlágidemiin)£(dem,attr,locpl,genpl,agr|dain njunuš kulturlágidemiin) Davvi-Kalohtas$(prop,cmp|Davvikalohtas). Dat lea riikkaidgaskasaš dáhpáhus; deaddu lea máilmmi davviguovlluid kultuvrras. Festivála čájeha dovdduseamos$(adj,mix|dovdoseamos) sámi ártisttaid$(n,a|artisttaid) ja álggahalli sámi ártisttaid$(n,a|artisttaid) sihke ártisttaid$(n,a|artisttaid) Davvi-Kalohtas(prop,cmp|Davvikalohtas), Sibiris$(prop,mix|Sibirjjás), Ruonáeatnamis, Kanadas ja eará riikkain.
Boahtte festivála teman$(n,á|temán) lea árktalaš guovlluid rituáladánsun. Mii áigut maid čájehit kultuvrraid guovtte$(num,svow|guovtti) álbmogis, mat leat eret Nuorta-Sibiris$(prop,mix|Nuorta-Sibirjjás). Dan lassin leat dieđusge konsearttat, čájáhusat, mánáid festivála, seminárat ja kurssat.
Festivála lágiduvvo mearrasápmelaš guovllus, Olmmáivákkis, Gáivuonas.
</p>');
$document->set_pretty_print('indented');
$document->print;

$document->parse('<p type="text">Valáštallansearvvi Nordlys jođiheaddji
      Peder Birkely Kárášjogas lea garrasit suhttan go ohpit leat
      gaikon ja bilidan searvvi kioskkaid. – Dát nuorra skealmmat orrot
      bilideamin§bilideamen dušše bilideami dihte, lohká eddon
      Birkely.</p>');
$document->set_pretty_print('indented');
$document->print;

$document->parse('<p type="text"> , ja berre fátmmastit fágadidaktihka
ja hárjehallanoahpu. Studeanta galgá maiddái sáhttit duođaštit sámegielat gelbbolašvuođa
fágas.
Sámi oahpaheaddjeoahpu studeanttat, geat váldet dárogielas 30 oahppočuoggá,
friddjejuvvojit nuppis dáin guovtti dárogiela suopmana geahččaleamis. Sii geat váldet 60
oahppočuoggá dárogiela, eai friddjejuvvo dákkár geahččaleamis.
Lávdegotti árvvoštallan
Lávdegoddi lea evttohan ovdalis namuhuvvon friddjenmearrádusaid almma dárkilut
čilgemiin.
Departemeantta árvvoštallan
Departemeanta imaštallá friddjema gáržžideami nuppi dáin dárogiela suopmaniin, ja
árvvoštallá našunála láhkaásahusa addit viidát vejolašvuođaid. Allaskuvllas lea almmatge
vejolašvuohta ráhkadit báikkálaš mearrádusaid. Departemeanta lea dattege ovttamielalaš sámi
rámmaplánalávdegottiin das, ahte friddjema eaktun galgá leat duođaštuvvon sámegielalaš
gelbbolašvuohta. Departemeantta evttohus boahtá ovdán láhkaásahusevttohusa
mielddusteavsttas.
§ 6 FÁPMUIBOAHTIN JA GASKABODDOSAŠ NJUOLGGADUSAT</p>');
$document->set_pretty_print('indented');
$document->print;

$document->parse('<p type="text"> §22.5.1 3. Beavdegirji sápmelaččaid birra</p>');
$document->set_pretty_print('indented');
$document->print;

$document->parse('<p type="text">• Jakov Semjonovits Jakovlev, Málet guokte stuorra historjjás muitaleaddji gova: 1000 €</p>');
$document->set_pretty_print('indented');
$document->print;
$document->parse('<p type="text">Tabeallas oainnát mo moadde bustáva leat unicodas.
mearka logilohkokoda
$
36
a
97
z
122
š
246
ž
248
Č
268
č
269
Đ
272
ŋ
331
ž
382
Я
831
€
8449
</p>');
$document->set_pretty_print('indented');
$document->print;

