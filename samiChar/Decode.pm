
package samiChar::Decode;

use Getopt::Long;
use File::Basename;
use strict;
use warnings;
use Carp qw(cluck carp);

use Data::Dumper;

use utf8;

use Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK);

$VERSION = sprintf "%d", q$Revision$ =~ m/(\d+)/g;
@ISA         = qw(Exporter);

@EXPORT = qw(&decode_text_file &decode_file &guess_text_encoding &guess_encoding &read_char_tables &decode_para &decode_title &decode_amp_para %Char_Tables);
@EXPORT_OK   = qw(&find_dec &combine_two_codings %Sami_Chars);

our %Char_Files = (
                  "latin6" => "iso8859-10-1.txt",
#                 "levi" => "levi.txt",
                  "winsam" => "winsam.txt",
#                 "macroman" => "macroman.txt",
                "plainroman" => "ROMAN.txt",
                "CP1258" => "CP1258.txt",
                  "iso_ir_197" => "iso_ir_197.txt",
                  "samimac_roman" => "samimac_roman.txt",
                  "levi_winsam" => "levi_CP1258.txt",
                  "8859-4" => "8859-4.txt",
#                 "8859-2" => "8859-2.txt",
					 );

our %min_amount = (
				   "latin6" =>  10,
				   "winsam" => 1,
				   "plainroman" => 10,
				   "CP1258" => 2,
				   "iso_ir_197" => 10,
				   "samimac_roman" => 10,
				   "levi_winsam" => 10,
				   "8859-4" => 10,
		   );

our %Char_Tables;

