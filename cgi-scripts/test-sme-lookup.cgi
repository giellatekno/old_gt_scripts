#!/usr/bin/perl

$utilitydir = "/opt/xerox/bin" ;
$smefstdir = "/opt/smi/sme/bin" ;

&printinitialhtmlcodes ;
&parser ;
&printfinalhtmlcodes ;


sub printinitialhtmlcodes
{
    print "Content-TYPE: text/html\n\n" ;

    print "<HEAD>\n";
   print "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\">\n";

    print "<TITLE>S&#225;mi morfologiija </TITLE>\n</HEAD>\n\n" ;
    print "<H2 ALIGN=\"center\">S&#225;mi instituhtta, Tromssa Universitehta</H2>\n\n" ;
    print "Copyright &copy; S&#225;mi giellateknologiijapro&#353;eakta.\n<BR>\n<BR>\n" ;
    print "<p>Om resultatet ikke blir leselig samisk, kan du hjelpe oss ved \
&#229; gj&#248;re f&#248;lgende:\
    <ul>\
    <li>G&#229; til foreg&#229;ende side, f&#248;lg anvisningene for hvordan man kan hjelpe</li> \
    <li>Lagre den resulterende siden (G&#229; til Fil->Lagre e.l.). Om man kopierer \
    siden inn i et e-post program kan det skje \"artige\" ting med kodingen av \
    disse sidene.</li> \
    <li>Send en e-post til \
<a href=mailto:\"boerre.gaup\@pc.nu\">B&#248;rre Gaup</a> der du legger ved den \
siden du nettopp lagret.\
    Fortell om hvilket <b>operativsystem</b> og <b>webleser</b> du bruker. Angi \
    gjerne versjonsinformasjon ogs&#229;.</li> \
<li>Kopier URL:en til svarsiden og lim \
den inn i brevet (den kan f.eks se slik ut: \
    <pre> \
    http://rust.uit.no:81/cgi-bin/smi/test-sme-lookup.cgi?text=geah%C4%8D%C4%8Dalan+muo%C5%A7%C5%A7%C3%A1 \
    </pre></li> \
    </ul> \
    Takk for hjelpen!\n";
}

sub printfinalhtmlcodes
{
    print "<HR SIZE=4 NOSHADE>\n<BR>\n\n" ;
    print "\n<ADDRESS>\n" ;
    print "\nS&#225;mi giellateknologiija, Trond Trosterud<BR>\n" ;
    print "http://www.hum.uit.no/sam/giellatekno/\n<BR>\n" ;
    print "</ADDRESS>\n" ;

    print "\n</BODY>\n</HTML>\n" ;
}


sub printsolution
{
    my ($solution, $num) = @_ ;
    $solution =~ s/\=\>/\=\> / ;
    $solution = xfst_to_html_entities($solution);
    print "\n<BR>\n$num.  $solution\n";
}

sub utf8_to_xfst {
    my ($text) = @_;
    #replace s&#225;mi letters with something lookup understands
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

    print "<p>utf8_to $text</p>\n";

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

    print "<p>xfst_to... $text</p>\n";
    return lc($text);
}

sub xfst_to_html_entities {
    my ($text) = @_;
    #replace lookup's text with utf8
    $text =~ s/\341/&\#225;/g; # a sharp
    $text =~ s/s1/&\#353;/g;   # s caron
    $text =~ s/t1/&\#359;/g;   # t stroke
    $text =~ s/n1/&\#331;/g;   # eng
    $text =~ s/d1/&\#273;/g;   # d stroke
    $text =~ s/z1/&\#382;/g;   # z caron
    $text =~ s/c1/&\#269;/g;   # c caron

    print "<p>xfst_to... $text</p>\n";
    return lc($text);
}

sub format_text {
    my ($text) = @_;
    $text =~ s/%(..)/pack("c",hex($1))/ge ;
    $text =~ s/\+/ /g ;
    $text =~ tr/;:/    / ;
    $text =~ s/\?/ \?/g ;
    $text =~ s/\./ \./g ;
    $text =~ s/\,/ \,/g ;
    $text =~ s/^\s+// ;         # chop any whitespace off the front
    $text =~ s/\s+$// ;         # chop any whitespace off the back
    $text =~ s/\s+/\ /g ;       # squeeze any multiple whitespaces into one

    print "<p>format_text $text</p>\n";
    return $text;
}

