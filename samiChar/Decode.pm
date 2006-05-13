
package samiChar::Decode;

use open ':utf8';
use Getopt::Long;
use File::Basename;
use strict;
use warnings;

use Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK);

$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA         = qw(Exporter);

@EXPORT = qw(&decode_text_file &decode_file &guess_text_encoding &guess_encoding &read_char_tables &decode_para &decode_title %Char_Tables);
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
#                 "utf8_utf8" => "utf8_utf8.txt",
                 "8859-4" => "8859-4.txt",
#                 "8859-2" => "8859-2.txt",
		   );


our %Char_Tables;

our %Sami_Chars = (
			"sme" =>  {
#		   0x00C1 => 1, #"LATIN CAPITAL LETTER A WITH ACUTE"
#		   0x00E1 => 1, #"LATIN SMALL LETTER A WITH ACUTE"
#		   0x010C => 1, #"LATIN CAPITAL LETTER C WITH CARON"
			0x010D => 1, #"LATIN SMALL LETTER C WITH CARON"
#		   0x0110 => 1, #"LATIN CAPITAL LETTER D WITH STROKE"
			0x0111 => 1, #"LATIN SMALL LETTER D WITH STROKE"
#		   0x014A => 1, #"LATIN CAPITAL LETTER ENG"
			0x014B => 1, #"LATIN SMALL LETTER ENG"
#		   0x0160 => 1, #"LATIN CAPITAL LETTER S WITH CARON"
			0x0161 => 1, #"LATIN SMALL LETTER S WITH CARON"
#		   0x0166 => 1, #"LATIN CAPITAL LETTER T WITH STROKE"
#		   0x0167 => 1, #"LATIN SMALL LETTER T WITH STROKE"
#		   0x017D => 1, #"LATIN CAPITAL LETTER Z WITH CARON"
			0x017E => 1  #"LATIN SMALL LETTER Z WITH CARON"
			    },

		    "smj" => {
#			0x00C1 => 1, #"LATIN CAPITAL LETTER A WITH ACUTE"
#			0x00E1 => 1, #"LATIN SMALL LETTER A WITH ACUTE"
#			0x00C4 => 1, #"LATIN CAPITAL LETTER A WITH DIARESIS"
			0x00E4 => 1, #"LATIN SMALL LETTER A WITH DIARESIS"
#			0x00C5 => 1, #"LATIN CAPITAL LETTER A WITH RING ABOVE"
			0x00E5 => 1, #"LATIN SMALL LETTER A WITH RING ABOVE"
#			0x00D1 => 1, #"LATIN CAPITAL LETTER N WITH TILDE"
#			0x00F1 => 1, #"LATIN SMALL LETTER N WITH TILDE"
		    },
# sma => {},
# sms => {},
# smn => {},
			);


our $UNCONVERTED = 0;
our $CORRECT = 1;
our $NO_ENCODING = 0;

# The minimal percentage of selected (unconverted) sámi characters in a file that
# decides whether the file needs to be decoded at all.
our $MIN_AMOUNT = 0.02;

# Printing some test data, chars and their amounts
our $Test=0;

