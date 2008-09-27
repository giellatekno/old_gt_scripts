#!/usr/bin/perl -w

# 7bit-utf8.pl
# The input is transformed from internal Latin 1 digraph Sami to utf8.
# It only takes the gang of six.
# $Id$


while (<>) 
{


# The Sámi digraphs

s/C1/Č/g ;
s/c1/č/g ;
s/D1/Đ/g ;
s/d1/đ/g ;
s/N1/Ŋ/g ;
s/n1/ŋ/g ;
s/S1/Š/g ;
s/s1/š/g ;
s/T1/Ŧ/g ;
s/t1/ŧ/g ;
s/Z1/Ž/g ;
s/z1/ž/g ;

print ;
}
