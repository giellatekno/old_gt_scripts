#!/usr/bin/perl -w

use CGI::Debug;
use strict;

use utf8;
use HTML::Entities;
use Unicode::String qw(utf8 latin1);
use XML::Twig;

use CGI::Minimal;

#use CGI qw/:standard :html3 *table *dl/;
$CGI::DISABLE_UPLOADS = 0;
# limit posts to 1 meg max
$CGI::POST_MAX        = 1_024 * 1_024; 
use CGI::Alert ('saara', 'http_die');

# Use project's utility functions.
use langTools::Util;
use langTools::XMLStruct;

# Configuration: variable definitions etc.
require "conf.pl";

########################################################################
#
#smi-cg.cgi
#
# resides:  Web Folder:cgi-bin:smi:smi.cgi
#
#       called from HTML; output HTML
#
# Original written by Ken Beesley, Xerox, for Aymara.
# reviewed and modified 12 april 2002, Trond Trosterud
# reviewed and modified 2006,2007 Saara Huhmarniemi
#
# $Id$
########################################################################

# this CGI script is called whenever a user submits an analysis request
# from the FORM on the different Sami HTML pages

# The script uses Perl module CGI.pm to retrieve and handle 
# information from HTML form and generating new HTML pages.

# Variables retrieved from the query.
our ($text,$pos,$charset,$lang,$plang,$xml_in,$xml_out,$action,$mode);
# Variable definitions, included in smi.cgi
our ($wordlimit,$utilitydir,$bindir,$paradigmfile,%paradigmfiles,$tmpfile,$tagfile,$langfile,$logfile,$div_file);
our ($preprocess,$analyze,$disamb,$gen_lookup,$generate,$hyphenate,%avail_pos,%languages);
our ($uit_href,$giellatekno_href,$projectlogo,$unilogo);

##### GET THE INPUT #####

$text="";  #The text to be analysed
my $query = CGI::Minimal->new;

$text = $query->param('text');
$pos = $query->param('pos');
$charset = $query->param('charset');
$lang = $query->param('lang');
$plang = $query->param('plang');

# Action is either "generate" or "analyze" or "paradigm"
$action = $query->param('action');
$mode = $query->param('mode');

# Input and output can be xml.
$xml_in = $query->param('xml_in');
$xml_out = $query->param('xml_out');

if (! $lang) { http_die '--no-alert','400 Bad Request',"<b>lang</b> parameter missing.\n" };
if (! $text) { http_die '--no-alert','400 Bad Request',"No text given.\n" };

##### INITIALIZE  ####



&init_variables;

# temporary files
open (FH, ">$tmpfile");
open (LFH, ">>$logfile");

my @candidates;
my $document;
my $page;
my $form_action="http://sami-cgi-bin.uit.no/cgi-bin/test/smi.cgi";
my $body;
my $giellatekno_logo;

# Initialize HTML-page
if(! $xml_out) {
	# Parse language file.
	$document = XML::Twig->new(keep_encoding => 1);
	if (! $document->safe_parsefile ("$langfile")) {
		print "parsing the XML-file failed: $@\n";
		exit;
	}                                                                                                   
	$page = $document->root;

	$body = XML::Twig::Elt->new("body");
	$body->set_pretty_print('record');
	$body->set_empty_tag_style ('expand');

	my $a = XML::Twig::Elt->new(a=>{href=>$uit_href},'The University of Troms&oslash; >');
	$a->paste('last_child',$body);
	$a = XML::Twig::Elt->new(a=>{href=>$giellatekno_href},'Giellatekno >');
	$a->paste('last_child',$body);
	my $br = XML::Twig::Elt->new('br');
	$br->paste('last_child', $body);

#	$a = XML::Twig::Elt->new(a=>{href=>$uit_href});
#	my $img = XML::Twig::Elt->new(img=>{src=>$unilogo, title=>'The University of Tromsø'});
#	$img->paste('last_child',$a);
#	$a->paste('last_child',$body);
	
	$giellatekno_logo = XML::Twig::Elt->new(a=>{href=>$giellatekno_href});
	my $img= XML::Twig::Elt->new(img=>{src=>$projectlogo, title=>'Giellatekno'});
	$img->paste('last_child',$giellatekno_logo);

	&printinitialhtmlcodes($action, $page,$body);
}

	

