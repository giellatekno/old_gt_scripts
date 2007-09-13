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

# Translate the tags to visl format
my $wordform;
my $num;
my $sentence;
my $embed="";
my @output;

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
		push (@output, $wordform);

		if ($wordform =~ /^[\.\!\?:\;]/) {
			
			$sentence =~ s/ ([,\;\.\!\?:])/$1/g;
			$num++;
			print "SOURCE: text\n";
			print "SME$num$sentence\n";
			print "A1\n";
			
			# First detect the level of embedding for heads (based upon < or > symbols)
			# ... still not written

			# Then change symbols, and replace directed symbols 
			# (@N> etc.) with undirected =D.
			my $output_string;
			my @new_output;

			my $prev;
			my $i=0;
			for my $out (@output) {
				my $output_str .= replace_tags($out);
				# If there was newline added, everything that comes 
				# after that, belongs actually to the previous output_line
				if ($output_str =~ s/(.+)\n\s*(.+)$/$2/) {
					$prev = $1;
					splice(@new_output, $i,0, $prev);
					$i++;
				}
				push (@new_output, $output_str);
				$i++;
			}
			local $, = "\n";
			#print @new_output;
			# Fix sentence initial D's
			my $result = sentence_initial_d(\@new_output);
			#if (! $result) { print STDERR "Sentence initial D, but no reformatting.\n"; }

			print @new_output;
			print "\n";
			@output = undef;
			pop @output;
			$sentence ="";
			$embed = "";
		}
	}
	# Format the analysis line
	else {
		# Parse derivational pos-tags.
		my $secondary;
		my $anl_line;
		if ($pos =~ s/^([A-Za-z]+)\* //) {
			$secondary = "<$1>";

			# We are not actually using this
			if ($pos =~ s/^([a-z]+|s1 Dimin) //) {
				$secondary .= " <$1>";
				$secondary =~ s/s1 /s1_/;
			} 
		} 
		else { $secondary =""; }
		
		# Check if there is an object embedded clause @CVP
		if ($syn) {
			if ($syn eq '@CVP') { 
				my $str = $embed . "Od:cl";
				push (@output, $str);
				$embed .= "="; 
			}
			$anl_line = $embed . $syn;
		}
		$syn = "";
		
		# Add POS-tag
		$anl_line .= ":$pos";

		# Add baseform and morphological tags separated with commas.
		if ($base) {
			$anl_line .= "\(\'$base\'";
			if ($morf) {
				$morf =~ s/ /,/g;
				$anl_line .= ",$morf";
			}
			if ($secondary) { $anl_line .= ",$secondary"; }
			$anl_line .= "\)";
		}
		$sentence .= " $wordform";
		$anl_line .= "\t$wordform";
		push (@output, $anl_line);
    }
}

# If there is a sentence-initial D, it is safe to assume
# that there is a group of elements forming a DP. E.g
# A1
# :g
# =D:pron('mun',<pers>,1sg,gen)   Mu
# =D:adj('boaris',sup,attr)       boarrÃ¡seamos
# S:n('viellja',sg,nom)   viellja
#
# is converted to:
# A1
# S:g
# =D:pron('mun',<pers>,1sg,gen)   Mu
# =D:adj('boaris',sup,attr)       boarrÃ¡seamos
# =H:n('viellja',sg,nom)   viellja
#
#
sub sentence_initial_d {
	my $out_aref = shift @_;

	my $num=0;
	my $i=$num;
	if ($$out_aref[$num] =~ /^S/) { $num++; }
	if ($$out_aref[$num] && $$out_aref[$num] =~ /^=D/) {
		my $length = scalar @$out_aref;
		while ($i < $length && $$out_aref[$i] =~ /^=D/) { $i++; }
		if ($i == $length) { return 0; }
		if ($$out_aref[$i] !~ /^S/) { return 0; }

		$$out_aref[$i] =~ s/^S/=H/;
		if ($num>0 && $$out_aref[$num-1]) { $$out_aref[$num-1] = "S:g"; }
		else { splice(@$out_aref, $num,0, "S:g"); }

		return 1;
	}
	return 1;
}
cd
# Replace all the cg-tags with visl-tags.
sub replace_tags {
	my $output = shift @_;
	
#		print "***$output***\n";  # debugging line, nice.

# After the tag revision, there is some revision to do. 
# Earlier, we specified a lot, now we generalise. For some conversions
# we will have to think again.

# Many of the following rules remove directional tags and replace them with =D.
# But the phrase they belong to must be headed before we apply these rules, 
# so that we know whether to look to the right or left for the =H.

# All tags pointing rightwards and not having a rightwards-pointing tag to 
# the left should get a :g tag on the previous line.

	$output =~ s/\@ADVL>/=D/g;       #  modifying ADVL
	$output =~ s/\@ADVL</=D/g;       # complement of ADVL
	$output =~ s/\@ADVL/A/g;           
	$output =~ s/\@N>/=D/g;     
###	$output =~ s/\@N>/=H/g;   	     # Revise!!   	      
###	$output =~ s/\@N>/:g\n=D/g;      # Revise!!
	$output =~ s/\@N</=D/g;
	$output =~ s/\@APP/=D/g;           # check this one.
#	$output =~ s/\@CNP/CO/g; # Must be revised, POS-sensitive	      
#	$output =~ s/\@CVP/CO/g; # Must be revised, POS-sensitive	      
#	$output =~ s/\@N>/CJT/g;            # one word A-_ja_B?
	$output =~ s/\@CNP/:cl\n=SUB/g;       
	$output =~ s/\@CVP/SUB/g;   # trying to get embedding to work
	$output =~ s/\@A>/=D/g;      
	$output =~ s/\@P</=D/g;      
	$output =~ s/\@P>/=D/g;     	       
	$output =~ s/\@Q</=D/g;      
	$output =~ s/\@HNOUN/X/g;         # hmm, is it really X?        
	$output =~ s/\@INTERJ/Ainterj/g;   
	$output =~ s/\@Num</=D/g;
	$output =~ s/\@Num>/=D/g;
	$output =~ s/\@Pron</=D/g;
	$output =~ s/\@Q</=D/g; 
	$output =~ s/\@Pron</X/g;
	$output =~ s/\@OBJ/Od/g;
	$output =~ s/\@OPRED/Co/g; 	    
	$output =~ s/\@PCLE/Apcle/g;
	$output =~ s/\@SPRED/Cs/g; 
	$output =~ s/\@COMP-CS/=D/g; 
###	$output =~ s/\@SUBJ/S:g\n=H:Num/g;   # Revise! This must be contextually used.
	$output =~ s/\@SUBJ/S/g;
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

