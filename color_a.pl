#!/usr/bin/perl -w
$|=1; # output autoflush 

while (<STDIN>) 
{
    # no analysis
    if (/[^ \s]+\+\?$/) {
       s/^([^\s]+)([\t ]+)([^\+ \s]+)(\s+)(\+)(\?)$/<font color="red">$1<\/font>$2<font color="maroon">$3<\/font>$4<font color="grey">$5<\/font><font color="black"><b>$6<\/b><\/font>/; 
    } else {
    # analysis 
       s/^([^\s]+)([\t ]+)([^\+]+)(\+)([^\+]+)(.*)$/<font color="red">$1<\/font>$2<font color="maroon">$3<\/font>$4<font color="black"><b>$5<\/b><\/font>$6/;
       s/(\+)/<font color="grey">$1<\/font>/g;
    }
    print;
}
