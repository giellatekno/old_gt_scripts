#!/usr/bin/perl

use warnings;
#use strict;

use CGI;

########################################################################
#
#sme-cg.pl
#
# resides:  Web Folder:cgi-bin:smi:sme-cg.cgi
#
#       called from FORM on skjema.html page; output HTML
#
# Original written by Ken Beesley, Xerox, for Aymara.
# reviewed and modified 12 april 2002, Trond Trosterud
# reviewed and modified 2003, 2004 Saara Huhmarniemi
#
########################################################################

# this CGI script is called whenever a user submits an analysis request
# from the FORM on the Northern Sami HTML page

# The script uses Perl module CGI.pm to retrieve and handle 
# information from HTML form and generating new HTML pages.

# System-Specific directories

# The directory where utilities like 'lookup' are stored
my $utilitydir = "/opt/xerox/bin" ;
# The directory where sme.fst is stored
my $smefstdir = "/opt/smi/sme/bin" ;
# The directory for vislcg and lookup2cg
my $bindir = "/www/opt/cg/bin" ;


my $wordlimit = 50 ;       # adjust as appropriate; prevent large-scale (ab)use

# GET THE INPUT

#         The data arrives by GET method (from the HTML FORM
#         in the HTML input page being viewed by the user)

# The format of the data sent to the CGI script in GET mode is a string
# separated into "fields".  Each field represents the data from one GUI
# widget in the HTML FORM.  (Compare the FORM to the fields listed
# below.)  Fields are separated with an ampersand.

# In the present example, the FORM contain one GUI widgets, transmitted
# to the CGI script in a field:

#      A string of characters, typed into an HTML TEXTAREA widget.  The FORM
#      specifies that these characters are to be labeled as "text".  So
#      if the user types "utanaka utamankapxarakiwa" in the TEXTAREA, it
#      will be transmitted to the CGI script as the field
#             text=utanaka+utamankapxarakiwa
#      Note that the space typed by the user will be replaced by a plus sign
#      for transmission.

#  Compare these descriptions against the FORM in the HTML page to see 
#    where these fields (and their labels and values) are coming from.


# the data is encoded for transmission
#  1.  any spaces in the original user input are replaced with plus signs
#  2.  other special characters are encoded (see below for decoding steps)

# with the GET method, the input is available in the environment variable
#       QUERY_STRING, with fields separated by ampersands, e.g.

#$query =  $ENV{'QUERY_STRING'}  ;

# the input field holds the text itself (word or words)
# in the format
# text=word1+word2+word3+word4...
# (literal spaces typed by the user were replaced with plus signs for
# transmission)

my $text;  #The text to be analysed
my $action; #Variable contains 'disamb' or 'analyze' from radio button
my $hidden; # The data in the hidden field

#open INPUT, "< test-query1" or die("Can't open the input file: $!");

# CGI-module
#$query = new CGI(\*INPUT);
$query = new CGI;
$action = $query->param('cg');
$text = $query->param('text');
$coding = $query->param('charset');

my $output = new CGI;
&printinitialhtmlcodes ;         # see the subroutine below
                                 # prints out the usual HTML header info
my $disamb=0;
if ($action =~ /disamb/)
{ $disamb=1; }

# Special characters in the text (e.g. literal ampersands, plus signs
# and equal signs 
# typed by the user) must be encoded for transmission, to prevent confusion with
# the delimiters used by CGI); here is the magic formula to undo the CGI encodings

$text =~ s/%(..)/pack("c",hex($1))/ge ;

# Convert html-entity input to 7-bit
$text = htmlent_7bit($text);

# Convert utf8-input to 7-bit
if ($coding !~ /latin/)
{ $text = utf8_7bit($text); }

