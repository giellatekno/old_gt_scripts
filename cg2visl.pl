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

# Trees are build. If you don't have the package in your computer,
# issue the following command:
# sudo perl -MCPAN -e 'install Tree::Simple'
# The default answer to all the questions presented by the
# installation program should be ok.
use Tree::Simple;

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
my @output;

while (<>) {
	
	# This is a multi-tag, both N and Prop	
	s/ N Prop/ prop/g ;

	# Take the wordform and read the analysis for it
	# straight aways
	if (/^\"<(.*?)>/) { $wordform =$1; next; }

	# Take the analysis line proceed to format the output.
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

	# If the input is punctuation, just add it to the output
	# without analysis.
	if ($pos =~ /(CLB|PUNCT|LEFT|RIGHT|clb|punct|left|right)/) {

		$sentence .= " $wordform";
		push (@output, $wordform);

		# If sentence boundary then format the tags
		# and print out everything
		if ($wordform =~ /^[\.\!\?:\;¶]/) {
			
			$sentence =~ s/ ([,\;\.\!\?:¶])/$1/g;
			$num++;
			print "SOURCE: text\n";
			print "SME$num$sentence\n";
			print "A1\n";

			my $tree = Tree::Simple->new("0", Tree::Simple->ROOT);
			build_tree(\@output, $tree);

			# Then change symbols
			my @new_output;

			$tree->traverse(sub {
				my ($_tree) = @_;
				my $value = $_tree->getNodeValue();
				my $new_value = replace_tags($value); 
				#my $new_value = $_tree->getNodeValue();
				print (("=" x $_tree->getDepth()), $new_value, "\n");
			});

			@output = undef;
			pop @output;
			$sentence ="";
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
		if ($syn) { $anl_line = $syn; }
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

# Main function for building a tree out of a sentence
sub build_tree {
	my ($out_aref, $tree) = @_;
	
	while (my $out = shift @$out_aref) {
		# Detect modifiers and heads (only right pointing at the moment)
		# This should be recursive, but for the time being, it is not.
		if ( $out =~ /^\=*\@.*?\>\:/) {
			format_rp_modifiers($out, $out_aref, $tree);
			next;
		}
		elsif ( $out =~ /^\=*\@.*?\<\:/) {
		    format_lp_modifiers($out, $out_aref, $tree);
            next;
		}
	    elsif ($out =~ /\@CVP:/) { 
			# Create a node for the embedded clause
            if ($out =~ /CS/) {
			     my $ecl = Tree::Simple->new('Od:cl', $tree);
			     $tree=$ecl;
            }
            else { $tree->addChild(Tree::Simple->new($out)); }
			next;
        }
		# Detect coordinated structures
		elsif ( $out =~ /\@CNP\:/) {
			format_coordination($out, $out_aref, $tree);
            next;
		}				
		elsif ($out =~ /\@\+FAUXV\:/) {
			format_auxiliary($out, $out_aref, $tree);
            next;
        }
		else { $tree->addChild(Tree::Simple->new($out)); }
	}
}

sub format_coordination {
	my ($coord, $out_aref, $subtree) = @_;

	my $c_aref = $subtree->getAllChildren;
	my $index = scalar @$c_aref;
	if ($index == 0) {return 0;}
	my $left_coord = $$c_aref[$index-1];
	if (! $left_coord) { print "$index\n"; }
	my $left_value = $left_coord->getNodeValue();

	(my $prev_tag = $left_value) =~ s/^(.*?)\:.*$/$1/;

	# Search for the same syntactic tag as in the left coordinator
	my @tmp_array;
	my $out = shift @$out_aref;
	my $quoted = quotemeta $prev_tag;
	while ($out && $out !~ /$quoted/) { 
		push (@tmp_array, $out);
		$out = shift @$out_aref;
	}
	if (! $out || $out !~ $quoted) { unshift(@$out_aref, @tmp_array); return 0; }
	push (@tmp_array, $out);

	my $group = $prev_tag . ":par";

	$subtree->removeChild ($index-1);

	$left_value =~ s/$quoted/CJT/;
	$left_coord->setNodeValue($left_value);

	# Create a node for the coordinated constituent
	my $par = Tree::Simple->new($group, $subtree);
	$par->addChild($left_coord);
	my $cnp = Tree::Simple->new($coord, $par);

	# Create the right coordinator.
	build_tree(\@tmp_array, $par);

	my $p_aref = $par->getAllChildren;
	my $ind = scalar @$p_aref;
	my $right_coord = $$p_aref[$ind-1];
	my $right_value = $right_coord->getNodeValue();
	$right_value =~ s/$quoted/CJT/;
	$right_coord->setNodeValue($right_value);
	#$par->addChild($right_coord);

}

sub format_lp_modifiers {
	my ($modifier, $out_aref, $subtree, $constituent) = @_;

	my @tmp_array;

	#print "OUT *** @$out_aref **\n";
	# If the right pointing tag is a constituent and not a string.
	if(! $modifier) { $modifier = $constituent->getNodeValue(); }

	# Read until all the modifiers are taken.
	(my $tag = $modifier ) =~ s/^(.*?)\:.*$/$1/s;
	(my $pos = $modifier ) =~ s/^\@[DG]?(.*?)[><]\:.*$/$1/s;
	if ($tag =~ /PRON/) { $pos = "Pron"; }
	
	my $out = shift @$out_aref;
	while ($out && $out =~ /^$tag\:/) {
		push (@tmp_array, $out);
		$out = shift @$out_aref;
	}
	if ($out && $out !~ /^$tag\:/) { unshift (@$out_aref, $out);  }

	my $left = get_last_child($subtree);
	if ($left == 0) { $subtree->addChild(Tree::Simple->new($modifier)); return 0; }
	my $left_value = $left->getNodeValue();

	# If the first constituent to the left was not the correct pos
	# Put everything back and return.
	if ($left_value !~ /^.*?\:$pos/) { 
		$subtree->addChild($left);
		$subtree->addChild(Tree::Simple->new($modifier));
		return 0; 
	}
	# Create a node for the complex constituent
	(my $htag = $left_value ) =~ s/^(.*?)\:.*$/$1/s;
	my $group = $htag . ":g";
	my $dp = Tree::Simple->new($group);

	# create a phrase
	$left_value =~ s/$htag/H/;
	$left->setNodeValue($left_value);
	$dp->addChild($left);

	if (! $constituent) { $dp->addChild(Tree::Simple->new($modifier)); }
	else { $dp->addChild($constituent); }
	for my $tmp (@tmp_array) {
		$dp->addChild(Tree::Simple->new($tmp));
	}
	$subtree->addChild($dp); 	
}

sub get_last_child {
	my $tree = shift @_;

	my $c_aref = $tree->getAllChildren;
	my $index = scalar @$c_aref;
	if ($index == 0) { return 0; }
	my $left_coord = $$c_aref[$index-1];
	if (! $left_coord) { return 0; }

	$tree->removeChild ($index-1);

	return $left_coord;
	
}

sub format_rp_modifiers {
	my ($modifier, $out_aref, $subtree, $constituent) = @_;
	
	my @tmp_array;

	#print "OUT *** @$out_aref **\n";
	# If the right pointing tag is a constituent and not a string.
	if(! $modifier) { $modifier = $constituent->getNodeValue(); }

	# Read until the head is found
	(my $tag = $modifier ) =~ s/^(.*?)\:.*$/$1/s;
	(my $pos = $modifier ) =~ s/^\@[DG]?(.*?)>\:.*$/$1/s;
	if ($tag =~ /PRON/) { $pos = "Pron"; }

	my $out = shift @$out_aref;
	while ($out && ($out =~ /^$tag\:/ || $out !~ /^.*?\:$pos/ || $out =~ /^[\(\)\.\:\!\?\-]/)) { 
		push (@tmp_array, $out);
		$out = shift @$out_aref;
	}
	if (! $out) { 
		unshift(@$out_aref, @tmp_array); 
		$subtree->addChild(Tree::Simple->new($modifier)); 
		return 0;
	}

	# Create a node for the complex constituent
	(my $htag = $out ) =~ s/^(.*?)\:.*$/$1/s;
	my $group = $htag . ":g";
	my $dp = Tree::Simple->new($group);

	# create a phrase
	if (! $constituent) { $dp->addChild(Tree::Simple->new($modifier)); }
	else { $dp->addChild($constituent); }
	while (@tmp_array) {
		my $tmp =  shift @tmp_array;
		last if ! $tmp;
		# Format left-pointing modifiers
		if ($tmp =~ /<\:/) { format_lp_modifiers($tmp, \@tmp_array, $dp); }
		elsif ( $tmp =~ /\@CNP\:/) { format_coordination($tmp, \@tmp_array, $dp); }
		else { $dp->addChild(Tree::Simple->new($tmp)); }
	}
#	$dp->traverse(sub {
#		my ($_tree) = @_;
		#my $value = $_tree->getNodeValue();
		#my $new_value = replace_tags($value); 
#		my $new_value = $_tree->getNodeValue();
#		print (("     =" x $_tree->getDepth()), $new_value, "\n");
#	});

	if ($htag =~ />/) {
		format_rp_modifiers (0, $out_aref, $subtree, $dp);
		$out =~ s/$htag/H/;
	    $dp->addChild(Tree::Simple->new($out));
	}
	elsif ($htag =~ /</) {
        print "TÄÄLLÄ\n";
		format_lp_modifiers (0, $out_aref, $subtree, $dp);
		$out =~ s/$htag/H/;
	    $dp->addChild(Tree::Simple->new($out));
	}
	else { 
	    $out =~ s/$htag/H/;
	    $dp->addChild(Tree::Simple->new($out));
        $subtree->addChild($dp); 
    }
}

sub format_auxiliary {
	my ($aux, $out_aref, $subtree) = @_;

	# Search for the same syntactic tag as in the left coordinator
	my @tmp_array;
	my @tmp_array2;
	my $out2;
	my $out = shift @$out_aref;
	while ($out && ($out !~ /\@\-FAUXV/ && $out !~ /\@\-FMAINV/ )) { 
		push (@tmp_array, $out);
		$out = shift @$out_aref;
	}
	if (! $out) { 
		unshift(@$out_aref, @tmp_array); 
		$subtree->addChild(Tree::Simple->new($aux));
		return;
	}
	#print "OUT $out\n";

	$aux =~ s/\@\+FAUXV/D:Vaux/;
	$out =~ s/\@\-FMAINV/H/;
	$out =~ s/\@\-FAUXV/D:Vaux/;

	# If the predicate was not discontinuous
	# Create a group node and return.
	if (! @tmp_array && $out =~ /H/) {
		my $group = "P:g";
		my $p = Tree::Simple->new($group, $subtree);
		$p->addChild(Tree::Simple->new($aux));
		$p->addChild(Tree::Simple->new($out));
		return;
	}
	# Search for main verb if it was not already found.
	if ($out =~ /Vaux/) {
		$out2 = shift @$out_aref;
		while ($out2 && ($out2 !~ /\@\-FMAINV/ )) {
			push (@tmp_array2, $out2);
			$out2 = shift @$out_aref;
		}
		if (! $out2) { 
			unshift(@$out_aref, @tmp_array2); 
			$subtree->addChild(Tree::Simple->new($out));
			return;
		}
		$out2 =~ s/\@\-FMAINV/H/;
	}

	# If everything is grouped:
	if (! @tmp_array && ! @tmp_array2) {
		my $group = "P:g";
		my $p = Tree::Simple->new($group, $subtree);
		$p->addChild(Tree::Simple->new($aux));
		$p->addChild(Tree::Simple->new($out));
		$p->addChild(Tree::Simple->new($out2));
		return;
	}
	# If the auxiliaries were discontinuous
	# Create a node for the continuing predicate
	my $group = "P:g-";
	my $p = Tree::Simple->new($group, $subtree);
	
	$p->addChild(Tree::Simple->new($aux));
	
	# Create the constituents in the middle of the discontinuous constituents
	if (@tmp_array) {
		build_tree(\@tmp_array, $subtree); 
		$group = "-P:g";
		$p = Tree::Simple->new($group, $subtree);
	}
	$p->addChild(Tree::Simple->new($out));

	if ($out2) {
		# Create a node for the continuing predicate	
		if (@tmp_array2) {
			build_tree(\@tmp_array2, $subtree); 
			$group = "-P:g";
			$p = Tree::Simple->new($group, $subtree);
		}
		$p->addChild(Tree::Simple->new($out2));		
	}
}


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

	$output =~ s/\@ADVL>/D/g;       #  modifying ADVL
	$output =~ s/\@ADVL</D/g;       # complement of ADVL
	$output =~ s/\@ADVL/A/g;           
	$output =~ s/\@N>/D/g;
### $output =~ s/\@N>/=H/g;   	     # Revise!!   	      
###	$output =~ s/\@N>/:g\n=D/g;      # Revise!!
	$output =~ s/\@N</D/g;
	$output =~ s/\@APP/D/g;           # check this one.
#	$output =~ s/\@CNP/CO/g; # Must be revised, POS-sensitive	      
#	$output =~ s/\@CVP/CO/g; # Must be revised, POS-sensitive	      
#	$output =~ s/\@N>/CJT/g;            # one word A-_ja_B?
	$output =~ s/\@CNP/SUB/g;       # --sh
	$output =~ s/\@CVP/SUB/g;   # trying to get embedding to work
	$output =~ s/\@A>/D/g;      
	$output =~ s/\@P</D/g;      
	$output =~ s/\@P>/D/g;     	       
	$output =~ s/\@Q</D/g;      
	$output =~ s/\@HNOUN/X/g;         # hmm, is it really X?        
	$output =~ s/\@INTERJ/Ainterj/g;   
	$output =~ s/\@Num</D/g;
	$output =~ s/\@Num>/D/g;
	$output =~ s/\@Pron</D/g;
	$output =~ s/\@Q</D/g; 
	$output =~ s/\@Pron</X/g;
	$output =~ s/\@OBJ/Od/g;
	$output =~ s/\@OPRED/Co/g; 	    
	$output =~ s/\@PCLE/Apcle/g;
	$output =~ s/\@SPRED/Cs/g; 
	$output =~ s/\@COMP-CS/D/g; 
###	$output =~ s/\@SUBJ/S:g\n=H:Num/g;   # Revise! This must be contextually used.
	$output =~ s/\@SUBJ/S/g;
	$output =~ s/\@X/X/g;
	$output =~ s/\@\+FAUXV:g/P:g/g;
	$output =~ s/\@\+FAUXV/D:Vaux/g; 
	$output =~ s/\@\-FAUXV/D:Vaux/g;
	$output =~ s/\@\+FMAINV/P/g;       
	$output =~ s/\@\-FMAINV/H/g;       
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

