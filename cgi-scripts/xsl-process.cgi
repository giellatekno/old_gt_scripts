#!/usr/bin/perl -w

# Importing CGI libraries
use CGI;
use File::Copy;

# Forwarding warnings and fatal errors to browser window
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

use XML::Twig;

# Set the file permissions of the newly created files to -rw-rw-r--
umask 0112;

# The first thing is to print some kind of html-code
print "Content-TYPE: text/html\n\n" ;

$query = new CGI;

$title = $query->param("title");
$author = $query->param("author");
$gender = $query->param("gender");
$author2 = $query->param("author2");
$gender2 = $query->param("gender2");
$author3 = $query->param("author3");
$gender3 = $query->param("gender3");
$author4 = $query->param("author4");
$gender4 = $query->param("gender4");
$pub = $query->param("pub");
$isbn = $query->param("isbn");
$issn = $query->param("issn");
$year = $query->param("year");
$lang = $query->param("lang");
$genre = $query->param("genre");
$filename = $query->param("filename");

# Define upload directory
if ($genre eq "news" || $genre eq "admin") {
	# Kautokeino hack
	if ($pub == Kautokeino) {
		$upload_dir = "/usr/local/share/corp/orig/$lang/$genre/guovda";
	}
	# Karasjok hack
	elsif ($pub == Karasjok) {
		$upload_dir = "/usr/local/share/corp/orig/$lang/$genre/karas";
	}
	
	else {
		$upload_dir = "/usr/local/share/corp/orig/$lang/$genre/$pub";
	}
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

#Change the group of the xsl-file to cvs.
#RCS command for initial checkin of the xsl-file.
#my $command = "chgrp cvs $upload_dir/$fname";
#system $command or die "System failed: $!";
#$command = "ci -t-\"xsl file, created in xsl-process.cgi\" -q -i $upload_dir/$fname";
#system $command or die "System failed: $!";


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
    if ("author2" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $author2 . "'");
    }
    if ("author-gender2" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $gender2 . "'");
    }
    if ("author3" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $author3 . "'");
    }
    if ("author-gender3" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $gender3 . "'");
    }
    if ("author4" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $author4 . "'");
    }
    if ("author-gender4" eq $var->{'att'}->{'name'}) {
        $var->set_att( 'select' => "'" . $gender4 . "'");
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
