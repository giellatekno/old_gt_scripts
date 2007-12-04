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

use Getopt::Long;
Getopt::Long::Configure ("bundling");

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

my $help;
my $verbose=0;
my $embedding = 0;
my $print_header=1;
my $test=1;

GetOptions ("e|embedding" => \$embedding,
			"v|verbose" => \$verbose,
			"h|help" => \$help);

if ($help) {
	&print_usage;
	exit;}

# Translate the tags to visl format
my $wordform;
my $num;
my $sentence;
my @output;
my $punct = quotemeta("[().:!?-,");

my %tagpos = ( "\@>PRON" => "Pron",
			   "\@PRON<" => "Pron",
			   "\@Pron<" => "Pron",
			   "\@>Pron" => "Pron",
			   "\@>ADVL" => "ADVL",
			   "\@ADVL<" => "ADVL",
			   "\@>Q" => "Num",
			   "\@Q<" => "Num",
			   "\@>A" => "\:(Adj|A)\\(",
			   "\@A<" => "\:(Adj|A)\\(",
			   "\@>N" => "\:(N|prop)\\(",
			   "\@N<" => "\:(N|prop)\\(",
			   "\@>P" => "P[or]",
			   "\@P<" => "P[or]",
			   "\@>Num" => "Num",
			   "\@Num<" => "Num",
			   "\@APP>ADVL" => "ADVL",
			   "\@APP-ADVL<" => "ADVL",
			   "\@APP>N" => "\:(N|prop)\\(",
			   "\@APP-N<" => "\:(N|prop)\\(",
			   "\@APP>Pron" => "Pron",
			   "\@APP-Pron<" => "Pron",
			   "\@APP>Num" => "Num",
			   "\@APP-Num<" => "Num",
			   "\@COMP-CS<" => "CS",
			   "\@-FADVL" => "\:(ADVL|V)\\(",
			   "\@-FOBJ" => "V.*(Inf|VAbess|Ger)",
			   "\@-FSUBJ" => "V.*(Inf|VAbess|Ger)",
			   "\@-FAUXV" => "(V.*(Inf|VAbess|Ger))",
			   );

my @csa_a = ("go", "goas", "ovdal", "dassá go", "dassážii go", "dan rájes go", "dan botta go", "dalle go", "ovdalgo", "maŋŋilgo", "jus", "jos", "juos", "joas", "nu ahte", "nuvt ahte", "dainna go", "danne go", "danin go", "dan dihte go", "dan dihtii go", "dasgo", "vai", "mađe", "vaikko", "nugo", "dego");
my %csa;
for my $c (@csa_a) { $csa{$c}=1; }

my %cso;
my @cso_a = ("ahte", "goas", "govt", "mo", "gos", "gosa", "guđe", "guđemuš", "vaikko");
for my $c (@cso_a) { $cso{$c}=1; }

my %csd;
my @csd_a = ("gos", "gosa", "mas", "masa");
for my $c (@csd_a) { $csd{$c}=1; }

my $header;
my $footer; 

