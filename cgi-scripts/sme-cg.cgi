#!/usr/bin/perl

#use strict;

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
# reviewed and modified 18 december 2003 Saara Huhmarniemi
#
########################################################################

# this CGI script is called whenever a user submits an analysis request
# from the FORM on the Northern Sami HTML page

# For manual testing, see comments at the bottom of the file

# the output of this script (output using the normal Perl 'print' commands)
# is an HTML file, sent back to the user's browser for display.  (How it
# gets back to the user's browser is a mystery to me--the web server must
# take care of this.)

# System-Specific directories

# The directory where utilities like 'lookup' are stored
my $utilitydir = "/opt/xerox/bin" ;
# The directory where sme.fst is stored
my $smefstdir = "/opt/smi/sme/bin" ;
# The directory for vislcg and lookup2cg
my $bindir = "/www/opt/cg/bin" ;


&printinitialhtmlcodes ;         # see the subroutine below
                                 # prints out the usual HTML header info

my $wordlimit = 50 ;                # adjust as appropriate; prevent large-scale (ab)use

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

$query =  $ENV{'QUERY_STRING'}  ;

# Test queries
#$query = "text=iez1as+deat1alas1+bajásc1uvgehusa+sáhkavuod1u+man1imus1+öäåæø.+IEZ1AS+DEAT1ALAS1+BAJAC1UVGEHUSA+SAHKAVUOD1U+ÄÅÖÆØ+MAN1IMUS1.&cg=disamb";

#$query = "text=Dán+sáhkavuod1u+lean+ráhkadan+Davviriikkaid+juristac1oahkkimii,+mii+dollojuvvui+Oslos+1999.+Giittán+Álimusrievtti+justitiarius+Carsten+Smith+mávssolas1+veahki+ovddas+ráhkadettiinan+dán+sáhkavuod1u?+Stuorra+giitu+maiddái+professor+Birger+Stuevold+Lassenii,+stipendiáhta+Are+Stenvikii+ja+professor+Kirsti+Strøm+Bullii+mávssolas1+njulgemiid+ovddas.&cg=disamb";

#$query="text=Giittán+maiddái+universitehtalektora+Fredrik+Harhoff+buriid+ságastallamiid+ovddas.+Artihkal+lea+dárogillii+almmuhuvvon+35.+Lassin+lea+deat1alas1+ahte+miellaguottut+sámiide+ja+sámi+dilálas1vuod1aide+máinnas1uvvojit,+ja+ahte+rád1d1ehus+dál+oaidná+dárbbu+lasihit+died1iheami+ja+bajásc1uvgehusa+dán+oktavuod1as,+dadjá Brustad.&cg=disamb";

#$query = "text=c1állá:ei&cg=disamb";

# the input field holds the text itself (word or words)
# in the format
# text=word1+word2+word3+word4...
# (literal spaces typed by the user were replaced with plus signs for
# transmission)

my $text1; #variable for taking the text field
my $cg;    #variable for the radio disambiguate/analyze field
my $text;  #The analyzed text
my $tmp2; 
my $name;
my $action; #Variable contains 'disamb' or 'analyze'

($text1, $cg) = split (/\&/, $query);
($name, $text) = split(/\=/, $text1) ; #split text=c1alla
($tmp2, $action) = split(/\=/, $cg) ; #split cg=disamb


my $disamb=0;
if ($action =~ /disamb/)
{ $disamb=1; }

#Mihin tarvitaan?
if ($name ne "text") {
    print "Error: Expected text in QUERY_STRING\n" ;
}

# special characters in the text (e.g. literal ampersands, plus signs and equal signs 
# typed by the user) must be encoded for transmission, to prevent confusion with
# the delimiters used by CGI); here is the magic formula to undo the CGI encodings

$text =~ s/%(..)/pack("c",hex($1))/ge ;

# change the plus signs back to the original spaces typed by the user
$text =~ s/\+/ /g ;

