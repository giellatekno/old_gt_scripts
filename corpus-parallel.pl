#!/usr/bin/perl -w

use strict;
binmode STDOUT, ":utf8";
use IO::File;
use File::Basename;
use Getopt::Long;
use XML::Twig;
use File::Find;

my $corpdir = "/usr/local/share/corp";
my $bindir = "/usr/local/share/corp/bin";
my $tmpdir = "/usr/local/share/corp/tmp";

my $gtbound_dir = "bound";
my $gtfree_dir = "free";
my $orig_dir = "orig";
my $lang = "sme";
my $para_lang = "nob";
my $list;
my $dir;
my %file_list;

my $help;
my $file;
my $files;

GetOptions ("help" => \$help,
			"files=s" => \$files,
			"dir=s" => \$dir,
			"lang=s" => \$lang,
			"para_lang=s" => \$para_lang,
			"list" => \$list,
			);

if ($help) {
	&print_help;
	exit 1;
}

# Search the files in the directory $dir and process each one of them.
if ($dir) {
	if ($list) {
		print STDERR "listing..\n";
		if (-d $dir) { find (\&list_files, $dir) }
		else { print "$dir ERROR: Directory did not exit.\n"; }		

		for my $file (sort keys %file_list) {
			print "$file\n";
			for my $plang (keys %{ $file_list{$file} } ) {
				print "\t$file_list{$file}{$plang}.xml\n";
			}
			print "\n";
		}
	}
	else {
		if (-d $dir) { find (\&process_file, $dir) }
		else { print "$dir ERROR: Directory did not exit.\n"; }
	}
}

elsif ($files) {
	my @input_files = split (",", $files);
	for my $f ( @input_files) {
		if (-f $f) { process_file($f); }
	}
}
elsif ($file) { process_file($file); }

# Process the file given in command line.
else { process_file ($ARGV[$#ARGV]) if -f $ARGV[$#ARGV]; }


sub list_files {
	my $file = $_;
	return if (! -f $file );

	return if ($file =~ /~$/);
	
	my %para_files;

    my $full = File::Spec->rel2abs($file);
	(my $path = $full) =~ s/(.*)[\/\\].*/$1/;

	my $document = XML::Twig->new;
	if (! $document->safe_parsefile ("$file") ) {
		print STDERR "$file: ERROR parsing the XML-file failed.\n";
		return;
	}
	my $location;
	my $root = $document->root;
	my $header = $root->first_child('header');
	my @parallel_texts = $header->children('parallel_text');
	for my $p (@parallel_texts) {
		my $plang = $p->{'att'}->{'xml:lang'};
		my $para_file = $p->{'att'}->{'location'};
		if($para_file) {
			(my $para_path = $path) =~ s/$lang/$plang/o;
			$para_file = $para_path . "/" . $para_file;
			$para_files{$plang} = $para_file;
		}
	}
	return if (! %para_files);

	$file_list{$full} = { %para_files };
}

sub process_file {
	my $file = $_;
    $file = shift (@_) if (!$file);

	my $document = XML::Twig->new;
	if (! $document->safe_parsefile ("$file") ) {
		print STDERR "$file: ERROR parsing the XML-file failed.\n";
		return;
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
		return;
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
	my $command="corpus-analyze.pl --output=\"$outfile\" --only_add_sentences --lang=$lang \"$file\"";
#	print STDERR "$command\n";
	if ( system( $command) != 0 ) {  return "errors in $command: $!\n"; }
	
# If there are more than one parallel file, these files are combined to one.
	if ($#full_paths > 0) { return "Cannot process more than one parallel file\n"; }
	
	my $pfile=$full_paths[0];
	(my $pbase = $pfile) =~ s/.*[\/\\](.*)/$1/;
	my $poutfile=$tmpdir . "/" . $pbase . ".sent";
	$command="corpus-analyze.pl  --output=\"$poutfile\" --only_add_sentences --lang=$para_lang \"$pfile\"";
	print STDERR "$command\n";
	if ( system($command) != 0 ) {  return "errors in $command: $!\n"; }
}

sub print_help {
	print << "END";
Searches for parallel documents and prepares them for alignment.
Usage: corpus-parallel.pl [OPTIONS] [FILE]
--help                Print this help text and exit.
--files=<f1,f2,..>    List of input files separated by comma.
--dir=<dir>           The directory where the files are searched.        
--lang=<lang>         The main language.
--para_lang=<lang>    The language of the parallel document(s).
--list                List the parallel files, use with option --dir.
--list_file=<file>    The name of the list file.
END

}

