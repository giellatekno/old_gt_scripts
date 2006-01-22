#!/usr/bin/perl -w

# Importing CGI libraries
use CGI;
use strict;

# Forwarding warnings and fatal errors to browser window
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

# File copying and xml-processing
use XML::Twig;

# Some securing operations. -sh
$ENV{'PATH'} = '/bin:/usr/bin:/usr/local/bin';
delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};

# The first thing is to print some kind of html-code
print "Content-TYPE: text/html; charset=utf-8\n\n" ;

my $convert = "/usr/local/share/corp/bin/convert2xml.pl";
my $tmpdir = "/usr/local/share/corp/tmp" ;

# Define upload directory and mkdir it, if necessary
my $upload_dir = "/usr/local/share/corp/tmp";
mkdir ($upload_dir, 0755) unless -d $upload_dir;

my $query = new CGI;
my $license_type = $query->param("license_type");
my $mainlang = $query->param("mainlang");

# Getting the filename and parsing the path away
my $filename = $query->param("document");
$filename =~ s/.*[\/\\](.*)/$1/;

# Replace space with underscore - c = complement the search list
my $fname = $filename;
$fname =~ tr/\.A-Za-z0-9ÁČĐŊŠŦŽÅÆØÄÖáčđŋšŧžåæøäö/_/c;

# a hash where we will store the md5sums
my @md5sum;

# Calculate md5sums of files in orig/ dir
@md5sum = (`find /usr/local/share/corp/orig -type f -print0 | xargs -0 -n1 md5sum | sort --key=1,32 -u | cut -c 1-32`);

# Resolving filetype
# MS Word = application/msword
my $filetype = $query->uploadInfo($filename)->{'Content-Type'};

# TODO: Check the file
# This includes: type, sámi characters (how?), ...

# Handle to the file
my $upload_filehandle = $query->upload("document");

if (!$upload_filehandle) {
    die "FILE NOT FOUND!";
}

# Open file on the server and print uploaded file into it.
open UPLOADFILE, ">$upload_dir/$fname"
      or die "Can't open file $upload_dir/$fname!";
while (<$upload_filehandle>) {
	print UPLOADFILE;
}
close UPLOADFILE;

my $md5 = (`md5sum $upload_dir/$fname | cut -c 1-32`);

# Check that file doesn't already exist
for my $i (@md5sum) {
	if ($i eq $md5) {
#		rm $upload_dir/$fname; # TODO: remove file, how to do it in Perl?
		die "File already exists in our corpus base!";
	}
}

# Calling convert2xml -script with hardcoded execution path
# The 'or die' part doesn't work, it dies everytime...
system "\"$convert\" --lang=\"$mainlang\" --tmpdir=\"$tmpdir\" --noxsl \"$upload_dir/$fname\"";
#	 or die "Error in conversion";


my $author1_ln;
my $publisher;
my $year;
my $isbn;
my $issn;
my $title;
my $document = XML::Twig->new(twig_handlers => 
							  { 'header/author/person' => sub { $author1_ln = $_->{'att'}->{'lastname'} },
								'header/publChannel/publisher' => sub { $publisher = $_->text },
								'header/publChannel/isbn' => sub { $isbn = $_->text },
								'header/publChannel/issn' => sub { $issn = $_->text },
								'header/year' => sub { $year = $_->text },
								'header/title' => sub { $title = $_->text },

							});

if ($document->safe_parsefile ("$upload_dir/$fname.xml") == 0) {
	 print STDERR "$fname: ERROR parsing the XML-file failed.\n";
 }

# The html-part starts here                                                                                 
print <<END_HTML;
<html>
  <head>
        <title>File uploaded</title>
  </head>

  <body>

<h1>File uploaded</h1>
    <p>Thank you for uploading the file <a href="$upload_dir/$filename"> $filename </a>.</p>
	<p>Please fill in the following form.</p>

<h1>The document information</h1>

    <form TYPE="text" ACTION="xsl-process.cgi" METHOD="post" enctype="multipart/form-data">
  Title: <input type="text" name="title" value="$title" size="50"> <br/>
      Author(s):
    <ol>
    <li id="order">
<label> Author: </label><br>
  Firstname: <input type="text" name="author1_fn" value="" size="30"><br/>
  Lastname: <input type="text" name="author1_ln" value="$author1_ln" size="30"><br/>
  Gender: <input type="radio" name="author1_gender" value="m"> Male
    <input type="radio" name="author1_gender" value="f"> Female <br/>
  Born: <input type="text" name="author1_born" value="" size="4"><br/>
  Nationality:
    <select name="author1_nat">
    <option value="fin">Finnish</option>
    <option value="nor">Norwegian</option>
               <option value="swe">Swedish</option>
    <option value="oth">other</option>
    </select> <br/>
    </li>
    </ol>
    </table>
    </p>

<table>
    <tr>
    <td>Publishing year:</td><td> <input type="text" name="year" value="$year"> </td>
    </tr>
    <tr>
      <td> Publishing place:</td><td> <input type="text" name="place" value=""> </td>
    </tr>
    <tr>
      <td> Publisher:</td><td> <input type="text" name="publisher" value="$publisher"> </td>
    </tr>
    <tr>
      <td> ISBN:</td><td> <input type="text" name="isbn" value="$isbn"> </td>
    <tr>
      <td> ISSN: </td><td><input type="text" name="issn" value="$issn"> </td>
    </tr>
    <tr>
      <td> Collection:</td><td> <input type="text" name="collection" value=""> </td>
    </tr>
    <tr>
     <td> Genre: </td><td>
             <select name="genre">
	           <option value="">--none--</option>
               <option value="news">Newstext</option>
               <option value="laws">Lawtext</option>
               <option value="ficti">Fiction</option>
                  <option value="bible">Bible</option>
               <option value="admin">Admin</option>
               <option value="facta">Facta</option>
	</select> </td>
    </tr>
    <tr>
       <td> Translated from: </td><td>
             <select name="translated_from">
	<option value="">--none--</option>
	<option value="sme">North S&aacute;mi</option>
	<option value="smj">Julev S&aacute;mi</option>
	<option value="sma">South S&aacute;mi</option>
               <option value="nno">Nynorsk</option>
	<option value="nob">Bokm&aring;l</option>
               <option value="fin">Finnish</option>
               <option value="swe">Swedish</option>
               <option value="eng">English</option>
               <option value="oth">other</option>
             </select></td>
</tr>
<tr>
<td>Translator: </td>
<td>  Firstname: <input type="text" name="translator_fn" value="" size="30"><br/>
 Lastname: <input type="text" name="translator_ln" value="" size="30"></td>
</td>
</tr>
<tr>
<td>Submitter:</td>
<td>  Name: <input type="text" name="sub_name" value="" size="30"><br/>
  Email: <input type="text" name="sub_email" value="" size="40"></td>
</tr>
</table>
      <input type="hidden" name="filename" value="$upload_dir/$fname">
      <input type="hidden" name="license_type" value="$license_type">
      <input type="hidden" name="mainlang" value="$mainlang">
      <input type="submit" name="Submit" value="submit form">
    </form>
  </body>
</html>

END_HTML
