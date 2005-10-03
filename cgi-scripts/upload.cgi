#!/usr/bin/perl -w

use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use File::Copy;
use XML::Twig;

print "Content-TYPE: text/html\n\n" ;

$upload_dir = "/usr/local/share/corp/sme/orig";

$query = new CGI;

$filename = $query->param("document");
$filename =~ s/.*[\/\\](.*)/$1/;

$upload_filehandle = $query->upload("document");

open UPLOADFILE, ">$upload_dir/$filename"
      or die "Can't open file!";

if (!$upload_filehandle) {
    die "FILE NOT FOUND!";
}

while (<$upload_filehandle>) {
	print UPLOADFILE;
}

close UPLOADFILE;

system "/home/tomi/gt/script/word2xml.pl --xsl=/home/tomi/gt/script/docbook2corpus.xsl \"$upload_dir/$filename\"";# or die "Couldn't call system";

copy ("/home/tomi/gt/script/XSL-template.xsl", "$upload_dir/$filename.xsl") or die "Copy failed!";

my $title;
my $author;
my $gender;
my $pub;
my $year;
my $lang;

my $document = XML::Twig->new(twig_handlers => {'xsl:variable' => 
sub { 
      if ("title" eq $_->{'att'}->{'name'}) {
        $title = $_->{'att'}->{'select'}
      }
      if ("author" eq $_->{'att'}->{'name'}) {
        $author = $_->{'att'}->{'select'}
      }
      if ("author-gender" eq $_->{'att'}->{'name'}) {
        $gender = $_->{'att'}->{'select'}
      }
      if ("publisher" eq $_->{'att'}->{'name'}) {
        $pub = $_->{'att'}->{'select'}
      }
      if ("year" eq $_->{'att'}->{'name'}) {
        $year = $_->{'att'}->{'select'}
      }
      if ("mainlang" eq $_->{'att'}->{'name'}) {
        $lang = $_->{'att'}->{'select'}
      }      
    }} );

$document->parsefile ("$upload_dir/$filename.xsl");

print $query->header ( ); 
print <<END_HTML;

<html>
  <head>
  	<title>File uploaded</title>
  </head>
  
  <body>
    <p>Thank you for uploading file <a href="$upload_dir/$filename"> $filename </a></p>
    <br/><br/>
    <form TYPE="text" ACTION="xsl-template.cgi" METHOD="post">
      Title: <input type="text" name="title" value=$title> <br/>
      Author name: <input type="text" name="author" value=$author> <br/>
      Author gender: <input type="radio" name="gender" value="m"> Male
            <input type="radio" name="gender" value="f"> Female <br/>
      Publishing year: <input type="text" name="year" value=$year> <br/>
      Publisher: <input type="text" name="pub" value=$pub> <br/>
      Genre: <br/>
             <select name="genre" size="5">
               <option value="news">Newstext</option>
               <option value="fict">Fiction</option>
               <option value="bible">Bible</option>
               <option value="asdf">Asdf</option>
               <option value="ghj">Ghj</option>
             </select> <br/>
      Language: ($lang)<br/>
             <select name="lang" size="5">
               <option value="sme">North Sámi</option>
               <option value="smj">Julev Sámi</option>
               <option value="nno">Nynorsk</option>
               <option value="nob">Bokmål</option>
               <option value="fi">Finnish</option>
               <option value="sv">Swedish</option>
             </select> <br/>

      <input type="submit" name="Submit" value="submit form">
    </form>
  </body>
</html>

END_HTML
