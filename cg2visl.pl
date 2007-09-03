#!/usr/bin/perl -w
#
# cg2visl.pl
# Script to convert cg output to visl input, in order to produce
# pedagogical programs. The visl format is documented at
# http://beta.visl.sdu.dk/
#
# $Id$

# strict variable definitions
use strict;

# usage of utf8 in the perl-code
use utf8;

# These definitions ensure that the script works 
# also in environments, where PERL_UNICODE is not set.
binmode( STDIN, ':utf8' );
binmode( STDOUT, ':utf8' );
binmode( STDERR, ':utf8' );
use open 'utf8';

my $output;

# Translate the tags to visl format
my $wordform;
my $num;
my $sentence;
while (<>) {
	
	# This is a multi-tag, both N and Prop	
	s/ N Prop/ prop/g ;
	
	if (/^\"<(.*?)>/) { $wordform =$1; next; }
	if (! /^\t\"(.*?)\" +(\?|((\p{L}+\*( \p{Ll}+| s1 Dimin)? )?\p{L}+))( +([^\@]*?))?( (\@.*))? *$/) {
		print STDERR "Input did not match: $_\n"; 
		next; 
	}
	my $morf;
	my $syn;
	my $base =$1;
	my $pos =$2;
	$morf =$7;
	$syn =$9;

	# When in clause boundary or similar, print output
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
			
			# First detect the level of embedding for heads (based upon < or > symbols)
			# ... still not written
			
			# Then change symbols, and replace directed symbols 
			# (@GN> etc.) with undirected =D.
			$output = replace_tags($output);
			
			print "$output";
			$output ="";
			$sentence ="";
		}
	}
	# Format the analysis line
	else {
		# Parse derivational pos-tags.
		my $secondary;
		if ($pos =~ s/^([A-Za-z]+)\* //) {
			$secondary = "<$1>";
			if ($pos =~ s/^([a-z]+|s1 Dimin) //) {
				$secondary .= " <$1>";
				$secondary =~ s/s1 /s1_/;
			} 
		} 
		else { $secondary =""; }
		
		# Add syntactic tag to the front
		if ($syn) { $output .=$syn; $syn =""; }
		else { $syn =""; }
		
		# Add POS-tag
		$output .= ":$pos";

		# Add baseform and morphological tags separated with commas.
		if ($base) {
			$output .= "\(\'$base\'";
			if ($morf) {
				$morf =~ s/ /,/g;
				$output .= ",$morf";
			}
			if ($secondary) { $output .= ",$secondary"; }
			$output .= "\)";
		}
		$sentence .= " $wordform";
		$output .= "\t$wordform\n";
    }
}

sub replace_tags {
	my $output = shift @_;
	
#		print "***$output***\n";  # debugging line, nice.
	$output =~ s/\@<GQ/=D/g;   	    
	$output =~ s/\@ADV-ADV/=D/g;       # adv modifying adv
	$output =~ s/\@ADV-A/=D/g;         # adv modifying adj
	$output =~ s/\@ADVL/A/g;           
	$output =~ s/\@AN>/=D/g;           
	$output =~ s/\@APP/=D/g;           # check this one.
	$output =~ s/\@ActioN/=D/g;   
	$output =~ s/\@CC-NP/CO/g; 	      
	$output =~ s/\@CC-VP/CO/g; 	      
	$output =~ s/\@CC/CO/g;			  
	$output =~ s/\@CMPND/CJT/g;            # one word A-_ja_B?
	$output =~ s/\@CS-NP/:cl\n=SUB/g;       
	$output =~ s/\@CS-VP/:cl\n=SUB/g;       
	$output =~ s/\@CS/:cl\n=SUB/g;           
	$output =~ s/\@DN>/:g\n=D/g;           
	$output =~ s/\@GA>/=D/g;      
	$output =~ s/\@GN>/=D/g;           
	$output =~ s/\@GP</=D/g;      
	$output =~ s/\@GP>/=D/g;   	       
	$output =~ s/\@GQ</=D/g;      
	$output =~ s/\@HNOUN/X/g;         
	$output =~ s/\@INTERJ/Ainterj/g;   
	$output =~ s/\@NNum>/=D/g;
	$output =~ s/\@NPron</=D/g;
	$output =~ s/\@NQ</=D/g;
	$output =~ s/\@NumN</=D/g;
	$output =~ s/\@NUM-PRON/X/g;
	$output =~ s/\@OBJ/Od/g;
	$output =~ s/\@OPRED/Co/g; 	    
	$output =~ s/\@PCLE/Apcle/g;
	$output =~ s/\@PCLE-COMPL/Apcle/g;
	$output =~ s/\@PROP>/=D/g;         # check this one.
	$output =~ s/\@PrcN>/=D/g;
	$output =~ s/\@PronN</=D/g;	    
	$output =~ s/\@PronN>/:g\n=D/g;	    
	$output =~ s/\@QN>/=H/g;   	           # check this   
	$output =~ s/\@QN</=D/g;	    
	$output =~ s/\@SPRED/Cs/g; 	    
	$output =~ s/\@SUBJ-QH/S:g\n=H:Num/g;
	$output =~ s/\@SUBJ/S/g;
	$output =~ s/\@TITLE/=D/g;         # check this
	$output =~ s/\@VOC/X/g;
	$output =~ s/\@X/X/g;
	$output =~ s/\@\+FAUXV/P:g\n=D:Vaux/g;
	$output =~ s/\@\-FAUXV/=D:Vaux/g;
	$output =~ s/\@\+FMAINV/P/g;       
	$output =~ s/\@\-FMAINV/=H/g;       
	$output =~ s/\@\-FSUBJ/S/g;            # non-finite subj
	
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
	$output =~ s/([ ,:])Der1//g ; # Der type tags
	$output =~ s/([ ,:])Der2//g ; # Der type tags
	$output =~ s/([ ,:])Der3//g ; # Der type tags
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
	
	return $output;
}