# Few characters from Norwegian/Swedish are added to North Sámi
# to ensure the correct encoding for texts with mixed content.
our %Sami_Chars = (
			"sma" => {
			0x00D2 => 1,
			0x00C5 => 1, #"LATIN CAPITAL LETTER A WITH RING ABOVE"
			0x00E5 => 1, #"LATIN SMALL LETTER A WITH RING ABOVE"
			0x00D6 => 1, #"LATIN SMALL LETTER O WITH DIAERESIS"
			0x00F6 => 1, #"LATIN CAPITAL LETTER O WITH DIAERESIS"
            0x00E4 => 1, #"LATIN SMALL LETTER A WITH DIAERESIS"
			0x00D8 => 1, #"LATIN CAPITAL LETTER O WITH STROKE"
            0x00E6 => 1, #"LATIN SMALL LETTER AE"
			0x00C6 => 1 #LATIN CAPITAL LETTER AE
			},
			
			"sme" =>  {
		   0x00D2 => 1,
			0x00C1 => 1, #"LATIN CAPITAL LETTER A WITH ACUTE"
		   0x00E1 => 1, #"LATIN SMALL LETTER A WITH ACUTE"
		   0x010C => 1, #"LATIN CAPITAL LETTER C WITH CARON"
			0x010D => 1, #"LATIN SMALL LETTER C WITH CARON"
		   0x0110 => 1, #"LATIN CAPITAL LETTER D WITH STROKE"
			0x0111 => 1, #"LATIN SMALL LETTER D WITH STROKE"
		   0x014A => 1, #"LATIN CAPITAL LETTER ENG"
			0x014B => 1, #"LATIN SMALL LETTER ENG"
		   0x0160 => 1, #"LATIN CAPITAL LETTER S WITH CARON"
			0x0161 => 1, #"LATIN SMALL LETTER S WITH CARON"
		   0x0166 => 1, #"LATIN CAPITAL LETTER T WITH STROKE"
		   0x0167 => 1, #"LATIN SMALL LETTER T WITH STROKE"
		   0x017D => 1, #"LATIN CAPITAL LETTER Z WITH CARON"
			0x017E => 1,  #"LATIN SMALL LETTER Z WITH CARON"
			0x00E5 => 1, #"LATIN SMALL LETTER A WITH RING ABOVE"
			0x00F8 => 1, #"LATIN SMALL LETTER O WITH STROKE"
			0x00D8 => 1, #"LATIN CAPITAL LETTER O WITH STROKE"
            0x00E4 => 1, #"LATIN SMALL LETTER A WITH DIAERESIS"
            0x00D6 => 1, #"LATIN SMALL LETTER O WITH DIAERESIS"
            0x00F6 => 1, #"LATIN CAPITAL LETTER O WITH DIAERESIS"
            0x00E6 => 1, #"LATIN SMALL LETTER AE"
			0x00C6 => 1, #LATIN CAPITAL LETTER AE
			},

				   "smj" => {
#			0x00C1 => 1, #"LATIN CAPITAL LETTER A WITH ACUTE"
			0x00D2 => 1,
			0x00E1 => 1, #"LATIN SMALL LETTER A WITH ACUTE"
#			0x00C4 => 1, #"LATIN CAPITAL LETTER A WITH DIAERESIS"
		   0x00E4 => 1, #"LATIN SMALL LETTER A WITH DIAERESIS"
#			0x00C5 => 1, #"LATIN CAPITAL LETTER A WITH RING ABOVE"
			0x00E5 => 1, #"LATIN SMALL LETTER A WITH RING ABOVE"
#			0x00D1 => 1, #"LATIN CAPITAL LETTER N WITH TILDE"
#			0x00F1 => 1, #"LATIN SMALL LETTER N WITH TILDE"
		    },
# sma => {},
# sms => {},
# smn => {},
				   "nob" => {
			0x00D2 => 1,
			0x0111 => 1, #"LATIN SMALL LETTER D WITH STROKE"
			0x0161 => 1, #"LATIN SMALL LETTER S WITH CARON"
			0x017E => 1,  #"LATIN SMALL LETTER Z WITH CARON"
			0x00F8 => 1, #"LATIN SMALL LETTER O WITH STROKE"
			0x00D8 => 1, #"LATIN CAPITAL LETTER O WITH STROKE"
            0x00E6 => 1, #"LATIN SMALL LETTER AE"
			0x00C6 => 1, #LATIN CAPITAL LETTER AE
			0x00E5 => 1, #"LATIN SMALL LETTER A WITH RING ABOVE"
            0x00E4 => 1, #"LATIN SMALL LETTER A WITH DIAERESIS"
            0x00D6 => 1, #"LATIN SMALL LETTER O WITH DIAERESIS"
            0x00F6 => 1, #"LATIN CAPITAL LETTER O WITH DIAERESIS"
			},

				   "nno" => {
		   0x00D2 => 1,
			0x00E5 => 1, #"LATIN SMALL LETTER A WITH RING ABOVE"
			0x00F8 => 1, #"LATIN SMALL LETTER O WITH STROKE"
			0x00D8 => 1, #"LATIN CAPITAL LETTER O WITH STROKE"
            0x00E4 => 1, #"LATIN SMALL LETTER A WITH DIAERESIS"
            0x00D6 => 1, #"LATIN SMALL LETTER O WITH DIAERESIS"
            0x00F6 => 1, #"LATIN CAPITAL LETTER O WITH DIAERESIS"
            0x00E6 => 1, #"LATIN SMALL LETTER AE"
			0x00C6 => 1, #LATIN CAPITAL LETTER AE
			0x00E5 => 1, #"LATIN SMALL LETTER A WITH RING ABOVE"
            0x00D6 => 1, #"LATIN SMALL LETTER O WITH DIAERESIS"
            0x00F6 => 1, #"LATIN CAPITAL LETTER O WITH DIAERESIS"
			},

				   "dan" => {
#			0x00C5 => 1, #"LATIN CAPITAL LETTER A WITH RING ABOVE"
			0x00D2 => 1,
			0x00E5 => 1, #"LATIN SMALL LETTER A WITH RING ABOVE"
#           0x00D6 => 1, #"LATIN SMALL LETTER O WITH DIAERESIS"
            0x00F6 => 1, #"LATIN CAPITAL LETTER O WITH DIAERESIS"
            0x00C6 => 1, #LATIN CAPITAL LETTER AE
            0x00E6 => 1 #"LATIN SMALL LETTER AE"
		    },
		    
			"swe" => {
			0x00D2 => 1,
			0x00C5 => 1, #"LATIN CAPITAL LETTER A WITH RING ABOVE"
			0x00E5 => 1, #"LATIN SMALL LETTER A WITH RING ABOVE"
			0x00D6 => 1, #"LATIN SMALL LETTER O WITH DIAERESIS"
			0x00F6 => 1, #"LATIN CAPITAL LETTER O WITH DIAERESIS"
            0x00E4 => 1, #"LATIN SMALL LETTER A WITH DIAERESIS"
		    },

			);

