#!/usr/bin/perl -w

while (<>) 
{
# convert the 7 sami letters encoded as
# utf-8

s/\xC3\xA1/\xE1/g; # a sharp
s/\xC5\xA1/s1/g;   # s caron
s/\xC5\xA7/t1/g;   # t stroke
s/\xC5\x8B/n1/g;   # eng
s/\xC4\x91/d1/g;   # d stroke
s/\xC5\xBE/z1/g;   # z caron
s/\xC4\x8D/c1/g;   # c caron
s/\xC3\x81/\xE1/g;# A sharp
s/\xC5\xA0/s1/g; # S caron
s/\xC5\xA6/t1/g; # T stroke
s/\xC5\x80/n1/g; # ENG
s/\xC4\x90/d1/g; # D stroke
s/\xC5\xBD/z1/g; # Z caron
s/\xC4\x8C/c1/g; # C caron

# convert the 7 sami letters
# written on win9x, converted
# to utf-8

s/\xC2\xB7/\xE1/g; #a sharp
s/\xC2\xA1/\xE1/g; #A sharp
s/\xC3\xB6/s1/g; #s1
s/\xC3\xA4/s1/g; #S1
s/\xC3\x87/c1/g; #C1
s/\xC3\xB8/z1/g; #z1
s/\xC2\xBA/t1/g; #t1
s/\xC3\xB2/d1/g; #d1
s/\xC3\x91/c1/g; #c1
# convert the 7 sami letters
# written on mac, converted
# to utf-8

s/\xC3\xA1/\xE1/g; # a sharp
s/\xC2\xA2\x45/c1/g ;
s/\xE2\x88\x8F/c1/g ;
s/\xE2\x88\x9E/d1/g ;
s/\xCF\x80/d1/g ;
s/\261/N1/g ;
s/\xE2\x88\xAB/n1/g ;
s/\xC2\xA5/s1/g ;
s/\xC2\xAA/s1/g ;
s/\xC2\xB5/T1/g ;
s/\xC2\xBA/t1/g ;
s/\267/Z1/g ;
s/\xCE\xA9/z1/g ;


print ;
}
