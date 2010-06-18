#!/usr/bin/perl -w
$|=1; # output autoflush 

$lang = $ARGV[0];

while (<STDIN>) 
{
    # word form
    s/^([^\s]+)([\t ]+)([^\+]+)(.+)$/<font color="red">$1<\/font>$2<font color="maroon">$3<\/font>$4/; 
    if ($lang eq "sme") {
      s/ (N|A|Adv|V|Pron|CS|CC|Adp|Po|Pr|Interj|Pcle|Num|Coll|Prop|Pers|Dem|Interr|Refl|Recipr|Rel|Indef|CLB)( [^\@]*)/ <font color="black"><b>$1<\/b>$2<\/font>/ ;


    s/(\+)/<font color="grey">$1<\/font>/g; 
  }
    print;
}
