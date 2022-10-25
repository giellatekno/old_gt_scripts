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

# Capital

s/\&\#x00E1;/á/g ;
s/\&\#x010D;/č/g ;
s/\&\#x0111;/đ/g ;
s/\&\#x014B;/ŋ/g ;
s/\&\#x0161;/š/g ;
s/\&\#x0167;/ŧ/g ;
s/\&\#x017E;/ž/g ;
s/\&\#x00E6;/æ/g ;
s/\&\#x00F8;/ø/g ;
s/\&\#x00E5;/å/g ;

s/\&\#x00C1;/Á/g ;
s/\&\#x010C;/Č/g ;
s/\&\#x0110;/Đ/g ;
s/\&\#x014A;/Ŋ/g ;
s/\&\#x0160;/Š/g ;
s/\&\#x0166;/Ŧ/g ;
s/\&\#x017D;/Ž/g ;
s/\&\#x00C6;/Æ/g ;
s/\&\#x00D8;/Ø/g ;
s/\&\#x00C5;/Å/g ;


s/\&\#x00AB;/«/g ;
s/\&\#x00BB;/»/g ;

s/\&\#x2013;/–/g ;
s/\&\#x0027;/'/g ;
s/\&\#x00C4;/Ä/g ;
s/\&\#x00E4;/ä/g ;
s/\&\#x00D6;/Ö/g ;
s/\&\#x00F6;/ö/g ;
s/\&\#x00C9;/É/g ;
s/\&\#x00E9;/é/g ;

s/\&\#x007E;/~/g ;

# small hex number

s/\\u00e1/á/g ;
s/\\u010d/č/g ;
s/\\u0111/đ/g ;
s/\\u014b/ŋ/g ;
s/\\u0161/š/g ;
s/\\u0167/ŧ/g ;
s/\\u017e/ž/g ;
s/\\u00e6/æ/g ;
s/\\u00f8/ø/g ;
s/\\u00e5/å/g ;

s/\\u00c1/Á/g ;
s/\\u010c/Č/g ;
s/\\u0110/Đ/g ;
s/\\u014a/Ŋ/g ;
s/\\u0160/Š/g ;
s/\\u0166/Ŧ/g ;
s/\\u017d/Ž/g ;
s/\\u00c6/Æ/g ;
s/\\u00d8/Ø/g ;
s/\\u00c5/Å/g ;


s/\\u00ab/«/g ;
s/\\u00bb/»/g ;

s/\\u2013/–/g ;
s/\\u0027/'/g ;
s/\\u00c4/Ä/g ;
s/\\u00e4/ä/g ;
s/\\u00d6/Ö/g ;
s/\\u00f6/ö/g ;
s/\\u00c9/É/g ;
s/\\u00e9/é/g ;

s/\\u007e/~/g ;

# html entity

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
