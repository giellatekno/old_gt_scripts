#!/usr/bin/perl

use warnings;
use strict;

use HTML::Entities;
use Unicode::String qw(utf8 latin1);

use CGI qw/:standard :html3 *table *dl/;
$CGI::DISABLE_UPLOADS = 0;
$CGI::POST_MAX        = 1_024 * 1_024; # limit posts to 1 meg max

# Forwarding warnings and fatal errors to browser window
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

# Use project's utility functions.
use langTools::Util;
use langTools::XMLStruct;
use Expect;

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

my $wordlimit = 250 ;       # adjust as appropriate; prevent large-scale (ab)use

# GET THE INPUT

my $text="";  #The text to be analysed

my $query = new CGI;
$text = $query->param('text');
my $pos = $query->param('pos');
my $cg = $query->param('cg');
my $charset = $query->param('charset');
my $lang = $query->param('language');

# Action is either "generate" or "analyze" or "paradigm"
my $action = $query->param('action');
my $paradigm_mode = $query->param('paradigm_mode');

# Input and output can be xml.
my $xml_in = $query->param('xml_in');
my $xml_out = $query->param('xml_out');

if(! $lang) { die "No language specified.\n"; }
if(! $text) { die "No text to be analyzed.\n"; }

# System-Specific directories
# The directory where utilities like 'lookup' are stored
#my $utilitydir = "/opt/xerox/bin" ;
my $utilitydir = "/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin";
# The directory where fst is stored
my $fstdir = "/opt/smi/$lang/bin" ;
# Common binaries
my $commondir = "/opt/smi/common/bin" ;
# The directory for vislcg and lookup2cg
my $bindir = "/opt/sami/cg/bin/";

# Files to generate paradigm
my $paradigmfile="/opt/smi/common/bin/paradigm.txt";
my %paradigmfiles = (
					 min => "$commondir/paradigm_min.txt",
					 standard => "$commondir/paradigm_standard.txt",
					 full => "$commondir/paradigm_full.txt",
					 );

$paradigmfile=$paradigmfiles{$paradigm_mode};

my $tagfile="/opt/smi/$lang/bin/korpustags.$lang.txt";
if (! -f $tagfile) { $tagfile="$commondir/korpustags.txt"; }

my $tmpfile="/usr/local/share/corp/tmp/smi-test.txt";

my $out = new CGI;
&printinitialhtmlcodes($action) ;         # see the subroutine below
                                 # prints out the usual HTML header info

if($charset =~ /latin1/) {
	$text = Unicode::String::latin1( $text);
}

# Convert html-entity to unicode
decode_entities( $text );

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
if (@words) {
     &printwordlimit;
}

# And here is where the actual lookup gets done:
# ###############################################
# 1.  echo the input string to preprocessor,
# 2.  pipe the now tokenized text (one word per line) to the lookup application
#         (which has some flags set, and which accesses sme.fst)
# 3.  The output of lookup is assigned as the value of $result

my $result;
my $output;

if ($action =~ /generate/) {
   $result = `echo $text | tr " " "\n" | \
			$utilitydir/lookup -flags mbL\" => \"LTT -utf8 -d $fstdir/i$lang.fst` ;
}
elsif ($action =~ /paradigm/) {
    $result = generate_paradigm($text, $pos);
}
else {
   if ($cg =~ /disamb/) {
     $result = `echo $text | $bindir/preprocess --abbr=$fstdir/abbr.txt | \
			$utilitydir/lookup -flags mbTT -utf8 -d $fstdir/$lang.fst | \ 
			$bindir/lookup2cg | $bindir/vislcg --grammar=$fstdir/$lang-dis.rle`;  }
  elsif ($cg =~ /analyse/) {
  	$result = `echo $text | $bindir/preprocess --abbr=$fstdir/abbr.txt | \
			$utilitydir/lookup -flags mbTT -utf8 -d $fstdir/$lang.fst | \ 
			$bindir/lookup2cg`; }
  elsif ($cg =~ /hyphenate/) {
  if ($lang eq "sme") {
   $result = `echo $text | $bindir/preprocess --abbr=$fstdir/abbr.txt | \
			$utilitydir/lookup -flags mbTT -utf8 $fstdir/hyph-$lang.fst | \
			$bindir/hyph-filter.pl`;
}
else {
   $result = `echo $text | $bindir/preprocess --abbr=$fstdir/abbr.txt | \
			$utilitydir/lookup -flags mbTT -utf8 $fstdir/hyph-$lang.fst | \
			cut -f2 | tr '\012' ' '`;
}
		}
   else {
	 $result = `echo $text | $bindir/preprocess | \
			$utilitydir/lookup -flags mbTT -utf8 -d $fstdir/$lang.fst | \ 
			$bindir/lookup2cg`; }
}

if ($action =~ /generate/ || $action =~ /paradigm/) { $output = gen2html($result);  } 
elsif ($cg =~ /hyphenate/) { $output = hyph2html($result); }
else { $output = dis2html($result); }