#Removing the unsecure characters from the input.
$text =~ s/[;<>\*\|`&\$!#\(\)\[\]\{\}:'"]/ /g; 

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

for my $text (@sentences)
{
    if ($issentence)
    { &printsenthtmlcodes($text, 0) ;}

# make space before punctuation
    $text =~ s/\?/ \?/g ;
    $text =~ s/\./ \./g ;
    $text =~ s/\,/ \,/g ;

    $text =~ s/^\s+// ;         # chop any whitespace off the front
    $text =~ s/\s+$// ;         # chop any whitespace off the back
    $text =~ s/\s+/\ /g ;       # squeeze any multiple whitespaces into one


# split the text into words crudely on spaces
	my @words;
    @words = split(/\s+/, $text) ;

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
# 1.  echo the string $allwords via a pipe to tr, which replaces spaces with newlines
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
#  This information will be directed automatically back to the user's browser for display


# first split the $result into solutiongroups (one solutiongroup for each input word)
# given the input that 'vislcg' gets (output of lookup2cg), solutiongroups are 
# separated by the marking of the first word: "<.

    # splits the result using "< as a delimiter between the groups
    # removes "<
	my @solutiongroups;
    @solutiongroups = split(/\"</, $result) ;

# the following is basically a loop over the original input words, now 
# associated with their solutions

    foreach $solutiongroup (@solutiongroups) {
#	print "\n<BR><HR SIZE=2 NOSHADE>\n" ;
	print "\n<P>\n" ;
	
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
    
    print "<HR SIZE=4 NOSHADE>\n<BR>\n\n" ;
    
    
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
#  Print out a standard HTML header
#  set character code to UTF-8

    print "Content-TYPE: text/html\n\n" ;
	print "<HTML>\n" ;
	print "<HEAD>\n" ;
    print "\n<TITLE>S&aacute;mi morfologiija </TITLE>\n" ;
	print "<META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html\"; charset=utf-8\">\n" ;
	print "\n</HEAD>\n";

#    print "<BODY BGCOLOR=\"#D0FFD0\">\n<P>\n\n" ;

#               Include some Copyright notices

    print "<H2 ALIGN=\"center\">S&aacute;mi instituhtta, Romssa universitehta</H2>\n\n" ;
    print "Copyright &copy; S&aacute;mi giellateknologiijapro&#353;eakta. \n<BR>\n<BR>\n" ;

# consider trying to automate the update of the release number
#    print "Pre-Release Version 0.1\n<BR>\n" ;

# get the date and time from the Xerox-side operating system, and display it
#    $time = `date` ;
#    chop ($time) ;
#    print "$time\n<BR>\n\n" ;
}

sub printfinalhtmlcodes
{
    print "\n<ADDRESS>\n" ;
    print "\nS&aacute;mi giellateknologiija, Trond Trosterud<BR>\n" ;
    print "http://www.hum.uit.no/sam/giellatekno/\n<BR>\n" ;
    print "</ADDRESS>\n" ;
    print "\n</BODY>\n" ;
    print "\n</HTML>\n" ;
}

sub printsolution {
    my ($solution, $num) = @_ ;
	my $unicode_solution = &unicode($solution);

    if ($num) {
		print "\n <br>&nbsp;&nbsp;&nbsp;&nbsp; $unicode_solution"; 
#		print "\n <br>&nbsp;&nbsp;&nbsp;&nbsp; $solution"; 
	}
    else { 
		print "\n $unicode_solution" ; 
#		print "\n $solution" ; 
	}
}


sub printsenthtmlcodes {
    my ($sentence, $num) = @_ ;

	my $unicode_sentence = &unicode($sentence);

    print "\n<P> $unicode_sentence <BR><HR SIZE=2 NOSHADE>\n" ;
#    print "\n<P> $sentence <BR><HR SIZE=2 NOSHADE>\n" ;
}

# Subroutine to convert Latin-1 to UTF-8
# calls script 7bit-utf8.pl
sub unicode {
	my $text  = shift(@_);

	# removing characters that would harm the shell.
	$text =~ s/[;<>\*\|`&\$!#\(\)\[\]\{\}:'"]/ /g; 
	$utext = `echo $text | $bindir/7bit-utf8.pl`;
	return $utext;
}
