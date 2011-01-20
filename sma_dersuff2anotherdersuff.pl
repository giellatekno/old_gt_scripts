#!/usr/bin/perl -w

# Bruk:
# 1. lag ei liste over -anidh-verb, og lagre som verb.txt
# skriv
# cat verb.txt | perl  sma_dersuff2anotherdersuff.pl | less

use utf8;

while (<>) 
{

# first the suffix
s/anidh/IEhtIdh/g ; 

# s/anidh/EdIdh/g ;

# s/något//g ; # något till inget

# then the umlaut

# B - A for iehtidh
s/ea/IE/g ; 
s/aa/AE/g ; 
s/åa/ÅE/g ; 
s/ua/UE/g ; 
s/æ/I/g ; 
s/a/E/g ; 
s/å/U/g ; 

# B - F for edidh

# s/ea/EE/g ; 
# s/aa/EE/g ; 
# s/åa/ÅE/g ; # osv…
# s/ua/UE/g ; 
# s/æ/I/g ; 
# s/a/E/g ; 
# s/å/U/g ; 

# then downcase
tr/[A-ZÆØÅ]/[a-zæøå]/;


print ;
}
