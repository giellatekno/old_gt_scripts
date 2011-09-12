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
	'-typos',
	'-typos -C',
	'-typos -ort',
	'-S',
	'-S -ort -C',
	'-syn',
	'-t',
	'-T',
);

my %files = (
    'list-sme.xml' => {
        "" => "",
        "-l sme" => "",
        "-l nob" => "",
        "-a" => "Ole Henrik Magga, Guovdageaidnu (1989–1997) ¶\nSven-Roald Nystø, Dievtasvuotna/Tysfjord (1997–2005) ¶\n",
        "-T" => "",
        "-L" => "Ole Henrik Magga, Guovdageaidnu (1989–1997) ¶\nSven-Roald Nystø, Dievtasvuotna/Tysfjord (1997–2005) ¶\n",
        "-t" => "",
        "-c" => "",
        "-C" => "",
        "-ort" => "",
        "-ortreal" => "",
        "-morphsyn" => "",
        "-syn" => "",
        "-lex" => "",
        "-typos" => "",
        "-S" => "",
        "-a -S" => "Ole\nHenrik\nMagga,\nGuovdageaidnu\n(1989–1997)\nSven-Roald\nNystø,\nDievtasvuotna/Tysfjord\n(1997–2005)\n",
    },
    'p-sme-errorlex.xml' => {
        "" => "Dánmárkku olgoáššiidministtar Lene Espersen muitalii čoakkáma álggus Dánmárkku árktalaš ráđi ságadoalli áigodaga ulbmiliin. ¶\n",
        "-l sme" => "Dánmárkku olgoáššiidministtar Lene Espersen muitalii čoakkáma álggus Dánmárkku árktalaš ráđi ságadoalli áigodaga ulbmiliin. ¶\n",
        "-l nob" => "",
        "-a" => "Dánmárkku olgoáššiidministtar Lene Espersen muitalii čoakkáma álggus Dánmárkku árktalaš ráđi ságadoalli áigodaga ulbmiliin. ¶\n",
        "-T" => "",
        "-L" => "",
        "-t" => "",
        "-c" => "Dánmárkku olgoriikaministtar Lene Espersen muitalii čoakkáma álggus Dánmárkku árktalaš ráđi ságadoalli áigodaga ulbmiliin. ¶\n",
        "-C" => "Dánmárkku olgoáššiidministtar Lene Espersen muitalii čoakkáma álggus Dánmárkku árktalaš ráđi ságadoalli áigodaga ulbmiliin. ¶\n",
        "-ort" => "Dánmárkku olgoáššiidministtar Lene Espersen muitalii čoakkáma álggus Dánmárkku árktalaš ráđi ságadoalli áigodaga ulbmiliin. ¶\n",
        "-ortreal" => "Dánmárkku olgoáššiidministtar Lene Espersen muitalii čoakkáma álggus Dánmárkku árktalaš ráđi ságadoalli áigodaga ulbmiliin. ¶\n",
        "-morphsyn" => "Dánmárkku olgoáššiidministtar Lene Espersen muitalii čoakkáma álggus Dánmárkku árktalaš ráđi ságadoalli áigodaga ulbmiliin. ¶\n",
        "-syn" => "Dánmárkku olgoáššiidministtar Lene Espersen muitalii čoakkáma álggus Dánmárkku árktalaš ráđi ságadoalli áigodaga ulbmiliin. ¶\n",
        "-lex" => "Dánmárkku olgoriikaministtar Lene Espersen muitalii čoakkáma álggus Dánmárkku árktalaš ráđi ságadoalli áigodaga ulbmiliin. ¶\n",
        "-typos" => "olgoáššiidministtar\tolgoriikaministtar\n",
        "-S" => "Dánmárkku\nolgoáššiidministtar\tolgoriikaministtar\n\nLene\nEspersen\nmuitalii\nčoakkáma\nálggus\nDánmárkku\nárktalaš\nráđi\nságadoalli\náigodaga\nulbmiliin.\n",
        "-a -S" => "Dánmárkku\nolgoáššiidministtar\tolgoriikaministtar\nLene\nEspersen\nmuitalii\nčoakkáma\nálggus\nDánmárkku\nárktalaš\nráđi\nságadoalli\náigodaga\nulbmiliin.\n",
    },
# 'p-sme-errorort.xml',
    'p-sme.xml' => {
        "" => "Ihtin lea ruohttabeaivi. ¶\n",
        "-l sme" => "Ihtin lea ruohttabeaivi. ¶\n",
        "-l nob" => "",
        "-a" => "Ihtin lea ruohttabeaivi. ¶\n",
        "-T" => "",
        "-L" => "",
        "-t" => "",
        "-c" => "Ihtin lea ruohttabeaivi. ¶\n",
        "-C" => "Ihtin lea ruohttabeaivi. ¶\n",
        "-ort" => "Ihtin lea ruohttabeaivi. ¶\n",
        "-ortreal" => "Ihtin lea ruohttabeaivi. ¶\n",
        "-morphsyn" => "Ihtin lea ruohttabeaivi. ¶\n",
        "-syn" => "Ihtin lea ruohttabeaivi. ¶\n",
        "-lex" => "Ihtin lea ruohttabeaivi. ¶\n",
        "-typos" => "",
        "-S" => "Ihtin\nlea\nruohttabeaivi.\n",
        "-a -S" => "Ihtin\nlea\nruohttabeaivi.\n",
    },
# 'p-nob.xml',
# 'p-sme-errormorphsyn.xml',
# 'p-sme-errorsyn.xml',
# 'table.xml',
# 'p-sma-title.xml',
# 'p-sme-errorortreal.xml',
# 'p-sme-error.xml'
);

for my $name (keys %files) {
    for my $option (keys % {$files{$name}}) {
        my $command = "ccat " . $option . " " . $name;
        my $ccat = `$command`;
        is($ccat, $files{$name}{$option}, "testing option «" . $option . "» on file «" . $name . "»");
    }
}
