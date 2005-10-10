#!/usr/bin/perl -w

# Importing CGI libraries
use CGI;
use File::Copy;


# Forwarding warnings and fatal errors to browser window
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

use XML::Twig;

my ( $sec, $min, $hr, $mday, $mon, $thisyear, $wday, $yday, $isdst ) =
  localtime(time);

$thisyear = 1900 + $thisyear;
$mon = 1 + $mon; # $mon should be modified so that it will give numbers 01-12

# Define upload directory
$upload_dir = "/usr/local/share/corp/sme/orig/$thisyear-$mon";

# The first thing is to print some kind of html-code
print "Content-TYPE: text/html\n\n" ;

$query = new CGI;

$title = $query->param("title");
$author = $query->param("author");
$gender = $query->param("gender");
$pub = $query->param("pub");
$isbn = $query->param("isbn");
$issn = $query->param("issn");
$year = $query->param("year");
$lang = $query->param("lang");
$genre = $query->param("genre");
$filename = $query->param("filename");

copy ("/home/tomi/gt/script/XSL-template.xsl", "$filename.xsl") or die "Copy failed ($filename.xsl): $!";

my $document = XML::Twig->new(twig_handlers => {'xsl:variable' => \&process });

$document->parsefile ("$filename.xsl");

open (FH, ">$filename.xsl") or die "Cannot open file $filename.xsl for output: $!";
$document->print( \*FH);

system "/home/tomi/gt/script/corpus2dir.pl";

# The html-part starts here
#print $query->header ( ); 
print <<END_HTML;

<html>
  <head>
  	<title>XSL-Processing</title>
  </head>
  
  <body>
    <p>$title</p>
  </body>
</html>

END_HTML

sub process {
    my ( $t, $var) = @_;
    
    if ("title" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => $title);
    }
    if ("author" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => $author);
    }
    if ("author-gender" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => $gender);
    }
    if ("publisher" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => $pub);
    }
    if ("ISBN" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => $isbn);
    }
    if ("ISSN" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => $issn);
    }
    if ("year" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => $year);
    }
    if ("genre" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => $genre);
    }
    if ("mainlang" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => $lang);
    }
}