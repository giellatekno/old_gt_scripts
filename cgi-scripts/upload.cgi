#!/usr/bin/perl -w

use strict;

# Importing CGI libraries
use CGI;
$CGI::DISABLE_UPLOADS = 0;
$CGI::POST_MAX        = 1_024 * 1_024; # limit posts to 1 meg max

# Forwarding warnings and fatal errors to browser window
use CGI::Alert 'saara';

# Show custom text to remote viewer
CGI::Alert::custom_browser_text << '-END-';
<h1>Error in uploading the file.</h1>
<p>Our maintainers have been informed.</p>
<p>Send feedback and questions to <a href="mailto:corpus@giellatekno.uit.no?subject=Feedback%C2%A0upload.cgi">corpus@giellatekno.uit.no</mail></p>
<p><a href="http://www.divvun.no/upload/upload-corpus-file.html">Upload more files</a> </p>
<p><a href="http://www.divvun.no/"> Divvun main page</a></p>
-END-

# File copying and xml-processing
use XML::Twig;

my $query = new CGI;

# The first thing is to print some kind of html-code
print "Content-TYPE: text/html; charset=utf-8\n\n" ;

my $convert = "/usr/local/share/corp/bin/convert2xml.pl";
my $tmpdir = "/usr/local/share/corp/upload" ;

# Define upload directory and mkdir it, if necessary
my $upload_dir = "/usr/local/share/corp/upload";
mkdir ($upload_dir, 0755) unless -d $upload_dir;

# Some securing operations. -sh
$ENV{'PATH'} = '/bin:/usr/bin:/usr/local/bin';
delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};

my $license_type = $query->param("license_type");
my $mainlang = $query->param("mainlang");

# Getting the filename and parsing the path away
my $filename = $query->param("document");
if (! $filename ) { die "No file was selected for upload.\n" }
$filename =~ s/.*[\/\\](.*)/$1/;

# Replace space with underscore - c = complement the search list
my $fname = $filename;
$fname =~ tr/\.A-Za-z0-9ÁČĐŊŠŦŽÅÆØÄÖáčđŋšŧžåæøäö/_/c;

# Generate a new file name 
# if there exists a file with the same name.
$fname =~ s/.*[\/\\](.*)/$1/;
my $i = 1;
while (-e "$upload_dir/$fname") {
	my $tmp = $fname;
	$tmp =~ s/(\.(.*))$//;
	$tmp = $tmp . "_" . $i;
	$fname = $tmp.$1;
	$i++;
}

# a hash where we will store the md5sums
my @md5sum;

# Calculate md5sums of files in orig/ dir
@md5sum = (`find /usr/local/share/corp/orig -type f -print0 | xargs -0 -n1 md5sum | sort --key=1,32 -u | cut -c 1-32`);

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
my @args = ("$convert", "--lang=$mainlang", "--tmpdir=$tmpdir", "--noxsl", "--upload", "$upload_dir/$fname");
system (@args);
#	 or die "Error in conversion";


my $author1_ln="";
my $publisher="";
my $year="";
my $isbn="";
my $issn="";
my $title="";
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
print <<END_HEADER
<html>
	<head>
END_HEADER
	;
	&write_js;

print <<END_HTML
	<title>File uploaded</title>
  </head>
  <body>

<h1>File uploaded</h1>
    <p>Thank you for uploading the file $filename </a>.</p>
	<p>Please fill in the following form with the available
    information of the document. The fields submitter name
    and email are mandatory.</p>

<h1>The document information</h1>

    <form name="metainfo" TYPE="text" ACTION="xsl-process.cgi"
	METHOD="post" enctype="multipart/form-data" onsubmit="return checkWholeForm(this)">

  Document title: <input type="text" name="title" value="$title" size="50"> <br/>
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
	<option value="">--none--</option>
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
       <td>If the document is multilingual,<br/> 
  select the other languages:</td>
	<td>
	<INPUT TYPE="checkbox" NAME="mlang_sme" value="1">North S&aacute;mi
	<INPUT TYPE="checkbox" NAME="mlang_smj" value="1">Julev S&aacute;mi
	<INPUT TYPE="checkbox" NAME="mlang_sma" value="1">South S&aacute;mi<BR/> 
	<INPUT TYPE="checkbox" NAME="mlang_nno" value="1">Nynorsk
	<INPUT TYPE="checkbox" NAME="mlang_nob" value="1">Bokm&aring;l<BR/> 
	<INPUT TYPE="checkbox" NAME="mlang_fin" value="1">Finnish
	<INPUT TYPE="checkbox" NAME="mlang_swe" value="1">Swedish
	<INPUT TYPE="checkbox" NAME="mlang_eng" value="1">English
	<INPUT TYPE="checkbox" NAME="mlang_ger" value="1">German
	<INPUT TYPE="checkbox" NAME="mlang_oth" value="1">other
	</td>
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
<td>  Name: <img src="star.gif" width="8" height="16" border="0" alt="star">
 <input type="text" name="sub_name" value="" size="30"><br/>
  Email: <img src="star.gif" width="8" height="16" border="0" alt="star">
<input type="text" name="sub_email" value="" size="40"></td>
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
	;

sub write_js {
	print <<END_OF_JS
<script language="JavaScript">

// check form
   	function checkWholeForm(theForm) {
		var why = "";
		why += checkEmail(theForm.sub_email.value);
		why += isEmpty(theForm.sub_name.value);
		if (why != "") {
			alert(why);
			return false;
		}
		return true;
	}
// email	
	function checkEmail (strng) {
		var error="";
		if (strng == "") {
			error = "You didn't enter an email address.\\n";
		}
		
		var emailFilter=/^.+@.+\\..{2,3}\$\/;
		if (!(emailFilter.test(strng))) { 
			error = "Please enter a valid email address.\\n";
		}
		else {
			//test email for illegal characters
				var illegalChars= /[\\(\\)\\<\\>\\,\\;\\:\\"\\[\\]]/
				if (strng.match(illegalChars)) {
					error = "The email address contains illegal characters.\\n";
				}
		}
		return error;
	}

// non-empty submitter	
	function isEmpty(strng) {
		var error = "";
		if (strng.length == 0) {
			error = "Please fill in the submitter name field.\\n"
			}
		return error;
		}
</script>
END_OF_JS
;
}
