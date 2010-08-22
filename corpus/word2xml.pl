#!/usr/bin/perl

use strict;
use encoding 'utf-8';
use open ':utf8';
use File::Find;
use File::Spec;
use IO::File;
use Getopt::Long;


my $xsl_file;
GetOptions ("xsl=s" => \$xsl_file);

my @files;

#print "$ARGV[$#ARGV]\n";
#exit (0);

find ( &process_file, $ARGV[$#ARGV]) if -d $ARGV[$#ARGV];
process_file ($ARGV[$#ARGV]) if -f $ARGV[$#ARGV];

sub process_file {
    my $file = $_;
    $file = shift (@_) if (!$file);
#    print "$file\n";

    if (-d $file) {
	my $orig = File::Spec->rel2abs($file);
	my $int = $orig;
#	$int =~ s/orig/int/i;
#	mkdir ("$int", 0755) unless -d $int;
	return;
    }
    return unless ($file =~ /\.doc/);
    return if (__FILE__ =~ $file);
    return if ($file =~ /[\~]$/);
    
    my $orig = File::Spec->rel2abs($file);
    my $int = $orig;
#    $int =~ s/orig/int/i; 
    $int =~ s/.doc$/.doc.xml/i;

#    print "$int\n";

    IO::File->new($int, O_RDWR|O_CREAT) 
	or die "Couldn't open $int for writing: $!\n";
    
    system "antiword -s -x db \"$orig\" | /usr/bin/xsltproc \"$xsl_file\" - > \"$int\"";

    push (@files, $int);
}

for my $file (@files) {
    open (FILE, $file) or die "Cannot open file $file: $!";

    my $string;
    my @outString;
    while ($string = <FILE>) {
		push (@outString, $string);
    }

    close FILE;
    open (FILE, $file) or die "Cannot open file $file: $!";

# This block is for Latin 6, Statens Kartverk
     if (grep( m/[èÈ¼©]/, @outString)){
	undef (@outString);
#	print $file . "Latin 6\n";
	while ($string = <FILE>) {
	    $string =~ s/È/Č/g;
	    $string =~ s/¼/ž/g;
	    $string =~ s/¿/ŋ/g;
	    $string =~ s/º/š/g;
	    $string =~ s/¹/đ/g;
	    $string =~ s/©/Đ/g;
	    $string =~ s/è/č/g;
	    push (@outString, $string);
	}
    }


# This block is for ISO-IR 197
     elsif (grep( m/[¡£¤¯²³]/, @outString)){
	undef (@outString);
#	print $file . "ISO-IR 197\n";
	while ($string = <FILE>) {
	    $string =~ s/¡/Č/g;
	    $string =~ s/¢/č/g;
	    $string =~ s/£/Đ/g;
	    $string =~ s/¤/đ/g;
	    $string =~ s/¯/Ŋ/g;
	    $string =~ s/±/ŋ/g;
	    $string =~ s/²/Š/g;
	    $string =~ s/³/š/g;
	    $string =~ s/µ/Ŧ/g;
	    $string =~ s/¸/ŧ/g;
	    $string =~ s/¹/Ž/g; 
	    $string =~ s/º/ž/g;
	    push (@outString, $string);
	}
    }


# This block is for Mac Roman input
     elsif (grep( m/[ª∞π∫Ω¥]/, @outString)){
	undef (@outString);
#	print $file . "Mac Roman\n";
	while ($string = <FILE>) {
#	    $string =~ s/ª/š/g; #NOT WORKING
	    $string =~ s/\302\252/š/g; #Octal UTF-8 for ª.
	    $string =~ s/∏/č/g;
	    $string =~ s/π/đ/g;
	    $string =~ s/∫/ŋ/g;
	    $string =~ s/\302\272/ŧ/g; #Octal UTF-8 for masc ord
	    $string =~ s/Ω/ž/g;
#	    $string =~ s/À/Á/g;
	    $string =~ s/\302\242/Č/g; #cent NOT WORKING
	    $string =~ s/∞/Đ/g;
	    $string =~ s/\302\261/Ŋ/g; #plusminus NOT WORKING
	    $string =~ s/\302\245/Š/g; #yen NOT WORKING
	    $string =~ s/\302\265/Ŧ/g; #Octal UTF-8 for myy
	    $string =~ s/∑/Ž/g;
	    push (@outString, $string);
	}
    }

    else {
	undef (@outString);
	print $file . "\n";	
	while ($string = <FILE>) {
#	    print $string . "\n";
# This block is for Levi input
#	    $string =~ s/∏/č/g; #MacRoman
	    $string =~ s/„/č/g; #Levi
	    $string =~ s/\˜/đ/g;#??? 
	    $string =~ s/¿/ž/g; #???
	    $string =~ s/‚/Č/g; #Le
	    $string =~ s/¹/ŋ/g; #Le
	    $string =~ s/‰/Đ/g; #Le

# This block is for Winsam
	    $string =~ s/ç/č/g; #WS
	    $string =~ s/Ç/Č/g; #WS
	    $string =~ s/ð/đ/g; #WS
	    $string =~ s/Ó/Š/g; #WS
	    $string =~ s/ó/š/g; #WS
	    $string =~ s/þ/ž/g; #WS
	    $string =~ s/ñ/ŋ/g; #WS
	    $string =~ s/Ñ/Ŋ/g; #WS
	    $string =~ s/ý/ŧ/g; #WS

#	    print $string . "\n";
	    push (@outString, $string);
        }
    }

    open (OUTFILE, ">$file");
    print (OUTFILE @outString);
    close (OUTFILE);

    undef (@outString);
}


