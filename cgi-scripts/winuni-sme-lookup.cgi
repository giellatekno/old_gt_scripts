#!/usr/bin/perl

#use Unicode::MapUTF8 qw(to_utf8 from_utf8 utf8_supported_charset);

$utilitydir =    "/opt/xerox/bin" ;
$smefstdir = "/opt/sme/bin" ;

&printinitialhtmlcodes ;         # see the subroutine below
                                 # prints out the usual HTML header info

$wordlimit = 50 ;                # adjust as appropriate; prevent large-scale (ab)use

@query =  $ENV{'QUERY_STRING'}  ;
print "<p> dette er query \n<i>@query</i></p>";
#$hola = `echo @query |iconv -f utf8 -t ws2|./ws2.pl`;
print "<p>Dette er hola $hola</p>\n";
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

# change common punctuation (for now) to spaces (the symbols . and , removed
# from this clause, cf next clause below. is this a security risk?)
$text =~ tr/;:/    / ;

# make space before question marks
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
#         (which has some flags set, and which accesses sme.fst)
# 3.  The output of lookup is assigned as the value of $result

print "ovenfor result\n";
$result = `echo $allwords | ./ws2.pl | tr " " "\n" | \
 $utilitydir/lookup -flags mbL\" => \"LTT -d $smefstdir/sme.fst` ;

#  ***** Now we need to parse the $result string to output the information as HTML ***
#  This information will be directed automatically back to the user's browser for display
print "nedenfor result\n";

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

    print "Content-TYPE: text/html;charset=UTF-8\n\n" ;
    print "<HEAD>\n<TITLE>S&aacute;mi morfologiija </TITLE>\n</HEAD>\n\n" ;

#    print "<BODY BGCOLOR=\"#D0FFD0\">\n<P>\n\n" ;

#               Include some Copyright notices

    print "<H2 ALIGN=\"center\">S&aacute;mi instituhtta, Tromssa Universitehta</H2>\n\n" ;
    print "Copyright &copy; S&aacute;mi giellateknologiijapro&#353;eakta.\n<BR>\n<BR>\n" ;

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

    print "\n</BODY>\n</HTML>\n" ;
}


sub printsolution {
    my ($solution, $num) = @_ ;
    $solution =~ s/\=\>/\=\> / ;
    $solution = to_utf8({ -string => $solution, -charset => 'ISO-8859-1' });
    print "\n<BR>\n$num.  $solution" ;
}



