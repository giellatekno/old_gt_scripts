#!/usr/bin/perl -w

# 7bit-utf8.pl
# The input is transformed from internal Latin 1 digraph Sami to utf8.
# It only takes the gang of six.
# $Id$


while (<>) 
{


# The Sámi digraphs

s/‚/Č/g ; #Le
s/„/č/g ; #Le
s/‰/Đ/g ; #Le
s/\˜/đ/g ;#Le
s/¿/ž/g ; #Le
s/¹/ŋ/g ; #Le
        
s/ç/č/g ; #WS
s/Ç/Č/g ; #WS
s/Ð/Đ/g ; #WS
s/ð/đ/g ; #WS
s/Ó/Š/g ; #WS
s/ó/š/g ; #WS
s/þ/ž/g ; #WS
s/ñ/ŋ/g ; #WS
s/Ñ/Ŋ/g ; #WS
s/´Y/Ŧ/g ; #WS
s/ý/ŧ/g ; #WS
        
        
s/¡/Č/g ; #197
s/¢/č/g ;
s/£/Đ/g ;
s/¤/đ/g ;
s/¯/Ŋ/g ;
s/±/ŋ/g ;
s/²/Š/g ;
s/³/š/g ;
s/µ/Ŧ/g ;
s/¸/ŧ/g ;
s/¹/Ž/g ; 
s/º/ž/g ;

print ;
}
