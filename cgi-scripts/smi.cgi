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
# reviewed and modified 2006 Saara Huhmarniemi
#
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
my $cg = $query->param('cg');
my $charset = $query->param('charset');
my $lang = $query->param('language');

# Action is either "generate" or "analyze"
my $action = $query->param('action');

# Testing
#$text = "Divvun lea";
#$text = qq("Nissun St&aacute;jgos lij B&aring;d&oslash;djon ja man&aacute;j");
#$lang = "sme";
#$cg = "hyphenate";
#$charset = "utf8";
#$action = "analyze";

if(! $lang) { die "No language specified.\n"; }
if(! $text) { die "No text to be analyzed.\n"; }

# System-Specific directories
# The directory where utilities like 'lookup' are stored
#my $utilitydir = "/opt/xerox/bin" ;
my $utilitydir = "/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin";
# The directory where fst is stored
my $fstdir = "/opt/smi/$lang/bin" ;
# The directory for vislcg and lookup2cg
my $bindir = "/usr/local/bin";

my $out = new CGI;
&printinitialhtmlcodes ;         # see the subroutine below
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

if ($action =~ /generate/) {
   $result = `echo $text | tr " " "\n" | \
			$utilitydir/lookup -flags mbL\" => \"LTT -utf8 -d $fstdir/i$lang.fst` ;
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
   $result = `echo $text | $bindir/preprocess --abbr=$fstdir/abbr.txt | \
			$utilitydir/lookup -flags mbTT -utf8 $fstdir/hyph-$lang.fst | cut -f2 | tr '\012' ' '`;
		}
   else {
	 $result = `echo $text | $bindir/preprocess | \
			$utilitydir/lookup -flags mbTT -utf8 -d $fstdir/$lang.fst | \ 
			$bindir/lookup2cg`; }
}


# first split the $result into solutiongroups 
# (one solutiongroup for each input word)
# given the input that 'vislcg' gets (output of lookup2cg), solutiongroups are 
# separated by the marking of the first word: "<.

    # splits the result using "< as a delimiter between the groups
    # removes "<
	my @solutiongroups;

if( $action =~ /analyze/) {
    @solutiongroups = split(/\"</, $result) ;
}
elsif($action =~ /generate/){
    @solutiongroups = split(/\n\n/, $result) ;
}
else {
    @solutiongroups = $result ;
}


# the following is basically a loop over the original input words, now 
# associated with their solutions

    foreach my $group (@solutiongroups) {
		next if (! $group);
		
		my $cnt = 0 ;
		
		# each $group contains the analysis
		# or analyses for a single input word.  Multiple
		# analyses are separated by a newline
		
		my @lexicalstrings;
		@lexicalstrings = split(/\n/, $group) ;
		
		# now loop through the analyses for a single input word
		
		print $out->start_dl;

		foreach my $string (@lexicalstrings) {

			# Print the word
			if ( $string =~ />/ ) {
				$string =~ s/>\"//g;
				print $out->dt($string);
			}
			else {
				# print solutions
				$string =~ s/\"//g;
				print $out->dd($string);
			}
		}
		print $out->end_dl();

		# these subroutines print out suitable HTML codes
	}

	
# print out the final HTML codes and end
&printfinalhtmlcodes ;

# end



######################################################################
#
#                   Subroutines from Here On
#
######################################################################


sub printinitialhtmlcodes {

    print $out->header(-type => 'text/html',
                          -charset => 'utf-8');
    print   $out->start_html('Sami morfologiija');

    print $out->h2("S&aacute;mi instituhtta, Romssa universitehta");
    print $out->p("Copyright &copy; S&aacute;mi giellateknologiijapro&#353;eakta.");
    print $out->hr;
}

sub printfinalhtmlcodes
{
    print $out->hr,
	$out->p("S&aacute;mi giellateknologiija, Trond Trosterud"), 
	$out->a({href=>"http://giellatekno.uit.no/"},"http://giellatekno.uit.no/"),
	$out->br,
	$out->end_html;
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

