#!/usr/bin/perl -w
use strict;

# use Perl module XML::Twig for XML-handling
# http://www.xmltwig.com/
use XML::Twig;
use Getopt::Long;

my $inalpha;
my $inset;
my $indefin;
my $inrules;
my $rule;
my $lang;

my $end = "";

my @alphabet;

GetOptions ("lang|l=s" => \$lang);

#my $document = XML::Twig::Elt->new('document');
#$document->set_att('xml:lang', $lang);
#$document->set_pretty_print('record');

print "<document xml:lang =\"$lang\">\n";
print "  <rules>\n";

while (<>) {
	chomp;

	if ($_ =~ /^Alphabet/) {
		$inalpha = 1;
		$inset = 0;
		$indefin = 0;
		$inrules = 0;
	}

	elsif ($_ =~ /^Sets/) {
		$inalpha = 0;
		$inset = 1;
		$indefin = 0;
		$inrules = 0;
	}

	elsif ($_ =~ /^Definitions/) {
#		print $end;
		$inalpha = 0;
		$inset = 0;
		$indefin = 1;
		$inrules = 0;
	}

	elsif ($_ =~ /^Rules/) {
		print $end;
		$inalpha = 0;
		$inset = 0;
		$indefin = 0;
		$inrules = 1;
	}

	elsif ($inalpha && ($_ !~ /^\s*\!/ && $_ !~ /^[\!\n\r]/ )) {
		my @alphas = split /\s+/, $_;
		for my $a (@alphas) {
			push (@alphabet, $a)
		}
	}

	elsif ($inset && ($_ !~ /^\s*\!/ && $_ !~ /^[\!\n\r]/ )) {
		if ($_ =~ /(\S+)\s+\=\s+([^\!^\;]*)/) {
			print $end;
			print "\t<set name=\"$1\">";
			print $2;
			$end = "\t</set>\n";
		}
		elsif ($_ =~ /([^\!^\;]*)/) {
			print $1;
		}
	}

	elsif ($indefin && ($_ !~ /^\s*\!/ && $_ !~ /^[\!\n\r]/ )) {
		if ($_ =~ /(\S+)\s+\=\s+([^\!^\;]*)/) {
			print $end;
			print "\t<definition name=\"$1\">";
			print $2;
			$end = "\t</definition>\n";
		}
		elsif ($_ =~ /([^\!^\;]*)/) {
			print $1;
		}
	}

	elsif ($inrules && ($_ !~ /^\s*\!/ && $_ !~ /^[\!\n\r]/ )) {
		if ($_ =~ /"(.*)"/) {
			my $rulename = $1;

			if ($rule =~ /\S+/) {
				print_rule($rule);
			}

			print "\n\t<rule name=\"$rulename\">\n";
			$rule = "";
			next;
		}

		if ($_ =~ /(\S*\=\S*)/) {
			my $ruletype = $1;
			$ruletype =~ s/</&lt;/;
			print "\t  <ruletype>$ruletype</ruletype>\n";
		}

		(my $line = $_) =~ s/\!.*//;
		$rule = $rule . $line;
	}
}

print_rule($rule);

print "\n  </rules>";
print "\n</document>\n";


sub print_rule {
	my ($rule) = @_;

				my $change;
				my $left;
				my $right;
				my @rules = split /\;/, $rule;

				for my $r (@rules) {

					if ($r =~ /\S*\=\S*\s+([\s\S]*)\s+_\s+(.*)/) {
						print "\t  <context left=\"$1\" right=\"$2\"/>\n";
					}

					elsif ($r =~ /([\s\S]*)\s+_\s+(.*)/) {
						$left = $1;
						$right = $2;
						if ($left =~ /\S*\=\S*/) {
							print "\t  <context right=\"$right\"/>\n";
						}
						else {
							print "\t  <context left=\"$left\" right=\"$right\"/>\n";
						}
					}

					if ($r =~ /(\S+):(\S+)\s+\S*\=\S*/) {
						$change = "\t  <change from=\"$1\" to=\"$2\"/>\n";
					}

					if ($r =~ /where.*matched/) {
						$change = "";
						$r =~ /\((.*)\).*\((.*)\)/;
						my @from = split /\s+/, $1;
						my @to = split /\s+/, $2;
						my $count = 0;
						for my $t (@from) {
							print "\t  <change from=\"$t\" to=\"$to[$count]\"/>\n";
							$count++;
						}
					}
				}

				print $change;
				print "\t</rule>\n";

}
