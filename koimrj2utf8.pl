#!/usr/bin/perl -w

use utf8;

while (<>) 
{

s/à/а/g ;
s/á/б/g ;
s/â/в/g ;
s/ä/д/g ;
s/å/е/g ;
s/ô/ф/g ;
s/ã/г/g ;
#s/_/х/g ;
s/è/и/g ;
s/é/й/g ;
s/ê/к/g ;
s/ë/л/g ;
s/ì/м/g ;
s/í/н/g ;
#s/_/ҥ/g ;
s/î/о/g ;
s/º/ӧ/g ;
s/ï/п/g ;
s/ð/р/g ;
s/ñ/с/g ;
s/ò/т/g ;
s/ó/у/g ;
s/û/ы/g ;
s/õ/х/g ;
s/ø/ш/g ;
s/ù/щ/g ;
s/÷/ч/g ;
s/ý/э/g ;
s/¢/ӱ/g ;
s/³/ӓ/g ;
s/¿/ӹ/g ;
#s/_/ъ/g ;
s/ü/ь/g ;
s/ÿ/я/g ;
s/ç/з/g ;
s/æ/ж/g ;
s/þ/ю/g ;
s/ö/ц/g ;


s/À/A/g ;
s/Á/б/g ;
s/Â/В/g ;
s/Ä/Д/g ;
s/Å/Е/g ;
s/Ô/Ф/g ;
s/Ã/Г/g ;
#s/_/Х/g ;
s/È/И/g ;
s/É/Й/g ;
s/Ê/К/g ;
s/Ë/Л/g ;
s/Ì/М/g ;
s/Í/Н/g ;
s/Î/О/g ;
s/Ï/П/g ;
s/Ð/Р/g ;
s/Ñ/С/g ;
s/Ò/Т/g ;
s/Ó/У/g ;
s/Û/Ы/g ;
s/Õ/Х/g ;
s/Ø/Ш/g ;
s/Ù/Щ/g ;
s/×/Ч/g ;
s/Ý/Э/g ;
#s/_/Ҥ/g ;
#s/_/Ӧ/g ;
#s/_/Ӱ/g ;
#s/_/Ъ/g ;
s/Ü/Ь/g ;
#s/_/Ӓ/g ;
s/¯/Ӹ/g ;
s/Ÿ/Я/g ;
s/Ç/З/g ;
s/Æ/Ж/g ;
s/Þ/Ю/g ;
s/Ö/Ц/g ;

s/¹/№/g ;

print ;
}