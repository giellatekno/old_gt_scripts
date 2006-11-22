# Util.pm 
# Utility functions for the using the different langtech tools.

package langTools::Util;

binmode STDOUT, ":utf8";
binmode STDIN, ":utf8";
use open ':utf8';
use warnings;
use strict;

use Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK);

$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA         = qw(Exporter);

@EXPORT = qw(&read_tags &generate_taglist);
@EXPORT_OK   = qw();

# Read the grammar for  paradigm tag list.
# Call the recursive function that generates the tag list.
sub generate_taglist {
	my ($gramfile, $tagfile, $taglist_aref, $mode) = @_;

	my @grammar;
	push (@grammar, "N+Number+Case+Possessive?+Clitic?");
	push (@grammar, "A+Grade?+Attributive?+Number?+Case?+Possessive?+Clitic?");
	push (@grammar, "V+Infinite?+Diathesis?+Polarity?+Mood?+Tense?+Person-Number?+Clitic?");
	push (@grammar, "Adv+Grade?+Clitic?");

	my %tags;

	if ($gramfile) {
		# Read from tag file and store to an array.
		open GRAM, "< $gramfile" or die "Cant open the file $gramfile: $!\n";
		my @tags;
		my $tag_class;
	  GRAM_FILE:
		while (<GRAM>) {
			chomp;
			next if /^\s*$/;
			next if /^%/;
			next if /^$/;
			next if /^#/;
			
			push (@grammar, $_);
		
		}
	}
	read_tags($tagfile, \%tags);
	
	my @taglists;
	# Read each grammar rule and generate the taglist.
	for my $gram (@grammar) {
		my @classes = split (/\+/, $gram);
		my $pos = shift @classes;
		my $tag = $pos;
		my @taglist;
		generate_tag($tag, \%tags, \@classes, \@taglist);
		$$taglist_aref{$pos}= [ @taglist ];
	}
#	for my $pos ( keys %$taglist_aref ) {
#		print "JEE @$taglist_aref{$pos} ";
#    }
}

# Ttravel recursively the taglists and generate
# the tagsets for pardigm generation.
# The taglist is stored to the array reference $taglist_aref.
sub generate_tag {
	my ($tag, $tags_href, $classes_aref, $taglist_aref) = @_;

	if (! @$classes_aref) { push (@$taglist_aref, $tag); return;  }
	my $class = shift @$classes_aref;
	if ($class =~ s/\?//) {
		my $new_tag = $tag;
		my @new_class = @$classes_aref;
		generate_tag($new_tag, $tags_href, \@new_class, $taglist_aref);
	}
		
	for my $t (keys %{$$tags_href{$class}}) {
		my $new_tag = $tag . "+" . $t;
		my @new_class = @$classes_aref;
		generate_tag($new_tag, $tags_href, \@new_class, $taglist_aref);
	}
}			

# Read the morphological tags from a file (korpustags.txt)
sub read_tags {
	my ($tagfile, $tags_href) =  @_;

	# Read from tag file and store to an array.
	open TAGS, "< $tagfile" or die "Cant open the file $tagfile: $!\n";
	my @tags;
	my $tag_class;
  TAG_FILE:
	while (<TAGS>) {
		chomp;
		next if /^\s*$/;
		next if /^%/;
		next if /^$/;
		next if /=/;
		
		if (s/^#//) {

			$tag_class = $_;
			for my $tag (@tags) {
				$$tags_href{$tag_class}{$tag} = 1;
			}
			undef @tags;
			pop @tags;
			next TAG_FILE;
		}
		my @tag_a = split (/\s+/, $_);
		unshift @tags, $tag_a[0];
 	}

	close TAGS;
}

1;

__END__
