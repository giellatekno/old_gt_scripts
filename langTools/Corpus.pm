
package langTools::Corpus;

use utf8;
use open 'utf8';

use warnings;
use strict;

use XML::Twig;
use Carp qw(cluck carp);

use Exporter;
our (@ISA, @EXPORT, @EXPORT_OK);

@ISA         = qw(Exporter);

@EXPORT = qw(&add_error_markup &pdfclean &txtclean);

#@EXPORT_OK   = qw(&process_paras);

#our ($fst);

our %types = ("\$" => "errorort",
			   "€" => "errorlex",
			   "£" => "errormorphsyn",
			   "¥" => "errorsyn",
			   "§" => "error");

our $sep = quotemeta("€§£\$¥");
our $str = "[^$sep\\s\\(\\)]+?";
our $str_par = "\\([^$sep\\(\\)]+?\\)";
our $plainerr = "($str|$str_par)[$sep]($str|$str_par)";
our $dummy1 = "($str|$str_par)( [$sep]|[$sep] | [$sep] )($str|$str_par)";
our $dummy2 = "( [$sep]|[$sep] | [$sep] )($str|$str_par)";
our $dummy3 = "( [$sep]|[$sep] | [$sep] )";
# our $dummy4 = "[$sep]";

my $test = $main::test;

