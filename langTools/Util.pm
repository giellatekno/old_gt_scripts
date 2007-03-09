# Util.pm 
# Utility functions for the using the different langtech tools.

package langTools::Util;

use utf8;

use Encode;
use warnings;
use strict;
use Carp qw(cluck);

use Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK);

$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA         = qw(Exporter);

@EXPORT = qw(&init_lookup &call_lookup &read_tags &generate_taglist);
@EXPORT_OK   = qw();

# Initialize expect object for analysis
# Returns a pointer to the object.
sub init_lookup {
	my ($command) =  @_;

	if (! $command) { cluck "No command specified"; }
	my $exp = Expect->spawn($command)
		or cluck "Cannot spawn $command";
	$exp->log_stdout(0);
	
	return $exp;
}


# Call expect object with a string.
# Returns the analysis.
sub call_lookup {
	my ($exp_ref, $string)  = @_;
	
	if (! $$exp_ref) { cluck "The expect object missing"; }

	#$string = Encode::encode_utf8($string);

	$$exp_ref->send("$string\n");
	$$exp_ref->expect(undef, '-re', '\r?\n\r?\n' );

	my $read_anl = $$exp_ref->before();

	#$read_anl = Encode::decode_utf8($read_anl);

	# Take away the original input.
	$read_anl =~ s/^.*?\n//;
	# Replace extra newlines.
	$read_anl =~ s/\r\n/\n/g;
	$read_anl =~ s/\r//g;

	return "$read_anl\n";

}



# Read the grammar for  paradigm tag list.
# Call the recursive function that generates the tag list.
sub generate_taglist {
	my ($gramfile, $tagfile, $taglist_aref, $mode) = @_;

	my @grammar;
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
			
			s/\s*$//;
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

		if ($mode && $mode eq "min" && $pos eq "N") {
			push(@taglist, "N+Sg+Nom");
			push(@taglist, "N+Sg+Gen");
			push(@taglist, "N+Sg+Acc");
			push(@taglist, "N+Pl+Gen");
			$$taglist_aref{$pos}= [ @taglist ];
			next;
		}
		generate_tag($tag, \%tags, \@classes, \@taglist);
		$$taglist_aref{$pos}= [ @taglist ];
	}
#	for my $pos ( keys %$taglist_aref ) {
#		print "\nJEE @{$$taglist_aref{'N'}} ";
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
		
	for my $t (@{$$tags_href{$class}}) {
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
			push (@{$$tags_href{$tag_class}}, @tags);
			undef @tags;
			pop @tags;
			next TAG_FILE;
		}
		my @tag_a = split (/\s+/, $_);
		push @tags, $tag_a[0];
 	}

	close TAGS;
}



1;

__END__
