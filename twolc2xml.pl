#!/usr/bin/perl -w
use strict;

# use Perl module XML::Twig for XML-handling
# http://www.xmltwig.com/
use XML::Twig;

my $r;
my $rule;

#my $document = XML::Twig::Elt->new('document');
#$document->set_pretty_print('record');

while (<>) {
	chomp;


	if ($_ =~ /^Rules/) {
		$r = 1;
	}

	elsif ($r && ($_ !~ /^\s*\!/ && $_ !~ /^[\!\n\r]/ )) {
		my $paste_rule = 0;

		if ($_ =~ /"(.*)"/) {
			my $rulename = $1;

			if ($rule =~ /\S+/) {
				print_rule($rule);
#				next;

#				my $change;
#				my @rules = split /\;/, $rule;

#				for my $r (@rules) {
#					if ($r =~ /\S*\=\S*\s+(.*)\s+_\s+(.*)/) {
#						print "\t<context left=\"$1\" right=\"$2\"/>\n";
#					}

#					elsif ($r =~ /(.*)\s+_\s+(.*)/) {
#						print "\t<context left=\"$1\" right=\"$2\"/>\n";
#					}

#					if ($r =~ /(\S+):(\S+)\s+\S*\=\S*/) {
#						$change = "\t<change from=\"$1\" to=\"$2\"/>\n";
#					}

#					if ($r =~ /where.*matched/) {
#						$change = "";
#						$r =~ /\((.*)\).*\((.*)\)/;
#						my @from = split /\s+/, $1;
#						my @to = split /\s+/, $2;
#						my $count = 0;
#						for my $t (@from) {
#							print "\t<change from=\"$t\" to=\"$to[$count]\"/>\n";
#							$count++;
#						}
#					}
#				}

#				print $change;
#				print "</rule>\n";
			}
			print "\n<rule name=\"$rulename\">\n";
			$rule = "";
			next;
		}

		if ($_ =~ /(\S*\=\S*)/) {
			my $ruletype = $1;
			print "\t<ruletype>$ruletype</ruletype>\n";
		}

		(my $line = $_) =~ s/\!.*//;
		$rule = $rule . $line;
	}
}

print_rule($rule);

sub print_rule {
	my ($rule) = @_;

				my $change;
				my @rules = split /\;/, $rule;

				for my $r (@rules) {
#					print "\nJEE $r\n";

					if ($r =~ /\S*\=\S*\s+(.*)\s+_\s+(.*)/) {
#						print "LC $1\n";
#						print "RC $2\n";
						print "\t<context left=\"$1\" right=\"$2\"/>\n";
					}

					elsif ($r =~ /(.*)\s+_\s+(.*)/) {
#						print "LC $1\n";
#						print "RC $2\n";
						print "\t<context left=\"$1\" right=\"$2\"/>\n";
					}

					if ($r =~ /(\S+):(\S+)\s+\S*\=\S*/) {
#						print "JEAH $1 $2\n";
						$change = "\t<change from=\"$1\" to=\"$2\"/>\n";
					}

					if ($r =~ /where.*matched/) {
						$change = "";
						$r =~ /\((.*)\).*\((.*)\)/;
#						print "PLAA $1 $2\n";
						my @from = split /\s+/, $1;
						my @to = split /\s+/, $2;
						my $count = 0;
						for my $t (@from) {
							print "\t<change from=\"$t\" to=\"$to[$count]\"/>\n";
							$count++;
						}
					}
				}

				print $change;
				print "</rule>\n";

}
