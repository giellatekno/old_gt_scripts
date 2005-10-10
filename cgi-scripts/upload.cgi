#!/usr/bin/perl -w

# Importing CGI libraries
use CGI;

# Forwarding warnings and fatal errors to browser window
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

#use Apache::SubProcess qw(system);

# File copying and xml-processing
use XML::Twig;

my ( $sec, $min, $hr, $mday, $mon, $thisyear, $wday, $yday, $isdst ) =
  localtime(time);

$thisyear = 1900 + $thisyear;
$mon = 1 + $mon; # $mon should be modified so that it will give numbers 01-12

# The first thing is to print some kind of html-code
print "Content-TYPE: text/html; charset=utf-8\n\n" ;

# Define upload directory and mkdir it, if necessary
$upload_dir = "/usr/local/share/corp/sme/orig/$thisyear-$mon";
mkdir ($upload_dir, 0755) unless -d $upload_dir;

$query = new CGI;

# Getting the filename and parsing the path away
$filename = $query->param("document");
$filename =~ s/.*[\/\\](.*)/$1/;

# Resolving filetype
# MS Word = application/msword
$filetype = $query->uploadInfo($filename)->{'Content-Type'};

# TODO: Check the file
# This includes: type, sámi characters (how?), ...

# Handle to the file
$upload_filehandle = $query->upload("document");

if (!$upload_filehandle) {
    die "FILE NOT FOUND!";
}

# Open file on the server and print uploaded file into it.
open UPLOADFILE, ">$upload_dir/$filename"
      or die "Can't open file!";
while (<$upload_filehandle>) {
	print UPLOADFILE;
}
close UPLOADFILE;

# Calling word2xml -script with hardcoded execution path
# The 'or die' part doesn't work, it dies everytime...
system "/home/tomi/gt/script/word2xml.pl --xsl=/home/tomi/gt/script/docbook2corpus.xsl \"$upload_dir/$filename\"";# or die "Couldn't call system";

# Define variables for XSL-template
my $title;
my $author;
my $gender;
my $pub;
my $year;
my $lang;
my $isbn;
my $issn;

# Resolve XSL-variables with XML::Twig
# Find out the language of the file
my $document = XML::Twig->new(twig_handlers =>
				  {'document' => sub { $lang = $_->{'att'}->{'xml:lang'}},
				   'header/title' => sub { $title = $_->text},
				   'header/author/person' => sub { $author = $_->{'att'}->{'name'};
				                                   $gender = $_->{'att'}->{'sex'}
				                                 },
				   'header/year' => sub { $year = $_->text},
				   'publChannel/publisher' => sub { $pub = $_->text},
				   'publisher/ISBN' => sub { $isbn = $_->text},
				   'publisher/ISSN' => sub { $issn = $_->text}
				  } );

$document->parsefile ("$upload_dir/$filename.xml");

# The html-part starts here
#print $query->header ( ); 
print <<END_HTML;

<html>
  <head>
  	<title>File uploaded</title>
  </head>
  
  <body>
    <p>Thank you for uploading file <a href="$upload_dir/$filename"> $filename </a></p>
    <br/><br/>
    <form TYPE="text" ACTION="xsl-process.cgi" METHOD="post">
      Title: <input type="text" name="title" value="$title" size="50"> <br/>
      Author name: <input type="text" name="author" value="$author" size="50"> <br/>
      Author gender: <input type="radio" name="gender" value="m"> Male
            <input type="radio" name="gender" value="f"> Female <br/>
      Publishing year: <input type="text" name="year" value=$year> <br/>
      Publisher: <input type="text" name="pub" value=$pub> <br/>
      ISBN: <input type="text" name="isbn" value=$isbn> <br/>
      ISSN: <input type="text" name="issn" value=$issn> <br/>
      Genre: <br/>
             <select name="genre" size="5">
               <option value="news">Newstext</option>
               <option value="fict">Fiction</option>
               <option value="bible">Bible</option>
               <option value="asdf">Asdf</option>
               <option value="ghj">Ghj</option>
             </select> <br/>
      Language: (document: $lang)<br/>
             <select name="lang" size="6">
               <option value="sme">North S&aacute;mi</option>
               <option value="smj">Julev S&aacute;mi</option>
               <option value="nno">Nynorsk</option>
               <option value="nob">Bokm&aring;l</option>
               <option value="fi">Finnish</option>
               <option value="sv">Swedish</option>
             </select> <br/>
      <input type="hidden" name="filename" value="$upload_dir/$filename">

      <input type="submit" name="Submit" value="submit form">
    </form>
  </body>
</html>

END_HTML
