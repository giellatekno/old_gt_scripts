#!/usr/bin/perl -w

# Importing CGI libraries
use CGI;
use File::Copy;

# Forwarding warnings and fatal errors to browser window
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

use XML::Twig;

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

# Define upload directory
if ($genre eq "news" || $genre eq "admin") {
	$upload_dir = "/usr/local/share/corp/orig/$lang/$genre/$pub";
}
else {
	$upload_dir = "/usr/local/share/corp/orig/$lang/$genre";
}

# Strip path
my $fname = $filename;
$fname =~ s/.*[\/\\](.*)/$1/;

# The principles
if (-e "$upload_dir/$fname") {
	$fname = $title;
	$fname =~ tr/\.A-Za-z0-9/_/c;
}

$i = 1;

while (-e "$upload_dir/$fname") {
	$fname = "$fname-$i";
	$i++;
}

copy ("/home/tomi/gt/script/XSL-template.xsl", "$upload_dir/$fname.xsl") or die "Copy failed ($upload_dir/$fname.xsl): $!";
move ("$filename", "$upload_dir/$fname");
move ("$filename.xml", "$upload_dir/$fname.xml");

my $document = XML::Twig->new(twig_handlers => {'xsl:variable' => \&process });

$document->parsefile ("$upload_dir/$fname.xsl");

open (FH, ">$upload_dir/$fname.xsl") or die "Cannot open file $upload_dir/$fname.xsl for output: $!";
$document->print( \*FH);

$finaldir = $upload_dir;
$finaldir =~ s/\/corp\/orig/\/corp\/gt/;
system "xsltproc --novalid $upload_dir/$fname.xsl $upload_dir/$fname.xml > $finaldir/$fname.xml";

# The html-part starts here
print <<END_HTML;

<html>
  <head>
  	<title>XSL-Processing</title>
  </head>
  
  <body>
    <p>$finaldir</p>
  </body>
</html>

END_HTML

sub process {
    my ( $t, $var) = @_;
    
    if ("title" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $title . "'");
    }
    if ("author" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $author . "'");
    }
    if ("author-gender" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $gender . "'");
    }
    if ("publisher" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $pub . "'");
    }
    if ("ISBN" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $isbn . "'");
    }
    if ("ISSN" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $issn . "'");
    }
    if ("year" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $year . "'");
    }
    if ("genre" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $genre . "'");
    }
    if ("mainlang" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $lang . "'");
    }
}