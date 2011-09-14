use Test::More 'no_plan';
use Test::Exception;
use Test::File;
use utf8;
use strict;
use Getopt::Long;
use warnings;

my %files = (
    'list-sme.xml' => {
        "" => "",
        "-l sme" => "",
        "-l nob" => "",
        "-a" => "Ole Henrik Magga, Guovdageaidnu (1989–1997) ¶\nSven-Roald Nystø, Dievtasvuotna/Tysfjord (1997–2005) ¶\n",
        "-T" => "",
        "-T -l sma" => "",
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
        "-typos -C" => "",
        "-typos -ort" => "",
        "-typos -ort -C" => "",
        "-typos -ortreal" => "",
        "-typos -morphsyn" => "",
        "-typos -syn" => "",
        "-typos -lex" => "",
        "-S" => "",
        "-S -C" => "",
        "-S -ort" => "",
        "-S -ort -C" => "",
        "-S -ortreal" => "",
        "-S -morphsyn" => "",
        "-S -syn" => "",
        "-S -lex" => "",
        "-a -S" => "Ole\nHenrik\nMagga,\nGuovdageaidnu\n(1989–1997)\nSven-Roald\nNystø,\nDievtasvuotna/Tysfjord\n(1997–2005)\n",
    },
    'p-sme-errorlex.xml' => {
        "" => "Dánmárkku olgoáššiidministtar Lene Espersen muitalii čoakkáma álggus Dánmárkku árktalaš ráđi ságadoalli áigodaga ulbmiliin. ¶\n",
        "-l sme" => "Dánmárkku olgoáššiidministtar Lene Espersen muitalii čoakkáma álggus Dánmárkku árktalaš ráđi ságadoalli áigodaga ulbmiliin. ¶\n",
        "-l nob" => "",
        "-a" => "Dánmárkku olgoáššiidministtar Lene Espersen muitalii čoakkáma álggus Dánmárkku árktalaš ráđi ságadoalli áigodaga ulbmiliin. ¶\n",
        "-T" => "",
        "-T -l sma" => "",
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
        "-typos -C" => "",
        "-typos -ort" => "",
        "-typos -ort -C" => "",
        "-typos -ortreal" => "",
        "-typos -morphsyn" => "",
        "-typos -syn" => "",
        "-typos -lex" => "olgoáššiidministtar\tolgoriikaministtar\n",
        "-S" => "Dánmárkku\nolgoáššiidministtar\tolgoriikaministtar\nLene\nEspersen\nmuitalii\nčoakkáma\nálggus\nDánmárkku\nárktalaš\nráđi\nságadoalli\náigodaga\nulbmiliin.\n",
        "-S -C" => "Dánmárkku\nolgoáššiidministtar\nLene\nEspersen\nmuitalii\nčoakkáma\nálggus\nDánmárkku\nárktalaš\nráđi\nságadoalli\náigodaga\nulbmiliin.\n",
        "-S -ort" => "Dánmárkku\nolgoáššiidministtar\nLene\nEspersen\nmuitalii\nčoakkáma\nálggus\nDánmárkku\nárktalaš\nráđi\nságadoalli\náigodaga\nulbmiliin.\n",
        "-S -ort -C" => "Dánmárkku\nolgoáššiidministtar\nLene\nEspersen\nmuitalii\nčoakkáma\nálggus\nDánmárkku\nárktalaš\nráđi\nságadoalli\náigodaga\nulbmiliin.\n",
        "-S -ortreal" => "Dánmárkku\nolgoáššiidministtar\nLene\nEspersen\nmuitalii\nčoakkáma\nálggus\nDánmárkku\nárktalaš\nráđi\nságadoalli\náigodaga\nulbmiliin.\n",
        "-S -morphsyn" => "Dánmárkku\nolgoáššiidministtar\nLene\nEspersen\nmuitalii\nčoakkáma\nálggus\nDánmárkku\nárktalaš\nráđi\nságadoalli\náigodaga\nulbmiliin.\n",
        "-S -syn" => "Dánmárkku\nolgoáššiidministtar\nLene\nEspersen\nmuitalii\nčoakkáma\nálggus\nDánmárkku\nárktalaš\nráđi\nságadoalli\náigodaga\nulbmiliin.\n",
        "-S -lex" => "Dánmárkku\nolgoáššiidministtar\tolgoriikaministtar\nLene\nEspersen\nmuitalii\nčoakkáma\nálggus\nDánmárkku\nárktalaš\nráđi\nságadoalli\náigodaga\nulbmiliin.\n",
        "-a -S" => "Dánmárkku\nolgoáššiidministtar\tolgoriikaministtar\nLene\nEspersen\nmuitalii\nčoakkáma\nálggus\nDánmárkku\nárktalaš\nráđi\nságadoalli\náigodaga\nulbmiliin.\n",
    },
    'p-sme-errorort.xml' => {
        "" => "sohkabealli mearreduvvo árbbi mielde. ¶\n",
        "-l sme" => "sohkabealli mearreduvvo árbbi mielde. ¶\n",
        "-l nob" => "",
        "-a" => "sohkabealli mearreduvvo árbbi mielde. ¶\n",
        "-T" => "",
        "-T -l sma" => "",
        "-L" => "",
        "-t" => "",
        "-c" => "sohkabealli mearriduvvo árbbi mielde. ¶\n",
        "-C" => "sohkabealli mearreduvvo árbbi mielde. ¶\n",
        "-ort" => "sohkabealli mearriduvvo árbbi mielde. ¶\n",
        "-ortreal" => "sohkabealli mearreduvvo árbbi mielde. ¶\n",
        "-morphsyn" => "sohkabealli mearreduvvo árbbi mielde. ¶\n",
        "-syn" => "sohkabealli mearreduvvo árbbi mielde. ¶\n",
        "-lex" => "sohkabealli mearreduvvo árbbi mielde. ¶\n",
        "-typos" => "mearreduvvo\tmearriduvvo\t#errtype=soggi,pos=verb\n",
        "-typos -C" => "",
        "-typos -ort" => "mearreduvvo\tmearriduvvo\t#errtype=soggi,pos=verb\n",
        "-typos -ort -C" => "mearreduvvo\tmearriduvvo\t#errtype=soggi,pos=verb\n",
        "-typos -ortreal" => "",
        "-typos -morphsyn" => "",
        "-typos -syn" => "",
        "-typos -lex" => "",
        "-S" => "sohkabealli\nmearreduvvo\tmearriduvvo\t#errtype=soggi,pos=verb\nárbbi\nmielde.\n",
        "-S -C" => "sohkabealli\nmearreduvvo\nárbbi\nmielde.\n",
        "-S -ort" => "sohkabealli\nmearreduvvo\tmearriduvvo\t#errtype=soggi,pos=verb\nárbbi\nmielde.\n",
        "-S -ort -C" => "sohkabealli\nmearreduvvo\tmearriduvvo\t#errtype=soggi,pos=verb\nárbbi\nmielde.\n",
        "-S -ortreal" => "sohkabealli\nmearreduvvo\nárbbi\nmielde.\n",
        "-S -morphsyn" => "sohkabealli\nmearreduvvo\nárbbi\nmielde.\n",
        "-S -syn" => "sohkabealli\nmearreduvvo\nárbbi\nmielde.\n",
        "-S -lex" => "sohkabealli\nmearreduvvo\nárbbi\nmielde.\n",
        "-a -S" => "sohkabealli\nmearreduvvo\tmearriduvvo\t#errtype=soggi,pos=verb\nárbbi\nmielde.\n",
    },
    'p-sme.xml' => {
        "" => "Ihtin lea ruohttabeaivi. ¶\n",
        "-l sme" => "Ihtin lea ruohttabeaivi. ¶\n",
        "-l nob" => "",
        "-a" => "Ihtin lea ruohttabeaivi. ¶\n",
        "-T" => "",
        "-T -l sma" => "",
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
        "-typos -C" => "",
        "-typos -ort" => "",
        "-typos -ort -C" => "",
        "-typos -ortreal" => "",
        "-typos -morphsyn" => "",
        "-typos -syn" => "",
        "-typos -lex" => "",
        "-S" => "Ihtin\nlea\nruohttabeaivi.\n",
        "-S -C" => "Ihtin\nlea\nruohttabeaivi.\n",
        "-S -ort" => "Ihtin\nlea\nruohttabeaivi.\n",
        "-S -ort -C" => "Ihtin\nlea\nruohttabeaivi.\n",
        "-S -ortreal" => "Ihtin\nlea\nruohttabeaivi.\n",
        "-S -morphsyn" => "Ihtin\nlea\nruohttabeaivi.\n",
        "-S -syn" => "Ihtin\nlea\nruohttabeaivi.\n",
        "-S -lex" => "Ihtin\nlea\nruohttabeaivi.\n",
        "-a -S" => "Ihtin\nlea\nruohttabeaivi.\n",
    },
    'p-sme-errormorphsyn.xml' => {
        "" => "nu ahte varrásat leat x0-tiippa . ¶\n",
        "-l sme" => "nu ahte varrásat leat x0-tiippa . ¶\n",
        "-l nob" => "",
        "-a" => "nu ahte varrásat leat x0-tiippa . ¶\n",
        "-T" => "",
        "-T -l sma" => "",
        "-L" => "",
        "-t" => "",
        "-c" => "nu ahte varrásat leat x0-tiippat . ¶\n",
        "-C" => "nu ahte varrásat leat x0-tiippa . ¶\n",
        "-ort" => "nu ahte varrásat leat x0-tiippa . ¶\n",
        "-ortreal" => "nu ahte varrásat leat x0-tiippa . ¶\n",
        "-morphsyn" => "nu ahte varrásat leat x0-tiippat . ¶\n",
        "-syn" => "nu ahte varrásat leat x0-tiippa . ¶\n",
        "-lex" => "nu ahte varrásat leat x0-tiippa . ¶\n",
        "-typos" => "varrásat leat x0-tiippa\tvarrásat leat x0-tiippat\t#cat=nomsg,const=spred,errtype=num,orig=nompl,pos=noun\n",
        "-typos -C" => "",
        "-typos -ort" => "",
        "-typos -ort -C" => "",
        "-typos -ortreal" => "",
        "-typos -morphsyn" => "varrásat leat x0-tiippa\tvarrásat leat x0-tiippat\t#cat=nomsg,const=spred,errtype=num,orig=nompl,pos=noun\n",
        "-typos -syn" => "",
        "-typos -lex" => "",
        "-S" => "nu\nahte\nvarrásat leat x0-tiippa\tvarrásat leat x0-tiippat\t#cat=nomsg,const=spred,errtype=num,orig=nompl,pos=noun\n.\n",
        "-S -C" => "nu\nahte\nvarrásat leat x0-tiippa\n.\n",
        "-S -ort" => "nu\nahte\nvarrásat leat x0-tiippa\n.\n",
        "-S -ort -C" => "nu\nahte\nvarrásat leat x0-tiippa\n.\n",
        "-S -ortreal" => "nu\nahte\nvarrásat leat x0-tiippa\n.\n",
        "-S -morphsyn" => "nu\nahte\nvarrásat leat x0-tiippa\tvarrásat leat x0-tiippat\t#cat=nomsg,const=spred,errtype=num,orig=nompl,pos=noun\n.\n",
        "-S -syn" => "nu\nahte\nvarrásat leat x0-tiippa\n.\n",
        "-S -lex" => "nu\nahte\nvarrásat leat x0-tiippa\n.\n",
        "-a -S" => "nu\nahte\nvarrásat leat x0-tiippa\tvarrásat leat x0-tiippat\t#cat=nomsg,const=spred,errtype=num,orig=nompl,pos=noun\n.\n",
    },
    'p-sme-errorsyn.xml' => {
        "" => "Sivilisašuvdna definerejuvvo dávjá dan vuođul ahte movt dat meannuda iežas geahnohepmosiid. ¶\n",
        "-l sme" => "Sivilisašuvdna definerejuvvo dávjá dan vuođul ahte movt dat meannuda iežas geahnohepmosiid. ¶\n",
        "-l nob" => "",
        "-a" => "Sivilisašuvdna definerejuvvo dávjá dan vuođul ahte movt dat meannuda iežas geahnohepmosiid. ¶\n",
        "-T" => "",
        "-T -l sma" => "",
        "-L" => "",
        "-t" => "",
        "-c" => "Sivilisašuvdna definerejuvvo dávjá dan vuođul   movt dat meannuda iežas geahnohepmosiid. ¶\n",
        "-C" => "Sivilisašuvdna definerejuvvo dávjá dan vuođul ahte movt dat meannuda iežas geahnohepmosiid. ¶\n",
        "-ort" => "Sivilisašuvdna definerejuvvo dávjá dan vuođul ahte movt dat meannuda iežas geahnohepmosiid. ¶\n",
        "-ortreal" => "Sivilisašuvdna definerejuvvo dávjá dan vuođul ahte movt dat meannuda iežas geahnohepmosiid. ¶\n",
        "-morphsyn" => "Sivilisašuvdna definerejuvvo dávjá dan vuođul ahte movt dat meannuda iežas geahnohepmosiid. ¶\n",
        "-syn" => "Sivilisašuvdna definerejuvvo dávjá dan vuođul   movt dat meannuda iežas geahnohepmosiid. ¶\n",
        "-lex" => "Sivilisašuvdna definerejuvvo dávjá dan vuođul ahte movt dat meannuda iežas geahnohepmosiid. ¶\n",
        "-typos" => "ahte\t \t#errtype=redun,pos=cs\n",
        "-typos -C" => "",
        "-typos -ort" => "",
        "-typos -ort -C" => "",
        "-typos -ortreal" => "",
        "-typos -morphsyn" => "",
        "-typos -syn" => "ahte\t \t#errtype=redun,pos=cs\n",
        "-typos -lex" => "",
        "-S" => "Sivilisašuvdna\ndefinerejuvvo\ndávjá\ndan\nvuođul\nahte\t \t#errtype=redun,pos=cs\nmovt\ndat\nmeannuda\niežas\ngeahnohepmosiid.\n",
        "-S -C" => "Sivilisašuvdna\ndefinerejuvvo\ndávjá\ndan\nvuođul\nahte\nmovt\ndat\nmeannuda\niežas\ngeahnohepmosiid.\n",
        "-S -ort" => "Sivilisašuvdna\ndefinerejuvvo\ndávjá\ndan\nvuođul\nahte\nmovt\ndat\nmeannuda\niežas\ngeahnohepmosiid.\n",
        "-S -ort -C" => "Sivilisašuvdna\ndefinerejuvvo\ndávjá\ndan\nvuođul\nahte\nmovt\ndat\nmeannuda\niežas\ngeahnohepmosiid.\n",
        "-S -ortreal" => "Sivilisašuvdna\ndefinerejuvvo\ndávjá\ndan\nvuođul\nahte\nmovt\ndat\nmeannuda\niežas\ngeahnohepmosiid.\n",
        "-S -morphsyn" => "Sivilisašuvdna\ndefinerejuvvo\ndávjá\ndan\nvuođul\nahte\nmovt\ndat\nmeannuda\niežas\ngeahnohepmosiid.\n",
        "-S -syn" => "Sivilisašuvdna\ndefinerejuvvo\ndávjá\ndan\nvuođul\nahte\t \t#errtype=redun,pos=cs\nmovt\ndat\nmeannuda\niežas\ngeahnohepmosiid.\n",
        "-S -lex" => "Sivilisašuvdna\ndefinerejuvvo\ndávjá\ndan\nvuođul\nahte\nmovt\ndat\nmeannuda\niežas\ngeahnohepmosiid.\n",
        "-a -S" => "Sivilisašuvdna\ndefinerejuvvo\ndávjá\ndan\nvuođul\nahte\t \t#errtype=redun,pos=cs\nmovt\ndat\nmeannuda\niežas\ngeahnohepmosiid.\n",
    },
# 'table.xml',
    'p-sme-errorortreal.xml' => {
        "" => "begynner å borre noen ¶\nJus dat leačča duohta de eat leat beare guhkás joavdan. ¶\n",
        "-l sme" => "begynner å borre noen ¶\nJus dat leačča duohta de eat leat beare guhkás joavdan. ¶\n",
        "-l nob" => "",
        "-a" => "begynner å borre noen ¶\nJus dat leačča duohta de eat leat beare guhkás joavdan. ¶\n",
        "-T" => "",
        "-T -l sma" => "",
        "-L" => "",
        "-t" => "",
        "-c" => "begynner å bore noen ¶\nJus dat leačča duohta de eat leat beare guhkas joavdan. ¶\n",
        "-C" => "begynner å borre noen ¶\nJus dat leačča duohta de eat leat beare guhkás joavdan. ¶\n",
        "-ort" => "begynner å bore noen ¶\nJus dat leačča duohta de eat leat beare guhkás joavdan. ¶\n",
        "-ortreal" => "begynner å borre noen ¶\nJus dat leačča duohta de eat leat beare guhkas joavdan. ¶\n",
        "-morphsyn" => "begynner å borre noen ¶\nJus dat leačča duohta de eat leat beare guhkás joavdan. ¶\n",
        "-syn" => "begynner å borre noen ¶\nJus dat leačča duohta de eat leat beare guhkás joavdan. ¶\n",
        "-lex" => "begynner å borre noen ¶\nJus dat leačča duohta de eat leat beare guhkás joavdan. ¶\n",
        "-typos" => "å borre\tå bore\t#errtype=onec,pos=verb\nguhkás\tguhkas\t#errtype=á,pos=adv\n",
        "-typos -C" => "",
        "-typos -ort" => "å borre\tå bore\t#errtype=onec,pos=verb\n",
        "-typos -ort -C" => "å borre\tå bore\t#errtype=onec,pos=verb\n",
        "-typos -ortreal" => "guhkás\tguhkas\t#errtype=á,pos=adv\n",
        "-typos -morphsyn" => "",
        "-typos -syn" => "",
        "-typos -lex" => "",
        "-S" => "begynner\nå borre\tå bore\t#errtype=onec,pos=verb\nnoen\nJus\ndat\nleačča\nduohta\nde\neat\nleat\nbeare\nguhkás\tguhkas\t#errtype=á,pos=adv\njoavdan.\n",
        "-S -C" => "begynner\nå borre\nnoen\nJus\ndat\nleačča\nduohta\nde\neat\nleat\nbeare\nguhkás\njoavdan.\n",
        "-S -ort" => "begynner\nå borre\tå bore\t#errtype=onec,pos=verb\nnoen\nJus\ndat\nleačča\nduohta\nde\neat\nleat\nbeare\nguhkás\njoavdan.\n",
        "-S -ort -C" => "begynner\nå borre\tå bore\t#errtype=onec,pos=verb\nnoen\nJus\ndat\nleačča\nduohta\nde\neat\nleat\nbeare\nguhkás\njoavdan.\n",
        "-S -ortreal" => "begynner\nå borre\nnoen\nJus\ndat\nleačča\nduohta\nde\neat\nleat\nbeare\nguhkás\tguhkas\t#errtype=á,pos=adv\njoavdan.\n",
        "-S -morphsyn" => "begynner\nå borre\nnoen\nJus\ndat\nleačča\nduohta\nde\neat\nleat\nbeare\nguhkás\njoavdan.\n",
        "-S -syn" => "begynner\nå borre\nnoen\nJus\ndat\nleačča\nduohta\nde\neat\nleat\nbeare\nguhkás\njoavdan.\n",
        "-S -lex" => "begynner\nå borre\nnoen\nJus\ndat\nleačča\nduohta\nde\neat\nleat\nbeare\nguhkás\njoavdan.\n",
        "-a -S" => "begynner\nå borre\tå bore\t#errtype=onec,pos=verb\nnoen\nJus\ndat\nleačča\nduohta\nde\neat\nleat\nbeare\nguhkás\tguhkas\t#errtype=á,pos=adv\njoavdan.\n",
    },
    'p-sme-error.xml' => {
        "" => "MáRKANSLUSKA ¶\n",
        "-l sme" => "MáRKANSLUSKA ¶\n",
        "-l nob" => "",
        "-a" => "MáRKANSLUSKA ¶\n",
        "-T" => "",
        "-T -l sma" => "",
        "-L" => "",
        "-t" => "",
        "-c" => "MÁRKANSLUSKA ¶\n",
        "-C" => "MÁRKANSLUSKA ¶\n",
        "-ort" => "MáRKANSLUSKA ¶\n",
        "-ortreal" => "MáRKANSLUSKA ¶\n",
        "-morphsyn" => "MáRKANSLUSKA ¶\n",
        "-syn" => "MáRKANSLUSKA ¶\n",
        "-lex" => "MáRKANSLUSKA ¶\n",
        "-typos" => "MáRKANSLUSKA\tMÁRKANSLUSKA\n",
        "-typos -C" => "MáRKANSLUSKA\tMÁRKANSLUSKA\n",
        "-typos -ort" => "",
        "-typos -ort -C" => "MáRKANSLUSKA\tMÁRKANSLUSKA\n",
        "-typos -ortreal" => "",
        "-typos -morphsyn" => "",
        "-typos -syn" => "",
        "-typos -lex" => "",
        "-S" => "MáRKANSLUSKA\tMÁRKANSLUSKA\n",
        "-S -C" => "MáRKANSLUSKA\tMÁRKANSLUSKA\n",
        "-S -ort" => "MáRKANSLUSKA\n",
        "-S -ort -C" => "MáRKANSLUSKA\tMÁRKANSLUSKA\n",
        "-S -ortreal" => "MáRKANSLUSKA\n",
        "-S -morphsyn" => "MáRKANSLUSKA\n",
        "-S -syn" => "MáRKANSLUSKA\n",
        "-S -lex" => "MáRKANSLUSKA\n",
        "-a -S" => "MáRKANSLUSKA\tMÁRKANSLUSKA\n",
    },
    'p-nob.xml' => {
        "" => "",
        "-l sme" => "",
        "-l nob" => "TINGRIK OG TIDFATTIG..? ¶\n",
        "-a" => "",
        "-T" => "",
        "-T -l sma" => "",
        "-L" => "",
        "-t" => "",
        "-c" => "",
        "-C" => "",
        "-ort" => "",
        "-ortreal" => "",
        "-morphsyn" => "",
        "-syn" => "",
        "-lex" => "",
        "-typos" => "",
        "-typos -C" => "",
        "-typos -ort" => "",
        "-typos -ort -C" => "",
        "-typos -ortreal" => "",
        "-typos -morphsyn" => "",
        "-typos -syn" => "",
        "-typos -lex" => "",
        "-S" => "",
        "-S -C" => "",
        "-S -ort" => "",
        "-S -ort -C" => "",
        "-S -ortreal" => "",
        "-S -morphsyn" => "",
        "-S -syn" => "",
        "-S -lex" => "",
        "-a -S" => "",
    },
    'p-sma-title.xml' => {
        "" => "",
        "-l sme" => "",
        "-l nob" => "",
        "-a" => "",
        "-T" => "",
        "-T -l sma" => "1. MAADTHVUAJNOE JÏH VISJOVNH 5 ¶\n",
        "-L" => "",
        "-t" => "",
        "-c" => "",
        "-C" => "",
        "-ort" => "",
        "-ortreal" => "",
        "-morphsyn" => "",
        "-syn" => "",
        "-lex" => "",
        "-typos" => "",
        "-typos -C" => "",
        "-typos -ort" => "",
        "-typos -ort -C" => "",
        "-typos -ortreal" => "",
        "-typos -morphsyn" => "",
        "-typos -syn" => "",
        "-typos -lex" => "",
        "-S" => "",
        "-S -C" => "",
        "-S -ort" => "",
        "-S -ort -C" => "",
        "-S -ortreal" => "",
        "-S -morphsyn" => "",
        "-S -syn" => "",
        "-S -lex" => "",
        "-a -S" => "",
    },
);

if (!system('make')) {
    for my $name (keys %files) {
        for my $option (keys % {$files{$name}}) {
            my $command = "./ccat " . $option . " " . $name;
            my $ccat = `$command`;
            is($ccat, $files{$name}{$option}, "testing option «" . $option . "» on file «" . $name . "»");
        }
        print "\n\n";
    }
} else {
    print "Can't compile ccat\n";
}