# Change the manual error markup §,$,€,¥,£ to xml-structure.
sub add_error_markup {
	my ($twig, $para) = @_;

	my @new_content;
	for my $c ($para->children) {
		my $text = $c->text;
        # separator: either §, $, €, ¥ or £
		while ($text && $text =~ /[$sep]/) {
			# No nested errors, no parentheses
# 			if ($text =~ s/^([^$sep]*\s)?(?:\()?($dummy1)(?:\))?(?=$|\n|\s|\p{P})//) {
# 				if ($1) {
# 					push @new_content, $1;
# 				}
# 				if ($2) {
# 					push @new_content, $2;
# 				}
# 			} elsif ($text =~ s/^([^$sep]*\s)?(?:\()?($dummy2)(?:\))?(?=$|\n|\s|\p{P})//) {
# 				if ($1) {
# 					push @new_content, $1;
# 				}
# 				if ($2) {
# 					push @new_content, $2;
# 				}
# 			} elsif ($text =~ s/^([^$sep]*\s)?(?:\()?($dummy3)(?:\))?(?=$|\n|\s|\p{P})//) {
# 				if ($1) {
# 					print "dummy3 1, $1\n";
# 					push @new_content, $1;
# 				}
# 				if ($2) {
# 					print "dummy3 2, $1\n";
# 					push @new_content, $2;
# 				}
# 			} elsif ($text =~ s/^([^$sep]*\s)?(?:\()?($dummy4)(?:\))?(?=$|\n|\s|\p{P})//) {
# 				print "hit dummy4\n";
# 				if($1) {
# 					print "dummy4 1, $1\n";
# 					push @new_content, $1;
# 				}
# 				if ($2) {
# 					print "dummy4 2, $2\n";
# 					push @new_content, $2;
# 				}
# 			} els
			if ($text =~ s/^([^$sep]*\s)?(?:\()?($plainerr)(?:\))?(?=$|\n|\s|\p{P})//) {
				if($1) { push @new_content, $1; }
				if ($test) { print STDERR "Plain error: $2\n"; } # Debug print-out
				get_error($2, \@new_content);
			} elsif ($text =~ s/^([^$sep\(\)]*\s)?(?:\()($plainerr)(?=[$sep])//) {
				if ($1) { push @new_content, $1; }
				my $tmp = $2;
				(my $error = $tmp) =~ s/[\(\)]//g;
				if ($test) { print STDERR "Complex error: $error\n"; } # More debug output
				get_error($error, \@new_content);
				my $last_err = pop @new_content;
				if ($text =~ s/^([$sep](?:\()?[^$sep\\(\\)]+?)(?:\))?(?=$|\n|\s)//) {
					my $tmp = $1;
					(my $error = $tmp) =~ s/[\(\)]//g;
					if ($test) { print STDERR "Another complex error: $error\n"; } # Debug
					get_error($error, \@new_content, $last_err);
				}
			} else {
# 				print "\n***\n*** WARNING - NO MATCH: $text\n***\n\n";
				push @new_content, $text;
				$text ="";
			}
		}
		if ($text) { push @new_content, $text; }
		
	}
	$para->set_content(@new_content);
}


sub get_error {
	my ($error, $separator, $correct, $cont_ref, $first_err) = @_;

		
		# look for extended attributes:
		my $extatt = 0;
		my $attlist = "";
		if ($correct =~ /\|/ ) {
			$extatt = 1;
			($attlist, $correct) = split(/\|/, $correct);
			$attlist =~ s/\s//g;
			if ($test) { print STDERR "Attribute list is: $attlist.\n"; }
#			my $fieldnum = ($pos, errtype, teacher) = split(/,/, $attlist);
		}

		my $error_elt;
		my $error_elt_name = "error";
		if ($types{$separator}) { $error_elt_name = $types{$separator}; }
		if ($first_err && ! $error) {
			$error_elt = XML::Twig::Elt->new($error_elt_name=>{correct=>$correct});
			$first_err->paste('last_child', $error_elt);
		}
		else {
			$error_elt = XML::Twig::Elt->new($error_elt_name=>{correct=>$correct}, $error);
		}
		# Add extra attributes if found:
		if ( $extatt ) {
			# Add attributes for orthographical errors:
			if ( $types{$separator} eq 'errorort') {
				my ($pos, $errtype, $teacher) = split(/,/, $attlist);
				if ( $errtype eq 'yes' || $errtype eq 'no' ) {
					$teacher = $errtype;
					$errtype = "";
				} elsif ( $pos eq 'yes' || $pos eq 'no' ) {
					$teacher = $pos;
					$pos = "";
					$errtype = "";
				}
				if ($pos)     { $error_elt->set_att('pos',     $pos); }
				if ($errtype) { $error_elt->set_att('errtype', $errtype); }
				if ($teacher) { $error_elt->set_att('teacher', $teacher); }
			}
			# Add attributes for lexical errors:
			if ( $types{$separator} eq 'errorlex') {
				my ($pos, $origpos, $errtype, $teacher) = split(/,/, $attlist);
				if ( $errtype eq 'yes' || $errtype eq 'no' ) {
					$teacher = $errtype;
					$errtype = "";
				} elsif ( $origpos eq 'yes' || $origpos eq 'no' ) {
					$teacher = $origpos;
					$origpos = "";
					$errtype = "";
				} elsif ( $pos eq 'yes' || $pos eq 'no' ) {
					$teacher = $pos;
					$pos = "";
					$origpos = "";
					$errtype = "";
				}
				if ($pos)     { $error_elt->set_att('pos',     $pos); }
				if ($errtype) { $error_elt->set_att('errtype', $errtype); }
				if ($teacher) { $error_elt->set_att('teacher', $teacher); }
			}
			# Add attributes for morphosyntactic errors:
			if ( $types{$separator} eq 'errormorphsyn') {
				my ($pos, $const, $cat, $orig, $errtype, $teacher) = split(/,/, $attlist);
				if ( $errtype eq 'yes' || $errtype eq 'no' ) {
					$teacher = $errtype;
					$errtype = "";
				} elsif ( $orig eq 'yes' || $orig eq 'no' ) {
					$teacher = $orig;
					$orig = "";
					$errtype = "";
				} elsif ( $cat eq 'yes' || $cat eq 'no' ) {
					$teacher = $cat;
					$cat = "";
					$orig = "";
					$errtype = "";
				} elsif ( $const eq 'yes' || $const eq 'no' ) {
					$teacher = $const;
					$const = "";
					$cat = "";
					$orig = "";
					$errtype = "";
				} elsif ( $pos eq 'yes' || $pos eq 'no' ) {
					$teacher = $pos;
					$pos = "";
					$const = "";
					$cat = "";
					$orig = "";
					$errtype = "";
				}
				if ($pos)     { $error_elt->set_att('pos',     $pos); }
				if ($const)   { $error_elt->set_att('const',   $const); }
				if ($cat)     { $error_elt->set_att('cat',     $cat); }
				if ($orig)    { $error_elt->set_att('orig',    $orig); }
				if ($errtype) { $error_elt->set_att('errtype', $errtype); }
				if ($teacher) { $error_elt->set_att('teacher', $teacher); }
			}
			# Add attributes for syntactic errors:
			if ( $types{$separator} eq 'errorsyn') {
				my ($pos, $errtype, $teacher) = split(/,/, $attlist);
				if ( $errtype eq 'yes' || $errtype eq 'no' ) {
					$teacher = $errtype;
					$errtype = "";
				} elsif ( $pos eq 'yes' || $pos eq 'no' ) {
					$teacher = $pos;
					$pos = "";
					$errtype = "";
				}
				if ($pos)     { $error_elt->set_att('pos',     $pos); }
				if ($errtype) { $error_elt->set_att('errtype', $errtype); }
				if ($teacher) { $error_elt->set_att('teacher', $teacher); }
			}
		}
		push (@$cont_ref, $error_elt);
		print "$error_elt\n";
	#else { print "NOT MATCH get_error: $text\n"; }
}


# Clean the output of an extracted pdf-file
sub pdfclean {

		my $file = shift @_;
		
		if (! open (INFH, "$file")) {
			print STDERR "$file: ERROR open failed: $!. ";
			return;
			}

		my $number=0;
		my $string;
		my @text_array;
		while ($string = <INFH>) {

			# Clean the <pre> tags
			next if ($string =~ /pre>/);
			# Leave  the line as is if it starts with html tag.
			if ($string =~ m/^\</) {
				push (@text_array,$string);
				next;
			}

			$string =~ s/[\n\r]/ /;
			
			# This if-construction is for finding the line numbers 
			# (which generally are in their own line and even separated by empty lines
			# The text before and after the line number is connected.
			
			if ( $string =~ /^\s*$/) {
				if ($number==1) {
					next;
				}
				else {
					$string = "<\/p>\n<p>";
				}
			}
			if ($string =~ /^\d+\s*$/) {
				$number=1;
				next;
			}
			# Headers are guessed and marked
			# This should be done after the decoding to get the characters correctly.
			$string =~ s/^([\d\.]+[\w\s]*)$/\n<\/p>\n<h2>$1<\/h2>\n<p>\n/;
			$number = 0;
			
			push (@text_array, $string);
		}
		close (INFH);

		open (OUTFH, ">$file") or die "Cannot open file $file: $!";
		print(OUTFH @text_array); 
		close (OUTFH);
}


# routine for printing out header in the middle of processing
# used in subroutine txtclean.
sub printheader {
	my ($header, $fh) = @_;

	$header->print($fh);
	$header->DESTROY;
	print $fh qq|<body>|;

}	


# Add prelimnary xml-structure for the text files.
sub txtclean {

    my ($file, $outfile, $lang) = @_;

	my $replaced = qq(\^\@\;|–&lt;|\!q|&gt);
	my $maxtitle=30;

    # Open file for printing out the summary.
	my $FH1;
	open($FH1,  ">$outfile");
	print $FH1 qq|<?xml version='1.0'  encoding="UTF-8"?>|, "\n";
	print $FH1 qq|<document xml:lang="$lang">|, "\n";

	# Initialize XML-structure
	my $twig = XML::Twig->new();
	$twig->set_pretty_print('indented');

	my $header = XML::Twig::Elt->new('header');
	my $body = XML::Twig::Elt->new('body');

	# Start reading the text
	# enable slurp mode
	local $/ = undef;
    if (! open (INFH, "$file")) {
        print STDERR "$file: ERROR open failed: $!. ";
        return;
    }

	my $text=0;
	my $notitle=1;
	my $p;

    while(my $string=<INFH>){

#		print "string: $string\n";
		$string =~ s/($replaced)//g;
		$string =~ s/@/(at)/g;
		$string =~ s/\\//g;
		# remove all the xml-tags.
		$string =~ s/<.*?>//g;
		$string =~ s/[<>]//g;
		my @text_array;
		my $title;

		return if (! $string);
		# The text contains newstext tags:
		if ($string =~ /\@(.*?)\:/) {
			while ($string =~ s/(\@(.*?)\:[^\@]*)//) {
				push @text_array, $1;
			}
			for my $line (@text_array) {
				if ($line =~ /^\@(.*?)\:(.*?)$/) {
					my $tag = $1;
					my $text = $2;
					
					if ( $tag =~ /(tittel|m.titt)/ && $text ) {
						$text =~ s/[\r\n]+//;
						
						# If the title is too long, there is probably an error
						# and the text is treated as normal paragraph.
						if(length($text) > $maxtitle) {
							$p = XML::Twig::Elt->new('p');
							$p->set_text($text);
							$p->paste('last_child', $body);
							$p=undef;
							next;
						}
						if ($notitle) {
							$title = XML::Twig::Elt->new('title');
							$title->set_text($text);
							$title->paste( 'last_child', $header);
							$notitle=0;
						}
						my $p = XML::Twig::Elt->new('p');
						$p->set_att('type', "title");
						$p->set_text($text);
						$p->paste('last_child', $body);
						$p=undef;
						next;
					}
					if ( $tag =~ /(tekst|ingress)/ ) {
						my $p = XML::Twig::Elt->new('p');
						$p->set_text($text);
						$p->paste('last_child', $body);
						$p=undef;
						next;
					}
					if ( $tag =~ /(byline)/ ) {
						my $a = XML::Twig::Elt->new('author');
						my $p = XML::Twig::Elt->new('person');
						$p->set_att('firstname', "");
						$p->set_att('lastname', "$text");
						$p->paste( 'last_child', $a);
						$p=undef;
						$a->paste( 'last_child', $header);
						next;
					}
					my $p = XML::Twig::Elt->new('p');
					$p->set_text($text);
					$p->set_att('type', "title");
					$p->paste('last_child', $body);
					$p=undef;
					next;
				}
				else { 
					carp "ERROR: line did not match: $line\n"; 
					return "ERROR";
				}
			}
		}

		# The text does not contain newstext tags:
		else {
			$notitle=0;
			my $p_continues=0;
			
			my @text_array = split(/[\n\r]/, $string);
			for my $line (@text_array) {
				$line .= "\n";
				if (! $p ) {
					$p = XML::Twig::Elt->new('p');
					$p->set_text($line);
					$p_continues = 1;
					next;
				}
				if( $line =~ /^\s*\n/  ) {
					$p_continues = 0;
					next;
				}
				if($p_continues ) {
					my $orig_text = $p->text;
					$line = $orig_text . $line;
					$p->set_text($line);
				}
				else {
					$p->paste('last_child', $body);
					$p=undef;
					$p = XML::Twig::Elt->new('p');
					$p->set_text($line);
					$p_continues = 1;
				}
			}
		}
	}
	close INFH;

	if ($p && $body) {
		$p->paste('last_child', $body);
	}
	$header->print($FH1);
	$body->print($FH1);

	print $FH1 qq|</document>|;
	close $FH1;
}

sub error_tester {
	my ($expr) = @_;
	my @new_content = undef;
	my $continue_correction = 0;
	my $error = undef;
	my $separator = undef;
	my $correction = undef;
	my $parsing_finished = 0;
	
# 	print "expr $expr\n";
	chomp($expr);
	for my $tok (split('\s', $expr)) {
		# Errors with word$sepword
		if ($tok =~ m/(.*\w)([$sep])(\w.*)/) {
			print "t1 $tok\n";
			$error = $1;
			$separator = $2;
			$correction = $3;
			$parsing_finished = 1;
# 			get_error($error, $separator, $correct, \@new_content);
			
		}
		# Errors with word$sep(expression)
		elsif ($tok =~ m/(^\w.*\w)([$sep])(\(\w.*\w\))/) {
			print "t2 $tok\n";
			$error = $1;
			$separator = $2;
			$correction = $3;
			$parsing_finished = 1;
		}
		# Errors with word$(start of expression end of expression)
		elsif ($tok =~ m/(^\w.*\w)([$sep])(\(\w.*\w$)/) {
			print "t3 $tok\n";
			$error = $1;
			$separator = $2;
			$correction = $3;
			$continue_correction = 1;
			$parsing_finished = 0;
		}
		# continuation of the above
		elsif ($continue_correction) {
			$correction = $correction . " " . $tok;
			if ($tok =~ m/(\w.*\))/) {
				$continue_correction = 0;
				print "t4 $correction\n";
				$parsing_finished = 1;
			}
		} 
		# Errors of this form 
		# (álggahuvvon 1991) £ (num,advl,locsg,nomsg,case|álggahuvvon 1991:s)
		elsif ($tok =~ m/(.*\))([$sep])(\(\w.*)/) {
			print "t6 $tok\n";
			$error = $1;
			$separator = $2;
			$correction = $3;

			my $tmp;
			do {
				$tmp = pop(@new_content); 
				$error = $tmp . " " . $error;
			} while ( $tmp !~ /^\(/);
			$continue_correction = 1;
			$parsing_finished = 0;
		}
		# A usual word
		else {
			print "t5 $tok\n";
			push(@new_content, $tok);
		}
		if ($parsing_finished) {
			push(@new_content, $error);
			push(@new_content, $separator);
			push(@new_content, $correction);
			$parsing_finished = 0;
		}
	}
	return @new_content;
}


1;

__END__