print $output;

# print out the final HTML codes and end
&printfinalhtmlcodes ;

# end



######################################################################
#
#                   Subroutines from Here On
#
######################################################################

sub generate_paradigm {
	my ($word, $pos) = @_;
	
    # Initialize paradigm and generator
	my %paradigms;
	my $analyze;
	my $answer;

	open (FH, ">$tmpfile");
	print FH "$word $pos\n";

	generate_taglist($paradigmfile,$tagfile,\%paradigms);
	$analyze="$utilitydir/lookup -flags mbTT -utf8 -d \"$fstdir/i$lang-norm.fst\" 2>/dev/null"; 

	my $exp = init_lookup($analyze);
	$exp->log_file("/usr/local/share/corp/tmp/exp.log", "w");
	print FH "$analyze\n";

	my $i=0;

	for my $a ( @{$paradigms{$pos}} ) {

		my $string = "$word+$a";
		print FH "$string\n";
		my $read_anl = call_lookup(\$exp, $string);

		print FH "read_anl: $read_anl\n";
		
		# Take away the original input.
		#$read_anl =~ s/^.*?\n//;
		# Replace extra newlines.
		$read_anl =~ s/\r\n/\n/g;
		$read_anl =~ s/\r//g; 

		next if ($read_anl =~ /\+\?/);

		$answer .= "$read_anl\n";
	}
	print FH "answer: $answer\n";
	$exp->hard_close();
	if (! $answer) { 
		$answer="No paradigm found. The word may not exist in our lexicon.\n";
		$answer .= @{paradigms{$pos}}
	}
	else { $answer = "$word $pos\n\n" . $answer; }

	return $answer;
}

sub printinitialhtmlcodes {
	my ($tool) = shift(@_);

    print $out->header(-type => 'text/html',
                          -charset => 'utf-8');
    print   $out->start_html('Sami morfologiija');
    print $out->h2("S&aacute;mi instituhtta, Romssa universitehta");

	if ($tool =~ /paradigm/) {

		print <<END ;
    <form ACTION="http://sami-cgi-bin.uit.no/cgi-bin/test/smi.cgi"
          METHOD="get" TARGET="_top" name="form2">

		<table border=0 >
			<tr>
			<td><textarea TYPE="text" NAME="text" VALUE="" ROWS="1" COLS="30" MAXLENGTH="10"></textarea>
			<select name="pos">
			<option value="N">Noun</option>
			<option value="V">Verb</option>
			<option value="A">Adjective</option>
			<option value="Pron">Pronoun</option>
			<option value="Adv">Adverb</option>
			</select>
			</td>
			</tr>

			<tr>
			<td>
			<input type="radio" name="paradigm_mode" value="min"/>Give minimal
			paradigm<br/>
			<input type="radio" name="paradigm_mode" value="standard" checked />Standard<br/>
			<input type="radio" name="paradigm_mode" value="full"/>Full<br/>
			</td>
			</tr>

			<tr>
			<td>
			<input TYPE="submit" VALUE="Give paradigm"/><input TYPE="reset" VALUE="Reset"/>
			</td>
			</tr>

			<tr>
			<td>
			<input TYPE="hidden" NAME="language" VALUE="sme" />
			<input TYPE="hidden" NAME="action" VALUE="paradigm" />
			</td>
			</tr>

			</table>
			</form>
			<hr>
END

}

}

sub printfinalhtmlcodes
{
    print <<END;

		<hr/>
			<p>Copyright &copy; S&aacute;mi giellateknologiijapro&#353;eakta.</p>
			<a href="http://giellatekno.uit.no/">http://giellatekno.uit.no/</a>
			</body>
			</html>
END
}

sub printwordlimit {
    print $out->b("\nWord limit is $wordlimit.\n");	
}

# Convert windows charachters to Sami digraphs
sub win_digr {
	my $ctext  = shift(@_);

	$ctext =~ s/\212/S1/g ;
	$ctext =~ s/\232/s1/g ;
	$ctext =~ s/\216/Z1/g ;
	$ctext =~ s/\236/z1/g ;

	return $ctext;
}


sub digr_utf8 {
	my $ctext = shift(@_);

	$ctext =~ s/A1/Á/g ;
	$ctext =~ s/a1/á/g ;
	$ctext =~ s/C1/Č/g ;
	$ctext =~ s/c1/č/g ;
	$ctext =~ s/D1/Đ/g ;
	$ctext =~ s/d1/đ/g ;
	$ctext =~ s/N1/Ŋ/g ;
	$ctext =~ s/n1/ŋ/g ;
	$ctext =~ s/S1/Š/g ;
	$ctext =~ s/s1/š/g ;
	$ctext =~ s/T1/Ŧ/g ;
	$ctext =~ s/t1/ŧ/g ;
	$ctext =~ s/Z1/Ž/g ;
	$ctext =~ s/z1/ž/g ;
	
	return $ctext;
}

