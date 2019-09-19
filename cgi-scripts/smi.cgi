#!/usr/bin/perl -w

# Debugging
#use CGI::Debug;
#use lib '/home/saara/gt/script';

use strict;

use utf8;
use HTML::Entities;
#use Unicode::String qw(utf8 latin1);
use XML::Twig;

use CGI::Minimal;
use CGI;
#use CGI qw/:standard :html3 *table *dl/;
#$CGI::DISABLE_UPLOADS = 0;
# limit posts to 1 meg max
#$CGI::POST_MAX        = 1_024 * 1_024;
use CGI::Alert ('chiara.argese@uit.no', 'http_die');

#use Encode qw( encode_utf8 );
#use JSON::MaybeXS ();
#use JSON::MaybeXS qw(encode_json decode_json);

# Use project's utility functions.
use langTools::Util;
use langTools::XMLStruct;


# Configuration: variable definitions etc.
require "/var/www/cgi-bin/smi/conf.pl";

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
# modified 2012 Heli Uibo, Sjur Moshagen
# modified 2013, 2014 Ciprian Gerstenberger
#
# $Id$
########################################################################

# this CGI script is called whenever a user submits an analysis request
# from the FORM on the different Sami HTML pages

# The script uses Perl module CGI.pm to retrieve and handle
# information from HTML form and generating new HTML pages.

# Variables retrieved from the query.
#our ($text,$pos,$charset,$lang,$plang,$xml_in,$xml_out,$action,$mode,$tr_lang);
our ($text,$pos,$lang,$plang,$xml_in,$xml_out,$action,$mode,$tr_lang,$json);
# Variable definitions, included in smi.cgi
our ($wordlimit,$utilitydir,$bindir,$paradigmfile,%paradigmfiles,$tmpfile,$tagfile,$langfile,$logfile,$div_file);
our ($preprocess,$analyze,$disamb,$dependency,$gen_lookup,$gen_norm_lookup,$generate,$generate_norm,$hyphenate,$transcribe,$convert,$lat2syll,$syll2lat,%avail_pos, %lang_actions, $translate,$placenames);
our ($uit_href,$giellatekno_href,$projectlogo,$unilogo);

##### GET THE INPUT #####
$text="";  #The text to be analysed
my $query = CGI::Minimal->new;
my $query2 = new CGI;

$text = $query->param('text');
$pos = $query->param('pos');
#$charset = $query->param('charset');
$lang = $query->param('lang');
$plang = $query->param('plang');

# Action is either "generate" or "analyze" or "paradigm" or "placenames"
$action = $query->param('action');
# Paradigm mode: minimal, standard, full, full with dialectal variation
$mode = $query->param('mode');
# The language for lemma translation in disambiguation.
$tr_lang = $query->param('translate');
if (! $tr_lang) { $tr_lang = "none"; }

# Input and output can be xml.
$xml_in = $query->param('xml_in');
$xml_out = $query->param('xml_out');

$json = $query->param('json');

if (! $lang && $action ne "placenames" ) { http_die '--no-alert','400 Bad Request',"<b>lang</b> parameter missing.\n" };
if (! $text) { http_die '--no-alert','400 Bad Request',"No text given.\n" };
if (! $action) { http_die '--no-alert','400 Bad Request',"No action given.\n" };

##### INITIALIZE  ####
&init_variables;

# temporary files
#open (FH, ">$tmpfile");
#open (LFH, ">>$logfile");

my @candidates;
my $document;
my $page;
my $form_action="http://gtweb.uit.no/cgi-bin/smi/smi.cgi";
my $body;
my $giellatekno_logo;

# Initialize HTML-page
if(! $xml_out) {
    if ($json eq 'true') {
        $document = XML::Twig->new(keep_encoding => 1);
        if (! $document->safe_parsefile ("$langfile")) {
            print "parsing the XML-file failed: $@\n";
            exit;
        }
        $page = $document->root;

        $body = XML::Twig::Elt->new("body");
        $body->set_pretty_print('record');
        $body->set_empty_tag_style ('expand');
    }
    else {
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

        $giellatekno_logo = XML::Twig::Elt->new(a=>{href=>$giellatekno_href});
        my $img= XML::Twig::Elt->new(img=>{src=>$projectlogo, style=>'border: none;', title=>'Giellatekno'});
        $img->paste('last_child', $giellatekno_logo);

        &printinitialhtmlcodes($action, $page, $body);
    }
}

