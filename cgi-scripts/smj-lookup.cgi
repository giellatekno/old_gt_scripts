#!/usr/bin/perl

use warnings;
use strict;

use CGI qw/:standard :html3 *table *dl/;
$CGI::DISABLE_UPLOADS = 0;
$CGI::POST_MAX        = 1_024 * 1_024; # limit posts to 1 meg max

# Forwarding warnings and fatal errors to browser window
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

########################################################################
#
#smj-lookup.cgi
#
# resides:  Web Folder:cgi-bin:smi:smj-lookup.cgi
#
#       called from FORM on skjema.html page; output HTML
#
# Original written by Ken Beesley, Xerox, for Aymara.
# reviewed and modified 12 april 2002, Trond Trosterud
# reviewed and modified 2006 Saara Huhmarniemi
#
########################################################################

# this CGI script is called whenever a user submits an analysis request
# from the FORM on the Northern Sami HTML page

# The script uses Perl module CGI.pm to retrieve and handle 
# information from HTML form and generating new HTML pages.

# System-Specific directories

# The directory where utilities like 'lookup' are stored
my $utilitydir = "/opt/xerox/bin" ;
# The directory where fst is stored
my $fstdir = "/opt/smi/smj/bin" ;
# The directory for vislcg and lookup2cg
my $bindir = "/www/opt/cg/bin" ;
#/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin

my $wordlimit = 50 ;       # adjust as appropriate; prevent large-scale (ab)use

# GET THE INPUT

my $text="";  #The text to be analysed
#my $action; #Variable contains 'disamb' or 'analyze' from radio button

my $query = new CGI;
$text = $query->param('text');
#$text = "Máná ietjá";
#$action = $query->param('cg');
#$coding = $query->param('charset');

if(! $text) {
	die "No text to be analyzed.\n";
}

my $out = new CGI;
&printinitialhtmlcodes ;         # see the subroutine below
                                 # prints out the usual HTML header info
#my $disamb=0;
#if ($action =~ /disamb/)
#{ $disamb=1; }

# Special characters in the text (e.g. literal ampersands, plus signs
# and equal signs 
# typed by the user) must be encoded for transmission, to prevent confusion with
# the delimiters used by CGI); here is the magic formula to undo the CGI encodings

$text =~ s/%(..)/pack("c",hex($1))/ge ;

# Convert html-entity input to 7-bit
#$text = htmlent_7bit($text);
#$text = win_7bit($text);

# Convert digraphs to utf-8
#$text = digr_utf8($text);

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

#if ($disamb) {
#     $result = `echo $text | $bindir/preprocess --abbr=$fstdir/abbr.txt | \
#			$utilitydir/lookup -flags mbTT -utf8 -d $fstdir/smj.fst | \ 
#			$bindir/lookup2cg | $bindir/vislcg --grammar=$fstdir/smj-dis.rle`; }
#else {
	$result = `echo $text | $bindir/preprocess | \
			$utilitydir/lookup -flags mbTT -utf8 -d $fstdir/smj.fst | \ 
			$bindir/lookup2cg`;
#}
 
#  Now we need to parse the $result string to output the information as HTML
#  This information will be directed automatically back 
#  to the user's browser for display

