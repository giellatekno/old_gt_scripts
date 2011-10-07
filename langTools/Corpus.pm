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
				"¢" => "errorortreal",
				"€" => "errorlex",
				"£" => "errormorphsyn",
				"¥" => "errorsyn",
				"§" => "error");

our $sep = quotemeta("€§£\$¥¢");

our $test = 0;

# Change the manual error markup §,$,€,¥,£ to xml-structure.
sub add_error_markup {
	my ($twig, $para) = @_;

	$para = recursive_search_for_error_expression($para);
}

sub recursive_search_for_error_expression {
    my ($element) = @_;

    my @new_content;

    for my $child ($element->children) {
        if ($child->tag eq "#PCDATA") {
            my $text = $child->text;
            push(@new_content, error_parser($text));
        } else {
            push(@new_content, recursive_search_for_error_expression($child));
        }
    }

    $element->set_content(@new_content);
    
    return $element;
}

sub error_parser {
	my ($text) = @_;

	my $error = undef;
	my $separator;
	my $correct;
	my $rest;
	my $error_elt;
	my @new_content;
	

	my $counter = 0;
	while ($text =~ m/[$sep]\S/ and $counter < 200) {
		$counter++;
		if ($test) {
			print "\n\nerror_parser 61 $text\n";
		}
		
		if ($text =~ s/([$sep])(\([^\)]*\)|\S+)(.*)//s) {
			$text .= $1;
			$separator = $1;
			$correct = $2;
			$rest = $3;
			
			if ($test) {
				print "error_parser 71 text «$text» separator «$separator» correct «$correct» rest «$rest»\n";
			}
			
			$text =~ s/(\([^\(]*\)|\w+|\w+[-\':\]]\w+|\w+[-\'\]\.]|\d+’\w+|\d+%:\w+)([$sep])//s;
			$error = $1;
			$correct =~ s/\)//;
			$correct =~ s/\(//;

			
			if ($test) {
				print "error_parser 81 text «$text» error «$error» separator «$separator» correct «$correct» rest «$rest»\n";
			}
			
			if ($error =~ /[$sep]/) {
				# we are in a nested markup
				my $parenthesis;
				if ($text =~ s/\)[$sep]//) {
					$parenthesis = 1;
				} elsif ($text =~ s/^[$sep]//) {
					$parenthesis = 0;
				}
				my @part1;
				if (! $text eq "") {
					unshift(@part1, $text);
				}
				my $found_start = 1;
				my $next_bit;
				while ($found_start && ($next_bit = pop(@new_content))) {
					$counter++;
					if (ref($next_bit) eq 'XML::Twig::Elt') {
						unshift(@part1, $next_bit);
					} else {
						if ($test) {
							print "error_parser 99 $next_bit\n";
						}
						if ($parenthesis) {
							my $position = rindex($next_bit, '(');
							if ($position > -1) {
								$found_start = 0;
								if (length($next_bit) > 1) {
									if ($test) {
										print "to part1: " . substr($next_bit, $position + 1, length($next_bit)) . "\n";
										print "back to new_content: " . substr($next_bit, 0, $position) . "\n";
									}
									if ($position == 0) {
										unshift(@part1, substr($next_bit, $position + 1, length($next_bit)));
									} elsif ($position + 1 == length($next_bit)) {
										push(@new_content, substr($next_bit, 0, $position));
									} else {
										unshift(@part1, substr($next_bit, $position + 1, length($next_bit)));
										push(@new_content, substr($next_bit, 0, $position));
									}
								}
							} else {
								unshift(@part1, $next_bit);
							}
						} else {
							push(@new_content, $next_bit);
							$found_start = 0;
						}
					}
				}
				$error_elt = XML::Twig::Elt->new('dummy');
				$error_elt->set_content(@part1);
				$error_elt = get_error($error_elt, $separator, $correct);
			} else {
				# a simple error
				$error =~ s/\)//;
				$error =~ s/\(//;
				$error_elt = get_error($error, $separator, $correct);
				push(@new_content, $text);
			}
			push(@new_content, $error_elt);
			$text = $rest;
			if ($test) {
				print "error_parser 127 «@new_content», text «$text»\n\n";
			}
		}
	}
	push (@new_content, $text);
	return @new_content;
}

sub get_error {
	my ($error, $separator, $correct) = @_;

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
	if (ref($error) eq 'XML::Twig::Elt') {
		$error_elt = $error;
		$error_elt->set_tag($error_elt_name);
		$error_elt->set_att(correct => $correct);
	} else {
		$error_elt = XML::Twig::Elt->new($error_elt_name=>{correct=>$correct}, $error);
	}
	# Add extra attributes if found:
	if ($extatt) {
		# Add attributes for orthographical errors:
		if ($types{$separator} eq 'errorort' || $types{$separator} eq 'errorortreal') {
#    		print "errorort: $attlist\n";
			my ($pos, $errtype, $teacher) = split(/,/, $attlist);
			if ($errtype eq 'yes' || $errtype eq 'no') {
				$teacher = $errtype;
				$errtype = "";
			} elsif ( $pos eq 'yes' || $pos eq 'no') {
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
#    		print "errorlex: $attlist\n";
			my ($pos, $origpos, $errtype, $teacher) = split(/,/, $attlist, 4);
			if ($errtype eq 'yes' || $errtype eq 'no') {
				$teacher = $errtype;
				$errtype = "";
			} elsif ($origpos eq 'yes' || $origpos eq 'no') {
				$teacher = $origpos;
				$origpos = "";
				$errtype = "";
			} elsif ($pos eq 'yes' || $pos eq 'no') {
				$teacher = $pos;
				$pos = "";
				$origpos = "";
				$errtype = "";
			}
			if ($pos) { 
				$error_elt->set_att('pos', $pos); 
			}
			if ($errtype) { 
				$error_elt->set_att('errtype', $errtype); 
			}
			if ($teacher) { 
				$error_elt->set_att('teacher', $teacher); 
			}
			if ($origpos) { 
				$error_elt->set_att('origpos', $origpos); 
			}
		}
		# Add attributes for morphosyntactic errors:
		if ( $types{$separator} eq 'errormorphsyn') {
#    		print "errormorphsyn: $attlist\n";
			my ($pos, $const, $cat, $orig, $errtype, $teacher) = split(/,/, $attlist, 6);
			if ($errtype eq 'yes' || $errtype eq 'no' ) {
				$teacher = $errtype;
				$errtype = "";
			} elsif ($orig eq 'yes' || $orig eq 'no') {
				$teacher = $orig;
				$orig = "";
				$errtype = "";
			} elsif ($cat eq 'yes' || $cat eq 'no') {
				$teacher = $cat;
				$cat = "";
				$orig = "";
				$errtype = "";
			} elsif ($const eq 'yes' || $const eq 'no') {
				$teacher = $const;
				$const = "";
				$cat = "";
				$orig = "";
				$errtype = "";
			} elsif ($pos eq 'yes' || $pos eq 'no') {
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
		if ($types{$separator} eq 'errorsyn') {
#    		print "errorsyn: $attlist\n";
			my ($pos, $errtype, $teacher) = split(/,/, $attlist);
			if ($errtype eq 'yes' || $errtype eq 'no') {
				$teacher = $errtype;
				$errtype = "";
			} elsif ($pos eq 'yes' || $pos eq 'no') {
				$teacher = $pos;
				$pos = "";
				$errtype = "";
			}
			if ($pos)     { $error_elt->set_att('pos',     $pos); }
			if ($errtype) { $error_elt->set_att('errtype', $errtype); }
			if ($teacher) { $error_elt->set_att('teacher', $teacher); }
		}
	}
	if ($test) {
		print "error_parser 274 ";
		$error_elt->print;
		print "\n";
	}

	return $error_elt;
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

1;

__END__
