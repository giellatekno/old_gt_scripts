#!/usr/bin/perl -w

use utf8;
use strict;

use IO::File;
use File::Basename;
use Getopt::Long;
use XML::Twig;
use File::Find;
use Carp qw(cluck croak);
use File::Copy;
use List::Util qw(min);

my $corpus_analyze="$ENV{'GTHOME'}/gt/script/corpus/corpus-analyze.pl";
my $tca2 = "$ENV{'GTHOME'}/gt/script/tca2.sh";

my $corpdir = "$ENV{'GTFREE'}";

my $host=`hostname`;
# If we are in G5
# if ($host !~ /victorio.uit.no/) {
#     $corpdir = "/Users/hoavda/Public/corp";
#     $corpus_analyze = "/Users/saara/gt/script/corpus-analyze.pl";
# }

my $tmpdir = $corpdir . "/tmp";
my $lang = "sme";
my $para_lang = "nob";
my $list;
my $dir;
my %file_list;

my $help;
my $file;
my $files;
my $outdir;

GetOptions ("help" => \$help,
			"files=s" => \$files,
			"dir=s" => \$dir,
			"lang=s" => \$lang,
			"para_lang=s" => \$para_lang,
			"list" => \$list,
			"outdir=s" => \$outdir,
			);

if ($help) {
	&print_help;
	exit 1;
}

if(! $outdir) { $outdir=$tmpdir; }

my $anchor_file = "$ENV{'GTFREE'}/anchor-" . $lang . $para_lang . ".txt";
#my $anchor_file = "/opt/smi/common/bin/anchor-smenno.txt";
#my $anchor_file = "/Users/saara/anchor-smenno.txt";


