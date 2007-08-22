#!/usr/bin/perl -w

# Script to convert cg output to visl input, in order to produce
# pedagogical programs. The visl format is documented at
# http://beta.visl.sdu.dk/


while (<>) {

# Translate the tags to visl format

# This is a multi-tag, both N and Prop

 s/ N Prop/ prop/g ;

# Here come the derivational tags


 



    if (/^\"<(.*?)>/) {
	$wordform =$1;
    }
    elsif (/^\t\"(.*?)\" +(([A-Za-z]+\*( [a-z]+| s1 Dimin)? )?[A-Za-z]+)( +([^\@]*?))?( (\@.*))? *$/) {
	$base =$1;
	$pos =$2;
	if ($5) {$morf =$6;}
	else {$morf ="";}
	if ($7) {$syn =$8;}
	if ($pos =~ /(CLB|PUNCT|LEFT|RIGHT|clb|punct|left|right)/) {
	    $sentence .= " $wordform";
	    $output .= "$wordform\n";
	    if ($wordform =~ /^[\.\!\?:\;]/) {

		$sentence =~ s/ ([,\;\.\!\?:])/$1/g;
		$output .= "\n";
		$num++;
		print "SOURCE: text\n";
		print "SME$num$sentence\n";
		print "A1\n";
#		goto target;

#		print "***$output\n";  # debugging line, nice.
		$output =~ s/\@<GQ/=D/g;   	    
		$output =~ s/\@ADV-A/=D/g;         #new, adv modifying adj
		$output =~ s/\@ADV-ADV/=D/g;       #new, adv modifying adv
		$output =~ s/\@ADVL/A/g;           #ok
		$output =~ s/\@AN>/=D/g;           #ok
		$output =~ s/\@APP/=D/g;           #new, check this one.
		$output =~ s/\@ActioN/=D/g;        #new
		$output =~ s/\@CC-NP/CO/g; 	       #new
		$output =~ s/\@CC-VP/CO/g; 	       #new
		$output =~ s/\@CC/CO/g;			   #new
		$output =~ s/\@CMPND/CJT/g;        #new, should be one word A-_ja_B?
		$output =~ s/\@CS-NP/SUB/g;        #new
		$output =~ s/\@CS-VP/SUB/g;        #new
		$output =~ s/\@CS/SUB/g;           #ok
		$output =~ s/\@DN>/=D/g;           #ok
		$output =~ s/\@GA>/=D/g;           #new
		$output =~ s/\@GN>/=D/g;           #ok
		$output =~ s/\@GP</=D/g;           #new
		$output =~ s/\@GP>/=D/g;   	       #ok
		$output =~ s/\@GQ</=D/g;           #new
		$output =~ s/\@HNOUN/X/g;          #new
		$output =~ s/\@INTERJ/Ainterj/g;   #ok
		$output =~ s/\@NNum>/X/g;
		$output =~ s/\@NPron</X/g;
		$output =~ s/\@NQ</X/g;
		$output =~ s/\@NumN</X/g;
		$output =~ s/\@NUM-PRON/X/g;
		$output =~ s/\@OBJ/Od/g;
		$output =~ s/\@OPRED/Co/g; 	    
		$output =~ s/\@PCLE/Apcle/g;
		$output =~ s/\@PCLE-COMPL/Apcle/g;
		$output =~ s/\@PROP>/=D/g;         #new, check this one.
		$output =~ s/\@PrcN>/=D/g;
		$output =~ s/\@PronN</=D/g;	    
		$output =~ s/\@PronN>/=D/g;	    
		$output =~ s/\@PronN</=D/g;	    
		$output =~ s/\@QN>/=H/g;   	       #ok, check this   
		$output =~ s/\@QN</=D/g;	    
		$output =~ s/\@SPRED/Cs/g; 	    
		$output =~ s/\@SUBJ/S/g;
		$output =~ s/\@SUBJ-QH/S/g;
		$output =~ s/\@TITLE/=D/g;         #ok, check this
		$output =~ s/\@VOC/X/g;
		$output =~ s/\@X/X/g;
		$output =~ s/\@\+FAUXV/Vaux/g;     #ok
		$output =~ s/\@\+FMAINV/P/g;       #ok
		$output =~ s/\@\-FMAINV/P/g;       #ok
		$output =~ s/\@\-FSUBJ/S/g;        #new, non-finite subj

$output =~ s/([ ,:])adda,/$1der,/g ;
$output =~ s/([ ,:])ahtti,/$1der,/g ;
$output =~ s/([ ,:])alla,/$1der,/g ;
$output =~ s/([ ,:])asti/$1der,/g ;
$output =~ s/[ ,:]asuf//g ;
$output =~ s/([ ,:])d,/$1der,/g ;
$output =~ s/([ ,:])eaddji,/$1der,/g ;
$output =~ s/([ ,:])eamos1,/$1der,/g ;
$output =~ s/([ ,:])eapmi,/$1der,/g ;
$output =~ s/([ ,:])g,/$1der,/g ;
$output =~ s/([ ,:])geahtes,/$1der,/g ;
$output =~ s/([ ,:])goahti,/$1der,/g ;
$output =~ s/([ ,:])h,/$1der,/g ;
$output =~ s/([ ,:])heapmi,/$1der,/g ;
$output =~ s/([ ,:])hudda,/$1der,/g ;
$output =~ s/([ ,:])huhtti,/$1der,/g ;
$output =~ s/([ ,:])huvva,/$1der,/g ;
$output =~ s/[ ,:]isuf//g ;
$output =~ s/([ ,:])j,/$1der,/g ;
$output =~ s/([ ,:])l,/$1der,/g ;
$output =~ s/([ ,:])las1,/$1der,/g ;
$output =~ s/([ ,:])l·gan,/$1der,/g ;
$output =~ s/([ ,:])meahttun,/$1der,/g ;
$output =~ s/([ ,:])mus1,/$1der,/g ;
$output =~ s/([ ,:])n,/$1der,/g ;
$output =~ s/([ ,:])s1,/$1der,/g ;
$output =~ s/([ ,:])st,/$1der,/g ;
$output =~ s/([ ,:])stuvva,/$1der,/g ;
$output =~ s/([ ,:])us,/$1der,/g ;
$output =~ s/([ ,:])vuohta,/$1der,/g ;

$output =~ s/([ ,:])ABBR/$1abbr/g ;
$output =~ s/([ ,:])ACR/$1acr/g ;
$output =~ s/([ ,:])Acc/$1acc/g ;
$output =~ s/([ ,:])Actio/$1actio/g ;
$output =~ s/([ ,:])Actor/$1actor/g ;
$output =~ s/([ ,:])Adp/$1prp/g ;
$output =~ s/([ ,:])Adv/$1adv/g ;
$output =~ s/([ ,:])Attr/$1attr/g ;
$output =~ s/([ ,:])A/$1adj/g ;
$output =~ s/([ ,:])CC/$1conj-s/g ;
$output =~ s/([ ,:])CLB/$1clb/g ;
$output =~ s/([ ,:])CS/$1conj-c/g ;
$output =~ s/([ ,:])Card/$1card/g ;
$output =~ s/[ ,:]Cmpnd//g ;
$output =~ s/([ ,:])Comp/$1comp/g ;
$output =~ s/([ ,:])Com/$1com/g ;
$output =~ s/([ ,:])ConNeg/$1conneg/g ; 
$output =~ s/([ ,:])Cond/$1cond/g ;
$output =~ s/([ ,:])Dem/$1<dem>/g ;
$output =~ s/([ ,:])Dimin/$1der/g ;
$output =~ s/([ ,:])Du1/$1--1du/g ;
$output =~ s/([ ,:])Du2/$1--2du/g ;
$output =~ s/([ ,:])Du3/$1--3du/g ;
$output =~ s/([ ,:])Ess/$1ess/g ;
$output =~ s/([ ,:])Foc/$1foc/g ;
$output =~ s/([ ,:])Gen/$1gen/g ;
$output =~ s/([ ,:])Ger/$1ger/g ;
$output =~ s/([ ,:])Ill/$1ill/g ;
$output =~ s/([ ,:])ImprtII/$1imp2/g ;
$output =~ s/([ ,:])Imprt/$1imp/g ;
$output =~ s/([ ,:])Indef/$1<idef>/g ;
$output =~ s/([ ,:])Ind/$1ind/g ;
$output =~ s/([ ,:])Inf/$1inf/g ;
$output =~ s/([ ,:])Interj/$1intj/g ;
$output =~ s/([ ,:])Interr/$1<int>/g ;
$output =~ s/([ ,:])LEFT/$1left/g ;
$output =~ s/([ ,:])Loc/$1loc/g ;
$output =~ s/([ ,:])Neg/$1neg/g ; 
$output =~ s/([ ,:])Nom/$1nom/g ;
$output =~ s/([ ,:])Num/$1num/g ;
$output =~ s/([ ,:])N/$1n/g ;
$output =~ s/([ ,:])Ord/$1ord/g ;
$output =~ s/([ ,:])PUNCT/$1punct/g ;
$output =~ s/([ ,:])Pass/$1pas/g ;
$output =~ s/([ ,:])Pcle/$1part/g ;
$output =~ s/([ ,:])Pers/$1<pers>/g ;
$output =~ s/([ ,:])Pl1/$1--1pl/g ;
$output =~ s/([ ,:])Pl2/$1--2pl/g ;
$output =~ s/([ ,:])Pl3/$1--3pl/g ;
$output =~ s/([ ,:])Pl/$1pl/g ;
$output =~ s/([ ,:])Pot/$1pot/g ;
$output =~ s/([ ,:])Po/$1prp-post/g ;
$output =~ s/([ ,:])PrfPrc/$1pcp2/g ;
$output =~ s/([ ,:])Pron/$1pron/g ;
$output =~ s/([ ,:])PrsPrc/$1pcp1/g ;
$output =~ s/([ ,:])Prs/$1pr/g ;
$output =~ s/([ ,:])Prt/$1impf/g ;
$output =~ s/([ ,:])Pr/$1prp-pre/g ;
$output =~ s/([ ,:])PxDu1/$1poss1du/g ;
$output =~ s/([ ,:])PxDu2/$1poss2du/g ;
$output =~ s/([ ,:])PxDu3/$1poss3du/g ;
$output =~ s/([ ,:])PxPl1/$1poss1pl/g ;
$output =~ s/([ ,:])PxPl2/$1poss2pl/g ;
$output =~ s/([ ,:])PxPl3/$1poss3du/g ;
$output =~ s/([ ,:])PxSg1/$1poss1sg/g ;
$output =~ s/([ ,:])PxSg2/$1poss2sg/g ;
$output =~ s/([ ,:])PxSg3/$1poss3sg/g ;
$output =~ s/([ ,:])Qst/$1qst/g ;
$output =~ s/([ ,:])RIGHT/$1right/g ;
$output =~ s/([ ,:])Recipr/$1<reci>/g ;
$output =~ s/([ ,:])Refl/$1<refl>/g ;
$output =~ s/([ ,:])Rel/$1<rel>/g ;
$output =~ s/([ ,:])Sg1/$1--1sg/g ;
$output =~ s/([ ,:])Sg2/$1--2sg/g ;
$output =~ s/([ ,:])Sg3/$1--3sg/g ;
$output =~ s/([ ,:])Sg/$1sg/g ;
$output =~ s/([ ,:])Superl/$1sup/g ;
$output =~ s/([ ,:])Sup/$1supi/g ;
$output =~ s/([ ,:])VAbess/$1vabe/g ;
$output =~ s/([ ,:])VGen/$1vgen/g ;
$output =~ s/([ ,:])V/$1v/g ;

		$output =~ s/--//g;
target:
		print "$output";
		$output ="";
		$sentence ="";
	    }
	}
	else {
		if ($pos =~ s/^([A-Za-z]+)\* //) {
		    $secondary = "<$1>";
		    if ($pos =~ s/^([a-z]+|s1 Dimin) //) {
			$secondary .= " <$1>";
			$secondary =~ s/s1 /s1_/;
		    } 
		} 
		else {$secondary ="";}
		if ($syn) {$output .=$syn; $syn ="";}
		else {$syn ="";}
		$output .= ":$pos";
		if ($base) {
		    $output .= "\(\'$base\'";
		    if ($morf) {
			$morf =~ s/ /,/g;
			$output .= ",$morf";
		    }
		    if ($secondary) {$output .= ",$secondary";}
		    $output .= "\)";
		}
		$sentence .= " $wordform";
		$output .= "\t$wordform\n";
	    }
    }
}




