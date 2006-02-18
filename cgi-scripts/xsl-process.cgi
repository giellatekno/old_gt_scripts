#!/usr/bin/perl -w

use strict;

# Importing CGI libraries
use CGI;
$CGI::DISABLE_UPLOADS = 1;
$CGI::POST_MAX        = 1_024 * 1_024; # limit posts to 1 meg max

# Forwarding warnings and fatal errors to browser window
use CGI::Alert 'saara';

# Show custom text to remote viewer
CGI::Alert::custom_browser_text << '-END-';
<h1>Error in updating the information to the file.</h1>
<p>Our maintainers have been informed.</p>
<p>Send feedback and questions to <a href="mailto:corpus@giellatekno.uit.no?subject=Feedback%C2%A0upload.cgi">corpus@giellatekno.uit.no</mail></p>
<p><a href="http://www.divvun.no/upload/upload-corpus-file.html">Upload more files</a> </p>
<p><a href="http://www.divvun.no/"> Divvun main page</a></p>

-END-

# File copying and xml-processing
use File::Copy;
use XML::Twig;

# Set the file permissions of the newly created files to -rw-rw-r--
umask 0112;

# The first thing is to print some kind of html-code
print "Content-TYPE: text/html\n\n" ;

my $query = new CGI;

my %bookinfo;
my @names = $query->param;
for my $name (@names) {
	$bookinfo{$name} = $query->param($name);
}
# In case of multilingual document, there should be at least one
# mlang-attribute specified.
for my $key (keys %bookinfo) {
	if ( $key =~ /mlang/) {
		$bookinfo{'multilingual'} = 1;
		last;
	}
}

my $corpdir = "/usr/local/share/corp";
my $tmp_dir = "$corpdir/upload";
my $upload_dir = "$corpdir/upload";
my $xsltemplate = "$corpdir/bin/XSL-template.xsl";

if(!$bookinfo{filename}) { die "File not specified\n"; }

# Parse the filename once more, once for security
# and second for to take away the path.
my $fname = $bookinfo{filename};
$fname =~ s/.*[\/\\](.*)/$1/;
$fname =~ tr/\.A-Za-z0-9ÁČĐŊŠŦŽÅÆØÄÖáčđŋšŧžåæøäö/_/c;
my $upload_file = "$upload_dir/$fname";

# Create the xsl-file and add the form data
copy ("$xsltemplate", "$upload_file.xsl") or die "Copy failed ($upload_file.xsl): $!";

my $document = XML::Twig->new(twig_handlers => {'xsl:variable' => \&process });

$document->parsefile ("$upload_file.xsl");
$document->set_pretty_print('record');

open (FH, ">$upload_file.xsl") or die "Cannot open file $upload_file.xsl for output: $!";
$document->print( \*FH);

# Create a temporary file for conversion.
my $tmpfile = $upload_file . ".tmp";
move ("$upload_file.xml", "$tmpfile.xml") or die "Could not move the file $upload_file.xml. $!";

# Convert the document
my $command;
$command = "xsltproc --novalid $upload_file.xsl $tmpfile.xml > $upload_file.xml";
system($command)  == 0
	or die "$command failed: $! \n";

# The html-part starts here
print <<END_HTML;

<html>
  <head>
  	<title>Document information updated</title>
  </head>
  
  <body>
    <h1>Document information updated</h1> 
	<p>Information updated to file $fname.xml.</p>
    <p><a href="http://www.divvun.no/upload/upload-corpus-file.html"> Upload more files</a> </p>
	<p><a href="http://www.divvun.no/"> Divvun main page</a></p>
  </body>
</html>

END_HTML

sub process {
    my ( $t, $var) = @_;

	my $attribute = $var->{'att'}->{'name'};
	if ($attribute && $bookinfo{$attribute} ) {
		if ($attribute eq "filename") {
			$var->set_att( 'select' => "'" . $fname  . "'");
		}
		else {
			$var->set_att( 'select' => "'" . $bookinfo{$attribute}  . "'");
		}
	}
}