our %Error_Types = (
	# mac-sami converted as iconv -f mac -t utf8
	"type01" => {
		"á" => "á",
		"ª" => "š",
		"¥" => "Š",
		"º" => "ŧ",
		"µ" => "Ŧ",
		"∫" => "ŋ",
		"±" => "Ŋ",
		"π" => "đ",
		"∞" => "Đ",
		"Ω" => "ž",
		"∑" => "Ž",
		"∏" => "č",
		"¢" => "Č",
		"æ" => "æ",
		"Æ" => "Æ",
		"ø" => "ø",
		"Ø" => "Ø",
		"å" => "å",
		"Å" => "Å",
		"ä" => "ä",
		"Ä" => "Ä",
		"ö" => "ö",
		"Ö" => "Ö",
	},
	
	# iso-ir-197 converted as iconv -f mac -t utf8
	"type02" => {
		"·" => "á",
		"¡" => "Á",
		"≥" => "š",
		"≤" => "Š",
		"∏" => "ŧ",
		"µ" => "Ŧ",
		"±" => "ŋ",
		"Ø" => "Ŋ",
		"§" => "đ",
		"£" => "Đ",
		"∫" => "ž",
		"π" => "Ž",
		"¢" => "č",
		"°" => "Č",
		"Ê" => "æ",
		"Δ" => "Æ",
		"¯" => "ø",
		"ÿ" => "Ø",
		"Â" => "å",
		"≈" => "Å",
		"‰" => "ä",
		"ƒ" => "Ä",
		"ˆ" => "ö",
		"÷" => "Ö",
	},

	# winsami2 converted as iconv -f mac -t utf8
	"type03" => {
		"·" => "á",
		"¡" => "Á",
		"ö" => "š",
		"ä" => "Š",
		"º" => "ŧ",
		"∫" => "Ŧ",
		"π" => "ŋ",
		"∏" => "Ŋ",
		"ò" => "đ",
		"â" => "Đ",
		"ø" => "ž",
		"æ" => "Ž",
		"Ñ" => "č",
		"Ç" => "Č",
		"Ê" => "æ",
		"Δ" => "Æ",
		"¯" => "ø",
		"ÿ" => "Ø",
		"Â" => "å",
		"≈" => "Å",
		"‰" => "ä",
		"ƒ" => "Ä",
		"ˆ" => "ö",
		"÷" => "Ö",
	},

	# winsami2 converted as iconv -f latin1 -t utf8
	"type04" => {
		"á" => "á",
		"Á" => "Á", 
		"" => "š",
		"" => "Š",
		"¼" => "ŧ",
		"º" => "Ŧ",
		"¹" => "ŋ",
		"¸" => "Ŋ",
		"" => "đ",
		"" => "Đ",
		"¿" => "ž",
		"¾" => "Ž",
		"" => "č",
		"" => "Č",
		"æ" => "æ",
		"Æ" => "Æ",
		"ø" => "ø",
		"Ø" => "Ø",
		"å" => "å",
		"Å" => "Å",
		"ä" => "ä",
		"Ä" => "Ä",
		"ö" => "ö",
		"Ö" => "Ö",
	},
	
	# iso-ir-197 converted as iconv -f latin1 -t utf8
	"type05" => {
		"á" => "á",
		"³" => "š",
		"²" => "Š",
		"¸" => "ŧ",
		"µ" => "Ŧ",
		"±" => "ŋ",
		"¯" => "Ŋ",
		"¤" => "đ",
		"£" => "Đ",
		"º" => "ž",
		"¹" => "Ž",
		"¢" => "č",
		"¡" => "Č",
		"æ" => "æ",
		"Æ" => "Æ",
		"ø" => "ø",
		"Ø" => "Ø",
		"å" => "å",
		"Å" => "Å",
		"ä" => "ä",
		"Ä" => "Ä",
		"ö" => "ö",
		"Ö" => "Ö",
	},
	
	# mac-sami to latin1
	"type06" => {
		"" => "á",
		"ç" => "Á", 
		"»" => "š",
		"´" => "Š",
		"¼" => "ŧ",
		"µ" => "Ŧ",
		"º" => "ŋ",
		"±" => "Ŋ",
		"¹" => "đ",
		"°" => "Đ",
		"½" => "ž",
		"·" => "Ž",
		"¸" => "č",
		"¢" => "Č",
		"¾" => "æ",
		"®" => "Æ",
		"¿" => "ø",
		"¯" => "Ø",
		"" => "å",
		"" => "Å",
		"" => "ä",
		"" => "Ä",
		"" => "ö",
		"" => "Ö",
		"Ê" => " ",
		"¤" => "§",
	},
	
	# found in titles in Min Áigi docs
	"type07" => {
		"á" => "á",
		"š" => "š",
		"đ" => "đ",
		"Ã°" => "đ",
		"Â¹" => "š",
		"Ã¨" => "č",
		"â€\?" => "”",
		"Ã©" => "é",
		"Ä\\?" => "č",
		"Å§" => "ŧ",
# 		"Ä\\?" => "Đ",
		"Ãŧ" => "ø",
		"Å " => "Š",
		"Ã¤" => "ä",
		"Ã«" => "Ä",
# 		"Ã\?" => "Á",
		"ÄŒ" => "Č",
		"Å‹" => "ŋ",
		"Ã¸" => "ø",
		"Å¾" => "ž",
		"Ã\\?" => "Á",
	},
	
	"type08" => {
		"Œ" => "å",
		"¿" => "ø",
		"¥" => "•",
	},

	"type09" => {
		"á" => "á",
		"ð" => "đ",
	},
	
);

