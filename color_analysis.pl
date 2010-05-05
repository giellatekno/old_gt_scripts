#!/usr/bin/perl -w
$|=1; # output autoflush 

$lang = $ARGV[0];

sub recase
{
    ($a) = @_;
    $a =~ s/\*(.)/uc($1)/eg;
    return $a;
}

print "<dl>\n";
while (<STDIN>) 
{
    s/^\$\\*//;
    s/^\$START//;
    
    s/&/\&amp;/g;
    s/</\&lt;/g;
    s/>/\&gt;/g;
    
    # word form
    s/^(\"&lt;.+&gt;\")/"<dt><b><font color=\"red\">".recase($1)."<\/font><\/b> "/e;
    
    # base form
    s/^[\t ]+(\"[^\"]+\")/<dd><font color="red">$1<\/font> /;
    
    # morpho-syntax
    if ($lang eq "sme") {
      s/ (N|A|Adv|V|Pron|CS|CC|Adp|Po|Pr|Interj|Pcle|Num|Coll|Prop|Pers|Dem|Interr|Refl|Recipr|Rel|Indef|CLB)( [^\@]*)/ <font color="yellow"><b>$1<\/b>$2<\/font>/ ;
#  Ess|Sg|Du|Pl|Nom|Gen|Acc|Ill|Loc|Com|SgCmp|SgNomCmp|SgGenCmp|PlGenCmp|Cmpnd|Guess|ShCmp
#  First|Last|None|CmpOnly|SgNomLeft|SgGenLeft|PlGenLeft|SgLeft|AllCmp
#  DefSgGenCmp|DefPlGenCmp|DefCmp
#  PxSg1|PxSg2|PxSg3|PxDu1|PxDu2|PxDu3|PxPl1|PxPl2|PxPl3
#  Comp|Superl|Attr|Card|Ord|Ind|Prs|Prt|Pot|Cond|Imprt
#  Sg1|Sg2|Sg3|Du1|Du2|Du3|Pl1|Pl2|Pl3
#  Inf|Ger|ConNeg|ConNegII|Neg|ImprtII|PrsPrc|PrfPrc|Sup|VGen|VAbess
#  Actio|Actor|ABBR|ACR|CLB|PUNCT|LEFT|RIGHT|TV|IV|Multi|G3|Qst|Foc
}
    
    # function
    s/(\@[^ ]+)/<font color="blue">$1<\/font>/g;

    # relation
    s/(\#[^ ]+)/<font color="grey">$1<\/font>/g;

    
    print;
}
print "</dl>\n";
