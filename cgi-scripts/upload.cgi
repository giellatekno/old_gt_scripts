#!/usr/bin/perl -w

use strict;

# Importing CGI libraries
use CGI qw/:standard/;
#use CGI::Upload;
$CGI::DISABLE_UPLOADS = 0;
$CGI::POST_MAX        = 1_024 * 1_024; # limit posts to 1 meg max

# Forwarding warnings and fatal errors to browser window
use CGI::Alert 'ciprian';

# Show custom text to remote viewer
CGI::Alert::custom_browser_text << '-END-';
<h1>Error in uploading the file.</h1>
<p>[MSG]</p>
<p>Our maintainers have been informed.</p>
<p>Send feedback and questions to <a href="mailto:feedback@divvun.no?subject=Feedback%C2%A0upload.cgi">feedback@divvun.no</mail></p>
<p><a href="http://www.divvun.no/upload/upload_corpus_file.html">Upload more files</a> </p>
<p><a href="http://www.divvun.no/"> Divvun main page</a></p>
-END-

# File copying and xml-processing
use XML::Twig;

# Allowed mime-headers.
# http://www.iana.org/assignments/media-types/
my %mime_types = ( "text/html" => "html",
					"application/msword" => "doc",
					"application/pdf" => "pdf",
					"text/plain" => "txt",
					"image/svg+xml" => "svg" );


# The first thing is to print some kind of html-code
print "Content-TYPE: text/html; charset=utf-8\n\n" ;

# Define upload directory and mkdir it, if necessary
my $upload_dir = "/home/apache_corpus/uplad";
mkdir ($upload_dir, 0755) unless -d $upload_dir;

# Some securing operations. -sh
$ENV{'PATH'} = '/bin:/usr/bin:/usr/local/bin';
delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};

# print new page for multiple file upload
my $file_count = param("file_count");
if (! $file_count) { $file_count = 1; }
if(param("print_multiple") && $file_count) {
	print_multiple_upload($file_count);
	exit;
}

# Getting the filename and content type check.
my @filehandle  = upload('document');    #array of file handles 

if (! @filehandle ) { die "No file was selected for upload.\n" }
for my $file (@filehandle) {
	my $filetype = uploadInfo($file)->{'Content-Type'}; 
	
	if (! $mime_types{$filetype}) { die "Upload only msword, pdf, svg and html-files.\n" }
	else {
		if ($file !~ m/\.(doc|pdf|html|txt|ptx|svg)$/) {
			$file = $file . "." . $mime_types{$file};
		}
	}
}

my $real_count = @filehandle;
if ($real_count > $file_count || $real_count > 9) {
	die "Upload only up to 9 files at the time.\n"
}

# Message sent to the maintainer after corpus upload.
my $message = "Files uploaded to $upload_dir.\n";

my $author1_ln="";
my $publisher="";
my $year="";
my $isbn="";
my $issn="";
my $title="";

my @fnames;
my @mainlangs;
my @license_types;


# Calculate md5sums of files in orig/ dir
my @md5sums = (`find /home/apache_corpus/ -type f -print0 | xargs -0 -n1 md5sum | sort --key=1,32 -u | cut -c 1-32`);
	

my $i;
for($i=0;$i<$file_count;$i++) {

    # Parsing the path away
	my $filename = $filehandle[$i];

    # Parsing the path away
	$filename =~ s/.*[\/\\](.*)/$1/;
    # Replace space with underscore - c = complement the search list
	my $fname = $filename;
	$fname =~ tr/\.A-Za-z0-9ÁČĐŊŠŦŽÅÆØÄÖáčđŋšŧžåæøäö/_/c;
	
    # Generate a new file name 
    # if there exists a file with the same name.
	$fname =~ s/.*[\/\\](.*)/$1/;
	my $j = 1;
	while (-e "$upload_dir/$fname") {
		my $tmp = $fname;
		$tmp =~ s/(\.(.*))$//;
		$fname = $tmp . "_" . $j . $1;
		$j++;
	}

   # Open file on the server and print uploaded file into it.
	open UPLOADFILE, ">$upload_dir/$fname"
		or die "Can't open file $upload_dir/$fname!";
	while (<$filename>) {
		print UPLOADFILE;
	}
	close UPLOADFILE;
	
	my $md5 = (`md5sum $upload_dir/$fname | cut -c 1-32`);	
    # Check that file doesn't already exist
	for my $j (@md5sums) {
		if ($j eq $md5) {
#		rm $upload_dir/$fname; # TODO: remove file, how to do it in Perl?
			die "$filename: File already exists in our corpus base!";
		}
	}

	my $mlang = "mainlang_" . $i;
	my $ltype = "license_type_" . $i;
	my $mainlang = param($mlang);
	my $license_type = param($ltype);
	push @mainlangs, $mainlang;
	push @license_types, $license_type;

	push @fnames, $fname;
	$message.= "Name: $fname\nlanguage: $mainlang\nlicense: $license_type\n"
}


# Print metainformation form.
&print_metaform;


########## Subroutines from here on ######

