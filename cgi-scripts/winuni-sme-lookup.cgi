#!/usr/bin/perl



$utilitydir =    "/usr/local/bin" ;
$smefstdir = "/opt/smi/sme/bin" ;

&printinitialhtmlcodes ;
&parser ;
&printfinalhtmlcodes ;


sub printinitialhtmlcodes 
{
    print "Content-TYPE: text/html\n\n" ;

    print "<HEAD>\n";
    print "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\">\n";
    
    print "<TITLE>S&aacute;mi morfologiija </TITLE>\n</HEAD>\n\n" ;
    print "<H2 ALIGN=\"center\">S&aacute;mi instituhtta, Tromssa Universitehta</H2>\n\n" ;
    print "Copyright &copy; S&aacute;mi giellateknologiijapro&#353;eakta.\n<BR>\n<BR>\n" ;
}

sub printfinalhtmlcodes 
{
    print "\n<ADDRESS>\n" ;
    print "\nS&aacute;mi giellateknologiija<BR>\n" ;
    print "http://giellatekno.uit.no/\n<BR>\n" ;
    print "</ADDRESS>\n" ;
    
    print "\n</BODY>\n</HTML>\n" ;
}


sub printsolution 
{
    my ($solution, $num) = @_ ;
    $solution =~ s/\=\>/\=\> / ;
    $solution = xfst_to_utf8($solution);
    print "\n<BR>\n$num.  $solution\n";
}

sub utf8_to_xfst {
    my ($text) = @_;
    #replace sámi letters with something lookup understands
    $text =~ s/\303\241/\341/g; # a sharp
    $text =~ s/\305\241/s1/g;   # s caron
    $text =~ s/\305\247/t1/g;   # t stroke
    $text =~ s/\305\213/n1/g;   # eng
    $text =~ s/\304\221/d1/g;   # d stroke
    $text =~ s/\305\276/z1/g;   # z caron
    $text =~ s/\304\215/c1/g;   # c caron
    $text =~ s/\303\201/\341/g; # A sharp
    $text =~ s/\305\240/s1/g; # S caron
    $text =~ s/\305\246/t1/g; # T stroke
    $text =~ s/\305\212/n1/g; # ENG
    $text =~ s/\304\220/d1/g; # D stroke
    $text =~ s/\305\275/z1/g; # Z caron
    $text =~ s/\304\214/c1/g; # C caron

    return $text;
}

sub xfst_to_utf8 {
    my ($text) = @_;
    #replace lookup's text with utf8
    $text =~ s/\341/\303\241/g; # a sharp
    $text =~ s/s1/\305\241/g;   # s caron
    $text =~ s/t1/\305\247/g;   # t stroke
    $text =~ s/n1/\305\213/g;   # eng
    $text =~ s/d1/\304\221/g;   # d stroke
    $text =~ s/z1/\305\276/g;   # z caron
    $text =~ s/c1/\304\215/g;   # c caron

    return lc($text);
}

sub parser 
{
    $wordlimit = 50 ;
    @query =  $ENV{'QUERY_STRING'}  ;
    ($name, $text) = split(/\=/, shift(@query)) ; # try to get only one field...
    
    if ($name ne "text") {
	print "Error: Expected text in QUERY_STRING\n" ;
    }
    
    $text =~ s/%(..)/pack("c",hex($1))/ge ;
    $text =~ s/\+/ /g ;
    $text =~ tr/;:/    / ;
    $text =~ s/\?/ \?/g ;
    $text =~ s/\./ \./g ;
    $text =~ s/\,/ \,/g ;
    $text =~ s/^\s+// ;         # chop any whitespace off the front
    $text =~ s/\s+$// ;         # chop any whitespace off the back
    $text =~ s/\s+/\ /g ;       # squeeze any multiple whitespaces into one
    
    $text = utf8_to_xfst($text);
    @words = split(/\s+/, $text) ;
    
    if (@words > $wordlimit) {
	$upperindex = $wordlimit - 1 ;
	@words = @words[0..$upperindex] ;
    }
    
    if (@words == 0) {
	print "\n<BR>\nNo words received.\n" ;
	&printfinalhtmlcodes ;
	return "No Words Received" ;
    }
    $allwords = join(" ", @words) ;
    $result = `echo $allwords |\
              tr " " "\n" | \
              $utilitydir/lookup -flags mbL\" => \"LTT -d $smefstdir/sme.fst` ;

    @solutiongroups = split(/\n\n/, $result) ;

    foreach $solutiongroup (@solutiongroups) {
	print "\n<BR><HR SIZE=2 NOSHADE>\n" ;

	$cnt = 0 ;
	
	@lexicalstrings = split(/\n/, $solutiongroup) ;
	
	
	foreach $lexicalstring (@lexicalstrings) {
	    &printsolution($lexicalstring, ++$cnt) ;
	}
    }
    print "<HR SIZE=4 NOSHADE>\n<BR>\n\n" ;
}
