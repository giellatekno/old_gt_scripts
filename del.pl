#!/usr/bin/perl -w

while (<>) 
{
s/- //g; # a sharp
s/&nbsp\;//g;
s/\x0c//g;
s/\xC3\xAC//g;
s/\xC3\xAE//g;
s/\xC2\xA9//g;
s/\342\200\242//g;
print ;
}
