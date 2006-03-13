#!/usr/bin/perl
#
# reformat_commonxsl.pl
#
# Perl script for adding version information of the conversion tools 
# to the common.xml. Called from copy_corpus_bin.sh
#
# $Id$

my $convert="convert2xml.pl";
my $hyph="add-hyph-tags.pl";
my $docbook="docbook2corpus2.xsl";
my $xhtml="xhtml2corpus.xsl";

my $convert_version;
my $hyph_version;
my $docbook_version;
my $xhtml_version;

open (FH, "<$convert");
while(<FH>) {
	if (/\$Revision\:(.*?)\$/) {
		$convert_version = $1;
		last;
	}
}
close FH;

open (FH, "<$hyph");
while(<FH>) {
	if (/\$Revision\:(.*?)\$/) {
		$hyph_version = $1;
		last;
	}
}
close FH;
open (FH, "<$docbook");
while(<FH>) {
	if (/\$Revision\:(.*?)\$/) {
		$docbook_version = $1;
		last;
	}
}
close FH;
open (FH, "<$xhtml");
while(<FH>) {
	if (/\$Revision\:(.*?)\$/) {
		$xhtml_version = $1;
		last;
	}
}
close FH;

my $common_xsl="common.xsl";

# Reformat the version information in the new xsl-file.
open (FH, "+<$common_xsl");
my @text_array = <FH> ;
my @result_array;
foreach my $line (@text_array){
	if ($line =~ /name\=\"common_version/) { $line =~ s/\$Revision$/$1/g; }
	if ($line =~ /name\=\"convert2xml_version/) { $line =~ s/(select=\"\').*?(\'\")/$1$convert_version$2/ };
	if ($line =~ /name\=\"hyph_version/) { $line =~ s/(select=\"\').*?(\'\")/$1$hyph_version$2/ };
	if ($line =~ /name\=\"xhtml2corpus_version/) { $line =~ s/(select=\"\').*?(\'\")/$1$xhtml_version$2/ };
	if ($line =~ /name\=\"docbook2corpus2_version/) { $line =~ s/(select=\"\').*?(\'\")/$1$docbook_version$2/ };
	push @result_array, $line;
}
seek (FH,0,0);
print FH @result_array;
truncate(FH, tell(FH));
close(FH);

# Do some reformatting also for the template.

my $xsl_template="XSL-template.xsl";

open (FH, "+<$xsl_template");
my @text_array = <FH> ;
my @result_array;
foreach my $line (@text_array){
	if ($line =~ /name\=\"current_version/) { $line =~ s/Revision/\$Revision\$/; }
	if ($line =~ /name\=\"template_version/) { $line =~ s/\$Revision\:(.*?)\$/$1/g; }
	push @result_array, $line;
}
seek (FH,0,0);
print FH @result_array;
truncate(FH, tell(FH));
close(FH);
