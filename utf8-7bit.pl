#!/usr/bin/perl -w
# Converting text from MS .doc files to internal format

# note that the newest versions of MS Word save as UTF-16.
# This script can thus only be used for files saved with
# StarOffice, OpenOffice or NeoOffice. Word files should be opened in
# any of these three, and then saved as "Text Encoded", and run through
# this script.

while (<>) 
{
# convert encoded text-saved text from staroffice
# the input files to star office are unicode-encoded ms-files.
# The files are transformet to internal Latin 1 digraph Sami.

# Here comes the digraphs, the UTF-8 values of the 
# Sámi letters.

s/\304\214/C1/g ;
s/\304\215/c1/g ;
s/\304\220/D1/g ;
s/\304\221/d1/g ;
s/\305\212/N1/g ;
s/\305\213/n1/g ;
s/\305\240/S1/g ;
s/\305\241/s1/g ;
s/\305\246/T1/g ;
s/\305\247/t1/g ;
s/\305\275/Z1/g ;
s/\305\276/z1/g ;

# Here, we convert the UTF-8 values of the right-hand side of Latin 1
# into Latin 1.

# Column 8 and 9 
# The entries here are strange, probably due to broken
# 1252 input, we let them stay until proven harmful.

s/â\200\223/--/g ; # Input is m-dash, I render by two hyphens.
s/â\200\231/\'/g ; # Single quotation marks
s/â\200\234/«/g ;  # These quotation marks had the symbol â
s/â\200\235/»/g ;  # preceeding them in a certain text.

s/\200\234/«/g ;
s/\200\235/»/g ;

# Column A

s/\302\240/\240/g ;   # xA0
s/\302\241/¡/g ;      # xA1
s/\302\242/¢/g ;      # xA2
s/\302\243/£/g ;      # xA3
s/\302\244/\244/g ;   # xA4
s/\302\245/¥/g ;      # xA5
s/\302\246/\246/g ;   # xA6
s/\302\247/§/g ;      # xA7

s/\302\250/¨/g ;      # xA8
s/\302\251/©/g ;      # xA9
s/\302\252/\252/g ;      # xAA
s/\302\253/\253/g ;      # xAB
s/\302\254/\254/g ;      # xAC
s/\302\255/\255/g ;      # xAD
s/\302\256/\256/g ;      # xAE
s/\302\257/\257/g ;      # xAF

# Column B

s/\302\260/\260/g ;      # xB0
s/\302\261/\261/g ;      # xB1
s/\302\262/\262/g ;      # xB2
s/\302\263/\263/g ;      # xB3
s/\302\264/\264/g ;      # xB4
s/\302\265/\265/g ;      # xB5
s/\302\266/\266/g ;      # xB6
s/\302\267/\267/g ;      # xB7

s/\302\270/\270/g ;      # xB8
s/\302\271/\271/g ;      # xB9
s/\302\272/\272/g ;      # xBA
s/\302\273/\273/g ;      # xBB
s/\302\274/\274/g ;      # xBC
s/\302\275/\275/g ;      # xBD
s/\302\276/\276/g ;      # xBE
s/\302\277/\277/g ;      # xBF

# Column C

s/\303\200/À/g ;
s/\303\201/Á/g ;    
s/\303\202/Â/g ;
s/\303\203/Ã/g ;
s/\303\204/Ä/g ;
s/\303\205/Å/g ;
s/\303\206/Æ/g ;
s/\303\207/C/g ;

s/\303\210/È/g ;
s/\303\211/É/g ;
s/\303\212/Ê/g ;
s/\303\213/Ë/g ;
s/\303\214/Ì/g ;
s/\303\215/Í/g ;
s/\303\216/Î/g ;
s/\303\217/Ï/g ;

s/\303\220/Ð/g ;
s/\303\221/Ñ/g ;
s/\303\222/Ò/g ;
s/\303\223/Ó/g ;
s/\303\224/Ô/g ;
s/\303\225/Õ/g ;
s/\303\226/Ö/g ;
s/\303\227/x/g ;

s/\303\230/Ø/g ;
s/\303\231/Ù/g ;
s/\303\232/Ú/g ;
s/\303\233/Û/g ;
s/\303\234/Ü/g ;
s/\303\235/Ý/g ;
s/\303\236/Þ/g ;
s/\303\237/ß/g ;

# Column E

s/\303\240/à/g ;
s/\303\241/á/g ;
s/\303\242/â/g ;
s/\303\243/ã/g ;
s/\303\244/ä/g ;
s/\303\245/å/g ;
s/\303\246/æ/g ;
s/\303\247/c/g ;

s/\303\250/è/g ;
s/\303\251/é/g ;
s/\303\252/ê/g ;
s/\303\253/ë/g ;
s/\303\254/ì/g ;
s/\303\255/í/g ;
s/\303\256/î/g ;
s/\303\257/ï/g ;

# Column F

s/\303\260/ð/g ;
s/\303\261/ñ/g ;
s/\303\262/ò/g ;
s/\303\263/ó/g ;
s/\303\264/ô/g ;
s/\303\265/õ/g ;
s/\303\266/ö/g ;
s/\303\267/-/g ;

s/\303\270/ø/g ;
s/\303\271/ù/g ;
s/\303\272/ú/g ;
s/\303\273/û/g ;
s/\303\274/ü/g ;
s/\303\275/ý/g ;
s/\303\276/þ/g ;
s/\303\277/ÿ/g ;


# removing litter
s/\377//g ;

print ;
}