our $UNCONVERTED = 0;
our $CORRECT = 1;
our $NO_ENCODING = 0;
our $ERROR = -1;

# The minimal percentage of selected (unconverted) sámi characters in a file that
# decides whether the file needs to be decoded at all.
our $MIN_AMOUNT = 0.0;

# Printing some test data, chars and their amounts
our $Test=1;


# Subroutine for decoding text file. Just iconv call.
sub decode_text_file() {

    my ($file, $encoding, $outfile) =  @_;
	
    unless ($outfile) {
		$outfile = $file . ".out";
	}	
    if ($encoding eq $NO_ENCODING) { return 0; }
	
    if (! $encoding ) {
		return "convert_file: Encoding is not specified.\n";
	}	
	if($Test) {
		print "Converting $file -> $outfile\n";
	}

	print "encoding is: $encoding\n";
	my $command="iconv -f LATIN1 -t UTF-8 -o \"$outfile\" \"$file\" 2>/dev/null";
	system($command) == 0 or return "Encoding failed: $!";

	return 0;
}

# Guess text encoding from a file $file if it's given.
# Else use the reference to a pargraph $para_ref.
sub guess_encoding () {
    my ($file, $lang, $para_ref) = @_;

	my @text_array;
	my $error=0;
    # Read the corpus file
	if ($file) { $error = &read_file($file, \@text_array); } 
	if ($error ) { carp "non-utf8 bytes.\n"; return $ERROR; }
	elsif (! @text_array) { @text_array = split("\n", $$para_ref); }
    
	my $encoding = $NO_ENCODING;
	my $last_count = 0;
	for my $type (sort( keys %Error_Types )) {
		my $count = 0;

		for my $line (@text_array) {
			foreach( keys % {$Error_Types{$type}}) {
				while ($line =~ /$_/g) {
					$count++;
				}
			}
		}
		if ($count > 0 && $count >= $last_count) {
			$encoding = $type;
			$last_count = $count;
		}
		if ($Test) {
			print "encoding is $encoding, count is $count\n";
		}
	}
	return $encoding;
}

sub decode_para (){
	my ($lang, $para_ref, $encoding) = @_;
	
	if (! $encoding) { $encoding = &guess_encoding(undef, $lang, $para_ref); }
	if (!$encoding eq $NO_ENCODING) { return; }

	if ($Test) {
		print "\n\npara_ref before $$para_ref\n\n";
	}
	foreach ( keys % {$Error_Types{$encoding}}) {
		$$para_ref =~ s/$_/${$Error_Types{$encoding}}{$_}/g;
	}
	if ($Test) {
		print "\n\npara_ref after $encoding\n $$para_ref\n\n";
	}

	return 0;
}


sub decode_amp_para {
	my ($para) = shift @_;
	
	my $newpara = $para;

	if ($para =~ /(.*?)\&\#(\d{2,4})\;(.*)/){	
		$newpara = $1;

		my $rest = $3;
		my $char =  pack("U*", $2);

		if ($rest) { $newpara .= decode_amp_para($rest);}
	} 
	return $newpara;
}

