#!/usr/bin/perl -w

while (<>) 
{
s/- //g; # a sharp
s/&nbsp\;//g;
print ;
}
