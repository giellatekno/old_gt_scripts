#!/usr/bin/perl

use CGI;

#$upload_dir = "/Users/tomi/corpus/tmp";
$upload_dir = "/usr/local/share/corp/sme/orig";

$query = new CGI;

$filename = $query->param("document");
$filename =~ s/.*[\/\\](.*)/$1/;

$upload_filehandle = $query->upload("photo");

open UPLOADFILE, ">$upload_dir/$filename";

binmode UPLOADFILE;

while (<$upload_filehandle>) {
#	print UPLOADFILE;
}

close UPLOADFILE;


print $query->header ( ); 
print <<END_HTML;

<html>
  <head>
  	<title>File uploaded</title>
  </head>
  
  <body>
  	<p>Thank you for uploading file <a href="$upload_dir/$filename"> $filename </a></p>
  </body
</html>