# Preliminary code table, hope to get better later.
sub decode_title (){
	my ($lang, $para_ref, $encoding) = @_;

	my %byte_table = (
		195 => {
			63 => "193", # Á
			161 => "225", # á
			166 => "230", # æ
			260 => "225", # á
			},
		196 => {
			63 => "269", # č
			338 => "268", # Č
			8216 => "273" # đ
			},
		197 => {
			161 => "353", # š
			260 => "353", # š
			190 => "382", # ž
			382 => "382", # ž
			189 => "381", # big ž
			330 => "381", # big ž
			167 => "359", # t stroke
			166 => "358", # big t stroke
			8249 => "331", # eng
			352 => "330" # big eng
			}
	);

	my $packed;
	my @unpacked = unpack("U*", $$para_ref);
	my $byte = shift(@unpacked);
    while ($byte) {
		my $next_byte;
		if ($byte == 8225 ) { 
			$byte = 225;
		}
		elsif ( 195 <= $byte && $byte <= 197 ) {
			$next_byte = shift(@unpacked);
			if (130 <= $next_byte && $next_byte <= 159 ) {
				$byte = shift(@unpacked);
				next;
			}
			if(my $new = $byte_table{$byte}{$next_byte}) {
				$byte=$new;
			}
		}
		my $char = pack("U*", $byte);
		$packed .= $char;
		$byte = shift(@unpacked);
    }
	$$para_ref=$packed;
	return 0;
}

sub decode_file (){
    my ($file, $encoding, $outfile, $lang, $decode_title) =  @_;

    unless ($outfile) {
		$outfile = $file . ".out";
	}
	
    if ($encoding eq $NO_ENCODING) { return 0; }
	
    if (! $encoding || !$Error_Types{$encoding}) {
		return "convert_file: Encoding is not specified or encoding $encoding is not supported: $!\n";
    }
	
	if($Test) {
		print "Converting $file -> $outfile\n";
	}
    my $charfile = $Char_Files{$encoding};
    
    my %convert_table = &read_char_table($charfile);
    my @text_array;
	my $error = &read_file($file, \@text_array);
	if ($error) { cluck "Non-utf8 bytes.\n"; return $ERROR; }

	my $in_title;
	for my $line (@text_array) {
		foreach ( keys % {$Error_Types{$encoding}}) {
			print "char is $_ replacment is ${$Error_Types{$encoding}}{$_}\n";
		}
	}
	
    if (! open (FH, ">$outfile")) { 
		carp "Cannot open file $outfile";
		return $ERROR;
	}
    print(FH @text_array); 
    close (FH);
	return 0;
}

sub read_file {
    my ($file, $text_aref, $allow_nonutf) =  @_;

	if (! open (FH, "<utf8", "$file")) { 
		carp "Cannot open file $file";
		return $ERROR;
	} else {
		while (<FH>) {
			if (! utf8::is_utf8($_)) { return "ERROR"; }
			push (@$text_aref, $_);
		}
		close (FH);
		return 0;
	}
}

sub read_char_tables {

	for my $encoding (keys %Char_Files) {
		my $file = $Char_Files{$encoding};
		$Char_Tables{$encoding} = { read_char_table($file) };
	}
	return 0;
}