# Subroutine for determining the correct encoding for text
# Text is assumed not to be converted to utf-8 earlier.
sub guess_text_encoding() {

	my ($file, $outfile, $lang) = @_;

	my @encodings = ("MAC-SAMI", "LATIN1");
	my %results;
	my %count_table;

    if (!$lang || ! $Sami_Chars{$lang}) {
		if ($Test) {
			print "guess_encoding: language is not specified or language $lang is not supported\n";
		}
		return $NO_ENCODING;
    }

	for my $enc (@encodings) {
		my $command="iconv -f $enc -t UTF-8 -o $outfile $file";
		system($command) == 0 or return "Guess encoding failed: $!";
		my %test_table;

		for my $char (keys % { $Sami_Chars{$lang}}){
			$count_table{$char} = 1;
		}
		my @text_array;
		# Read the output
		if (-f $outfile) {
			@text_array = &read_file($outfile);
		}
		my $count = 0;
		my $total_count = 0;
		for my $line (@text_array) {
			$total_count += length($line);
			my @unpacked = unpack("U*", $line);
			for my $byte (@unpacked) {
				if( $count_table{$byte} ) { $count++; }				
			}
		}
		if ($total_count != 0 ) {
			$results{$enc} = 100 * ($count / $total_count);
		}
	}			
    # Select the best encoding by comparing the amount of chars to be converted.
    my $encoding = $NO_ENCODING;
    my $last_val;
    for my $key (sort { $results{$a} cmp $results{$b} } keys %results) {
		if($Test) {
			my $rounded_unconv = sprintf("%.3f", $results{$key});
			my $rounded_correct = sprintf("%.3f", $results{$key});
			print $file, " ", $key, " ", $rounded_unconv, " ", $rounded_correct, "\n";
		}
		$last_val = $key;
	}
    if ($results{$last_val} && $results{$last_val} > $MIN_AMOUNT ) {
		$encoding = $last_val;
    }
	if($Test) {
		if ($encoding eq $NO_ENCODING ) { print "Correct encoding.\n"; }
		else { print "$encoding \n"; }
	}
    return $encoding;

}

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
	my $command="iconv -f $encoding -t UTF-8 -o $outfile $file";
	system($command) == 0 or return "Encoding failed: $!";

	return 0;
}

sub guess_encoding () {
    my ($file, $lang, $para_ref) = @_;

    if (!$lang || ! $Sami_Chars{$lang}) {
		if ($Test) {
			print "guess_encoding: language is not specified or language $lang is not supported\n";
		}
		return $NO_ENCODING;
    }

	my @text_array;
    # Read the corpus file
	if ($file) {
		@text_array = &read_file($file);
	} 
	else { @text_array = split("\n", $$para_ref); }
    
    # Store the statistics here
    my %statistics = ();

    for my $encoding (keys %Char_Files) {

		# Read the encoding table
		my %convert_table = %{ $Char_Tables{$encoding} };

		# test_table contains the tested sámi chars in both utf and tested encoding.
		# count_table is for counting the occurences of sámi chars,
		# both those in tested encoding and already correct ones.
		my %test_table; 
		my %count_table;
	  CHAR_TABLE:
		for my $char (keys % { $Sami_Chars{$lang}}){
			$count_table{$char}->[$UNCONVERTED] = 0;
			$count_table{$char}->[$CORRECT] = 0;
		  CONVERT_TABLE:
			# pick the tested sámi chars from conversion table
			for my $key (keys %convert_table) {
				if ($convert_table{$key} == $char) {
					$test_table{$key} = $char;
					last CONVERT_TABLE;
				}
			} #CONVERT_TABLE
		} #CHAR_TABLE
		
		# Count the occurences of the sami characters
		# in the corpus file line by line
		my $total_char_count=0;
	  LINE:
		for my $line (@text_array) {
			my @unpacked = unpack("U*", $line);
		  BYTE:
			for my $byte (@unpacked) {
				$total_char_count++;
				if ($test_table{$byte}) {
					# Sámi char in tested encoding is found
					$count_table{$test_table{$byte}}->[$UNCONVERTED]++;
				}
				elsif ($count_table{$byte}) {
					# Already correctly coded sámi char
					$count_table{$byte}->[$CORRECT]++;
				}
			} # BYTE
		} # LINE

		# Count the total
		# Add the statistical tests here if needed.
		my $unconv_total = 0;
		my $other_total = 0;
		for my $key (keys %count_table) {
			$unconv_total += $count_table{$key}->[$UNCONVERTED];
			$other_total += $count_table{$key}->[$CORRECT];
		}
		if ($total_char_count > 0) {
			$statistics{$encoding}->[$UNCONVERTED] = 100 * ($unconv_total /  $total_char_count) ;
			$statistics{$encoding}->[$CORRECT] = 100 * ($other_total /  $total_char_count) ;
		}
		# Test print
		if($Test) {
			for my $key (keys %count_table) {
				my $found = 0;
				for my $key2 (keys %test_table) {
					if ($key == $test_table{$key2}) {
						print $encoding, " ", $key, " ", pack("U*", $key), " ", pack("U*", $key2), " ", $count_table{$key}->[$UNCONVERTED], " ", $count_table{$key}->[$CORRECT], "\n";
						$found = 1;
						last;
					}
				}
				if ($found == 0) {
					print $encoding, " ", $key, " ", pack("U*", $key), " ", $count_table{$key}->[$UNCONVERTED], " ", $count_table{$key}->[$CORRECT], "\n";
				}
			}
		} # Test print
		
	}
    # Select the best encoding by comparing the amount of chars to be converted.
    my $encoding = $NO_ENCODING;
    my $last_val;
    for  my $key (sort { $statistics{$a}->[$UNCONVERTED] cmp $statistics{$b}->[$UNCONVERTED] } keys %statistics) {
		if($Test) {
			my $rounded_unconv = sprintf("%.3f", $statistics{$key}->[$UNCONVERTED]);
			my $rounded_correct = sprintf("%.3f", $statistics{$key}->[$CORRECT]);
			print $file, " ", $key, " ", $rounded_unconv, " ", $rounded_correct, "\n";
		}
		$last_val = $key;
	}
    if ($statistics{$last_val}->[$UNCONVERTED] && $statistics{$last_val}->[$UNCONVERTED] > $MIN_AMOUNT ) {
		$encoding = $last_val;
    }
	if($Test) {
		if ($encoding eq $NO_ENCODING ) { print "Correct encoding.\n"; }
		else { print "$encoding \n"; }
	}
    return $encoding;
}

