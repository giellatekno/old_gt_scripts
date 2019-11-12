#!/usr/bin/perl -w
use utf8;

while (<>)
{


s/Ã¡/á/g ;

s/=C3=81/Á/g ;
s/=C3=A1/á/g ;
s/=C4=8C/Č/g ;
s/=C4=8D/č/g ;


# LATIN 1 as =XX values


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

# Latin 1 as UTF-8 read as Latin 1

s/%C2%A0/ /g ;
s/%C2%A1/¡/g ;
s/%C2%A2/¢/g ;
s/%C2%A3/£/g ;
s/%C2%A4/¤/g ;
s/%C2%A5/\\/g ;
s/%C2%A6/¦/g ;
s/%C2%A7/§/g ;
s/%C2%A8/¨/g ;
s/%C2%A9/©/g ;
s/%C2%AA/ª/g ;
s/%C2%AB/«/g ;
s/%C2%AC/¬/g ;
s/%C2%AD/­/g ;
s/%C2%AE/®/g ;
s/%C2%AF/¯/g ;

s/%C2%B0/°/g ;
s/%C2%B1/±/g ;
s/%C2%B2/²/g ;
s/%C2%B3/³/g ;
s/%C2%B4/´/g ;
s/%C2%B5/µ/g ;
s/%C2%B6/¶/g ;
s/%C2%B7/·/g ;
s/%C2%B8/¸/g ;
s/%C2%B9/¹/g ;
s/%C2%BA/º/g ;
s/%C2%BB/»/g ;
s/%C2%BC/¼/g ;
s/%C2%BD/½/g ;
s/%C2%BE/¾/g ;
s/%C2%BF/¿/g ;

s/%C3%80/À/g ;
s/%C3%81/Á/g ;
s/%C3%82/Â/g ;
s/%C3%83/Ã/g ;
s/%C3%84/Ä/g ;
s/%C3%85/Å/g ;
s/%C3%86/Æ/g ;
s/%C3%87/Ç/g ;
s/%C3%88/Ø/g ;
s/%C3%89/Ù/g ;
s/%C3%8A/Ê/g ;
s/%C3%8B/Ë/g ;
s/%C3%8C/Ì/g ;
s/%C3%8D/Í/g ;
s/%C3%8E/Î/g ;
s/%C3%8F/Ï/g ;

s/%C3%90/Đ/g ;
s/%C3%91/Ñ/g ;
s/%C3%92/Ò/g ;
s/%C3%93/Ó/g ;
s/%C3%94/Ô/g ;
s/%C3%95/Õ/g ;
s/%C3%96/Õ/g ;
s/%C3%97/×/g ;
s/%C3%98/Ø/g ;
s/%C3%99/Ù/g ;
s/%C3%9A/Ú/g ;
s/%C3%9B/Û/g ;
s/%C3%9C/Ü/g ;
s/%C3%9D/Ý/g ;
s/%C3%9E/Þ/g ;
s/%C3%9F/ß/g ;

s/%C3%A0/à/g ;
s/%C3%A1/á/g ;
s/%C3%A2/â/g ;
s/%C3%A3/ã/g ;
s/%C3%A4/ä/g ;
s/%C3%A5/å/g ;
s/%C3%A6/æ/g ;
s/%C3%A7/ç/g ;
s/%C3%A8/è/g ;
s/%C3%A9/é/g ;
s/%C3%AA/ê/g ;
s/%C3%AB/ë/g ;
s/%C3%AC/ì/g ;
s/%C3%AD/í/g ;
s/%C3%AE/î/g ;
s/%C3%AF/ï/g ;

s/%C3%B0/ð/g ;
s/%C3%B1/ñ/g ;
s/%C3%B2/ò/g ;
s/%C3%B3/ó/g ;
s/%C3%B4/ô/g ;
s/%C3%B5/õ/g ;
s/%C3%B6/ö/g ;
s/%C3%B7/÷/g ;
s/%C3%B8/ø/g ;
s/%C3%B9/ù/g ;
s/%C3%BA/ú/g ;
s/%C3%BB/û/g ;
s/%C3%BC/ü/g ;
s/%C3%BD/ý/g ;
s/%C3%BE/þ/g ;
s/%C3%BF/ï/g ;

# The North Saami letters of Latin A, as UTF-8 read as Latin 1

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
s/%C5%BD/Ž/g ;
s/%C5%BE/ž/g ;

# space
s/%20/ /g ;
# post-editing


print ;
}
