#!/usr/bin/perl -w

# 7bit-utf8.pl
# The input is transformed from internal Latin 1 digraph Sami to utf8.
# $Id$


while (<>) 
{


# First half of Col C
# This set has to be first, because some of the characters 
# occur in the next set 
# (� = \304 etc. to avoid substituting them twise.) 
s/�/\303\203/g ;
s/�/\303\200/g ;
s/�/\303\201/g ;    
s/�/\303\202/g ;
s/�/\303\204/g ;
s/�/\303\205/g ;
s/�/\303\206/g ;
#s/C/\303\207/g ;


# The S�mi digraphs

s/C1/\304\214/g ;
s/c1/\304\215/g ;
s/D1/\304\220/g ;
s/d1/\304\221/g ;
s/N1/\305\212/g ;
s/n1/\305\213/g ;
s/S1/\305\240/g ;
s/s1/\305\241/g ;
s/T1/\305\246/g ;
s/t1/\305\247/g ;
s/Z1/\305\275/g ;
s/z1/\305\276/g ;


# Column A

s/\240/\302\240/g ;   # xA0
s/�/\302\241/g ;      # xA1
s/�/\302\242/g ;      # xA2
s/�/\302\243/g ;      # xA3
s/\244/\302\244/g ;   # xA4
s/�/\302\245/g ;      # xA5
s/\246/\302\246/g ;   # xA6
s/�/\302\247/g ;      # xA7

s/�/\302\250/g ;      # xA8
s/�/\302\251/g ;      # xA9
s/\252/\302\252/g ;      # xAA
s/\253/\302\253/g ;      # xAB
s/\254/\302\254/g ;      # xAC
s/\255/\302\255/g ;      # xAD
s/\256/\302\256/g ;      # xAE
s/\257/\302\257/g ;      # xAF

# Column B

s/\260/\302\260/g ;      # xB0
s/\261/\302\261/g ;      # xB1
s/\262/\302\262/g ;      # xB2
s/\263/\302\263/g ;      # xB3
s/\264/\302\264/g ;      # xB4
s/\265/\302\265/g ;      # xB5
s/\266/\302\266/g ;      # xB6
s/\267/\302\267/g ;      # xB7

s/\270/\302\270/g ;      # xB8
s/\271/\302\271/g ;      # xB9
s/\272/\302\272/g ;      # xBA
s/\273/\302\273/g ;      # xBB
s/\274/\302\274/g ;      # xBC
s/\275/\302\275/g ;      # xBD
s/\276/\302\276/g ;      # xBE
s/\277/\302\277/g ;      # xBF


# Second half of Col C

s/�/\303\210/g ;
s/�/\303\211/g ;
s/�/\303\212/g ;
s/�/\303\213/g ;
s/�/\303\214/g ;
s/�/\303\215/g ;
s/�/\303\216/g ;
s/�/\303\217/g ;


# Col D

s/�/\303\220/g ;
s/�/\303\221/g ;
s/�/\303\222/g ;
s/�/\303\223/g ;
s/�/\303\224/g ;
s/�/\303\225/g ;
s/�/\303\226/g ;
#s/x/\303\227/g ;

s/�/\303\230/g ;
s/�/\303\231/g ;
s/�/\303\232/g ;
s/�/\303\233/g ;
s/�/\303\234/g ;
s/�/\303\235/g ;
s/�/\303\236/g ;
s/�/\303\237/g ;


# Col E

s/�/\303\240/g ;
s/�/\303\241/g ;
s/�/\303\242/g ;
s/�/\303\243/g ;
s/�/\303\244/g ;
s/�/\303\245/g ;
s/�/\303\246/g ;
#s/c/\303\247/g ;

s/�/\303\250/g ;
s/�/\303\251/g ;
s/�/\303\252/g ;
s/�/\303\253/g ;
s/�/\303\254/g ;
s/�/\303\255/g ;
s/�/\303\256/g ;
s/�/\303\257/g ;

# Col F

s/�/\303\260/g ;
s/�/\303\261/g ;
s/�/\303\262/g ;
s/�/\303\263/g ;
s/�/\303\264/g ;
s/�/\303\265/g ;
s/�/\303\266/g ;
s/-/\303\267/g ;

s/�/\303\270/g ;
s/�/\303\271/g ;
s/�/\303\272/g ;
s/�/\303\273/g ;
s/�/\303\274/g ;
s/�/\303\275/g ;
s/�/\303\276/g ;
s/�/\303\277/g ;

# Miscellanious cp 1252 (?) conversion
# These

s/--/�\200\223/g ; # Input is m-dash, I render by two hyphens.
s/\'/�\200\231/g ; # Single quotation marks
s/�/�\200\234/g ;  # These quotation marks had the symbol �
s/�/�\200\235/g ;  # preceeding them in a certain text.

s/�/\200\234/g ;
s/�/\200\235/g ;

print ;
}
