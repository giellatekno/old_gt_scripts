
package langTools::Corpus;

use utf8;
use warnings;
use strict;

use XML::Twig;
use Carp qw(cluck);

use Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK);

$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA         = qw(Exporter);

@EXPORT = qw(&add_error_markup);

@EXPORT_OK   = qw(&process_paras);

#our ($fst);


# Change the manual error markup § to xml-structure.
#
sub add_error_markup {
	my ($twig, $para) = @_;

	my @new_content;
	for my $c ($para->children) {
		my $text = $c->text;
		my $new_text;
		my $nomatch = 0;
		while ($text =~ /\x{00A7}/) {
			if ($text =~ m/^
				(.*?         # match the text without corrections
				\s?)
				([^\s]*?)           # string before the error-correction separator
				\x{00A7}           # separator
				(                  # either
				\(.*?\)|         # string after separator, possible parentheses or
			    [^\s]*?([\s\n]+)   # string after separator, no parentheses
				)
				(.*)           # rest of the string.
				$/xm ) {

				my $start = $1;
				my $error = $2;
				my $correct = $3;
				$error =~ s/\s$//g;
				my $space = $4;
				my $rest = $5;
				
				(my $corr = $correct) =~ s/\s?$//;
				$corr =~ s/[\(\)]//g;
				push (@new_content, $start);

				my $error_elt = XML::Twig::Elt->new(error=>{correct=>$corr}, $error);
				push (@new_content, $error_elt);

				# Add space back to the string.
				if ($space) { $rest = $space . $rest; }

				# If there is no more text or error marking process next element.
				if (! $rest || $rest !~ /\x{00A7}/) {
					push (@new_content, $rest);
					last;
				}
				$text = $rest;
			} else { 
				print "Did not match: $text\n"; 
				push(@new_content, $text); 
				last;
			}
		}
	}
	$para->set_content(@new_content);

}


1;

__END__