# Remove the unsecure characters from the input.
$text =~ s/[;<>\*\|`&\$!\#\(\)\[\]\{\}:'"]/ /g; 

# split the text crudely to sentences. Note! if there are two or more delimiters,
# like ..??.. the text coming after that is not analyzed.

my @senten;
my $k=0;

my $issentence=0;
if ($text =~ /[\.?]/)
{ $issentence=1; }

# split the text to clauses and delimiters.
@senten = split(/([\.?])/, $text); 

# add the delimiters back to the sentences.
while(my $sent = shift @senten) {
    $sent .= shift @senten;
    $sentences[$k++] = $sent;
}

if (@sentences == 0) {
    print "\n<BR>\nNo words received.\n" ;
    &printfinalhtmlcodes ;
    return "No Words Received" ;
}

# Start going through each sentence.
for my $sentence (@sentences)
{
    if ($issentence)
    { &printsenthtmlcodes($sentence, 0) ;}

# make space before punctuation
    $sentence =~ s/\?/ \?/g ;
    $sentence =~ s/\./ \./g ;
    $sentence =~ s/\,/ \,/g ;

    $sentence =~ s/^\s+// ;         # chop any whitespace off the front
    $sentence =~ s/\s+$// ;         # chop any whitespace off the back
    $sentence =~ s/\s+/\ /g ;       # squeeze any multiple whitespaces into one


# split the sentence into words crudely on spaces
	my @words;
    @words = split(/\s+/, $sentence) ;

# Limit the input to a certain number of words (specified in variable $wordlimit
# set above)

	my $upperindex;
    if (@words > $wordlimit) {
	$upperindex = $wordlimit - 1 ;
	@words = @words[0..$upperindex] ;
    }

# make a check to see if there are any words at all

    if (@words == 0) {
		print "\n<BR>\nNo words received.\n" ;
		&printfinalhtmlcodes ;
		return "No Words Received" ;
	}

# if we reach here, then the user did indeed one or more words;
# join the words back into a single string

# each remaining word now separated by spaces
	my $allwords;
    $allwords = join(" ", @words) ;

# The morphological analysis will be done using the 'lookup' utility,
# which takes a tokenized "file" as input (i.e. one word to a line)

# In Perl, backquoted expressions are sent to be performed by the native
# operating system, here UNIX, and the text result is returned, e.g.
# $date = `date` ;
# would call the Unix utility 'data' and assign the answer, e.g. a string like
#    Thu Mar 21 16:37:10 MET 2002
# as the value of the Perl variable $data

# the same backquoting trick will be used to lookup the input words in
# using the 'lookup' utility, which will access the aymara.fst transducer

# we will take the string of space-separated input words in the Perl variable 
# $allwords (computed above), pipe them to a very simple tokenizer that puts
# one word on each line (i.e. inserts a newline character between words), and 
# then pipe that tokenized "file" to the 'lookup' utility


# And here is where the actual lookup gets done:
# ###############################################
# 1.  echo the string $allwords via a pipe to tr, which replaces spaces 
#     with newlines
# 2.  pipe the now tokenized text (one word per line) to the lookup application
#         (which has some flags set, and which accesses sme.fst)
# 3.  The output of lookup is assigned as the value of $result

	my $result;

    if ($disamb) {
		$result = `echo $allwords | tr " " "\n" | \
$utilitydir/lookup -flags mbTT -d $smefstdir/sme.fst | \ 
$bindir/lookup2cg | $bindir/vislcg --grammar=$smefstdir/sme-dis.rle`; 
    }
    else {
	$result = `echo $allwords | tr " " "\n" | \
$utilitydir/lookup -flags mbTT -d $smefstdir/sme.fst | \ 
$bindir/lookup2cg`;
}
 
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

    foreach $solutiongroup (@solutiongroups) {
		print "\n<P>" ;
		
		$cnt = 0 ;
		
		# each $solutiongroup contains the analysis
		# or analyses for a single input word.  Multiple
		# analyses are separated by a newline
		
		my @lexicalstrings;
		@lexicalstrings = split(/\n/, $solutiongroup) ;
		
		# each lexicalstring looks like
		
		# now loop through the analyses for a single input word
		
		foreach $lexicalstring (@lexicalstrings) {
			
			# Print the input word
			if ( $lexicalstring =~ />/ ) {
				$lexicalstring =~ s/>\"//g; #remove >"
				&printsolution($lexicalstring, 0);
			}
			else {
				# print the solutions
				$lexicalstring =~ s/\"//g; #remove "
				&printsolution($lexicalstring, ++$cnt);
			}
		}
		# these subroutines print out suitable HTML codes
	}	

} # end of looping the input sentences.
	
# print out the final HTML codes and end
&printfinalhtmlcodes ;

# end



######################################################################
#
#                   Subroutines from Here On
#
######################################################################


sub printinitialhtmlcodes {

	print $output->header(-type => 'text/html',
						  -charset => 'utf-8');
	print	$output->start_html('Sami morfologiija');
						 
	print $output->h2("S&aacute;mi instituhtta, Romssa universitehta");
	print $output->p("Copyright &copy; S&aacute;mi giellateknologiijapro&#353;eakta.");
}

sub printfinalhtmlcodes
{
    print $output->hr;
	print $output->address("S&aacute;mi giellateknologiija, Trond
Trosterud",$output->br,"http://www.hum.uit.no/sam/giellatekno/");
	print $output->br;
	print $output->end_html;

}

sub printsolution {
    my ($solution, $num) = @_ ;
	my $unicode_solution = &unicode($solution);

    if ($num) {
		print $output->br;
		print "&nbsp;&nbsp;&nbsp;&nbsp; $unicode_solution \n"; 
	}
    else { 
		print "\n $unicode_solution" ; 
	}
}

sub printsenthtmlcodes {
    my ($sentence, $num) = @_ ;

	my $unicode_sentence = &unicode($sentence);

    print "\n<HR SIZE=2 NOSHADE>$unicode_sentence <BR>" ;
}

# Subroutine to convert Latin-1 to utf-8
# calls script 7bit-utf8.pl
sub unicode {
	my $text  = shift(@_);
	
	# removing characters that would harm the shell.
	$text =~ s/[;<>\*\|`&\$!\#\(\)\[\]\{\}:'"]/ /g; 
	$utext = `echo $text | $bindir/7bit-utf8.pl`;
	return $utext;
}

