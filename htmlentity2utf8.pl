#!/usr/bin/perl -w

use utf8;
# use UTF-8 ;

while (<>)

{
#s//š/g ;
#s//ž/g ;
s/\&\#225;/á/g ;
s/\&\#269;/č/g ;
s/\&\#273;/đ/g ;
s/\&\#331;/ŋ/g ;
s/\&\#353;/š/g ;
s/\&\#359;/ŧ/g ;
s/\&\#382;/ž/g ;
s/\&\#193;/Á/g ;
s/\&\#268;/Č/g ;
s/\&\#272;/Đ/g ;
s/\&\#330;/Ŋ/g ;
s/\&\#352;/Š/g ;
s/\&\#358;/Ŧ/g ;
s/\&\#381;/Ž/g ;
s/\&\#0225;/á/g ;
s/\&\#0269;/č/g ;
s/\&\#0273;/đ/g ;
s/\&\#0331;/ŋ/g ;
s/\&\#0353;/š/g ;
s/\&\#0359;/ŧ/g ;
s/\&\#0382;/ž/g ;
s/\&\#0193;/Á/g ;
s/\&\#0268;/Č/g ;
s/\&\#0272;/Đ/g ;
s/\&\#0330;/Ŋ/g ;
s/\&\#0352;/Š/g ;
s/\&\#0358;/Ŧ/g ;
s/\&\#0381;/Ž/g ;

s/\&Aacute;/Á/g ;
s/\&Acirc;/Â/g ;
s/\&Agrave;/À/g ;
s/\&Aring;/Å/g ;
s/\&Auml;/Ä/g ;
s/\&AElig;/Æ/g ;
s/\&Ccedil;/Ç/g ;
s/\&Iacute;/Ì/g ;
s/\&Oslash;/Ø/g ;
s/\&Otilde;/Õ/g ;
s/\&Ouml;/Ö/g ;
s/\&Scaron;/Š/g ;
s/\&Umacr;//g ;
s/\&Uuml;/Ü/g ;
s/\&Zcaron;/Ž/g ;
s/\&aacute;/á/g ;
s/\&acirc;//g ;
s/\&aelig;/æ/g ;
s/\&agr;/α/g ;
s/\&agrave;/à/g ;
s/\&amp;/\&/g ;
s/\&ap;/≈/g ;
s/\&aring;/å/g ;
s/\&auml;/ä/g ;
s/\&bgr;/β/g ;
s/\&ccedil;/ç/g ;
s/\&deg;/°/g ;
s/\&eacute;/é/g ;
s/\&ggr;/γ/g ;
s/\&gt;/>/g ;
s/\&icirc;/î/g ;
s/\&ldquo;/«/g ; # note! this is a bug
s/\&laquo;/«/g ; # here ldquo and laquo are identical. Fix!
s/\&lsquo;/‹/g ;
s/\&lstrok;/ł/g ;
s/\&mdash;/—/g ;
s/\&middot;/•/g ;
s/\&oacute;/ó/g ;
s/\&oslash;/ø/g ;
s/\&otilde;/õ/g ;
s/\&ouml;/ö/g ;
s/\&plusmn;/±/g ;
s/\&rdquo;/”/g ;
s/\&raquo;/»/g ;
s/\&rsquo;/’/g ;
s/\&scaron;/š/g ;
s/\&sect;/§/g ;
s/\&sup2;/²/g ;
s/\&sup3;/³/g ;
s/\&times;/×/g ;
s/\&ucirc;/û/g ;
s/\&umacr;/ū/g ;
s/\&uuml;/ü/g ;
s/\&yacute;/ý/g ;
s/\&zcaron;/š/g ;
s/\&ndash;/–/g ;
s/\&mdash;/—/g ;
s/\&quot;/"/g ;


print ;

}