# Process input XML
if ($xml_in) {
  if ($action eq "analyze" ||
      $action eq "disamb" ||
      $action eq "dependency" ||
      $action eq "hyphenate" ||
      $action eq "transcribe" ||
      $action eq "convert" ||
      $action eq "lat2syll" ||
      $action eq "syll2lat") {
    $text = xml2preprocess($text);
  }
  if ($action eq "generate" ||
      $action eq "paradigm") {
    $text = xml2words($text);
  }
}

# no charset radio buttons
#if($charset eq "latin1") {
#  $text = Unicode::String::latin1( $text);
#}

# Convert html-entity to unicode
decode_entities( $text );

#print LFH "PARAM $action, $lang, $plang";
#if ($action eq "paradigm") { print LFH "$pos"; }
#print LFH "\n$text\n";

# Special characters in the text (e.g. literal ampersands, plus signs
# and equal signs
# typed by the user) must be encoded for transmission, to prevent confusion with
# the delimiters used by CGI); here is the magic formula to undo the CGI encodings
$text =~ s/%(..)/pack("c",hex($1))/ge ;

# Convert digraphs to utf-8
$text = digr_utf8($text);

# Remove the unsecure characters from the input.
#$text =~ s/[;<>\*\|`&\$!\#\(\)\[\]\{\}:'"]/ /g;
$text =~ s/[;<>\*\|`&\$!\#\(\)\[\]\{\}'"]/ /g;  # Deleted colon from this set to avoid removing colon from the word forms as NRK:s (Heli)

# ` This stupid dummy line is here just to restore emacs syntax colouring.

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
my %candits;
my $coloring = "./color_d.pl sme";
my $coloring_a = "./color_a.pl";
if ($action eq "generate")  { $result = `echo $text | $generate_norm`; }
elsif ($action eq "paradigm") { $result = generate_paradigm($text, $pos, \%answer, \%candits); }
elsif ($action eq "disamb") {
  if ($translate) { $result = `echo $text | $disamb | $translate | $coloring`; }
  else { $result = `echo $text | $disamb | $coloring`; }
}
elsif ($action eq "dependency") {
  if ($translate) { $result = `echo $text | $dependency | $translate | $coloring`; }
  else { $result = `echo $text | $dependency | $coloring`; }
}
elsif ($action eq "analyze") { $result = `echo $text | $analyze | $coloring_a`; }
elsif ($action eq "hyphenate") { $result = `echo $text | $hyphenate`; }
elsif ($action eq "transcribe") { $result = `echo $text | $transcribe`; }
elsif ($action eq "convert") { $result = `echo $text | $convert`; }
elsif ($action eq "lat2syll") { $result = `echo $text | $lat2syll`; }
elsif ($action eq "syll2lat") { $result = `echo $text | $syll2lat`; }
elsif ($action eq "placenames") { $result = `echo $text | $placenames`; }
else {
  if (!$xml_out)  { print "<p>No action given</p>"; }
  else { print "<error>No parameter for action recieved</error>"; }
}

# Formatting of the output:
######################################

my $output;
my $out_json;
my $encoded;
if (!$xml_out) {
  if ( $action eq "disamb" ||
       $action eq "dependency") {
    #$result =~ s/</&lt\;/g;
    $output = dis2html($result,1);
    #$output = $result;
  }
  elsif ($action eq "analyze") {
    #$result =~ s/</&lt\;/g;
    $output = dis2html($result,1);
  }
elsif ($action eq "generate") { $output = gen2html($result,0,1); }
  elsif ($action eq "hyphenate") { $output = hyph2html($result,1); }
  elsif ($action eq "transcribe") { $output = hyph2html($result,1); }
  elsif ($action eq "convert") { $output = hyph2html($result,1); }
  elsif ($action eq "lat2syll") { $output = hyph2html($result,1); }
  elsif ($action eq "syll2lat") { $output = hyph2html($result,1); }
  elsif ($action eq "placenames") { $output = dis2html($result,1); }
  # PARADIGM OUTPUT
  elsif ($action eq "paradigm") {
      my $grammar = $page->first_child("grammar");
    # Format error messages
    if ($result == -1) {
      my $no_result = $page->first_child_text("noresult[\@tool='paradigm']");
      if (! $no_result) { $no_result = $page->first_child_text("no_result"); }
      if (! $no_result) { $no_result = "No paradigm found."; }
      my $pos_text = $grammar->first_child_text("pos[\@type='$pos']");
      $pos_text = "$text $pos_text ($pos)";
      my $p=XML::Twig::Elt->new('p');
      my $b=XML::Twig::Elt->new(b=>$pos_text);
      $b->paste('last_child',$p);
      $p->paste('last_child',$body);
      $p=XML::Twig::Elt->new(p=>$no_result);
      $p->paste('last_child',$body);
    }
      if ($json eq 'true') {
          for (my $j=0; $j<$result; $j++) {
              if ($answer{$j}{pos} && $answer{$j}{form}) {
                  my $text2 = $answer{$j}{form} . ": ";
                  if($answer{$j}{anl}) { $text2 .= $answer{$j}{anl} . "   "; }
                  else {
                      $text2 .= $grammar->first_child_text("pos[\@type='$answer{$j}{pos}']");
                      $text2 .= ", $answer{$j}{pos}";
                  }
                  #my $start_json=XML::Twig::Elt->new(start_json=>$text2);
                  my $start_json = '{';
                  $start_json .= $text2;
              }
              # Format paradigm list to html.
              # If minimal mode, show only first paradigm
              $output = gen2json($answer{$j}{para},0,1,$answer{$j}{fulllemma});
              last if (! $mode || $mode eq "minimal");
          }
      }
    else {
      for (my $j=0; $j<$result; $j++) {
        if ($answer{$j}{pos} && $answer{$j}{form}) {
  	my $text2 = $answer{$j}{form} . ": ";
  	if($answer{$j}{anl}) { $text2 .= $answer{$j}{anl} . "   "; }
  	else {
  	  $text2 .= $grammar->first_child_text("pos[\@type='$answer{$j}{pos}']");
  	  $text2 .= " ($answer{$j}{pos})";
  	}
  	my $p=XML::Twig::Elt->new('p');
  	my $b=XML::Twig::Elt->new(b=>$text2);
  	$b->paste('last_child',$p);
  	$p->paste('last_child',$body);
        }
        # Format paradigm list to html.
        # If minimal mode, show only first paradigm
        $output = gen2html($answer{$j}{para},0,1,$answer{$j}{fulllemma});
        $output->paste('last_child', $body);
        last if (! $mode || $mode eq "minimal");
      }
      if (%candits) {
        my $other_forms = $page->first_child_text("otherforms[\@tool='paradigm']");
        my @content;
        my $p=XML::Twig::Elt->new('p');
        my $b=XML::Twig::Elt->new(b=>$other_forms);
        push(@content, $b);
        my $br=XML::Twig::Elt->new('br');
        push(@content, $br);

        for my $c (keys %candits) {
  	$c =~ s/^([^\+]+)/"<font color=\"indianred\">".$1."<\/font>"/e;
  	$c =~ s/(\+)/<font color=\"grey\">$1<\/font>/g;
  	push(@content, $c);
  	my $br_copy = $br->copy;
  	push (@content, $br_copy);
        }
        $p->set_content(@content);
        $p->paste('last_child', $body);
      }
    }
  } # End of paradigm output

  # Paste the result to the html-structure, print final html-codes.
    if ($json ne 'true') {
        if ($output && $action ne "paradigm") { $output->paste('last_child', $body); }
        printfinalhtmlcodes($page, $body) ;
        $body->print;
        print "</html>";
    } else {
	print $query2->header(-type=>'application/json');
	print $output;
    }
} # End of if (!$xml_out)
else {
  if ($result =~ s/ERROR//) { print "<error>$result</error>"; }
  elsif ($action eq "generate" ) { $output = gen2xml($result,0);  }
  elsif ($action eq "paradigm" ) { $output = paradigm2xml($result, \%answer, \%candits, $mode);  }
  elsif ($action eq "hyphenate") { $output = hyph2xml($result); }
  elsif ($action eq "transcribe") { $output = hyph2xml($result); }
  elsif ($action eq "placenames") { $output = hyph2xml($result); }
  elsif ($action eq "convert") { $output = hyph2xml($result); }
  elsif ($action eq "lat2syll") { $output = hyph2xml($result); }
  elsif ($action eq "syll2lat") { $output = hyph2xml($result); }
  elsif ($action eq "analyze") { $output = analyzer2xml($result); }
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
  my ($word, $pos, $answer_href, $cand_href) = @_;

  #print FH "$word $pos\n";

  my %paradigms;
  my $gen_call;
  my $anypos;
  my $answer;
  my $i=0;
  if ($pos eq "Any") { $anypos = 1; }

  #	print FH "GEN-NORM: $gen_norm_lookup\n";
  #	print FH "GEN: $gen_lookup\n";
  #	print FH "PARADIGMFILE: $paradigmfile\n";
  #	if ($mode) { print FH "MODE: $mode\n"; }
  # Initialize paradigm list
  generate_taglist($paradigmfile,$tagfile,\%paradigms);

  my $result = `echo $word | $analyze`;
  my @analyzes = split(/\n+/, $result);

  # Generate paradigm for the given word class
  # when it is given by the user, ie we know the POS:
  if (!$anypos) {
    $answer = call_para($word, \@{$paradigms{$pos}});
    if($answer) {
      $$answer_href{$i}{form} = $text;
      $$answer_href{$i}{pos} = $pos;
      $$answer_href{$i}{para} = $answer;
      for my $a (@analyzes) {
	if ($pos eq "Pron" && $a =~ /$pos/) {
	  my $rest;
	  ($rest, $$answer_href{$i}{anl}) = split(/\s+/, $a);
	}
      }
      $i++;
      if ($pos eq "Pron") { format_pron($answer_href, 0); }
      return $i; # We got the paradigm, stop here and present it.
    }
  }

  # ... but in case we do not know the POS:
  # Pick the POS-tag from analysis and send it back to the paradigm generator.
  my %poses;
  my %derivations;
  my @der_anl;
  for my $anl (@analyzes) {
    next if ($anl =~ /\+\?/);
    my ($lemma, $anl) = split(/\s+/, $anl);

    # Derivations are processed separately
    if ($anl !~ /Der/) {

      # If the word is a compound with no tags in the first parts.
      # e.g. sáme#giel+A+Attr remove the boundary marks.
      # Format compounds that consists of several analyzed parts.
      # Call the baseform generating function (same as in lookup2cg)
      # bátni+N+SgNomCmp#lohku --> bátnelohku+N+Sg+Nom

      my $anlpos;
      my $anllemma;
      my $fulllemma;
      # If the analysis contains #, and does not start with something else than + followed by #
      # it is a compound:
      if ($anl =~/\#/ && $anl !~ /^[^\+]+\#[^\#]+$/) {
	my $anltmp = $anl;
	# Note: Is the following line needed when we negate /Der/ 15 lines further up?
	$anltmp =~ s/\#\+Der\d\+Der\//\#/g;
	$anltmp =~ /^(.*\#.*?)\+(.*)$/;
	$anltmp = $1;
	my $line2 = $2;
	format_compound(\$anltmp, \$line2, \$word);
	$fulllemma=$anltmp;
	($anlpos) = split(/\+/, $line2);
	($anllemma = $anltmp) =~ s/^.*\#([^\#]+)$/$1/;
	#print FH "$anltmp ja $line2 ja $anllemma ja $anlpos\n";
      }
      # if not, it is NOT a compound (nor a derivation):
      else {
	my @line = split (/\+/, $anl);
	$anllemma=$line[0];
	$anlpos=$line[1];
      }
      # pos and word
      next if (! $anypos && $pos ne $anlpos);
      $poses{$anl}{ranking} = 1;
      if ($anllemma =~ s/\#//g) { $poses{$anl}{ranking} = 2; }
      $poses{$anl}{lemma} = $anllemma;
      $poses{$anl}{pos} = $anlpos;

      if ($fulllemma) {
	$poses{$anl}{fulllemma} = $fulllemma;
	$poses{$anl}{ranking} = 3;
      }
      #print FH "POS $anlpos\nlemma $anllemma\nfulllemma  $poses{$anl}{fulllemma}\n";
    }
    # The derivations are treated separately
    elsif ($anl =~ m/^(.+\+(V|N|Adv|A).*?)\+(V|N|Adv|A)\+/) {
      my $word_der=$1;
      my $word_pos=$2;
      next if (! $anypos && $pos ne $word_pos);
      $derivations{$anl}{lemma} = $word_der;
      $derivations{$anl}{pos} = $word_pos;
      push (@der_anl, $anl);
      #print FH "POS $word_pos\n WORD_DER $word_der\n";
    }
  }
  # Select the analyses for the best match for the user input.
  my $first_cand;
  my $cand_p;
  my $cand_w;
  my $cand_anl;
  my $cand_fulllemma;
  my @analyzes_noder = sort { $poses{$a}{ranking} <=> $poses{$b}{ranking} } keys %poses;
  if (! %$answer_href || $anypos) {
    for my $anl (@analyzes_noder) {
      if ($poses{$anl}{pos} eq $pos || $anypos) {
	if ($poses{$anl}{lemma} eq $word && $avail_pos{$poses{$anl}{pos}}) {
	  #print FH "FIRST $anl\n";
	  $first_cand = $poses{$anl};
	  $cand_p = $poses{$anl}{pos};
	  $cand_w = $poses{$anl}{lemma};
	  if ($poses{$anl}{fulllemma}) {
	    $cand_fulllemma = $poses{$anl}{fulllemma};
	  }
	  $cand_anl = $anl;
	}
	else {
	  push (@candidates, $anl);
	}
      }
    }
    # If the lemma matches to the input, generate paradigm
  FIRST_CAND: {
      if ($first_cand) {
	$answer = call_para($cand_w, \@{$paradigms{$cand_p}});
	if (! $answer) { $first_cand=0; $$cand_href{$cand_anl}=1; last FIRST_CAND; }
	$$answer_href{$i}{form} = $text;
	$$answer_href{$i}{pos} = $cand_p;
	$$answer_href{$i}{anl} = $cand_anl;
	$$answer_href{$i}{fulllemma} = $cand_fulllemma;
	$$answer_href{$i}{para} = $answer;
	$i++;
      }
    }
    # If there was no exact match pick the first analysis.
    if(! $first_cand && @candidates) {
      while(@candidates) {
	my $anl = shift(@candidates);
	$answer = call_para($poses{$anl}{lemma}, \@{$paradigms{$poses{$anl}{pos}}});
	if (! $answer) { next; }
	$$answer_href{$i}{form} = $text;
	$$answer_href{$i}{pos} = $poses{$anl}{pos};
	$$answer_href{$i}{anl} = $anl;
	$$answer_href{$i}{fulllemma} = $poses{$anl}{fulllemma};
	$$answer_href{$i}{para} = $answer;
	$i++;
	last;
      }
    }
  }
  for my $c (@candidates) {
    if ($$answer_href{0}{pos} ne $poses{$c}{pos}) { $$cand_href{$c}=1; }
  }

  for my $d (@der_anl) {

    # If one derivations is included, next ones go to candidates.
    if ($$answer_href{$i-1}{der}) {  $$cand_href{$d}=1; next; }
    my $p = $derivations{$d}{pos};
    my $lemma = $derivations{$d}{lemma};
    $answer = call_para($lemma, \@{$paradigms{$p}});

    if ($answer) {
      if (! $$answer_href{form} ) {
	$$answer_href{$i}{form} = $text;
	$$answer_href{$i}{pos} = $p;
	$$answer_href{$i}{anl} = $d;
	$$answer_href{$i}{para} = $answer;
	$$answer_href{$i}{der} = 1;
	$i++;
      }
    }
  }
  if (! $$answer_href{0}) { $i=-1; }
  else {
    for (my $j=0; $j<$i; $j++) {
      if ($$answer_href{$j}{pos} eq "Pron") { format_pron($answer_href, $j); }
    }
  }
  return $i;
}


# Don't include pronouns in all persons, just the asked one.
sub format_pron {
  my ($answer_href, $j) = @_;

  my @tags=split(/\+/, $$answer_href{$j}{anl});
  my $number = $tags[3];
  my @paras = split (/\n/, $$answer_href{$j}{para});
  my @newparas;
  for my $p (@paras) {
    if ($p =~ /Refl/)  { push (@newparas, $p); next; }
    next if (($mode && $mode ne "full") && $p !~ /$number/);
    push (@newparas, $p);
  }
  $$answer_href{$j}{para} = join("\n\n", @newparas);
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
    #print FH "FORMS $all";
    my $generated;
    if ($mode && $mode eq "dialect") {
      #print FH "GEN $gen_lookup\n";
      $generated = `echo \"$all\" | $gen_lookup`;
    }
    else {
      $generated = `echo \"$all\" | $gen_norm_lookup`;
      #print FH "GEN $gen_norm_lookup\n";
    }
    my @all_cand = split(/\n+/, $generated);
    for my $a (@all_cand) {
      if ($a !~ /\+\?/) {
	$answer .= $a . "\n\n";
      }
    }
    #		if ($answer) { print FH "ANS $answer";}
  }

  return $answer;
}

sub printinitialhtmlcodes {
  my ($tool,$texts,$body) = @_;

  my $tmp_tool = $tool;
  if ($tool =~ /hyphenate|transcribe|convert|lat2syll|syll2lat|disamb|dependency/) { $tmp_tool = "analyze"; }
  #	print FH "TOOL $tool $tmp_tool\n";

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
  my $form = XML::Twig::Elt->new(form => {action=>$form_action,method=>'get',target=>'_self',name=>'form3'});

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
    my $textarea = XML::Twig::Elt->new(input => {type=>'text',name=>'text','size'=>50});
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
      if ($lang_actions{$m}) {
	my $input = XML::Twig::Elt->new(input=>{type=> 'radio',name=> 'mode',value=> $m},$labels{$m});
	if ($mode && $mode eq $m ) { $input->set_att("checked", 1); }
	$input->paste('last_child', $td);
	my $br = XML::Twig::Elt->new('br');
	$br->paste('last_child', $td);
      }
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

  ##### PLACENAMES
  elsif ($tmp_tool =~ /placenames/) {

    my $tr = XML::Twig::Elt->new("tr");
    my $td = XML::Twig::Elt->new("td");
    my $textarea = XML::Twig::Elt->new(input => {type=>'text',name=>'text','size'=>50});
    $textarea->paste('last_child', $td);

    #my $input= XML::Twig::Elt->new(input=> {type=> 'hidden',name=>'lang',value=> $lang});
    #$input->paste('last_child', $td);
    my $input= XML::Twig::Elt->new(input=> {type=> 'hidden',name=>'plang',value=> $plang});
    $input->paste('last_child', $td);
    $input= XML::Twig::Elt->new(input=> {type=> 'hidden',name=>'action',value=> 'placenames'});
    $input->paste('last_child', $td);

    $td->paste('last_child', $tr);
    $td = XML::Twig::Elt->new('td');
    $giellatekno_logo->paste('last_child',$td);

    $td->paste('last_child', $tr);
    $tr->paste('last_child', $table);

  } # end of GENERATOR

  ##### analyze/hyphenate/transcribe/convert/lat2syll/syll2lat/disambiguate/dependency
  else {
    # Get the texts for selection menu
    my @tools = qw(analyze disamb dependency hyphenate convert lat2syll syll2lat transcribe);
    my %labels;

    for my $t (@tools) {
      next if (! $lang_actions{$t});
      $labels{$t} = $selection->first_child_text("\@tool='$t'" );
      if ($t eq "disamb" && $lang_actions{translate}) {
	my $lang_texts = $texts->first_child("selection[\@tool='translate']");
	if ($lang_texts) {
	  for my $l (keys %{$lang_actions{translate}}) {
	    $labels{translate}{$l} = $lang_texts->first_child_text("select[\@lang='$l']");
	  }
	  $labels{translate}{none} = $lang_texts->first_child_text("select[\@lang='none']");
	}
      }
    }
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
    my @tmp;

    # Print the radiobuttons for the available tools
    for my $l ( @tools) {
      next if ( ! $lang_actions{$l});
      my $input = XML::Twig::Elt->new(input=>{type=> 'radio',name=> 'action',value=> $l},$labels{$l});
      if ($tool eq $l ) { $input->set_att('checked', 1); }
      push (@tmp, $input);

      # Add translation radio buttons besides the
      # disambiguation button.
      if ($l eq "disamb" && $lang_actions{translate}) {
	my $text = "&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;[";
	push (@tmp, $text);
	for my $lg (keys %{$lang_actions{translate}}) {
	  my $text = $labels{translate}{$lg};
	  my $input2 = XML::Twig::Elt->new(input=>{type=> 'radio',name=> 'translate',value=>$lg},$text);
	  if ($tr_lang eq $lg ) { $input2->set_att('checked', 1); }
	  push (@tmp, $input2);
	}
	$text = $labels{translate}{none};
	my $input2 = XML::Twig::Elt->new(input=>{type=> 'radio',name=> 'translate',value=>'none'},$text);
	if ($tr_lang eq 'none') { $input2->set_att(checked=>'yes'); }
	push (@tmp, $input2);
	$text = "&#160;]";
	push (@tmp, $text);
      }
      my $br = XML::Twig::Elt->new('br');
      push (@tmp, $br);
    }
    my $input= XML::Twig::Elt->new(input=> {type=> 'hidden',name=>'lang',value=> $lang});
    push (@tmp, $input);
    $input= XML::Twig::Elt->new(input=> {type=> 'hidden',name=>'plang',value=> $plang});
    push (@tmp, $input);

    $td = XML::Twig::Elt->new("td");
    $td->set_content(@tmp);

    $td->paste('last_child', $tr);
    $tr->paste('last_child', $table);

  } # end of analyze/hyphenate/transcribe/convert/lat2syll/syll2lat/disambiguate/dependency

  # Submit and reset texts
  my $submit_text = $texts->first_child_text("input[\@type='submit']");
  my $reset_text = $texts->first_child_text("input[\@type='reset']");

  $tr = XML::Twig::Elt->new("tr");
  $td = XML::Twig::Elt->new("td");
  my $input = XML::Twig::Elt->new(input=>{type=> 'submit',value=> $submit_text});
  $input->paste('last_child', $td);
  $input = XML::Twig::Elt->new(input=>{type=> 'reset',value=> $reset_text});
  $input->paste('last_child', $td);
  #disable utf8 and latin1 radio buttons
  #my $input_utf8 = XML::Twig::Elt->new(input=> {type=> 'radio',name=> 'charset',value=>'utf-8'},'utf-8');
  #my $input_l1 = XML::Twig::Elt->new(input=>{type=> 'radio',name=> 'charset',value=> 'latin-1'},'latin-1');

  #if ($charset eq "latin-1") { $input_l1->set_att('checked'=>1); }
  #else { $input_utf8->set_att('checked'=>1); }

  #$input_utf8->paste('last_child',$td);
  #$input_l1->paste('last_child',$td);
  $td->paste('last_child', $tr);

  $tr->paste('last_child', $table);
  $table->paste('last_child', $form);
  $form->paste('last_child', $body);

}

sub print_header {
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

sub printfinalhtmlcodes {
  my ($texts, $body) = @_;

  my $copyright = $texts->first_child_text('CC-BY');

  my $hr = XML::Twig::Elt->new('hr');
  $hr->paste('last_child', $body);
  my $p = XML::Twig::Elt->new(p=> $copyright);
  my $br = XML::Twig::Elt->new('br');
  $br->paste('last_child', $p);
  my $a = XML::Twig::Elt->new(a=> {href=>'http://giellatekno.uit.no/doc/lang/sme/docu-mini-smi-grammartags.html'},'Morphological tags');
  $a->paste('last_child', $p);
  $p->paste('last_child', $body);

}

sub printwordlimit {
  #    print $out->b("\nWord limit is $wordlimit.\n");
}