# Print metainfomation form
sub print_metaform {


	print <<END_HEADER;
	<html>
	<head>
END_HEADER

&write_js;

	if($real_count > 1) {
		print <<END_FIRST_PART;
		<title>File uploaded</title>
			</head>
			<body>
			
			<h1>File uploaded</h1>
			<p>Thank you for uploading the file @filehandle </a>.</p>
			<p>Please fill in the following form with the available
			information of the document. The fields submitter name
			and email are mandatory.</p>
END_FIRST_PART

}	

	else {
		print <<END_FIRST_PART;
		<title>Files uploadeded</title>
			</head>
			<body>
			
			<h1>File uploaded</h1>
			<p>Thank you for uploading the files @filehandle </a>.</p>
			<p>Please fill in the following form with the available
			information of the documents. Notice that all the
			documents will recieve the same metainformation. The fields submitter name
			and email are mandatory.</p>
END_FIRST_PART

	}

	print <<END_HTML;
	<h1>The document information</h1>

    <form name="metainfo" TYPE="text" ACTION="xsl-process.cgi"
	METHOD="post" enctype="multipart/form-data" onsubmit="return checkWholeForm(this)">

  Document title: <input type="text" name="title" value="$title" size="50"> <br/>
      Author(s):
<table BORDER=0 CELLPADDING=10>
<tr><td>
1. Author:<br>
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
</td>
<td>
3. Author:<br>
  Firstname: <input type="text" name="author3_fn" value="" size="30"><br/>
  Lastname: <input type="text" name="author3_ln" value="" size="30"><br/>
  Gender: <input type="radio" name="author3_gender" value="m"> Male
    <input type="radio" name="author3_gender" value="f"> Female <br/>
  Born: <input type="text" name="author3_born" value="" size="4"><br/>
  Nationality:
    <select name="author3_nat">
	<option value="">--none--</option>
    <option value="fin">Finnish</option>
    <option value="nor">Norwegian</option>
               <option value="swe">Swedish</option>
    <option value="oth">other</option>
    </select> <br/>

</td></tr>
<tr><td>

2. Author:<br>
  Firstname: <input type="text" name="author2_fn" value="" size="30"><br/>
  Lastname: <input type="text" name="author2_ln" value="" size="30"><br/>
  Gender: <input type="radio" name="author2_gender" value="m"> Male
    <input type="radio" name="author2_gender" value="f"> Female <br/>
  Born: <input type="text" name="author2_born" value="" size="4"><br/>
  Nationality:
    <select name="author2_nat">
	<option value="">--none--</option>
    <option value="fin">Finnish</option>
    <option value="nor">Norwegian</option>
               <option value="swe">Swedish</option>
    <option value="oth">other</option>
    </select> <br/>
</td>
<td>
4. Author:<br>
  Firstname: <input type="text" name="author4_fn" value="" size="30"><br/>
  Lastname: <input type="text" name="author4_ln" value="" size="30"><br/>
  Gender: <input type="radio" name="author4_gender" value="m"> Male
    <input type="radio" name="author4_gender" value="f"> Female <br/>
  Born: <input type="text" name="author4_born" value="" size="4"><br/>
  Nationality:
    <select name="author4_nat">
	<option value="">--none--</option>
    <option value="fin">Finnish</option>
    <option value="nor">Norwegian</option>
               <option value="swe">Swedish</option>
    <option value="oth">other</option>
    </select> <br/>
</td></tr>
</table>
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
      <input type="hidden" name="filename" value="@fnames">
      <input type="hidden" name="license_type" value="@license_types">
      <input type="hidden" name="mainlang" value="@mainlangs">
      <input type="submit" name="Submit" value="submit form">
    </form>
  </body>
</html>

END_HTML
}

sub print_multiple_upload {

	my $file_c = shift @_;

	
	print <<END_H;
	<html>
		<head>
		<title>File uploaded</title>
		</head>
		<body>
		
		<h1>Fill in the filenames and languages</h1>
		
		<form  ACTION="http://gtweb.uit.no/cgi-bin/smi/upload2.cgi"
		METHOD="post" ENCTYPE="multipart/form-data">
		
END_H
	
	my $i;
	for($i=0;$i<$file_c;$i++) {
		my $j=$i+1;
		print <<END_FIELDS;
		<table border="0" cellspacing="5" cellpadding="0" >
			<tr><td> File $j: </td><td><INPUT TYPE="file" NAME="document"></td></tr>
			<tr><td> Main language: </td><td>
			<select name="mainlang_$i">
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
			<tr><td> License: </td><td>
			<select name="license_type_$i">
			<option value="free">Free</option>
			<option value="standard">Standard</option>
			<option value="other">Other</option>
			</select>
			</td></tr>
			</table>
			
END_FIELDS

}
	
	print <<END;
		<br/>
			<input type="hidden" name="file_count" value="$file_c">
			<INPUT TYPE="submit" NAME="Submit" VALUE="Submit Form" >
		</form>
		</body>
		</html>
		
END

}


sub write_js {
	print <<END_OF_JS;
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

}