$header = ("<\?xml version='1.0' encoding='UTF-8'\?>
<corpus lang=\"smi\" sentenceCode=\"SMEB\\d+\">\n
<note></note>\n
<corpussource>\n
<icon>/icons/5svans.gif</icon>\n
<title>PRE-ANALYZED SÁMI SENTENCES</title>\n
<authors></authors>\n
</corpussource>\n
<section name=\"\">\n
<![CDATA[\n\n");

$footer = ("]]>\n
</section>\n
</corpus>\n");

# Added conditionals so that header is not printed when debugging.
if (! $verbose && ! $test) { print $header ; }

while (<>) {
	
	next if (/^\#/);
	next if (/^\s*$/);

	# This is a multi-tag, both N and Prop	
	s/ N Prop/ prop/g ;

	# Take the wordform and read the analysis for it
	# straight aways
	if (/^\"<(.*?)>/) { $wordform =$1; next; }

	# Take the analysis line proceed to format the output.
	#s/V\* Der\d Der\/\w //;
	if (! /^\t\"(.*?)\" +(\?|((\p{L}+\*( \p{Ll}+)? )?\p{L}+\*?))( +([^\@]*?))?( (\@.*))? *$/) {
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
			print "\nSOURCE: text\n";
			print "SMEB$num$sentence\n"; # SMEB to differ from first file
			print "A1\n";

			my $tree = Tree::Simple->new("0", Tree::Simple->ROOT);
			if ($wordform =~ /\?/) { $tree->addChild(Tree::Simple->new("QUE:cl")); }
			elsif ($wordform =~ /\!/) { $tree->addChild(Tree::Simple->new("COM:cl")); }
			else { $tree->addChild(Tree::Simple->new("STA:cl")); }
			build_tree(\@output, $tree);

			# Then change symbols
			my @new_output;

			$tree->traverse(sub {
				my ($_tree) = @_;
				my $value = $_tree->getNodeValue();
				my $new_value = $value;
				if (! $verbose) {
					$new_value = replace_tags($value); 
				}
				$new_value =~ s/^\=*(\.)/$1/;
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

if (! $verbose && ! $test) { print $footer; }


# Main function for building a tree out of a sentence
sub build_tree {
	my ($out_aref, $tree) = @_;

	while (my $out = shift @$out_aref) {

		# Detect modifiers and heads 
		if ( $out =~ /^\@\>.*?\:/) {
			format_rp_modifiers($out, $out_aref, $tree);
			next;
		}
		elsif ( $out =~ /^\@.*?\<\:/) {
		    format_lp_modifiers($out, $out_aref, $tree);
            next;
		}
	    elsif ($out =~ /\@CVP:/) { 
			# Create a node for the embedded clause
            if ($out =~ /CS/) {
                 $out =~ /\(\'(.*?)\'\)/;
                 my $lemma = $1;
                 my $group;
                 my $last = get_last_child($tree);
                 if ($last) {
                     my $lvalue = $last->getNodeValue();
                     $tree->addChild($last);
                     if ($lvalue =~ /(Dem|Adj)/) {
                         if ($lemma eq "ahte") { $group = "D:cl"; }
                     }
                 }
                 if(! $group) {
                     if ($csa{$lemma}) { $group = "A:cl"; }
                     elsif ($cso{$lemma}) { $group = "Od:cl"; }
                 }
                 if ($group) {
			         my $ecl = Tree::Simple->new($group, $tree);
                     $ecl->addChild(Tree::Simple->new($out));
			         $tree=$ecl;
                 }
                 else {
                    my $tvalue = $tree->getNodeValue; 
                    if($tvalue && $tvalue =~ /^A\:cl/) {
                        my $p = $tree->getParent;
                        $tree=$p;
                    }
			        verbose("add_to_tree", $out , __LINE__);	
                    $tree->addChild(Tree::Simple->new($out));
                    next;
                }
            }
            else { 
			    format_coordination($out, $out_aref, $tree);
                next;
            }
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
		elsif ($out =~ /\@\+FMAINV\:/) {
			format_mainv($out, $out_aref, $tree);
            next;
        }
		elsif ($out =~ /\@\-(FOBJ|FADVL|FSUBJ|FAUXV)\:/) {
			if (! format_lp_modifiers($out, $out_aref, $tree)) {
                get_last_child($tree);
			    format_rp_modifiers($out, $out_aref, $tree);
            }
            next;
        }
		else {
             $out =~ /\(\'(.*?)\'/;
             my $lemma = $1;
             my $group;
             if ($lemma && $csd{$lemma} && $out =~ /\@ADVL/) { $group = "D:cl"; }
                 
             my $last = get_last_child($tree);
             if ($last) {
                 my $lvalue = $last->getNodeValue();
                 $tree->addChild($last);
                 if ($lvalue =~ /TV/) {
                     if (($lemma && $cso{$lemma}) || $out =~ /(Rel|Interr)/) { $group = "Od:cl"; }
                }     
            }
            if ($group) {
			     my $ecl = Tree::Simple->new($group, $tree);
			     verbose("add_to_tree", $out , __LINE__);	
                 $ecl->addChild(Tree::Simple->new($out));
			     $tree=$ecl;
                 next;
            }

			verbose("add_to_tree", $out , __LINE__);	
            $tree->addChild(Tree::Simple->new($out)); }
	}
}

sub format_coordination {
	my ($coord, $out_aref, $subtree) = @_;

	verbose("format_coordination", $coord , __LINE__);	

	if ($coord =~ /go/) { 
		$subtree->addChild(Tree::Simple->new($coord));
		return;
	}

	#print "*** COORD_OUT @$out_aref\n";
	#print "*** COORD_LÄHTÖ @$out_aref\n";
	#print_tree($subtree);

	my $left_coord = get_last_child($subtree);
	if (! $left_coord) { return; }
	my $left_value = $left_coord->getNodeValue();
	if ($left_value =~ /^[$punct]$/ ) {
		$subtree->addChild($left_coord);
		$subtree->addChild(Tree::Simple->new($coord));
		return;
	}

	(my $prev_tag = $left_value) =~ s/^(.*?)\:.*$/$1/;
	my $quoted = quotemeta $prev_tag;

	# build the right coordinator
	my $right_coord;
	my $tmp_sub = Tree::Simple->new();	
	build_tree($out_aref, $tmp_sub);
	my $c_aref = $tmp_sub->getAllChildren;
	my $rvalue;
	if ($$c_aref[0]) { $rvalue = $$c_aref[0]->getNodeValue(); }
	#print "RVALLUE $rvalue $quoted\n";
	if (! $rvalue || $rvalue !~ /$quoted/) {		
		$subtree->addChild($left_coord);
		$subtree->addChild(Tree::Simple->new($coord));
		for my $c (@$c_aref) { $subtree->addChild($c); }
		return;
	}

	# Search the same syntactic tag on the same level to the left
	# Doppe mii sáhttit oastit gáfe, deaja, sávtta dahje bruvssa.
	# commas may intervene
	my $rest = get_last_child($subtree);
	my @rest_array;
	my $rest_value;
	if ($rest) {
		$rest_value = $rest->getNodeValue();
		while ($rest_value && ($rest_value =~ /$quoted/ || $rest_value =~ /^\,$/)) { 
			unshift (@rest_array, $rest);
			$rest = get_last_child($subtree);
			last if ($rest == 0);
			$rest_value = $rest->getNodeValue();
		}
	}

	# put back the last node, since it did not match anyway.
	if ($rest_value && $rest_value !~ /$quoted/) { $subtree->addChild($rest); }
	if (@rest_array) { 
		$rest = shift(@rest_array);
		if ($rest =~ /^\,$/) { $subtree->addChild($rest); }
		else { unshift(@rest_array, $rest); }
	}
	my $group = $prev_tag . ":par";

	$left_value =~ s/$quoted/CJT/;
	$left_coord->setNodeValue($left_value);

	# Create a node for the coordinated constituent
	my $par = Tree::Simple->new($group, $subtree);
	while (@rest_array) {
		$rest_value = $rest->getNodeValue();
		$rest_value =~ s/$quoted/CJT/;
		$rest->setNodeValue($rest_value);
		$par->addChild($rest);
		$rest = pop(@rest_array);
	}
	$par->addChild($left_coord);
	my $cnp = Tree::Simple->new($coord, $par);

	#print "COORD1\n";
	#print_tree($par);

	# Add the right coordinator.
	$rvalue =~ s/$quoted/CJT/;
	$$c_aref[0]->setNodeValue($rvalue);
	$par->addChild($$c_aref[0]);
	my $num = scalar @$c_aref;
	for (my $i=1; $i<$num; $i++) {
		$subtree->addChild($$c_aref[$i]);
	}
	#print "COORD2\n";
	#print_tree($par);

	return $par;
}

sub format_lp_modifiers {
	my ($modifier, $out_aref, $subtree, $constituent) = @_;

	my @tmp_array;

	# If the left pointing tag is a constituent and not a string.
	my $mod;
	if(! $modifier) { 
		$modifier = $constituent->getNodeValue();
		$mod = $constituent;
	}
	else { $mod = Tree::Simple->new($modifier); }

	verbose("format_lp_modifiers", $modifier , __LINE__);
	#print "OUT *** @$out_aref **\n";

	# Read until all the modifiers are taken.
	(my $tag = $modifier ) =~ s/^(.*?)\:.*$/$1/s;
	(my $pos = $modifier ) =~ s/^\@\>?[DG]?(.*?)\<?\:.*$/$1/s;

	# Insert complex node.
	#print "LÄHTÖ\n";
	#print_tree($subtree);

	if (! insert_complex_node ($subtree, $tag, $mod, 0)) {
		$subtree->addChild($mod);
		#my $modval= $mod->getNodeValue();
		#print "FAILED $modval\n";
		return 0;
	}
	#print "PAALLA\n";
	#print_tree($subtree);

	return 1;
}

sub insert_complex_node {
	my ($tree, $tag, $sibling, $num) = @_;

	my $criterion = $tagpos{$tag};
	my $last = get_last_child($tree);
	if (! $last) { return 0; }
	my $last_value = $last->getNodeValue();
	if (! $criterion || ! $last_value) { 
		$tree->addChild($last); 
		return 0;
	}
	my $sibling_value = $sibling->getNodeValue();

	#print "NUM $num $last_value CRIT $criterion\n";

	verbose("insert_complex_node", $last_value , __LINE__);	

	my $cont_grp;

	# Don't form verb groups that cross commas.
	if ($tag =~ /FAUXV/ && $last_value =~ /^\,/) { 
		$tree->addChild($last); 
		return 0;
	}
	if ($last_value =~ /$criterion/) {
		my $group;
		(my $htag = $last_value ) =~ s/^(.*?)\:.*$/$1/s;
		if ($tag =~ /(FOBJ|FADVL|FSUBJ|FAUXV)/ && $last_value !~ /\+FAUXV/) {
			$last_value =~ s/^.*?:V/P:v/;
			$group = $htag . ":icl";
		}
		else {
			$group = $htag . ":g";
			# if there were nodes in between.
			if ($num != 0) { $cont_grp = "-$group"; $group .= "-"; }
			$last_value =~ s/$htag/H/;
		}
		#print "GROUP $group\n";
		my $new_node = Tree::Simple->new($group);
		$last_value =~ s/^\-//;
		$last_value =~ s/\@\+FAUXV/D:vaux/;

		$last->setNodeValue($last_value);

		$sibling->setNodeValue($sibling_value);
		$new_node->addChild($last); 
		# if there were nodes in between.
		# Add continuation group node.
		if ($num == 0) { 
			$new_node->addChild($sibling); 
			$tree->addChild($new_node);
			#print "ALLA0\n";
			#print_tree($tree);
			return 1;
		}
		else { 
			$tree->addChild($new_node);
			#print "ALLA\n";
			#print_tree($tree);
			return $cont_grp;
		 }
	}
	elsif (! $last->isLeaf ) {
		$cont_grp = insert_complex_node($last, $tag, $sibling, $num);
		if ($cont_grp) {
			#print "CONT $cont_grp\n";
			if($num == 0) {	
				if ($cont_grp ne "1") {
					my $new_node = Tree::Simple->new($cont_grp);
					$new_node->addChild($sibling); 
					$last->addChild($new_node);	
				}
				else {  $tree->addChild($last); }
				#print "ALLA2 second\n";
				#print_tree($tree);
				return 1; 
			}
		}
	}
	$cont_grp = insert_complex_node($tree, $tag, $sibling, $num+1); 

	if ( $cont_grp) { 
		if($num == 0) {
			#print "CONT $cont_grp\n";
			$tree->addChild($last); 
			if ($cont_grp ne "1") {
				my $new_node = Tree::Simple->new($cont_grp);
				$new_node->addChild($sibling); 
				$tree->addChild($new_node);	
			}
			else { $tree->addChild($sibling); }
			
			#print "ALLA3 second\n";
			#print_tree($tree);
			return $cont_grp; 
		}
	}
	else {
		$tree->addChild($last); 
		#print "ALLA3 first\n";
		#print_tree($last);
		#print_tree($tree);
		return $cont_grp; 
	}
	$tree->addChild($last);
	return 0;
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

	# If the right pointing tag is a constituent and not a string.
	if(! $modifier) { $modifier = $constituent->getNodeValue(); }

	verbose("format_rp_modifiers", $modifier , __LINE__);	
	#print "RIGHTOUT *** @$out_aref **\n";

	# Read until the head is found
	(my $tag = $modifier ) =~ s/^(.*?)\:.*$/$1/s;
	#(my $pos = $modifier ) =~ s/^\@\>[DG]?(.*?)\:.*$/$1/s;
	my $out = shift @$out_aref;
	# All the modifiers are for the same head
	if ($embedding == 0) {
		while ($out && ($out =~ /^$tag\:/ || $out !~ /$tagpos{$tag}/ || $out =~ /^[\(\)\.\:\!\?\-]/)) 
		{ 
			push (@tmp_array, $out);
			$out = shift @$out_aref;
		}
	}
	# Try to find the closest head for each modifier
	elsif ($embedding == 1) {
		while ($out && ($out !~ /$tagpos{$tag}/ || $out =~ /^[\(\)\.\:\!\?\-]/)) { 
			push (@tmp_array, $out);
			$out = shift @$out_aref;
		}
	}
	if (! $out) { 
		unshift(@$out_aref, @tmp_array); 
		$subtree->addChild(Tree::Simple->new($modifier)); 
		return 0;
	}

	# Create a node for the complex constituent
	(my $htag = $out ) =~ s/^(.*?)\:.*$/$1/s;
	my $group;
	if ($modifier =~ /(FOBJ|FADVL|FSUBJ|FAUXV)/) {
		$out =~ s/^.*?:V/P:v/;
		$group = $htag . ":icl";
	}
	else { $group = $htag . ":g"; }
	my $dp = Tree::Simple->new($group);

	# create a phrase
	if (! $constituent) { $dp->addChild(Tree::Simple->new($modifier)); }
	else { $dp->addChild($constituent); }
	while (@tmp_array) {
		my $tmp =  shift @tmp_array;
		last if ! $tmp;
		# Format left-pointing modifiers
		if ($tmp =~ /\<\:/) { 
			if (! format_lp_modifiers($tmp, \@tmp_array, $dp)) {
				print "OKOK\n";
			}
			
		}
		elsif ( $tmp =~ /\@CNP\:/) { format_coordination($tmp, \@tmp_array, $dp); }
		else { $dp->addChild(Tree::Simple->new($tmp)); }
	}

	if ($htag =~ /(<|\@\-)/) {
		if (! format_lp_modifiers (0, $out_aref, $subtree, $dp)) {
			if ($htag =~ /(\@\-)/) {
				get_last_child($subtree);
				format_rp_modifiers (0, $out_aref, $subtree, $dp);
			}
		}
		$out =~ s/$htag/H/;
	    $dp->addChild(Tree::Simple->new($out));
	}
	elsif ($htag =~ />|\@\-/) {
		format_rp_modifiers (0, $out_aref, $subtree, $dp);
		$out =~ s/$htag/H/;
	    $dp->addChild(Tree::Simple->new($out));

	}
	else { 
	    $out =~ s/$htag/H/;
	    $dp->addChild(Tree::Simple->new($out));
        $subtree->addChild($dp);
    }
#print "RP\n";
#print_tree($subtree);

}

sub format_auxiliary {
	my ($aux, $out_aref, $subtree) = @_;

	verbose("format_auxiliary", $aux , __LINE__);	

	# Search for the same syntactic tag as in the left coordinator
	my @tmp_array;
	my @tmp_array2;
	my $out2;
	my $out = shift @$out_aref;
	while ($out && ($out !~ /\@\-FAUXV/ && $out !~ /\@\-FMAINV/)) { 
		push (@tmp_array, $out);
		$out = shift @$out_aref;
	}
	if (! $out) { 
		unshift(@$out_aref, @tmp_array); 
		$subtree->addChild(Tree::Simple->new($aux));
		return;
	}
	# If next constituent in the list is coordination,
	# Format that constituent first
	#my $out_node;
	#my $tmp_node;
	#if ($$out_aref[0] =~ /CVP/) {
	#	my $coord = shift @$out_aref;
	#	$tmp_node = Tree::Simple->new($out));
	#	format_coordination($coord, $out_aref, $tmp);
	#	$out_node = get_last_child($tmp);
    #    $out = $out_node->getNodeValue();
	#}

	$aux =~ s/\@\+FAUXV/D:Vaux/;
	$out =~ s/\@\-FMAINV/H/;
	$out =~ s/\:T?V/\:VInf/;
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
		if ($out !~ /VInf/) { $out =~ s/\:V/\:VInf/; }
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

sub format_mainv {
	my ($mainv, $out_aref, $subtree) = @_;

	verbose("format_mainv", $mainv , __LINE__);	

	# Search for the same syntactic tag as in the left coordinator
	my @tmp_array;
	my @tmp_array2;
	my $out2;
	my $out = shift @$out_aref;
	while ($out && ($out !~ /AUXV/ && $out !~ /MAINV/ )) { 
		push (@tmp_array, $out);
		$out = shift @$out_aref;
	}
	if (! $out || $out !~ /\@-FMAINV/) { 
		if ($out) { push(@tmp_array, $out); }
		unshift(@$out_aref, @tmp_array); 
		$subtree->addChild(Tree::Simple->new($mainv));
		return;
	}

	$mainv =~ s/\@\+FMAINV/D/;
	$out =~ s/\@\-FMAINV/H/;
	$out =~ s/\:T?V/\:VInf/;

	# If the predicate was not discontinuous
	# Create a group node and return.
	if (! @tmp_array ) {
		my $group = "P:g";
		my $p = Tree::Simple->new($group, $subtree);
		$p->addChild(Tree::Simple->new($mainv));
		$p->addChild(Tree::Simple->new($out));
		return;
	}
	# If the verbs were discontinuous
	# Create a node for the continuing predicate
	my $group = "P:g-";
	my $p = Tree::Simple->new($group, $subtree);
	
	$p->addChild(Tree::Simple->new($mainv));
	
	# Create the constituents in the middle of the discontinuous constituents
	if (@tmp_array) {
		build_tree(\@tmp_array, $subtree); 
		$group = "-P:g";
		$p = Tree::Simple->new($group, $subtree);
	}
	$p->addChild(Tree::Simple->new($out));
}


# Replace all the cg-tags with visl-tags.
sub replace_tags {
	my $output = shift @_;

	return if (! $output);

#		print "***$output***\n";  # debugging line, nice.

# After the tag revision, there is some revision to do. 
# Earlier, we specified a lot, now we generalise. For some conversions
# we will have to think again.

# Many of the following rules remove directional tags and replace them with =D.
# But the phrase they belong to must be headed before we apply these rules, 
# so that we know whether to look to the right or left for the =H.

# All tags pointing rightwards and not having a rightwards-pointing tag to 
# the left should get a :g tag on the previous line.

	$output =~ s/\@>ADVL/D/g;       #  modifying ADVL
	$output =~ s/\@ADVL</D/g;       # complement of ADVL
	$output =~ s/\@ADVL/A/g;           
	$output =~ s/\@>N/D/g;
	$output =~ s/\@N</D/g;
	$output =~ s/\@APP-.*?</D/g;           # check this one.
	$output =~ s/\@APP>.*?(?=\:)/D/g;           # check this one.
#	$output =~ s/\@CNP/CO/g; # Must be revised, POS-sensitive	      
#	$output =~ s/\@CVP/CO/g; # Must be revised, POS-sensitive	      
#	$output =~ s/\@>N/CJT/g;            # one word A-_ja_B?
	$output =~ s/\@CNP/CC/g;       # --sh
	$output =~ s/\@CVP/CO/g;   # trying to get embedding to work
	$output =~ s/\@>A/D/g;      
	$output =~ s/\@A</D/g;      
	$output =~ s/\@P</D/g;      
	$output =~ s/\@>P/D/g;     	       
	$output =~ s/\@Q</D/g;      
	$output =~ s/\@HNOUN/X/g;         # hmm, is it really X?        
	$output =~ s/\@INTERJ/Ainterj/g;   
	$output =~ s/\@Num</D/g;
	$output =~ s/\@>Num/D/g;
	$output =~ s/\@PRON</D/g;
	$output =~ s/\@Q</D/g; 
	$output =~ s/\@Pron</X/g;
	$output =~ s/\@OBJ/Od/g;
	$output =~ s/\@-FOBJ/Od/g;
	$output =~ s/\@OPRED/Co/g; 	    
	$output =~ s/\@HAB/HAB/g; 	    
	$output =~ s/\@VOC/VOC/g; 	    
	$output =~ s/\@PCLE/Apcle/g;
	$output =~ s/\@SPRED/Cs/g; 
	$output =~ s/\@COMP-CS/D/g; 
###	$output =~ s/\@SUBJ/S:g\n=H:Num/g;   # Revise! This must be contextually used.
	$output =~ s/\@SUBJ/S/g;
	$output =~ s/\@X/X/g;
	$output =~ s/^P:TV/P:v/g;
	$output =~ s/\@\+FAUXV:g/P:g/g;
	$output =~ s/\@\+FAUXV/P:Vaux/g; 
	$output =~ s/\@\-FAUXV/D:Vaux/g;
	$output =~ s/\@\+FMAINV/P/g;       
	$output =~ s/\@\-FMAINV\:T?V/H\:v/g;       
	$output =~ s/\@\-FSUBJ/S/g;            # non-finite subj
	$output =~ s/\:Comp/:adj/g ;
	
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
	$output =~ s/([ ,:])PxPl3/$1poss3pl/g ;
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
	$output =~ s/([ ,:])VInf/$1v/g ;
	$output =~ s/([ ,:])V/$1v/g ;
		
	$output =~ s/--//g;
	
	return $output;
}


sub print_tree {
	my $tree = shift @_;

	print "_______________\n";
	$tree->traverse(sub {
		my ($_tree) = @_;
		my $new_value = $_tree->getNodeValue();
		print (("     =" x $_tree->getDepth()), $new_value, "\n");
	});
	print "\n_______________\n";
	
}

sub verbose {
	my ($from, $word, $linenumber) = @_;
	
	if (!$verbose) {
		return;
	}
	
	print STDERR "[$from:$linenumber] $word\n";
}