sub browser_dependent_transform {
    my ($text) = @_;
    
    use HTTP::BrowserDetect;
    my $browser = new HTTP::BrowserDetect($ENV{HTTP_USER_AGENT});
    
    $tust = $browser->os_string;
    print "<p>dette er os_strengen $tust</p>";

    # Detect operating system
    if ($browser->windows) {
	print "<p>i win</p>\n";
	if ($browser->winnt) {
	    $text = utf8_to_xfst($text);
	} elsif ($browser->win95 || $browser->win98 || $browser->winME) {
	    if ($browser->opera){
		print "<p>opera</p>\n";
		$text = ws2_to_xfst($text);
	    }  else {
	    $text = quasi_ws2_to_xfst($text);
	}
	}
    } elsif ($browser->linux) {
	$text = utf8_to_xfst($text);
    } elsif ($browser->mac) {
	$text = mac_to_xfst($text);
    } else {
	print "hola\n";
    }

    return lc($text);
}


# MS IE (at least 5.5) formats the query string as utf8. Under Win9x
# the characters that are input are from ws2, but encoded as utf-8...
sub quasi_ws2_to_xfst {
    my ($text) = @_;
    #replace s�i letters with something lookup understands
    $text =~ s/\303\241/\341/g; # a sharp
    $text =~ s/\305\241/s1/g;   # s caron
    $text =~ s/\302\274/t1/g;   # t stroke
    $text =~ s/\302\271/n1/g;   # eng
    $text =~ s/\313\234/d1/g;   # d stroke
    $text =~ s/\302\277/z1/g;   # z caron
    $text =~ s/\342\200\236/c1/g;   # c caron
    $text =~ s/\303\201/\341/g; # A sharp
    $text =~ s/\305\240/s1/g; # S caron
    $text =~ s/\302\272/t1/g; # T stroke
    $text =~ s/\302\270/n1/g; # ENG
    $text =~ s/\342\200\260/d1/g; # D stroke
    $text =~ s/\302\276/z1/g; # Z caron
    $text =~ s/\342\200\232/c1/g; # C caron

    print "<p>quasi $text</p>\n";

    return $text;
}

# Opera under Windows (at least 5.x) formats the query string as 8 bit,
# so the transform is plain ws2 to 7 bit.
sub ws2_to_xfst {
    my ($text) = @_;

    $text =~ s/\202/c1/g ;
    $text =~ s/\204/c1/g ;
    $text =~ s/\211/d1/g ;
    $text =~ s/\230/d1/g ;
    $text =~ s/\270/n1/g ;
    $text =~ s/\271/n1/g ;
    $text =~ s/\212/s1/g ;
    $text =~ s/\232/s1/g ;
    $text =~ s/\274/t1/g ;
    $text =~ s/\272/t1/g ;
    $text =~ s/\277/z1/g ;
    $text =~ s/\276/z1/g ;

    print "<p>ws2_to $text</p>\n";
    return lc($text);
}

sub mac_to_xfst {
    my ($text) = @_;

    $text =~ s/\242/C1/g ;
    $text =~ s/\270/c1/g ;
    $text =~ s/\260/D1/g ;
    $text =~ s/\271/d1/g ;
    $text =~ s/\261/N1/g ;
    $text =~ s/\272/n1/g ;
    $text =~ s/\264/S1/g ;
    $text =~ s/\273/s1/g ;
    $text =~ s/\265/T1/g ;
    $text =~ s/\274/t1/g ;
    $text =~ s/\267/Z1/g ;
    $text =~ s/\275/z1/g ;

    print "<p>mac_to... $text</p>\n";
    return ($text);
}

sub parser
{
    $wordlimit = 50 ;
    @query =  $ENV{'QUERY_STRING'}  ;
    ($name, $text) = split(/\=/, shift(@query)) ; # try to get only one field...
    
    if ($name ne "text") {
	print "Error: Expected text in QUERY_STRING\n" ;
    }
    
    $text = format_text($text);
    $text = browser_dependent_transform($text);

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
}