sub decode_para (){
	my ($lang, $para_ref) = @_;

	my $encoding = &guess_encoding("", $lang, $para_ref);
	if ($encoding eq $NO_ENCODING) { return; }
	print "$encoding\n";
	my %convert_table = %{ $Char_Tables{$encoding} };
	my @unpacked = unpack("U*", $$para_ref);
	for my $byte (@unpacked) {
		if ($convert_table{$byte}) {
			$byte = $convert_table{$byte};
		}
	}
	$$para_ref = pack("U*", @unpacked);
	return 0;
}

sub decode_title (){
	my ($lang, $para_ref) = @_;

	my $encoding = "utf8_utf8";
	my %convert_table = %{ $Char_Tables{$encoding} };
	my @unpacked = unpack("U*", $$para_ref);
	for my $byte (@unpacked) {
		if ($convert_table{$byte}) {
			$byte = $convert_table{$byte};
		}
	}
	$$para_ref = pack("U*", @unpacked);
	return 0;
}

sub decode_file (){
    my ($file, $encoding, $outfile) =  @_;

    unless ($outfile) {
		$outfile = $file . ".out";
	}
	
    if ($encoding eq $NO_ENCODING) { return 0; }
	
    if (! $encoding || !$Char_Files{$encoding}) {
		return "convert_file: Encoding is not specified or encoding $encoding is not supported: $!\n";
    }
	
	if($Test) {
		print "Converting $file -> $outfile\n";
	}
    my $charfile = $Char_Files{$encoding};
    
    my %convert_table = &read_char_table($charfile);
    my @text_array = &read_file($file);

    for my $line (@text_array) {
		my @unpacked = unpack("U*", $line);
		for my $byte (@unpacked) {
			if ($convert_table{$byte}) {
				$byte = $convert_table{$byte};
			}
		}
		$line = pack("U*", @unpacked);
	}
	
    open (FH, ">$outfile") or return "Cannot open file $outfile: $!";
    print(FH @text_array); 
    close (FH);
	return 0;
}

sub read_file {
    my $file = shift @_;
    my @text_array;

    open (FH, $file) or return "Cannot open file $file: $!";
    while (<FH>) {
	push (@text_array, $_);
    }
    close (FH);
    return @text_array;
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
    my @text_array = &read_file($file);

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
