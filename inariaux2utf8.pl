#!/usr/bin/perl -w

# 7bit-utf8.pl
# The input is transformed from internal Latin 1 digraph Sami to utf8.
# It only takes the gang of six.
# $Id$


while (<>) 
{


# The Sámi digraphs

s/ç/č/g ;
s/ð/đ/g ;
s/§/ž/g ;
s/Ç/Č/g ;
s/ñ/ŋ/g ;
s/æ/â/g ;
s/Ð/Đ/g ; # icel to sami
s/Ö/õ/g ;

print ;
}
