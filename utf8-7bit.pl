#!/usr/bin/perl -w
# Converting text from MS .doc files to internal format

while (<>) 
{
# convert encoded text-saved text from staroffice
# the input files to star office are unicode-encoded ms-files.
# The files are transformet to internal Latin 1 digraph Sami.


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

s/\303\200/�/g ;
s/\303\201/�/g ;    
s/\303\202/�/g ;
s/\303\203/�/g ;
s/\303\204/�/g ;
s/\303\205/�/g ;
s/\303\206/�/g ;
s/\303\207/C/g ;

s/\303\210/�/g ;
s/\303\211/�/g ;
s/\303\212/�/g ;
s/\303\213/�/g ;
s/\303\214/�/g ;
s/\303\215/�/g ;
s/\303\216/�/g ;
s/\303\217/�/g ;

s/\303\220/�/g ;
s/\303\221/�/g ;
s/\303\222/�/g ;
s/\303\223/�/g ;
s/\303\224/�/g ;
s/\303\225/�/g ;
s/\303\226/�/g ;
s/\303\227/x/g ;

s/\303\230/�/g ;
s/\303\231/�/g ;
s/\303\232/�/g ;
s/\303\233/�/g ;
s/\303\234/�/g ;
s/\303\235/�/g ;
s/\303\236/�/g ;
s/\303\237/�/g ;

s/\303\240/�/g ;
s/\303\241/�/g ;
s/\303\242/�/g ;
s/\303\243/�/g ;
s/\303\244/�/g ;
s/\303\245/�/g ;
s/\303\246/�/g ;
s/\303\247/c/g ;

s/\303\250/�/g ;
s/\303\251/�/g ;
s/\303\252/�/g ;
s/\303\253/�/g ;
s/\303\254/�/g ;
s/\303\255/�/g ;
s/\303\256/�/g ;
s/\303\257/�/g ;

s/\303\260/�/g ;
s/\303\261/�/g ;
s/\303\262/�/g ;
s/\303\263/�/g ;
s/\303\264/�/g ;
s/\303\265/�/g ;
s/\303\266/�/g ;
s/\303\267/-/g ;

s/\303\270/�/g ;
s/\303\271/�/g ;
s/\303\272/�/g ;
s/\303\273/�/g ;
s/\303\274/�/g ;
s/\303\275/�/g ;
s/\303\276/�/g ;
s/\303\277/�/g ;

s/�\200\223/--/g ; # Input is m-dash, I render by two hyphens.
s/�\200\231/\'/g ; # Single quotation marks
s/�\200\234/�/g ;  # These quotation marks had the symbol �
s/�\200\235/�/g ;  # preceeding them in a certain text.

s/\200\234/�/g ;
s/\200\235/�/g ;

s/§/�/g ;         # paragraph

# removing litter
s/\377//g ;

print ;
}
