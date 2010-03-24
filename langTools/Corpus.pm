
package langTools::Corpus;

use utf8;
use open 'utf8';

use warnings;
use strict;

use XML::Twig;
use Carp qw(cluck carp);

use Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK);

$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA         = qw(Exporter);

@EXPORT = qw(&add_error_markup &pdfclean &txtclean);

#@EXPORT_OK   = qw(&process_paras);

#our ($fst);

our %types = ("£" => "synt",
			  "€" => "lex",
			  "\$" => "ort");

our $sep = quotemeta("€§£\$");
our $sep_c = "\§|\$|€|\£";
our $str = "[^$sep\\s\\(\\)]+?";
our $str_par = "\\([^$sep\\(\\)]+?\\)";
our $plainerr = "($str|$str_par)[$sep]($str|$str_par)";

# Change the manual error markup § to xml-structure.

sub add_error_markup {
	my ($twig, $para) = @_;

	my @new_content;
	for my $c ($para->children) {
		my $text = $c->text;
		my $new_text;
		my $nomatch = 0;
        # separator: either §, $,€ or £
		while ($text && $text =~ /[$sep]/) {

			# No nested errors, no parentheses
			if ($text =~ s/^([^$sep]*\s)?(?:\()?($plainerr)(?:\))?(?=$|\n|\s|\p{P})//) {
				if($1) { push @new_content, $1; }
				get_error($2, \@new_content);
			}

			elsif ($text =~ s/^([^$sep\(\)]*\s)?(?:\()($plainerr)(?=[$sep])//) {
				if ($1) { push @new_content, $1; }
				my $tmp = $2;
				(my $error = $tmp) =~ s/[\(\)]//g;
				get_error($error, \@new_content);
				my $last_err = pop @new_content;
				if ($text =~ s/^([$sep](?:\()?[^$sep\\(\\)]+?)(?:\))?(?=$|\n|\s)//) {
					my $tmp = $1;
					(my $error = $tmp) =~ s/[\(\)]//g;
					get_error($error, \@new_content, $last_err);
				}
			}
			else {
				print "\n***\n*** WARNING - NO MATCH: $text\n***\n\n";
				push @new_content, $text;
				$text ="";
			}
		}
		if ($text) { push @new_content, $text; }
		
	}
	$para->set_content(@new_content);
}


sub get_error {
	my ($text, $cont_ref, $first_err) = @_;

	if ($text =~ m/^(.*?)([$sep])(.*)$/ ) {
		
		my $error = $1;
		my $separator = $2;
		my $correct = $3;
		#print "JEE $separator\nERROR $error\nCORRECT $correct\n";

		$error =~ s/\s$//g;
		
		(my $corr = $correct) =~ s/\s?$//;
		$error =~ s/[\(\)]//g;
		$corr =~ s/[\(\)]//g;

#		# look for extended attributes:
#		my $extatt = false;
#		my $attlist = "";
#		if ($corr =~ /\|/ ) {
#			$extatt = true;
#			($attlist, $corr) = split(/\|/, $corr);
#			my $fieldnum = ($pos, errtype, teacher) = split(/,/, $attlist);
#		}

		my $error_elt;
		if ($first_err && ! $error) {
			$error_elt = XML::Twig::Elt->new(error=>{correct=>$corr});
			$first_err->paste('last_child', $error_elt);
		}
		else {
			$error_elt = XML::Twig::Elt->new(error=>{correct=>$corr}, $error);
		}
		if ($types{$separator}) { $error_elt->set_att('type', $types{$separator}); }
		push (@$cont_ref, $error_elt);		
	} 
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