# Search the files in the directory $dir and list the files
# that have parallel file.
if ($dir) {
	if ($list) {
		print STDERR "listing..\n";
		if (-d $dir) { find (\&list_files, $dir) }
		else { print "$dir ERROR: Directory did not exit.\n"; }		

		for my $file (sort keys %file_list) {
			if ($para_lang){
				if($file_list{$file}{$para_lang}) {
					print "$file";
					print ",$file_list{$file}{$para_lang}.xml";
					print "\n";
				}
			} else {
				print "$file";
				for my $plang (keys %{ $file_list{$file} } ) {
					print ",$file_list{$file}{$plang}.xml";
				}
				print "\n";

			}
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
else { process_file (Encode::decode_utf8($ARGV[$#ARGV])) if -f $ARGV[$#ARGV]; }

# Subroutine to take the parallel files for a file
# Routine examines xml-header of the file.
sub list_files {
	my $file = $_;
	if (! -f $file ) {
		print STDERR "No such file: $file\n";
		return;
	}
	return if ($file =~ /~$/);
	
	my %para_files;

	my $full = File::Spec->rel2abs($file);
	(my $path = $full) =~ s/(.*)[\/\\].*/$1/;

	my $document = XML::Twig->new;
	if (! $document->safe_parsefile ("$file") ) {
		cluck "Parsing the XML-file failed: $file";
		return;
	}
	my $location;
	my $root = $document->root;
	my $header = $root->first_child('header');
	next if (!$header);
	my @parallel_texts = $header->children('parallel_text');
	for my $p (@parallel_texts) {
		my $plang = $p->{'att'}->{'xml:lang'};
		my $para_file = $p->{'att'}->{'location'};
		if($para_file) {
			(my $para_path = $path) =~ s/$lang/$plang/o;
			$para_file = $para_path . "/" . $para_file;
			my $para_xml = $para_file . ".xml";
			if (! -f $para_xml) {
				if (!$para_lang || $para_lang eq $plang) {
					print STDERR "$file: Parallel file $para_xml does not exsist.\n";
					next;
				}
			}
			$para_files{$plang} = $para_file;
		}
	}
	return if (! %para_files);

	$file_list{$full} = { %para_files };
}

# The file and it's parallel counterpart are splitted to sentences,
# aligned and analyzed.
sub process_file {
	my $file = $_;
    $file = shift (@_) if (!$file);

	my $document = XML::Twig->new;
	if (! $document->safe_parsefile ("$file") ) {
		cluck "parsing the XML-file failed.\n";
		return;
	}
	
	# Find the parallel files for the document.
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
		$p = $para_path . "/" . $p;
		if ($p !~ /\.xml/) {
			$p = $p . ".xml";
		}
		push (@full_paths, $p);
	}
	

	# Prepare files for further processing by 
	# adding <s> tags and sentence ids.
    # The output goes to tmp.

    # Take only the file name without path.
	(my $base = $file) =~ s/.*[\/\\](.*).xml/$1/;
# 	my $newfile = $outdir . "/" . $base . ".xml";
# 	if (! -f $newfile) { copy($file,$newfile); }
# 	$file=$newfile;
	my $outfile = $outdir . "/" . $base . $lang . ".sent.xml";

	my $command="$corpus_analyze --all --output=\"$outfile\" --only_add_sentences --lang=$lang \"$file\"";
	print STDERR "$0: $command\n";
	if ( system( $command) != 0 ) {  return "errors in $command: $!\n"; }

#     # If there are more than one parallel file, these files are combined to one.
	if ($#full_paths > 0) { return "Cannot process more than one parallel file\n"; }
	my $pfile=$full_paths[0];
	(my $pbase = $pfile) =~ s/.*[\/\\](.*).xml/$1/;
# 	my $newpfile = $outdir . "/" . $pbase . ".xml";
# 	if (! -f $newpfile) { copy($pfile,$newpfile); }
# 	$pfile = $newpfile;
	
	my $poutfile=$outdir . "/" . $pbase . $para_lang . ".sent.xml";
	$command="$corpus_analyze --all --output=\"$poutfile\" --only_add_sentences --lang=$para_lang \"$pfile\"";
	print STDERR "$0: $command\n";	
	if ( system($command) != 0 ) {  return "errors in $command: $!\n"; }

	$command="$tca2 $anchor_file $outfile $poutfile";
	print STDERR "$0: $command\n";
	system($command);
    
    make_tmx($base, $pbase, $lang, $para_lang);

}

sub make_tmx {
    my ($base, $pbase, $lang, $plang) = @_;

    open(F1, "<:encoding(utf8)", $outdir . "/" . $base . $lang . ".sent_new.txt")  || die("Could not open file!");
    my @f1_data = <F1>;
    close(F1);
    open(F2, "<:encoding(utf8)", $outdir . "/" . $pbase . $para_lang . ".sent_new.txt")  || die("Could not open file!");
    my @f2_data = <F2>;
    close(F2);
    
    my $f1_length = @f1_data;
    my $f2_length = @f2_data;
    my $mmin = min($f1_length, $f2_length);
    
    my $body = XML::Twig::Elt->new("body");
    $body->set_pretty_print('indented');
    
    for (my $i = 0; $i < $mmin; $i++) {
        my $tu_elt = XML::Twig::Elt->new("tu");
        
        make_tuv($f1_data[$i], $lang)->paste('last_child', $tu_elt);
        make_tuv($f2_data[$i], $plang)->paste('last_child', $tu_elt);
        
        $tu_elt->paste('last_child', $body);
    }

    my $FH1;
    open($FH1, " >:encoding(utf8)", $ENV{'GTFREE'} . "/prestable/tmx/" . $lang . $plang . "/" . $base . "-" . $pbase . ".tmx.xml");
    print_tmx_header($FH1, $lang);
    $body->print($FH1);
    print $FH1 qq|</tmx>|, "\n";
}

sub make_tuv {
    my ($sentence, $lang) = @_;
    
    my $tuv_elt = XML::Twig::Elt->new("tuv");
    $tuv_elt->set_att('xml:lang', $lang);
    $sentence =~ s/<s id="[^ ]*">//g;
    $sentence =~ s/<\/s>//g;
    my $seg_elt = XML::Twig::Elt->new("seg", $sentence);
    $seg_elt->paste('last_child', $tuv_elt);
    
    return $tuv_elt;
}

sub print_tmx_header {
    my ($FH1, $lang) = @_;
    
    print $FH1 qq|<?xml version='1.0'  encoding="UTF-8"?>|, "\n";
    print $FH1 qq|<tmx>|, "\n";
    print $FH1 qq|<header|, "\n";
    print $FH1 qq|    segtype="sentence"|, "\n";
    print $FH1 qq|    o-tmf="OmegaT TMX"|, "\n";
    print $FH1 qq|    adminlang="EN-US"|, "\n";
    print $FH1 qq|    srclang="$lang-NO"|, "\n";
    print $FH1 qq|    datatype="plaintext"|, "\n";
    print $FH1 qq|    >|, "\n";
    print $FH1 qq|</header>|, "\n";
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
--outdir=<dir>        The directory where the output files are stored.
END

}