# Convert html to Sami digraphs
sub htmlent_7bit {
	my $ctext  = shift(@_);

	$ctext =~ s/\212/S1/g ;
	$ctext =~ s/\232/s1/g ;
	$ctext =~ s/\216/Z1/g ;
	$ctext =~ s/\236/z1/g ;

	$ctext =~ s/&\#193\;/Á/g ;
	$ctext =~ s/&\#225\;/á/g ;
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

	$ctext =~ s/&\#192;/À/g ;
	$ctext =~ s/&\#194;/Â/g ;
	$ctext =~ s/&\#195;/Ã/g ;
	$ctext =~ s/&\#196;/Ä/g ;
	$ctext =~ s/&\#197;/Å/g ;
	$ctext =~ s/&\#198;/Æ/g ;
	$ctext =~ s/&\#199;/Ç/g ;
	$ctext =~ s/&\#200;/È/g ;
	$ctext =~ s/&\#201;/É/g ;
	$ctext =~ s/&\#202;/Ê/g ;
	$ctext =~ s/&\#203;/Ë/g ;
	$ctext =~ s/&\#204;/Ì/g ;
	$ctext =~ s/&\#205;/Í/g ;
	$ctext =~ s/&\#206;/Î/g ;
	$ctext =~ s/&\#207;/Ï/g ;
	$ctext =~ s/&\#208;/Ð/g ;
	$ctext =~ s/&\#209;/Ñ/g ;
	$ctext =~ s/&\#210;/Ò/g ;
	$ctext =~ s/&\#211;/Ó/g ;
	$ctext =~ s/&\#212;/Ô/g ;
	$ctext =~ s/&\#213;/Õ/g ;
	$ctext =~ s/&\#214;/Ö/g ;
	$ctext =~ s/&\#215;/x/g ;
	$ctext =~ s/&\#216;/Ø/g ;
	$ctext =~ s/&\#217;/Ù/g ;
	$ctext =~ s/&\#218;/Ú/g ;
	$ctext =~ s/&\#219;/Û/g ;
	$ctext =~ s/&\#220;/Ü/g ;
	$ctext =~ s/&\#221;/Ý/g ;
	$ctext =~ s/&\#222;/Þ/g ;
	$ctext =~ s/&\#223;/ß/g ;
	$ctext =~ s/&\#224;/à/g ;
	$ctext =~ s/&\#226;/â/g ;
	$ctext =~ s/&\#227;/ã/g ;
	$ctext =~ s/&\#228;/ä/g ;
	$ctext =~ s/&\#229;/å/g ;
	$ctext =~ s/&\#230;/æ/g ;
	$ctext =~ s/&\#231;/ç/g ;
	$ctext =~ s/&\#232;/è/g ;
	$ctext =~ s/&\#233;/é/g ;
	$ctext =~ s/&\#234;/ê/g ;
	$ctext =~ s/&\#235;/ë/g ;
	$ctext =~ s/&\#236;/ì/g ;
	$ctext =~ s/&\#237;/í/g ;
	$ctext =~ s/&\#238;/î/g ;
	$ctext =~ s/&\#239;/ï/g ;
	$ctext =~ s/&\#240;/ð/g ;
	$ctext =~ s/&\#241;/ñ/g ;
	$ctext =~ s/&\#242;/ò/g ;
	$ctext =~ s/&\#243;/ó/g ;
	$ctext =~ s/&\#244;/ô/g ;
	$ctext =~ s/&\#245;/õ/g ;
	$ctext =~ s/&\#246;/ö/g ;
	$ctext =~ s/&\#247;/÷/g ;
	$ctext =~ s/&\#248;/ø/g ;
	$ctext =~ s/&\#249;/ù/g ;
	$ctext =~ s/&\#250;/ú/g ;
	$ctext =~ s/&\#251;/û/g ;
	$ctext =~ s/&\#252;/ü/g ;
	$ctext =~ s/&\#253;/ý/g ;
	$ctext =~ s/&\#254;/þ/g ;
	$ctext =~ s/&\#255;/ÿ/g ;

	$ctext =~ s/&nbsp;/ /g ;


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

$ctext =~ s/\303\200/À/g ;
$ctext =~ s/\303\201/Á/g ;    
$ctext =~ s/\303\202/Â/g ;
$ctext =~ s/\303\203/Ã/g ;
$ctext =~ s/\303\204/Ä/g ;
$ctext =~ s/\303\205/Å/g ;
$ctext =~ s/\303\206/Æ/g ;
$ctext =~ s/\303\207/C/g ;

$ctext =~ s/\303\210/È/g ;
$ctext =~ s/\303\211/É/g ;
$ctext =~ s/\303\212/Ê/g ;
$ctext =~ s/\303\213/Ë/g ;
$ctext =~ s/\303\214/Ì/g ;
$ctext =~ s/\303\215/Í/g ;
$ctext =~ s/\303\216/Î/g ;
$ctext =~ s/\303\217/Ï/g ;

$ctext =~ s/\303\220/Ð/g ;
$ctext =~ s/\303\221/Ñ/g ;
$ctext =~ s/\303\222/Ò/g ;
$ctext =~ s/\303\223/Ó/g ;
$ctext =~ s/\303\224/Ô/g ;
$ctext =~ s/\303\225/Õ/g ;
$ctext =~ s/\303\226/Ö/g ;
$ctext =~ s/\303\227/x/g ;

$ctext =~ s/\303\230/Ø/g ;
$ctext =~ s/\303\231/Ù/g ;
$ctext =~ s/\303\232/Ú/g ;
$ctext =~ s/\303\233/Û/g ;
$ctext =~ s/\303\234/Ü/g ;
$ctext =~ s/\303\235/Ý/g ;
$ctext =~ s/\303\236/Þ/g ;
$ctext =~ s/\303\237/ß/g ;

$ctext =~ s/\303\240/à/g ;
$ctext =~ s/\303\241/á/g ;
$ctext =~ s/\303\242/â/g ;
$ctext =~ s/\303\243/ã/g ;
$ctext =~ s/\303\244/ä/g ;
$ctext =~ s/\303\245/å/g ;
$ctext =~ s/\303\246/æ/g ;
$ctext =~ s/\303\247/c/g ;

$ctext =~ s/\303\250/è/g ;
$ctext =~ s/\303\251/é/g ;
$ctext =~ s/\303\252/ê/g ;
$ctext =~ s/\303\253/ë/g ;
$ctext =~ s/\303\254/ì/g ;
$ctext =~ s/\303\255/í/g ;
$ctext =~ s/\303\256/î/g ;
$ctext =~ s/\303\257/ï/g ;

$ctext =~ s/\303\260/ð/g ;
$ctext =~ s/\303\261/ñ/g ;
$ctext =~ s/\303\262/ò/g ;
$ctext =~ s/\303\263/ó/g ;
$ctext =~ s/\303\264/ô/g ;
$ctext =~ s/\303\265/õ/g ;
$ctext =~ s/\303\266/ö/g ;
#$ctext =~ s/\303\267/-/g ;

$ctext =~ s/\303\270/ø/g ;
$ctext =~ s/\303\271/ù/g ;
$ctext =~ s/\303\272/ú/g ;
$ctext =~ s/\303\273/û/g ;
$ctext =~ s/\303\274/ü/g ;
$ctext =~ s/\303\275/ý/g ;
$ctext =~ s/\303\276/þ/g ;
$ctext =~ s/\303\277/ÿ/g ;

$ctext =~ s/â\200\223/--/g ; # Input is m-dash, I render by two hyphens.
$ctext =~ s/â\200\231/\'/g ; # Single quotation marks
$ctext =~ s/â\200\234/«/g ;  # These quotation marks had the symbol â
$ctext =~ s/â\200\235/»/g ;  # preceeding them in a certain text.

$ctext =~ s/\200\234/«/g ;
$ctext =~ s/\200\235/»/g ;

# removing litter
$ctext =~ s/\377//g ;

	return $ctext;
}

