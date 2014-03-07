#!/usr/bin/perl


########################################################################
#
#mdf-lookup.pl
#
# resides:  Web Folder:cgi-bin:smi:mdf-lookup.cgi
#
#       called from FORM on skjema.html page; output HTML
#
# Original written by Ken Beesley, Xerox, for Aymara.
# reviewed and modified 12 april 2002, Trond Trosterud
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
$utilitydir =    "/opt/xerox/bin" ;
# The directory where transcriptor-numbers2text-desc.xfst is stored
$mdffstdir = "/opt/smi/mdf/bin" ;


&printinitialhtmlcodes ;         # see the subroutine below
                                 # prints out the usual HTML header info

$wordlimit = 50 ;                # adjust as appropriate; prevent large-scale (ab)use

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

# text=word+word+word

 
@query =  $ENV{'QUERY_STRING'}  ;

# the input field holds the text itself (word or words)
# in the format
# text=word1+word2+word3+word4...
# (literal spaces typed by the user were replaced with plus signs for
# transmission)

($name, $text) = split(/\=/, shift(@query)) ; # try to get only one field...
#($name, $text) = split(/\=/, shift(@queryfield)) ; # original...


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

# make space before punctuation
$text =~ s/\?/ \?/g ;
$text =~ s/\./ \./g ;
$text =~ s/\,/ \,/g ;

$text =~ s/^\s+// ;         # chop any whitespace off the front
$text =~ s/\s+$// ;         # chop any whitespace off the back
$text =~ s/\s+/\ /g ;       # squeeze any multiple whitespaces into one

# split the text into words crudely on spaces
@words = split(/\s+/, $text) ;


# Limit the input to a certain number of words (specified in variable $wordlimit
# set above)

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
#         (which has some flags set, and which accesses transcriptor-numbers2text-desc.xfst)
# 3.  The output of lookup is assigned as the value of $result


$result = `echo $allwords | tr " " "\n" | \
 $utilitydir/lookup -flags mbL\" => \"LTT -d -utf8 $mdffstdir/transcriptor-numbers2text-desc.xfst` ;
# $utilitydir/lookup -flags mbL" => "LTT -d $mdffstdir/transcriptor-numbers2text-desc.xfst` ;
# testing line two here, lauri's advice.
#back with line one

#  ***** Now we need to parse the $result string to output the information as HTML ***
#  This information will be directed automatically back to the user's browser for display


# first split the $result into solutiongroups (one solutiongroup for each input word)
# given the way that 'lookup' formats its results, solutiongroups are separated by
# two newline characters

@solutiongroups = split(/\n\n/, $result) ;

# the following is basically a loop over the original input words, now 
# associated with their solutions

foreach $solutiongroup (@solutiongroups) {
    print "\n<BR><HR SIZE=2 NOSHADE>\n" ;

    $cnt = 0 ;

  # each $solutiongroup contains the analysis
  # or analyses for a single input word.  Multiple
  # analyses are separated by a newline

    @lexicalstrings = split(/\n/, $solutiongroup) ;

  # each lexicalstring looks like
  #       input=>root [CAT]

  # now loop through the analyses for a single input word

    foreach $lexicalstring (@lexicalstrings) {
	&printsolution($lexicalstring, ++$cnt) ;
#    &printglosses($lexicalstring) ;
    }

  # these subroutines print out suitable HTML codes
}

print "<HR SIZE=4 NOSHADE>\n<BR>\n\n" ;

# print out the final HTML codes and end

&printfinalhtmlcodes ;

# end



######################################################################
#
#                   Subroutines from Here On
#
######################################################################





sub printinitialhtmlcodes
{
#               Print out a standard HTML header

    print "Content-TYPE: text/html; charset=UTF-8\n\n" ;
    print "<HEAD>\n<TITLE>Davvis&aacute;megiel lohkos&aacute;nit</TITLE>\n</HEAD>\n\n" ;

#    print "<BODY BGCOLOR=\"#D0FFD0\">\n<P>\n\n" ;

#               Include some Copyright notices

    print "<H2 ALIGN=\"center\">Romssa universitehta</H2>\n\n" ;
    print "Copyright &copy; Giellatekno, S&aacute;mi giellateknologiijapro&#353;eakta.\n<BR>\n<BR>\n" ;

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
    print "\nS&aacute;mi giellateknologiija<BR>\n" ;
    print "http://giellatekno.uit.no\n<BR>\n" ;
    print "</ADDRESS>\n" ;

    print "\n</BODY>\n" ;
}


sub printsolution {
    my ($solution, $num) = @_ ;
    $solution =~ s/\=\>/\=\> / ;
    print "\n<BR>\n$num.  $solution" ;
}



