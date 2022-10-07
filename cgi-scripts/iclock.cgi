#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use CGI::Minimal;
use CGI::Alert ('trond.trosterud@uit.no', 'http_die');

my %titles = (
    crk => 'Lullis&aacute;megiel lohkos&aacute;nit',
    fin => 'Lullis&aacute;megiel lohkos&aacute;nit',
    hdn => 'Lullis&aacute;megiel lohkos&aacute;nit',
    myv => 'Lullis&aacute;megiel lohkos&aacute;nit',
    rus => 'Lullis&aacute;megiel lohkos&aacute;nit',
    sma => 'Lullis&aacute;megiel lohkos&aacute;nit',
    sme => 'Davvis&aacute;megiel lohkos&aacute;nit',
    smj => 'Julevs&aacute;megiel lohkos&aacute;nit',
);

# Variables retrieved from the query.
my ($text,$lang);
my $query = CGI::Minimal->new;

$text = $query->param('text');
$lang = $query->param('lang');
# special characters in the text (e.g. literal ampersands, plus signs and equal signs
# typed by the user) must be encoded for transmission, to prevent confusion with
# the delimiters used by CGI); here is the magic formula to undo the CGI encodings

if (! $text ) { http_die '--no-alert','400 Bad Request',"Empty text.\n" };
if (! $lang ) { http_die '--no-alert','400 Bad Request',"No lang.\n" };
if (length($lang) != 3) { http_die '--no-alert','400 Bad Request',"Lang must be three chars.\n" };

$text =~ s/%(..)/pack("c",hex($1))/ge ;

# change the plus signs back to the original spaces typed by the user
$text =~ s/\+/ /g ;

#Removing the unsecure characters from the input.
$text =~ s/[;<>\*\|`&\$!#\(\)\[\]\{\}'"]/ /g;

# make space before punctuation
$text =~ s/\?/ \?/g ;
$text =~ s/\./ \./g ;
$text =~ s/\,/ \,/g ;

$text =~ s/^\s+// ;         # chop any whitespace off the front
$text =~ s/\s+$// ;         # chop any whitespace off the back
$text =~ s/\s+/\ /g ;       # squeeze any multiple whitespaces into one


# System-Specific directories

# The directory where utilities like 'lookup' are stored
my $utilitydir =    "/usr/bin" ;
# The directory where  transcriptor-clock-digit2text.filtered.lookup.hfstol is stored
my $fstdir = "/opt/smi/$lang/bin" ;
unless (-d $fstdir) { http_die '--no-alert','404 Not found',"fstdir does not exist.\n" };
my $clock_fst = "$fstdir/transcriptor-clock-digit2text.filtered.lookup.hfstol";
unless (-f $clock_fst) { http_die '--no-alert','404 Not found',"$clock_fst does not exist.\n" };

&printinitialhtmlcodes ;         # see the subroutine below
                                 # prints out the usual HTML header info

my $wordlimit = 50 ;                # adjust as appropriate; prevent large-scale (ab)use

my @words = split(/\s+/, $text) ;


# Limit the input to a certain number of words (specified in variable $wordlimit
# set above)

if (@words > $wordlimit) {
    my $upperindex = $wordlimit - 1 ;
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
my $allwords = join(" ", @words) ;

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
#         (which has some flags set, and which accesses transcriptor-clock-digit2text.filtered.lookup.hfstol)
# 3.  The output of lookup is assigned as the value of $result


my $result = `echo $allwords | tr " " "\n" | \
 $utilitydir/hfst-lookup -q $clock_fst | sed "s/0.000000//"` ;

#  ***** Now we need to parse the $result string to output the information as HTML ***
#  This information will be directed automatically back to the user's browser for display


# first split the $result into solutiongroups (one solutiongroup for each input word)
# given the way that 'lookup' formats its results, solutiongroups are separated by
# two newline characters

my @solutiongroups = split(/\n\n/, $result) ;

# the following is basically a loop over the original input words, now
# associated with their solutions

foreach my $solutiongroup (@solutiongroups) {
  print "\n<BR><HR SIZE=2 NOSHADE>\n" ;

  my $cnt = 0 ;

  # each $solutiongroup contains the analysis
  # or analyses for a single input word.  Multiple
  # analyses are separated by a newline

  my @lexicalstrings = split(/\n/, $solutiongroup) ;

  # each lexicalstring looks like
  #       input=>root [CAT]

  # now loop through the analyses for a single input word

  foreach my $lexicalstring (@lexicalstrings) {
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
  print "<HEAD>\n<TITLE>$titles{$lang}</TITLE>\n</HEAD>\n\n" ;

  #    print "<BODY BGCOLOR=\"#D0FFD0\">\n<P>\n\n" ;

  #               Include some Copyright notices

  print "<H2 ALIGN=\"center\">Romssa universitehta</H2>\n\n" ;
  print "Copyright &copy; Giellatekno.\n<BR>\n<BR>\n" ;

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
  print "http://giellatekno.uit.no/\n<BR>\n" ;
  print "</ADDRESS>\n" ;

  print "\n</BODY>\n" ;
}


sub printsolution {
  my ($solution, $num) = @_ ;
  $solution =~ s/\=\>/\=\> / ;
  print "\n<BR>\n$num.  $solution" ;
}
