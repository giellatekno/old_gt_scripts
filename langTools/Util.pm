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

@EXPORT = qw(&read_tags);
@EXPORT_OK   = qw();


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