# Process input XML
if ($xml_in) {
	if ($action eq "analyze" || $action eq "disamb" || $action eq "hyphenate") {
		$text = xml2preprocess($text);
	}
	if ($action eq "generate" || $action eq "paradigm") { $text = xml2words($text); }
}

if($charset eq "latin1") { $text = Unicode::String::latin1( $text); }

# Convert html-entity to unicode
decode_entities( $text );

print LFH "PARAM $action, $lang, $plang";
if ($action eq "paradigm") { print LFH "$pos, $mode"; }
print LFH "\n$text\n";

# Special characters in the text (e.g. literal ampersands, plus signs
# and equal signs 
# typed by the user) must be encoded for transmission, to prevent confusion with
# the delimiters used by CGI); here is the magic formula to undo the CGI encodings
$text =~ s/%(..)/pack("c",hex($1))/ge ;

# Convert digraphs to utf-8
$text = digr_utf8($text);

# Remove the unsecure characters from the input.
$text =~ s/[;<>\*\|`&\$!\#\(\)\[\]\{\}:'"]/ /g; 

# Change linebreaks to space and check the word limit
my @words = split(/[\s]+/, $text);
$text = join(' ', splice(@words,0,$wordlimit));
if (@words && ! $xml_out) { &printwordlimit; }

# And here is where the actual lookup gets done:
# ###############################################
# 1.  echo the input string to preprocessor,
# 2.  pipe the now tokenized text (one word per line) to the lookup application
#         (which has some flags set, and which accesses sme.fst)
# 3.  The output of lookup is assigned as the value of $result


my $result;
my %answer;
if ($action eq "generate")  { $result = `echo $text | $generate`; }
elsif ($action eq "paradigm") { $result = generate_paradigm($text, $pos, \%answer); }
elsif ($action eq "disamb") { $result = `echo $text | $disamb`; }
elsif ($action eq "analyze") { $result = `echo $text | $analyze`; }
elsif ($action eq "hyphenate") { $result = `echo $text | $hyphenate | cut -f2 | tr '\012' ' '`; }
else { 
if (!$xml_out)  { print "<p>No action given</p>"; }
else { print "<error>No parameter for action recieved</error>"; }
}

# Formatting of the output:
######################################

my $output;

if (! $xml_out) {
	if ($action eq "analyze" || $action eq "disamb") { 
          $result =~ s/</&lt\;/g; 
          $output = dis2html($result,1);
    }
	elsif ($action eq "generate") { $output = gen2html($result,0,1);  } 
	elsif ($action eq "hyphenate") { $output = hyph2html($result,1); }

    elsif ($action eq "paradigm") {
      my $grammar = $page->first_child("grammar");

      if ($answer{noparadigm}) {
	     my $no_result = $page->first_child_text("noresult[\@tool='paradigm']");
         if (! $no_result) { $page->first_child_text("no_result"); }
  	     my $pos_text = $grammar->first_child_text("pos[\@type='$pos']");

         $pos_text = "$text $pos_text ($pos)";
         my $p=XML::Twig::Elt->new(p=>$no_result);
         my $b=XML::Twig::Elt->new(b=>$pos_text);
         $b->paste('last_child',$p);
         $p->paste('last_child',$body);

      }
      if ($answer{pos} && $answer{form}) { 
         my $text2 = $answer{form} . " ";
	     $text2 .= $grammar->first_child_text("pos[\@type='$answer{pos}']");
         $text2 .= " ($answer{pos})";
         my $p=XML::Twig::Elt->new('p');
         my $b=XML::Twig::Elt->new(b=>$text2);
         $b->paste('last_child',$p);
         $p->paste('last_child',$body);
      }
      if ($result) { 
           $output = gen2html($result,0,1); 
           $output->paste('last_child', $body); 
      }
	  if ($answer{candidates}) { 
	     my $other_forms = $page->first_child_text("otherforms[\@tool='paradigm']");
         my @content;
         my $p=XML::Twig::Elt->new('p');
         my $b=XML::Twig::Elt->new(b=>$other_forms);
         push(@content, $b);
         my $br=XML::Twig::Elt->new('br');
         push(@content, $br);

		for my $c (keys %{$answer{candidates}}) { 
            push(@content, $c);
            my $br_copy = $br->copy;
            push (@content, $br_copy);
	    }
        $p->set_content(@content);
        $p->paste('last_child', $body);
    }
    }

    # Paste the result to the html-structure, print final html-codes.
    if ($output && $action ne "paradigm") { $output->paste('last_child', $body); }
	printfinalhtmlcodes($page, $body) ;
    $body->print;
    print "</html>";
}
else {
	if ($result =~ s/ERROR//) { print "<error>$result</error>"; }
	elsif ($action eq "generate" || $action =~ /paradigm/) { $output = gen2xml($result);  } 
	elsif ($action eq "hyphenate") { $output = hyph2xml($result); }
	else { $output = dis2xml($result); }
print $output;
}

# end



######################################################################
#
#                   Subroutines from Here On
#
######################################################################

sub generate_paradigm {
	my ($word, $pos, $answer_href) = @_;
	
	print FH "$word $pos\n";

	my %paradigms;
	my $gen_call;
	my %all_ans;
	my $anypos;
	my $answer;
	if ($pos eq "Any") { $anypos = 1; }

    # Initialize paradigm list
	generate_taglist($paradigmfile,$tagfile,\%paradigms);

	# Generate paradigm for the given word class
	if (! $anypos) {
		$answer = call_para($word, \@{$paradigms{$pos}});
		if($answer) { 	
			$all_ans{$answer} = 1;
			$$answer_href{form} = "$text";
			$$answer_href{pos} = "$pos";
			if ($xml_out) { return $answer; }
		}
	}
	# If there was no answer, try to analyze the input word.
	# Pick the POS-tag and send it pack to the paradigm generator.
	my $result = `echo $word | $analyze`;
	my @answers = split(/\n+/, $result);

	print FH "echo $word | $analyze\n";
	print FH "ANALYSIS $result\n";
	
	# Check the pos tag and derivation
	my %poses;
	my %derivations;
	my @answers_clean;
	for my $ans (@answers) {
		next if ($ans =~ /\+\?/);
		my ($lemma, $ans) = split(/\s+/, $ans);
		if ($ans !~ /Der/) { 
			my @line = split (/\+/, $ans);
			my $p = $line[1];
			my $w = $line[0];

			next if (! $anypos && $pos ne $p);
			$poses{$ans}{'lemma'} = $w;
			$poses{$ans}{'pos'} = $p;
			push (@answers_clean, $ans);
		}
	    elsif ($ans =~ m/^(.*?(V|N|Adv|A).*?)\+(V|N|Adv|A)\+/) {
			my $word_der=$1;
			my $word_pos=$2;
            next if (! $anypos && $pos ne $word_pos);
			$derivations{$word_der} = $word_pos;
			print FH "POS $word_pos\n WORD_DER $word_der\n";
		}
	}
	# Search the analyses for the best match for the user input.
	my $first_cand;
	my $cand_p;
	my $cand_w;
	if (! %all_ans || $anypos) {
		for my $ans (@answers_clean) {
			if ($poses{$ans}{pos} eq $pos || $anypos) {
				if ($poses{$ans}{lemma} eq $word && $avail_pos{$poses{$ans}{pos}}) {
					print FH "FIRST $ans\n";
					$first_cand = $poses{$ans};
					$cand_p = $poses{$ans}{pos};
					$cand_w = $poses{$ans}{lemma};
				}
				else {
					print FH "CAND $ans\n";
					push (@candidates, $ans);
                }
            }
		}
		# If the lemma matches to the input, generate paradigm
		if ($first_cand) {
			$$answer_href{form} = "$text";
			$$answer_href{pos} = "$cand_p";
			$answer = call_para($cand_w, \@{$paradigms{$cand_p}});
			if ($answer) { $all_ans{$answer}=2; }
		}
		# If there was no exact match pick the first analysis.
		elsif(@candidates) {
			my $ans = shift(@candidates);
			$$answer_href{form} = "$text";
			$$answer_href{pos} = "$poses{$ans}{pos}";
			$answer = call_para($poses{$ans}{lemma}, \@{$paradigms{$poses{$ans}{pos}}});
			if ($answer) { $all_ans{$answer}=2; }
		}
    }
	for my $c (@candidates) {
		if ($$answer_href{pos} ne $poses{$c}{pos}) { $$answer_href{candidates}{$c}=1; }
	}
	for my $d (keys %derivations) {
		my $p = $derivations{$d};
		$answer = call_para($d, \@{$paradigms{$p}});
		if ($answer) { 
			$all_ans{$answer}=3; 
			if (! $$answer_href{form} ) {
				$$answer_href{form} = "$text";
				$$answer_href{pos} = "$p";
			}
		}
	}
	if(! %all_ans) {
		$$answer_href{noparadigm}=1;
		$$answer_href{form}="";
		$$answer_href{pos}="";
		print FH "NOANSWER\n";
	}
	else {
		$answer="";
		for my $key (sort { $all_ans{$a} <=> $all_ans{$b} } keys %all_ans) {
			$answer .= $key;
			$answer .= "\n";
			print FH "ANSWER2 $key OK\n";
		}		
	}
	return $answer;
}

# Call paradigm generator
sub call_para {

	my ($word, $para_aref) = @_;

	my $answer;
	my $all;
	for my $a ( @$para_aref ) {
		my $string = "$word+$a";
		$all .= $string . "\n";
	}
	if ($all) {
		print FH "FORMS $all";
		my $generated = `echo \"$all\" | $gen_lookup`;
		my @all_cand = split(/\n+/, $generated);
		for my $a (@all_cand) { if ($a !~ /\+\?/) { $answer .= $a . "\n\n"; } }
		if ($answer) { print FH "ANS $answer";}
	}

	return $answer;
}