sub read_char_table{
    my $charfile = shift @_;
    
    my $data_dir = dirname __FILE__;
    
    open (CHARFILE, $data_dir."/data/".$charfile) or 
		die "Cannot open file $data_dir/data/$charfile : $!";
    my %convert_table;
    
    while (my $line = <CHARFILE>) {

		next if ($line =~ /^\#/);
		my  @convertLine = split (/\s+/, $line);
		if ($convertLine[0] && $convertLine[1]) {
			my $byte1 = hex($convertLine[0]);
			my $byte2 = hex($convertLine[1]);
			unless ($byte1 == $byte2) {
				$convert_table{$byte1} = $byte2;
			}
		}
    }
    close (CHARFILE);
    return %convert_table;
}

sub find_dec {
		
    my ($dec, $file) =  @_;
    my $count = 0;

    # Read the corpus file
    my @text_array;
	my $error= &read_file($file, \@text_array);

    for my $line (@text_array) {
		my @unpacked = unpack("U*", $line);
		for my $byte (@unpacked) {
			if ($dec == $byte) {
				$count++;
			}		
		}
    }
    return $count;
}


# Combine two codetables
sub combine_two_codings {
    my ($coding1, $coding2, $outfile) = @_;

    my $charfile1 = $Char_Files{$coding1};
    my $charfile2 = $Char_Files{$coding2};

    open (OUTFILE, ">$outfile");
    print (OUTFILE "# $coding1 $coding2 \n");

    my $data_dir = dirname __FILE__;

    open (CHARFILE, $data_dir."/data/".$charfile1) or 
		die "Cannot open file $charfile1: $!";
    my %first_coding;
    while (my $line = <CHARFILE>) {
	next if ($line =~ /^\#/);
	
	chomp $line;
	my ($hex, $utf, $desc) = split (/\s+/, $line, 3);
	$first_coding{$hex} = $utf;
    }
    
    close (CHARFILE);    
    
    open (CHARFILE, $data_dir."/data/".$charfile2) or 
		die "Cannot open file $charfile2: $!";
    my %second_coding;
    while (my $line = <CHARFILE>) {
		next if ($line =~ /^\#/);
		chomp $line;
		my ($hex, $utf, $desc) = split (/\s+/, $line, 3);
		$second_coding{$hex} = $utf;
    }
    
    my %combined;
    
    for my $key (keys %first_coding) {
		if ($second_coding{$key}) {
			if ($second_coding{$key} ne $first_coding{$key}) {
				$combined{$second_coding{$key}} = $first_coding{$key};
			}
#	elsif (($second_coding{$key} != $key) && (! $combined{$key})) {
#	    $combined{$key} = $first_coding{$key};
#	}
		}
	}
    for my $key (keys %combined) {
		print (OUTFILE $key, " ", $combined{$key}, "\n");
	}
    
    close (CHARFILE); 
    close (OUTFILE);
}


1;

__END__

=head1 NAME

samiChar::Decode.pm -- convert characters byte-wise to other characters.

=head1 SYNOPSIS

    use samiChar::Decode;

    my $file = "file.txt";
    my $outfile = "file.txt";
    my $encoding;
    my $lang = "sme";

    $encoding = &guess_encoding($file, $lang, $para_ref);
    &decode_file($file, $encoding, $outfile);

    $encoding = &guess_text_encoding($file, $outfile, $lang);
    &decode_text_file($file, $encoding, $outfile);


=head1 DESCRIPTION

samiChar::Decode.pm decodes characters to utf-8 byte-wise, using
code tables. It is planned for decoding the Sámi characters
in a situation, where the document is converted to utf-8 without
knowing the original encoding. The decoding is implemented by
using code table files, so the module can be used to other
conversions as well. The output is however always utf-8.

The module contains also a function for guessing the original
encoding. It takes into account only the most common Sámi
characters and their frequency in the text.

=head2 Code tables

Code tables are text files with the following format:

Three space-separated columns:

=over 4

=item    Column #1 is the input char (in hex as 0xXX or 0xXXXX))

=item    Column #2 is the Unicode char (in hex as 0xXXXX)

=item    Column #3 the Unicode name 

=back

Most of the code tables are available at the Unicode Consortium:
L<ftp://ftp.unicode.org/Public/MAPPINGS/>

Some of the code tables like samimac_roman and levi_winsam are composed from two code tables, the one that is used as input encoding and another that is used as the file was converted to utf-8.

=over 4

=item  samimac_roman: codetables samimac.txt and ROMAN.txt

=item  levi_winsam: codetables levi.txt and CP1258.txt

=back

levi.txt and samimac.txt are available under Trond's home page at: L<http://www.hum.uit.no/a/trond/smi-kodetabell.html>. The codetables are composed using the function C<&combine_two_codings($coding1, $coding2, $outfile)> which is
available in this package.

These encodings are available:

=over 4

=item    latin6 => iso8859-10-1.txt

=item    plainroman => ROMAN.txt

=item    CP1258 => CP1258.txt

=item    iso_ir_197 => iso_ir_197.txt

=item    samimac_roman => samimac_roman.txt

=item    levi_winsam => levi_CP1258.txt

=item    winsam => winsam.txt

=item    8859-4 => 8859-4.txt

=back

=head2 Guessing the input encoding

The original input encoding is guessed by examining the text and
searching the most common characters. The unicode 
characters in hex are listed in hash C<%Sami_Chars> for Northern Sámi
for example. The uncommented characters are the ones that take
part into guessing the encoding.

The encodings are listed in the hash C<%Charfiles>, they are tested one
at the time. The occurences of the selected characters
in that encoding are counted and the one with most occurences
is returned. There is a place for more statistical analysis, but
this simple test worked for me.

If there is no certain amount of characters found, the test
returns -1, which means that the characters should be already
correctly utf-8 encoded. 

=head1 BUGS 

There may be mappings that are missing from the list of code tables.

=head1 AUTHOR

Saara Huhmarniemi <saara.huhmarniemi@helsinki.fi>
