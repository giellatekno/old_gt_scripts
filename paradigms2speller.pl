#!/bin/perl -w
# Perl script that parses generated paradigms, and convert them to
# typos-like output format.
#
#  Input is like this:
# 
# áigi+N+Sg+Nom
# áigi
# 
# áigi+N+Sg+Gen
# áiggi
# áigge
# áigge
# 
# áigi+N+Sg+Acc
# áiggi
# 
# áigi+N+Sg+Ill
# áigái
# 
#  Output should be:
# 
# áigi		# áigi+N+Sg+Nom
# áiggi		# áigi+N+Sg+Gen
# áigge		# áigi+N+Sg+Gen
# áigge		# áigi+N+Sg+Gen
# áiggi		# áigi+N+Sg+Acc
# áigái		# áigi+N+Sg+Ill


my $noise = 1;
my $taglist ="";
my @wordforms;
my $i = 0;

while ( <> ) {
    chop;
    $noise = 0 if $_ =~ /\+/;
    next if $noise;
#    print "$noise";
	# An empty line marks the beginning of next input,
	# "Closing file" marks end of single POS input
	if (/^\s*$/ || /Closing file/) {
        # print found input in the wanted format
        # if no wordforsm, print wordform placeholder + taglist
        if (! $wordforms[0]) {
            print "--no-generated-wf--		#$taglist\n";
        } else {
        # otherwise:
        # for each wordform
            foreach $wordform (@wordforms) {
                # print wordform + taglist
                print "$wordform		#$taglist\n";
            }
        }
        $noise = 1 if $_ =~ /Closing file/;
        $i = 0;
		@wordforms = undef;
		$taglist = "";
    	next;
    }
    # if input contains + then = wordform requested
	if (/\+/) {
        $taglist = $_ ;
#        print "$taglist\n" ;
    	next;
    # otherwise it is the generated string
    } elsif (/\w/) {
        $wordforms[$i] = $_ ;
#        print "$wordforms[$i]\n" ;
        $i++;
    } else {
	print STDERR "Found some unexpected content: $_\n";
    }
}