sub printinitialhtmlcodes {
	my ($tool,$texts,$body) = @_;

	my $tmp_tool = $tool;
	if ($tool =~ /hyphenate|disamb/) { $tmp_tool = "analyze"; }
	print FH "TOOL $tool $tmp_tool\n";

	# Read the texts from the XML-file.

	# Header title
	my $title = $texts->first_child_text("title[ \@tool='$tmp_tool' and \@lang='$lang']");
	if (! $title) { $title = $texts->first_child_text("title[\@tool='$tmp_tool']"); }
	
	# First title on the texts
#	my $h1 = $texts->first_child_text("h1[\@tool='$tmp_tool' and \@lang='$lang']");
#	if (! $h1) { $h1 = $texts->first_child_text("h1[\@tool='$tmp_tool']"); }
#	if ($h1) { my $h1_new=XML::Twig::Elt->new(p=>$h1);
#			   $h1_new->paste( 'last_child', $body); }
	
	# References to the form texts
	my $selection = $texts->first_child("selection[\@tool='$tmp_tool' and \@lang='$lang']"); 
	if (! $selection) { $selection = $texts->first_child("selection[\@tool='$tmp_tool']"); }

	# Instructions for the user
	my $instruction = $texts->first_child_text("instruction[\@tool='$tmp_tool' and \@lang='$lang']"); 
	if (! $instruction) { $instruction = $texts->first_child_text("instruction[\@tool='$tmp_tool']"); }

	my $p = XML::Twig::Elt->new(p => $instruction);
	$p->paste('last_child', $body);
	# Header and main titles are the same for all tools
	print_header($title,$body);
	my $form = XML::Twig::Elt->new(form => {action=>$form_action,method=>'get',target=>'top',name=>'form3'});

	my $table = XML::Twig::Elt->new(table => {border=> 0,cellspacing=> 1,cellpadding=> 2});
	my $tr = XML::Twig::Elt->new("tr");
	my $td = XML::Twig::Elt->new("td");


	###### PARADIGM
	if ($tmp_tool =~ /paradigm/) {
		
		# Get the texts for selection menu
		my %labels;
		my @modes = qw(minimal standard full);
		for my $m (@modes) { $labels{$m} = $selection->first_child_text("\@type='$m'"); }

		my %pos_labels;
		my @poses;
		my $grammar = $texts->first_child('grammar');
		for my $p ($grammar->children('pos')) {
			my $type = $p->{'att'}->{'type'};
			push (@poses, $type);
			$pos_labels{$type} = $p->text;
		}
		my $tr = XML::Twig::Elt->new('tr');
		my $td = XML::Twig::Elt->new('td');
		my $textarea = XML::Twig::Elt->new(input => {type=>'text',name=>'text','rows'=>2,'cols'=>50});
		$textarea->paste('last_child', $td);

		my $select = XML::Twig::Elt->new(select => {name => 'pos'});

		for my $label (@poses) {
			my $option = XML::Twig::Elt->new(option=>{value=>$label},$pos_labels{$label});
			$option->paste('last_child', $select);
		}
		$select->paste('last_child', $td);
		$td->paste('last_child', $tr);
		$td = XML::Twig::Elt->new('td');
		$giellatekno_logo->paste('last_child',$td);

		$td->paste('last_child', $tr);
		$tr->paste('last_child', $table);

		$tr = XML::Twig::Elt->new("tr");
		$td = XML::Twig::Elt->new("td");
		
		for my $m (@modes) {
			my $input = XML::Twig::Elt->new(input=>{type=> 'radio',name=> 'mode',value=> $m},$labels{$m});
			if ($mode eq $m ) { $input->set_att("checked", 1); }
			$input->paste('last_child', $td);
			my $br = XML::Twig::Elt->new('br');
			$br->paste('last_child', $td);

		}
		my $input= XML::Twig::Elt->new(input=> {type=> 'hidden',name=>'lang',value=> $lang});
		$input->paste('last_child', $td);
		$input= XML::Twig::Elt->new(input=> {type=> 'hidden',name=>'plang',value=> $plang});
		$input->paste('last_child', $td);
		$input= XML::Twig::Elt->new(input=> {type=> 'hidden',name=>'action',value=> 'paradigm'});
		$input->paste('last_child', $td);

		$td->paste('last_child', $tr);
		$tr->paste('last_child', $table);

	} # end of PARADIGM
	
	##### GENERATOR
	elsif ($tmp_tool =~ /generate/) {
		
		my $tr = XML::Twig::Elt->new("tr");
		my $td = XML::Twig::Elt->new("td");
		my $textarea = XML::Twig::Elt->new(input => {type=>'text',name=>'text','size'=>50});
		$textarea->paste('last_child', $td);
		
		my $input= XML::Twig::Elt->new(input=> {type=> 'hidden',name=>'lang',value=> $lang});
		$input->paste('last_child', $td);
		$input= XML::Twig::Elt->new(input=> {type=> 'hidden',name=>'plang',value=> $plang});
		$input->paste('last_child', $td);
		$input= XML::Twig::Elt->new(input=> {type=> 'hidden',name=>'action',value=> 'generate'});
		$input->paste('last_child', $td);

		$td->paste('last_child', $tr);
		$td = XML::Twig::Elt->new('td');
		$giellatekno_logo->paste('last_child',$td);

		$td->paste('last_child', $tr);
		$tr->paste('last_child', $table);

	} # end of GENERATOR

	##### analyze/hyphenate/disambiguate
	else {
		# Get the texts for selection menu
		my %labels;

		$labels{analyze} = $selection->first_child_text('@tool="analyze"');
		$labels{disamb} = $selection->first_child_text('@tool="disamb"');
		$labels{hyphenate} = $selection->first_child_text('@tool="hyphenate"');

		my $tr = XML::Twig::Elt->new("tr");
		my $td = XML::Twig::Elt->new("td");
		my $textarea = XML::Twig::Elt->new(textarea => {wrap=>'virtual',type=>'text',name=>'text','rows'=>6,'cols'=>50});
		$textarea->paste('last_child', $td);

		$td->paste('last_child', $tr);
		$td = XML::Twig::Elt->new('td');
		$giellatekno_logo->paste('last_child',$td);


		$td->paste('last_child',$tr);
		$tr->paste('last_child', $table);
		$tr = XML::Twig::Elt->new("tr");
		$td = XML::Twig::Elt->new("td");

		for my $l (sort { $a cmp $b } keys %labels) {
			my $input = XML::Twig::Elt->new(input=>{type=> 'radio',name=> 'action',value=> $l},$labels{$l});
			if ($tool eq $l ) { $input->set_att('checked', 1); }
			$input->paste('last_child', $td);
			my $br = XML::Twig::Elt->new('br');
			$br->paste('last_child', $td);
		}
		my $input= XML::Twig::Elt->new(input=> {type=> 'hidden',name=>'lang',value=> $lang});
		$input->paste('last_child', $td);
		$input= XML::Twig::Elt->new(input=> {type=> 'hidden',name=>'plang',value=> $plang});
		$input->paste('last_child', $td);

		$td->paste('last_child', $tr);
		$tr->paste('last_child', $table);
			
		} # end of analyze/hyphenate/disambiguate

	# Submit and reset texts
	my $submit_text = $texts->first_child_text("input[\@type='submit']");
	my $reset_text = $texts->first_child_text("input[\@type='reset']");

#	$tr = XML::Twig::Elt->new("tr");

#	$tr->paste('last_child', $table);

	$tr = XML::Twig::Elt->new("tr");
	$td = XML::Twig::Elt->new("td");
	my $input = XML::Twig::Elt->new(input=>{type=> 'submit',value=> $submit_text});
	$input->paste('last_child', $td);
	$input = XML::Twig::Elt->new(input=>{type=> 'reset',value=> $reset_text});
	$input->paste('last_child', $td);

	my $input_utf8 = XML::Twig::Elt->new(input=> {type=> 'radio',name=> 'charset',value=>'utf-8'},'utf-8');
	my $input_l1 = XML::Twig::Elt->new(input=>{type=> 'radio',name=> 'charset',value=> 'latin-1'},'latin-1');

	if ($charset eq "latin-1") { $input_l1->set_att('checked'=>1); }
	else { $input_utf8->set_att('checked'=>1); }

	$input_utf8->paste('last_child',$td);
	$input_l1->paste('last_child',$td);
	$td->paste('last_child', $tr);

	$tr->paste('last_child', $table);
	$table->paste('last_child', $form);
	$form->paste('last_child', $body);
	
}

sub print_header
{
	my ($title) = shift @_;
	print <<EOH ;
Content-type: text/html

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
                <html>
                <head>
                <meta http-equiv="Content-type" content="text/html; charset=UTF-8">
EOH
	print "<title>$title</title></head>";

}


sub printfinalhtmlcodes
{
	my ($texts, $body) = @_;

	my $copyright = $texts->first_child_text('copyright');

	my $hr = XML::Twig::Elt->new('hr');
	$hr->paste('last_child', $body);
	my $p = XML::Twig::Elt->new(p=> $copyright);
	my $br = XML::Twig::Elt->new('br');
	$br->paste('last_child', $p);
	my $a = XML::Twig::Elt->new(a=> {href=>'http://giellatekno.uit.no/'},'http://giellatekno.uit.no/');
	$a->paste('last_child', $p);
	$p->paste('last_child', $body);

}



sub printwordlimit {
#    print $out->b("\nWord limit is $wordlimit.\n");	
}


