#!/usr/bin/perl
#
# This script detects what os the client is using, and writes a
#fitting webpage.  
# This script uses the following script(s): [winuni|win9x|utf8|default]-sme-lookup
use HTTP::BrowserDetect;

&printinitialhtmlcodes;
&detecter;
&printfinalhtmlcodes;

sub detecter 
{
    my $browser = new HTTP::BrowserDetect($ENV{HTTP_USER_AGENT});
    $script = "";
    
    # Detect operating system
    if ($browser->windows) {
	if ($browser->winnt) {
	    $script="winuni";
	} elsif ($browser->win95 || $browser->win98 || $browser->winME) {
	    $script="win9x";
	}
    } elsif ($browser->linux) {
	$script="utf8";
    }
    elsif ($browser->mac) {
	$script="mac";
    }
    else {
	$script="default";
    }	
    $tust = $browser->os_string;
    print "<p>her er verdien av scriptet $script</p>\n";
    print "<p>dette er $ENV{HTTP_USER_AGENT}</p>\n";
    print "<p>dette er os_strengen $tust</p>";
    print "<CENTER><FORM ACTION=\"http://rust.uit.no:81/cgi-bin/smi/$script-sme-lookup.cgi\"\n";
    print "METHOD=\"GET\" TARGET=\"_top\"></P></CENTER>";
    
}
    
    
#This subroutine prints out the common html for the webinterface.
sub printinitialhtmlcodes  {
    print "Content-TYPE: text/html\n\n" ;
    print "<html>\n";
    print "<head>\n";
    print "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\">\n";
    print "<title>Testside</title>\n";
    print "</head>\n";
    print "<body>\n";
    print "<h1>Test</h1>\n";
}

sub printfinalhtmlcodes {
    
    
    print "<CENTER>\n";
    print "<P>&#268;&#225;le s&#225;tneh&#225;mi:\n";
    print "<INPUT TYPE=\"text\" NAME=\"text\" SIZE=\"50\"></P>\n";
    print "</CENTER>\n";
    print "\n";
    print "<CENTER><P>\n";
    print "<INPUT TYPE=\"submit\" VALUE=\"Analysere\">&nbsp;&nbsp;&nbsp;<INPUT TYPE=\"reset\"\n";
    print "VALUE=\"Sihko\"></FORM></P></CENTER> <p>\n";
    print "\n";
    print "\n";
    print "</body> \n";
    print "</html>\n";
}
