#!/usr/bin/perl -w
use utf8;

while (<>)
{


s/Ã¡/á/g ;

s/=C3=81/Á/g ;
s/=C3=A1/á/g ;
s/=C4=8C/Č/g ;
s/=C4=8D/č/g ;


# LATIN 1


s/=C0/À/g ;
s/=C1/Á/g ;
s/=C2/Â/g ;
s/=C3/Ã/g ;
s/=C4/Ä/g ;
s/=C5/Å/g ;
s/=C6/Æ/g ;
s/=C7/Ç/g ;
s/=C8/È/g ;
s/=C9/É/g ;
s/=CA/Ê/g ;
s/=CB/Ë/g ;
s/=CC/Ì/g ;
s/=CD/Í/g ;
s/=CE/Î/g ;
s/=CF/Ï/g ;

s/=D0/E/g ;
s/=D1/Ñ/g ;
s/=D2/Ò/g ;
s/=D3/Ó/g ;
s/=D4/Ô/g ;
s/=D5/Õ/g ;
s/=D6/Ö/g ;
s/=D8/Ø/g ;
s/=D9/Ù/g ;
s/=DA/Ú/g ;
s/=DB/Û/g ;
s/=DC/Ü/g ;
s/=DD/Ý/g ;
s/=DE/T/g ;
s/=DF/ß/g ;

s/=E0/à/g ;
s/=E1/á/g ;
s/=E2/â/g ;
s/=E3/ã/g ;
s/=E4/ä/g ;
s/=E5/å/g ;
s/=E6/æ/g ;
s/=E7/ç/g ;
s/=E8/è/g ;
s/=E9/é/g ;
s/=EA/ê/g ;
s/=EB/ë/g ;
s/=EC/ì/g ;
s/=ED/í/g ;
s/=EE/î/g ;
s/=EF/ï/g ;

s/=F0/E/g ;
s/=F1/ñ/g ;
s/=F2/ò/g ;
s/=F3/ó/g ;
s/=F4/ô/g ;
s/=F5/õ/g ;
s/=F6/ö/g ;
s/=F8/ø/g ;
s/=F9/ù/g ;
s/=FA/ú/g ;
s/=FB/û/g ;
s/=FC/ü/g ;
s/=FD/ý/g ;
s/=FE/T/g ;
s/=FF/ÿ/g ;



s/%C3%81/Á/g ;
s/%C3%A1/á/g ;
s/%C4%8C/Č/g ;
s/%C4%8D/č/g ;
s/%C4%90/Đ/g ;
s/%C4%91/đ/g ;
s/%C5%8A/Ŋ/g ;
s/%C5%8B/ŋ/g ;
s/%C5%A0/Š/g ;
s/%C5%A1/š/g ;
s/%C5%A6/Ŧ/g ;
s/%C5%A7/ŧ/g ;
s/%C5%8D/Ž/g ;
s/%C5%8E/ž/g ;
s/%C3%86/Æ/g ;
s/%C3%98/Ø/g ;
s/%C3%85/Å/g ;
s/%C3%96/Ö/g ;
s/%C3%84/Ä/g ;
s/%C3%A6/æ/g ;
s/%C3%88/ø/g ;
s/%C3%A5/å/g ;
s/%C3%86/ö/g ;
s/%C3%A4/ä/g ;
s/%C3%90/Ð/g ;
s/%C3%80/ð/g ;


# post-editing





print ;
}
