#!/usr/bin/perl -w

use utf8;
# use UTF-8 ;

while (<>)

{
s/Á/\&Aacute;/g;
s/Â/\&Acirc;/g;
s/À/\&Agrave;/g;
s/Å/\&Aring;/g;
s/Ä/\&Auml;/g;
s/Æ/\&AElig;/g;
s/Ç/\&Ccedil;/g;
s/Ì/\&Iacute;/g;
s/Ø/\&Oslash;/g;
s/Õ/\&Otilde;/g;
s/Ö/\&Ouml;/g;
s/Š/\&Scaron;/g;
s/Ü/\&Uuml;/g;
s/Ž/\&Zcaron;/g;
s/á/\&aacute;/g;
s/æ/\&aelig;/g;
s/α/\&agr;/g;
s/à/\&agrave;/g;
s/≈/\&ap;/g;
s/å/\&aring;/g;
s/ä/\&auml;/g;
s/β/\&bgr;/g;
s/ç/\&ccedil;/g;
s/°/\&deg;/g;
s/é/\&eacute;/g;
s/γ/\&ggr;/g;
s/î/\&icirc;/g;
s/«/\&ldquo;/g;
s/«/\&laquo;/g;
s/‹/\&lsquo;/g;
s/ł/\&lstrok;/g;
s/—/\&mdash;/g;
s/•/\&middot;/g;
s/ó/\&oacute;/g;
s/ø/\&oslash;/g;
s/õ/\&otilde;/g;
s/ö/\&ouml;/g;
s/±/\&plusmn;/g;
s/”/\&rdquo;/g;
s/»/\&raquo;/g;
s/’/\&rsquo;/g;
s/š/\&scaron;/g;
s/§/\&sect;/g;
s/²/\&sup2;/g;
s/³/\&sup3;/g;
s/×/\&times;/g;
s/û/\&ucirc;/g;
s/ū/\&umacr;/g;
s/ü/\&uuml;/g;
s/ý/\&yacute;/g;
s/š/\&zcaron;/g;
s/–/\&ndash;/g;
s/—/\&mdash;/g;

print ;

}
