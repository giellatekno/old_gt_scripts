#!/usr/bin/perl -w

use strict;
binmode STDOUT, ":utf8";
use IO::File;
use File::Basename;
use Getopt::Long;
use XML::Twig;

my $corpdir = "/usr/local/share/corp";
my $bindir = "/usr/local/share/corp/bin";
my $tmpdir = "/usr/local/share/corp/tmp";

my $gtbound_dir = "bound";
my $gtfree_dir = "free";
my $orig_dir = "orig";
my $lang = "sme";
my $para_lang = "nob";

my $help;
my $file;
my $files;

GetOptions ("file=s" => \$file,
			"files=s" => \$files,
			"lang=s" => \$lang,
			"para_lang=s" => \$para_lang,
			);

if ($help) {
	&print_help;
	exit 1;
}

if ($files) {
	my @input_files = split (",", $files);
	for my $f ( @input_files) {
		process_file($f);
	}
}
else { process_file($file); }

sub process_file {
	my $file = shift @_;

	my $document = XML::Twig->new;
	if (! $document->safe_parsefile ("$file") ) {
		print STDERR "$file: ERROR parsing the XML-file failed.\n";
		exit;
	}
	
	my $location;
	my $root = $document->root;
	my $header = $root->first_child('header');
	my @parallel_texts = $header->children('parallel_text');
	for my $p (@parallel_texts) {
		my $plang = $p->{'att'}->{'xml:lang'};
		next if ($plang ne $para_lang);
		$location = $p->{'att'}->{'location'};
		last;
	}
	
	if(! $location) {
		print "No parallel texts found for language $para_lang.\n";
		exit;
	}
	
# The path to the original.
# And path to parallel files.
	$file = File::Spec->rel2abs($file);
	(my $path = $file) =~ s/(.*)[\/\\].*/$1/;
	(my $para_path = $path) =~ s/$lang/$para_lang/o;
	
	my 	@para_files = split(",", $location);
	my @full_paths;
	for my $p (@para_files) {
		$p = $para_path . "/" . $p . ".xml";
		push (@full_paths, $p);
	}
	
# Prepare files for further processing by 
# adding <s> tags and sentence ids.
# The output goes to tmp.
	
# Take only the file name without path.
	(my $base = $file) =~ s/.*[\/\\](.*)/$1/;
	my $outfile=$tmpdir . "/" . $base . ".sent";
	my $command="corpus-analyze.pl --input=\"$file\" --output=\"$outfile\" --only_add_sentences --lang=$lang";
	print "$command\n";
#	if ( system($command) != 0 ) {  die "errors in $command: $!\n"; }
	
# If there are more than one parallel file, these files are combined to one.
	if ($#full_paths > 0) { die "Cannot process more than one parallel file\n"; }
	
	my $pfile=$full_paths[0];
	(my $pbase = $pfile) =~ s/.*[\/\\](.*)/$1/;
	my $poutfile=$tmpdir . "/" . $pbase . ".sent";
	$command="corpus-analyze.pl --input=\"$pfile\" --output=\"$poutfile\" --only_add_sentences --lang=$para_lang";
	print "$command\n";
	if ( system($command) != 0 ) {  die "errors in $command: $!\n"; }
}
