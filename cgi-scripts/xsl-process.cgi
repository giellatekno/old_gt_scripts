#!/usr/bin/perl -w

# Importing CGI libraries
use CGI;
use File::Copy;
use strict;

# Forwarding warnings and fatal errors to browser window
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

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

my $corpdir = "/usr/local/share/corp";
my $tmp_dir = "$corpdir/tmp";
my $xsltemplate = "$corpdir/bin/XSL-template.xsl";
my $orig_dir;
my $langgenre ="";

if ($bookinfo{mainlang} && $bookinfo{genre}) {
	$langgenre = $bookinfo{'mainlang'} . "/" . $bookinfo{'genre'};
	$orig_dir = "$corpdir/orig/$langgenre";
}
else {
	print "Warning: main language and genre were not specified.\n";
	$orig_dir = $tmp_dir;
}

my $finaldir = $orig_dir;
$finaldir =~ s/orig/gt/;

# Define the directory in the orig-hierarchy
if ($langgenre && ( $bookinfo{'genre'} eq "news" || $bookinfo{'genre'} eq "admin")) {
	# Kautokeino hack
	if ($bookinfo{'publisher'} eq "Kautokeino") {
		$orig_dir = "/usr/local/share/corp/orig/$langgenre/guovda";
	}
	# Karasjok hack
	elsif ($bookinfo{'publisher'} eq "Karasjok") {
		$orig_dir = "/usr/local/share/corp/orig/$langgenre/karas";
	}
	
	else {
		$orig_dir = "/usr/local/share/corp/orig/$langgenre/$bookinfo{'publisher'}";
	}
}

# Strip path
if(!$bookinfo{filename}) {
	die "File not specified\n";
}
my $filename = $bookinfo{filename};
my $fname = $filename;
$fname =~ s/.*[\/\\](.*)/$1/;

$i = 1;
while (-e "$orig_dir/$fname") {
	$fname = "$fname-$i";
	$i++;
}

# Create the xsl-file and add the form data
copy ("$xsltemplate", "$orig_dir/$fname.xsl") or die "Copy failed ($orig_dir/$fname.xsl): $!";

my $document = XML::Twig->new(twig_handlers => {'xsl:variable' => \&process });

$document->parsefile ("$orig_dir/$fname.xsl");
$document->set_pretty_print('record');

open (FH, ">$orig_dir/$fname.xsl") or die "Cannot open file $orig_dir/$fname.xsl for output: $!";
$document->print( \*FH);

# Convert the document
my $command;
if ($orig_dir eq $finaldir) {
	my $new_filename = $filename . "1";
	move ("$filename.xml", "$new_filename.xml") or die "Could not move the file $filename. $!";
	$filename = $new_filename;
	$command = "xsltproc --novalid $orig_dir/$fname.xsl $filename.xml > $finaldir/$fname.xml";
}
else {
	move ("$filename", "$orig_dir/$fname");
	$command = "xsltproc --novalid $orig_dir/$fname.xsl $filename.xml > $finaldir/$fname.xml";
}
system($command)  == 0 
	or die "$command failed: $! \n";


#Change the group of the xsl-file to cvs.
#RCS command for initial checkin of the xsl-file.
#my $command = "chgrp cvs $orig_dir/$fname";
#system $command or die "System failed: $!";
#$command = "ci -t-\"xsl file, created in xsl-process.cgi\" -q -i $orig_dir/$fname";
#system $command or die "System failed: $!";


# The html-part starts here
print <<END_HTML;

<html>
  <head>
  	<title>XSL-Processing</title>
  </head>
  
  <body>
    <p>$finaldir/$fname.xml</p>
  </body>
</html>

END_HTML

sub process {
    my ( $t, $var) = @_;

	my $attribute = $var->{'att'}->{'name'};
	if ($attribute && $bookinfo{$attribute} ) {
		$var->set_att( 'select' => "'" . $bookinfo{$attribute}  . "'");
	}
}
