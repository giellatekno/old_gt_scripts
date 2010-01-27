#!/usr/bin/perl -w
$|=1;

sub Niceline ($) {
   my ($input) = @_;
   $_ = $input;

   if (/^</) {
	return "\n$_";
   }

   if (/^\"<\*/) {
	s/^\"<\*//;
	$_ = ucfirst($_);
	s/^á/Á/;
	s/^à/À/;
	s/^â/Â/;
	s/^ã/Ã/;
	s/^é/É/;
	s/^ê/Ê/;
	s/^í/Í/;
	s/^î/Î/;
	s/^ó/Ó/;
	s/^ô/Ô/;
	s/^õ/Õ/;
	s/^ú/Ú/;
	s/^û/€/;
	s/^ç/Ç/;
	s/^ñ/Ñ/;
	s/^æ/Æ/g;
	s/^ø/Ø/g;
	s/^å/Å/g;
	s/^/\"</;
   }
   if (/ <error>/) {
	s/<error>//;
	s/\"[^\"]+\" ([^\"]*\"[^\"]+\") +/$1 /; # removes old base form and adapts new one
#	s/\"[^\"]+\" //;
#	s/(\"[^\"]+\") +/\t$1 /;
   }
   s/(.)\012/$1 /; # space added because of ADV/CONJ colouring in ambiguous readings
#   s/\$START//;
#    if (/<\*>/) {
#	s/\"<(.)/\"<uc($1)/;
#    }
   s/\"</\012/g;
   s/>\"//g;
   s/^[ \t]+\"/\t \[/g;
   s/\t\"/\t\[/g; # after line.vislcg
   s/([^\$])\" /$1\] /g;
#    print "***$_\n";
   s/([^<\n])\$\"/$1\$\]/; # isolated $
#   s/<\*> //g;
   s/ \@/ \@/g;
# foelgende linie alternerer med de 2 efterfoelgende
#    s/\' +\{/\'\{/g;
   s/ +\{[^\}\012]*\} +/ /g;
   s/ *\{[^\}\012]*\} *//g;
   s/ [0-9]+\012/\n/g;
   s/<=[a-zA-Z]*=> //g;
#    tr/\330/\012/;
   s/<(\$|\/|hi)>/\n<$1>/g;

   s/[ \t]+\[\$[^a-zA-Z0-9]+\] / /; # remove baseform of punctuation

   return $_;
}

return 1;