# first split the $result into solutiongroups 
# (one solutiongroup for each input word)
# given the input that 'vislcg' gets (output of lookup2cg), solutiongroups are 
# separated by the marking of the first word: "<.

    # splits the result using "< as a delimiter between the groups
    # removes "<
	my @solutiongroups;
    @solutiongroups = split(/\"</, $result) ;

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
		print $out->end_table();

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
sub win_7bit {
	my $ctext  = shift(@_);

	$ctext =~ s/\212/S1/g ;
	$ctext =~ s/\232/s1/g ;
	$ctext =~ s/\216/Z1/g ;
	$ctext =~ s/\236/z1/g ;

	return $ctext;
}


# Convert html to Sami digraphs
sub htmlent_7bit {
	my $ctext  = shift(@_);

	$ctext =~ s/&\#193\;/�/g ;
	$ctext =~ s/&\#225\;/�/g ;
	$ctext =~ s/&\#268\;/C1/g ;
	$ctext =~ s/&\#269\;/c1/g ;
	$ctext =~ s/&\#272\;/D1/g ;
	$ctext =~ s/&\#273\;/d1/g ;
	$ctext =~ s/&\#330\;/N1/g ;
	$ctext =~ s/&\#331\;/n1/g ;
	$ctext =~ s/&\#352\;/S1/g ;
	$ctext =~ s/&\#353\;/s1/g ;
	$ctext =~ s/&\#358\;/T1/g ;
	$ctext =~ s/&\#359\;/t1/g ;
	$ctext =~ s/&\#381\;/Z1/g ;
	$ctext =~ s/&\#382\;/z1/g ;

	$ctext =~ s/&\#192;/�/g ;
	$ctext =~ s/&\#194;/�/g ;
	$ctext =~ s/&\#195;/�/g ;
	$ctext =~ s/&\#196;/�/g ;
	$ctext =~ s/&\#197;/�/g ;
	$ctext =~ s/&\#198;/�/g ;
	$ctext =~ s/&\#199;/�/g ;
	$ctext =~ s/&\#200;/�/g ;
	$ctext =~ s/&\#201;/�/g ;
	$ctext =~ s/&\#202;/�/g ;
	$ctext =~ s/&\#203;/�/g ;
	$ctext =~ s/&\#204;/�/g ;
	$ctext =~ s/&\#205;/�/g ;
	$ctext =~ s/&\#206;/�/g ;
	$ctext =~ s/&\#207;/�/g ;
	$ctext =~ s/&\#208;/�/g ;
	$ctext =~ s/&\#209;/�/g ;
	$ctext =~ s/&\#210;/�/g ;
	$ctext =~ s/&\#211;/�/g ;
	$ctext =~ s/&\#212;/�/g ;
	$ctext =~ s/&\#213;/�/g ;
	$ctext =~ s/&\#214;/�/g ;
	$ctext =~ s/&\#215;/x/g ;
	$ctext =~ s/&\#216;/�/g ;
	$ctext =~ s/&\#217;/�/g ;
	$ctext =~ s/&\#218;/�/g ;
	$ctext =~ s/&\#219;/�/g ;
	$ctext =~ s/&\#220;/�/g ;
	$ctext =~ s/&\#221;/�/g ;
	$ctext =~ s/&\#222;/�/g ;
	$ctext =~ s/&\#223;/�/g ;
	$ctext =~ s/&\#224;/�/g ;
	$ctext =~ s/&\#226;/�/g ;
	$ctext =~ s/&\#227;/�/g ;
	$ctext =~ s/&\#228;/�/g ;
	$ctext =~ s/&\#229;/�/g ;
	$ctext =~ s/&\#230;/�/g ;
	$ctext =~ s/&\#231;/�/g ;
	$ctext =~ s/&\#232;/�/g ;
	$ctext =~ s/&\#233;/�/g ;
	$ctext =~ s/&\#234;/�/g ;
	$ctext =~ s/&\#235;/�/g ;
	$ctext =~ s/&\#236;/�/g ;
	$ctext =~ s/&\#237;/�/g ;
	$ctext =~ s/&\#238;/�/g ;
	$ctext =~ s/&\#239;/�/g ;
	$ctext =~ s/&\#240;/�/g ;
	$ctext =~ s/&\#241;/�/g ;
	$ctext =~ s/&\#242;/�/g ;
	$ctext =~ s/&\#243;/�/g ;
	$ctext =~ s/&\#244;/�/g ;
	$ctext =~ s/&\#245;/�/g ;
	$ctext =~ s/&\#246;/�/g ;
	$ctext =~ s/&\#247;/�/g ;
	$ctext =~ s/&\#248;/�/g ;
	$ctext =~ s/&\#249;/�/g ;
	$ctext =~ s/&\#250;/�/g ;
	$ctext =~ s/&\#251;/�/g ;
	$ctext =~ s/&\#252;/�/g ;
	$ctext =~ s/&\#253;/�/g ;
	$ctext =~ s/&\#254;/�/g ;
	$ctext =~ s/&\#255;/�/g ;

	$ctext =~ s/&nbsp;/ /g ;


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

sub utf8_7bit {
	my $ctext  = shift(@_);

	# removing characters that would harm the shell.
#	$ctext =~ s/[;<>\*\|`&\$!#\(\)\[\]\{\}:'"]/ /g; 

$ctext =~ s/\304\214/C1/g ;
$ctext =~ s/\304\215/c1/g ;
$ctext =~ s/\304\220/D1/g ;
$ctext =~ s/\304\221/d1/g ;
$ctext =~ s/\305\212/N1/g ;
$ctext =~ s/\305\213/n1/g ;
$ctext =~ s/\305\240/S1/g ;
$ctext =~ s/\305\241/s1/g ;
$ctext =~ s/\305\246/T1/g ;
$ctext =~ s/\305\247/t1/g ;
$ctext =~ s/\305\275/Z1/g ;
$ctext =~ s/\305\276/z1/g ;

$ctext =~ s/\303\200/�/g ;
$ctext =~ s/\303\201/�/g ;    
$ctext =~ s/\303\202/�/g ;
$ctext =~ s/\303\203/�/g ;
$ctext =~ s/\303\204/�/g ;
$ctext =~ s/\303\205/�/g ;
$ctext =~ s/\303\206/�/g ;
$ctext =~ s/\303\207/C/g ;

$ctext =~ s/\303\210/�/g ;
$ctext =~ s/\303\211/�/g ;
$ctext =~ s/\303\212/�/g ;
$ctext =~ s/\303\213/�/g ;
$ctext =~ s/\303\214/�/g ;
$ctext =~ s/\303\215/�/g ;
$ctext =~ s/\303\216/�/g ;
$ctext =~ s/\303\217/�/g ;

$ctext =~ s/\303\220/�/g ;
$ctext =~ s/\303\221/�/g ;
$ctext =~ s/\303\222/�/g ;
$ctext =~ s/\303\223/�/g ;
$ctext =~ s/\303\224/�/g ;
$ctext =~ s/\303\225/�/g ;
$ctext =~ s/\303\226/�/g ;
$ctext =~ s/\303\227/x/g ;

$ctext =~ s/\303\230/�/g ;
$ctext =~ s/\303\231/�/g ;
$ctext =~ s/\303\232/�/g ;
$ctext =~ s/\303\233/�/g ;
$ctext =~ s/\303\234/�/g ;
$ctext =~ s/\303\235/�/g ;
$ctext =~ s/\303\236/�/g ;
$ctext =~ s/\303\237/�/g ;

$ctext =~ s/\303\240/�/g ;
$ctext =~ s/\303\241/�/g ;
$ctext =~ s/\303\242/�/g ;
$ctext =~ s/\303\243/�/g ;
$ctext =~ s/\303\244/�/g ;
$ctext =~ s/\303\245/�/g ;
$ctext =~ s/\303\246/�/g ;
$ctext =~ s/\303\247/c/g ;

$ctext =~ s/\303\250/�/g ;
$ctext =~ s/\303\251/�/g ;
$ctext =~ s/\303\252/�/g ;
$ctext =~ s/\303\253/�/g ;
$ctext =~ s/\303\254/�/g ;
$ctext =~ s/\303\255/�/g ;
$ctext =~ s/\303\256/�/g ;
$ctext =~ s/\303\257/�/g ;

$ctext =~ s/\303\260/�/g ;
$ctext =~ s/\303\261/�/g ;
$ctext =~ s/\303\262/�/g ;
$ctext =~ s/\303\263/�/g ;
$ctext =~ s/\303\264/�/g ;
$ctext =~ s/\303\265/�/g ;
$ctext =~ s/\303\266/�/g ;
#$ctext =~ s/\303\267/-/g ;

$ctext =~ s/\303\270/�/g ;
$ctext =~ s/\303\271/�/g ;
$ctext =~ s/\303\272/�/g ;
$ctext =~ s/\303\273/�/g ;
$ctext =~ s/\303\274/�/g ;
$ctext =~ s/\303\275/�/g ;
$ctext =~ s/\303\276/�/g ;
$ctext =~ s/\303\277/�/g ;

$ctext =~ s/�\200\223/--/g ; # Input is m-dash, I render by two hyphens.
$ctext =~ s/�\200\231/\'/g ; # Single quotation marks
$ctext =~ s/�\200\234/�/g ;  # These quotation marks had the symbol �
$ctext =~ s/�\200\235/�/g ;  # preceeding them in a certain text.

$ctext =~ s/\200\234/�/g ;
$ctext =~ s/\200\235/�/g ;

# removing litter
$ctext =~ s/\377//g ;

	return $ctext;
}

