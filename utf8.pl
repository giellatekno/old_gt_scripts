#!/usr/bin/perl -w

while (<>) 
{
# convert the 7 sami letters

s/\303\241/\xE1;/g; # a sharp
s/\305\241/s1/g;   # s caron
s/\305\247/t1/g;   # t stroke
s/\305\213/n1/g;   # eng
s/\304\221/d1/g;   # d stroke
s/\305\276/z1/g;   # z caron
s/\304\215/c1/g;   # c caron
s/\303\201/\xE1/g;# A sharp
s/\305\240/s1/g; # S caron
s/\305\246/t1/g; # T stroke
s/\305\212/n1/g; # ENG
s/\304\220/d1/g; # D stroke
s/\305\275/z1/g; # Z caron
s/\304\214/c1/g; # C caron

print ;
}
