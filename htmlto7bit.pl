#!/usr/bin/perl -w

# Usage:
# htmlto7bit.pl inputfile.html > outputfile-in-our-internal-format

# This script takes a html document as input. It then takes all entities
# at least the si ones and converts them to utf8 letters.
# After that we can take away all the garbage that's in html files,
# and finally convert it to 7bit.

# Note! The "garbage" should not be taken away, but utilised. The script
# is thus still not completed.
# TODO:   Use header and list information as input to disambiguation.
# Needed: Convention for representing <h1></h1> etc. tags in the preprocessor.

# The decimal notation of the latin 1 range is included.
# The other code tables (win125, lat6, ws2) are not completed with non-sami conversion.

use strict;
use HTML::Parser 3.00 ();


# Find the charset
my $charset = find_charset( `grep charset= $ARGV[0]` );

my $result;
my %inside;

# Parse the file
HTML::Parser->new(api_version => 3,
		  handlers    => [start => [\&tag, "tagname, '+1'"],
				  end   => [\&tag, "tagname, '-1'"],
				  text  => [\&text, "text"],
				 ],
		  marked_sections => 1,
		  )->parse_file(shift) || die "Can't open file: $!\n";;

# Then process the parsed result
if ($charset eq "windows-1252") { $result = win_1252($result) }
elsif ($charset eq "iso-8859-10") { $result = latin6($result) }
elsif ($charset eq "utf-8") { $result = unicode_ent_utf8($result) }
elsif ($charset eq "UTF-8") { $result = unicode_ent_utf8($result) }
elsif ($charset eq "iso-8859-1") { $result = unicode_ent_utf8($result) }
else { $result = generic($result); }

#
# Final manipulation, and printout
#
$result = remove_garbage($result);
$result = utf8_to_7bit($result);
print $result;                  # This option gives text + newlines.
#print map_words($result);      # This option gives the text as one running line.



#
#
# Find what charset is in the file
#
#
sub find_charset
{
    my ($res) = @_;
    my $cset;
    if ($res) {
	my $first=index($res,"charset=") + 8;
	my $last= rindex($res,"\">") - $first;
	
	$cset = substr($res,($first),$last);
	print "$first, $last\t$cset \n";      # no merry printing of "hola ..."
    } else { print "ingen charset\n";         # TODO: remove this header.
	     $cset = "none";}

    return $cset;
}



#
#
# These functions belong to the parser
#
#
sub tag
{
   my($tag, $num) = @_;
   $inside{$tag} += $num;
#   print " ";  # not for all tags
}

sub text
{
    return if $inside{script} || $inside{style};
    $result .= $_[0];
}

#
#
# These are the main functions for processing the parsed file
#
#

#
# This takes care of the cases where it's not possible to decide 
# the html file's charset
#
sub generic {
    my ($text) = @_;

    $text = unicode_ent_to_utf8($text);
    $text = html_entities_to_utf8($text);
    $text = ws2_to_utf8($text);
#    $text = latin9_to_utf8($text);

    return $text;
}

#
# This converts the sami characters in cp-1252 to unicode ones.
#
sub win_1252
{
    
    my ($text) = @_;

    $text =~ s/\xe1/\xc3\x81/g;       # A sharp
    $text =~ s/\232/\xc5\xa1/g;   # s caron
    $text =~ s/\236/\xc5\xbe/g;   # z caron


    $text =~ s/\xc1/\xC3\xA1/g;       # A sharp
    $text =~ s/\212/\xc5\xa0/g;   # S caron
    $text =~ s/\216/\xc5\xbd/g;   # Z caron

    return unicode_ent_to_utf8($text);
}

#
# this one takes care of the pages from saamiweb.org
#
sub latin6
{
    
    my ($text) = @_;

    $text =~ s/\e1/\xc3\xa1/g; # a sharp
    $text =~ s/&\#168;/\xc5\xa1/g;   # s caron
    $text =~ s/\232/\xc5\xa1/g;   # s caron

    $text =~ s/\c1/\xc3\xa1/g; # A sharp

    return unicode_ent_to_utf8($text);
}

#
# This converts unicode html entities to utf8
#
#sub unicode_ent_to_utf8
sub unicode_ent_utf8
{
    my ($text) = @_;
    # First unicode ones

    # This takes care of decimal notation

# Decimal sgml entities of the A column of Latin 1

    $text =~ s/&\#160;/\xc2\xa0/g; # 
    $text =~ s/&\#161;/\xc2\xa1/g; # 
    $text =~ s/&\#162;/\xc2\xa2/g; # 
    $text =~ s/&\#163;/\xc2\xa3/g; # 
    $text =~ s/&\#164;/\xc2\xa4/g; # 
    $text =~ s/&\#165;/\xc2\xa5/g; # 
    $text =~ s/&\#166;/\xc2\xa6/g; # 
    $text =~ s/&\#167;/\xc2\xa7/g; # 

    $text =~ s/&\#168;/\xc2\xa8/g; # 
    $text =~ s/&\#169;/\xc2\xa9/g; # 
    $text =~ s/&\#170;/\xc2\xaa/g; # 
    $text =~ s/&\#171;/\xc2\xab/g; # 
    $text =~ s/&\#172;/\xc2\xac/g; # 
    $text =~ s/&\#173;/\xc2\xad/g; # 
    $text =~ s/&\#174;/\xc2\xae/g; # 
    $text =~ s/&\#175;/\xc2\xaf/g; # 

# Decimal sgml entities of the B column of Latin 1

    $text =~ s/&\#176;/\xc4\xb0/g; # 
    $text =~ s/&\#177;/\xc2\xb1/g; # 
    $text =~ s/&\#178;/\xc2\xb2/g; # 
    $text =~ s/&\#179;/\xc2\xb3/g; # 
    $text =~ s/&\#180;/\xc2\xb4/g; # 
    $text =~ s/&\#181;/\xc2\xb5/g; # 
    $text =~ s/&\#182;/\xc2\xb6/g; # 
    $text =~ s/&\#183;/\xc2\xb7/g; # 

    $text =~ s/&\#184;/\xc2\xb8/g; # 
    $text =~ s/&\#185;/\xc2\xb9/g; # 
    $text =~ s/&\#186;/\xc2\xba/g; # 
    $text =~ s/&\#187;/\xc2\xbb/g; # 
    $text =~ s/&\#188;/\xc2\xbc/g; # 
    $text =~ s/&\#189;/\xc2\xbd/g; # 
    $text =~ s/&\#190;/\xc2\xbe/g; # 
    $text =~ s/&\#191;/\xc2\xbf/g; # 

# Decimal sgml entities of the C column of Latin 1

    $text =~ s/&\#192;/\xc3\x80/g; # À
    $text =~ s/&\#193;/\xc3\x81/g; # Á
    $text =~ s/&\#194;/\xc3\x82/g; # 
    $text =~ s/&\#195;/\xc3\x83/g; # 
    $text =~ s/&\#196;/\xc3\x84/g; # 
    $text =~ s/&\#197;/\xc3\x85/g; # 
    $text =~ s/&\#198;/\xc3\x86/g; # 
    $text =~ s/&\#199;/\xc3\x87/g; # 

    $text =~ s/&\#200;/\xc3\x88/g; # 
    $text =~ s/&\#201;/\xc3\x89/g; # 
    $text =~ s/&\#202;/\xc3\x8a/g; # 
    $text =~ s/&\#203;/\xc3\x8b/g; # 
    $text =~ s/&\#204;/\xc3\x8c/g; # 
    $text =~ s/&\#205;/\xc3\x8d/g; # 
    $text =~ s/&\#206;/\xc3\x8e/g; # 
    $text =~ s/&\#207;/\xc3\x8f/g; # 

# Decimal sgml entities of the D column of Latin 1

    $text =~ s/&\#208;/\xc4\x90/g; # Assuming Iclandic doesn't exist :-(
    $text =~ s/&\#209;/\xc3\x91/g; # 
    $text =~ s/&\#210;/\xc3\x92/g; # 
    $text =~ s/&\#211;/\xc3\x93/g; # 
    $text =~ s/&\#212;/\xc3\x94/g; # 
    $text =~ s/&\#213;/\xc3\x95/g; # 
    $text =~ s/&\#214;/\xc3\x96/g; # 
    $text =~ s/&\#215;/\xc3\x97/g; # 

    $text =~ s/&\#216;/\xc3\x98/g; # 
    $text =~ s/&\#217;/\xc3\x99/g; # 
    $text =~ s/&\#218;/\xc3\x9a/g; # 
    $text =~ s/&\#219;/\xc3\x9b/g; # 
    $text =~ s/&\#220;/\xc3\x9c/g; # 
    $text =~ s/&\#221;/\xc3\x9d/g; # 
    $text =~ s/&\#222;/\xc3\x9e/g; # 
    $text =~ s/&\#223;/\xc3\x9f/g; # 

# Decimal sgml entities of the E column of Latin 1

    $text =~ s/&\#224;/\xc3\xa0/g; # 
    $text =~ s/&\#225;/\xc3\xa1/g; # a sharp
    $text =~ s/&\#226;/\xc3\xa2/g; # 
    $text =~ s/&\#227;/\xc3\xa3/g; # 
    $text =~ s/&\#228;/\xc3\xa4/g; # 
    $text =~ s/&\#229;/\xc3\xa5/g; # 
    $text =~ s/&\#230;/\xc3\xa6/g; # 
    $text =~ s/&\#231;/\xc3\xa7/g; # 

    $text =~ s/&\#232;/\xc3\xa8/g; # 
    $text =~ s/&\#233;/\xc3\xa9/g; # 
    $text =~ s/&\#234;/\xc3\xaa/g; # 
    $text =~ s/&\#235;/\xc3\xab/g; # 
    $text =~ s/&\#236;/\xc3\xac/g; # 
    $text =~ s/&\#237;/\xc3\xad/g; # 
    $text =~ s/&\#238;/\xc3\xae/g; # 
    $text =~ s/&\#239;/\xc3\xaf/g; # 

# Decimal sgml entities of the F column of Latin 1

    $text =~ s/&\#240;/\xc5\x8b/g; # d1, assuming the Icelandic error again
    $text =~ s/&\#241;/\xc3\xb1/g; # ñ
    $text =~ s/&\#242;/\xc3\xb2/g; # 
    $text =~ s/&\#243;/\xc3\xb3/g; # 
    $text =~ s/&\#244;/\xc3\xb4/g; # 
    $text =~ s/&\#245;/\xc3\xb5/g; # 
    $text =~ s/&\#246;/\xc3\xb6/g; # 
    $text =~ s/&\#247;/\xc3\xb7/g; # 

    $text =~ s/&\#248;/\xc3\xb8/g; # 
    $text =~ s/&\#249;/\xc3\xb9/g; # 
    $text =~ s/&\#250;/\xc3\xba/g; # 
    $text =~ s/&\#251;/\xc3\xbb/g; # 
    $text =~ s/&\#252;/\xc3\xbc/g; # 
    $text =~ s/&\#253;/\xc3\xbd/g; # 
    $text =~ s/&\#254;/\xc3\xbe/g; # 
    $text =~ s/&\#255;/\xc3\xbf/g; # 


# Sgml named entities


# Named sgml entities of the A column of Latin 1

    $text =~ s/&nbsp;/ /g; #        nbsp to space.
    $text =~ s/&iexcl;/\xc2\xa1/g; # 
    $text =~ s/&cent;/\xc2\xa2/g; # 
    $text =~ s/&pound;/\xc2\xa3/g; # 
    $text =~ s/&curren;/\xc2\xa4/g; # 
    $text =~ s/&yen;/\xc2\xa5/g; # 
    $text =~ s/&brvbar;/\xc2\xa6/g; # 
    $text =~ s/&sect;/\xc2\xa7/g; # 

    $text =~ s/&uml;/\xc2\xa8/g; # 
    $text =~ s/&copy;/\xc2\xa9/g; # 
    $text =~ s/&ordf;/\xc2\xaa/g; # 
    $text =~ s/&laquo;/\xc2\xab/g; # 
    $text =~ s/&not;/\xc2\xac/g; # 
    $text =~ s/&shy;/\xc2\xad/g; # 
    $text =~ s/&reg;/\xc2\xae/g; # 
    $text =~ s/&macr;/\xc2\xaf/g; # 

# Named sgml entities of the B column of Latin 1

    $text =~ s/&deg;/\xc4\xb0/g; # 
    $text =~ s/&plusnm;/\xc2\xb1/g; # 
    $text =~ s/&sup2;/\xc2\xb2/g; # 
    $text =~ s/&sup3;/\xc2\xb3/g; # 
    $text =~ s/&acute;/\xc2\xb4/g; # 
    $text =~ s/&micro;/\xc2\xb5/g; # 
    $text =~ s/&para;/\xc2\xb6/g; # 
    $text =~ s/&middot;/\xc2\xb7/g; # 

    $text =~ s/&cedil;/\xc2\xb8/g; # 
    $text =~ s/&sup1;/\xc2\xb9/g; # 
    $text =~ s/&ordm;/\xc2\xba/g; # 
    $text =~ s/&raquo;/\xc2\xbb/g; # 
    $text =~ s/&frac14;/\xc2\xbc/g; # 
    $text =~ s/&frac12;/\xc2\xbd/g; # 
    $text =~ s/&frac34;/\xc2\xbe/g; # 
    $text =~ s/&iquest;/\xc2\xbf/g; # 

# Named sgml entities of the C column of Latin 1

    $text =~ s/&Agrave;/\xc3\x80/g; # À
    $text =~ s/&Aacute;/\xc3\x81/g; # Á
    $text =~ s/&Acirc;/\xc3\x82/g; # 
    $text =~ s/&Atilde;/\xc3\x83/g; # 
    $text =~ s/&Auml;/\xc3\x84/g; # 
    $text =~ s/&Aring;/\xc3\x85/g; # 
    $text =~ s/&AElig;/\xc3\x86/g; # 
    $text =~ s/&Ccedil;/\xc3\x87/g; # 

    $text =~ s/&Egrave;/\xc3\x88/g; # 
    $text =~ s/&Eacute;/\xc3\x89/g; # 
    $text =~ s/&Ecirc;/\xc3\x8a/g; # 
    $text =~ s/&Euml;/\xc3\x8b/g; # 
    $text =~ s/&Igrave;/\xc3\x8c/g; # 
    $text =~ s/&Iacute;/\xc3\x8d/g; # 
    $text =~ s/&Icirc;/\xc3\x8e/g; # 
    $text =~ s/&Iuml;/\xc3\x8f/g; # 

# Named sgml entities of the D column of Latin 1

    $text =~ s/&ETH;/\xc4\x90/g; # Assuming Iclandic doesn't exist :-(
    $text =~ s/&Ntilde;/\xc3\x91/g; # 
    $text =~ s/&Ograve;/\xc3\x92/g; # 
    $text =~ s/&Oacute;/\xc3\x93/g; # 
    $text =~ s/&Ocirc;/\xc3\x94/g; # 
    $text =~ s/&Otilde;/\xc3\x95/g; # 
    $text =~ s/&Ouml;/\xc3\x96/g; # 
    $text =~ s/&times;/\xc3\x97/g; # 

    $text =~ s/&Oslash;/\xc3\x98/g; # 
    $text =~ s/&Ugrave;/\xc3\x99/g; # 
    $text =~ s/&Uacute;/\xc3\x9a/g; # 
    $text =~ s/&Ucirc;/\xc3\x9b/g; # 
    $text =~ s/&Uuml;/\xc3\x9c/g; # 
    $text =~ s/&Yacute;/\xc3\x9d/g; # 
    $text =~ s/&THORN;/\xc3\x9e/g; # 
    $text =~ s/&szlig;/\xc3\x9f/g; # 

# Named sgml entities of the E column of Latin 1

    $text =~ s/&agrave;/\xc3\xa0/g; # 
    $text =~ s/&aacute;/\xc3\xa1/g; # a sharp
    $text =~ s/&acirc;/\xc3\xa2/g; # 
    $text =~ s/&atilde;/\xc3\xa3/g; # 
    $text =~ s/&auml;/\xc3\xa4/g; # 
    $text =~ s/&aring;/\xc3\xa5/g; # 
    $text =~ s/&aelig;/\xc3\xa6/g; # 
    $text =~ s/&ccedil;/\xc3\xa7/g; # 

    $text =~ s/&egrave;/\xc3\xa8/g; # 
    $text =~ s/&eacute;/\xc3\xa9/g; # 
    $text =~ s/&ecirc;/\xc3\xaa/g; # 
    $text =~ s/&euml;/\xc3\xab/g; # 
    $text =~ s/&igrave;/\xc3\xac/g; # 
    $text =~ s/&iacute;/\xc3\xad/g; # 
    $text =~ s/&icirc;/\xc3\xae/g; # 
    $text =~ s/&iuml;/\xc3\xaf/g; # 

# Named sgml entities of the F column of Latin 1

    $text =~ s/&eth;/\xc5\x8b/g; # d1, assuming the Icelandic error again
    $text =~ s/&ntilde;/\xc3\xb1/g; # ñ
    $text =~ s/&ograve;/\xc3\xb2/g; # 
    $text =~ s/&oacute;/\xc3\xb3/g; # 
    $text =~ s/&ocirc;/\xc3\xb4/g; # 
    $text =~ s/&otilde;/\xc3\xb5/g; # 
    $text =~ s/&ouml;/\xc3\xb6/g; # 
    $text =~ s/&divide;/\xc3\xb7/g; # 

    $text =~ s/&oslash;/\xc3\xb8/g; # 
    $text =~ s/&ugrave;/\xc3\xb9/g; # 
    $text =~ s/&uacute;/\xc3\xba/g; # 
    $text =~ s/&ucirc;/\xc3\xbb/g; # 
    $text =~ s/&uuml;/\xc3\xbc/g; # 
    $text =~ s/&yacute;/\xc3\xbd/g; # 
    $text =~ s/&thorn;/\xc3\xbe/g; # 
    $text =~ s/&yuml;/\xc3\xbf/g; # 

# Named entities from ASCII

    $text =~ s/&amp;/\x26/g; # 
    $text =~ s/&lt;/\x3c/g; # 
    $text =~ s/&gt;/\x3e/g; # 
    $text =~ s/&quot;/\x22/g; # 

# Decimal sgml entities of the 6 x 2 Sámi letters

    $text =~ s/&\#353;/\xc5\xa1/g;   # s caron
    $text =~ s/&\#359;/\xc5\xa7/g;   # t stroke
    $text =~ s/&\#331;/\xc5\x8b/g;   # eng
    $text =~ s/&\#273;/\xc4\x91/g;   # d stroke
    $text =~ s/&\#382;/\xc5\xbe/g;   # z caron
    $text =~ s/&\#269;/\xc4\x8d/g;   # c caron

    $text =~ s/&\#352;/\xc5\xa0/g;   # S caron
    $text =~ s/&\#358;/\xc5\xa6/g;   # T stroke
    $text =~ s/&\#330;/\xc5\x8a/g;   # ENG
    $text =~ s/&\#272;/\xc4\x90/g;   # D stroke
    $text =~ s/&\#381;/\xc5\xbd/g;   # Z caron
    $text =~ s/&\#268;/\xc4\x8c/g;   # C caron



# Hex notation of the Sámi letters

    $text =~ s/&\#x0161;/\xc5\xa1/g;   # s caron
    $text =~ s/&\#x0167;/\xc5\xa7/g;   # t stroke
    $text =~ s/&\#x014b;/\xc5\x8b/g;   # eng
    $text =~ s/&\#x0111;/\xc4\x91/g;   # d stroke
    $text =~ s/&\#x017e;/\xc5\xbe/g;   # z caron
    $text =~ s/&\#x010d;/\xc4\x8d/g;   # c caron

    $text =~ s/&\#x0160;/\xc5\xa0/g;   # S caron
    $text =~ s/&\#x0166;/\xc5\xa6/g;   # T stroke
    $text =~ s/&\#x014a;/\xc5\x8a/g;   # ENG
    $text =~ s/&\#x0110;/\xc4\x90/g;   # D stroke
    $text =~ s/&\#x017d;/\xc5\xbd/g;   # Z caron
    $text =~ s/&\#x010c;/\xc4\x8c/g;   # C caron

# hex notation of the Sámi letters, capital A-F

    $text =~ s/&\#x014B;/\xc5\x8b/g;   # eng
    $text =~ s/&\#x017E;/\xc5\xbe/g;   # z caron
    $text =~ s/&\#x010D;/\xc4\x8d/g;   # c caron

    $text =~ s/&\#x014A;/\xc5\x8a/g;   # ENG
    $text =~ s/&\#x017D;/\xc5\xbd/g;   # Z caron
    $text =~ s/&\#x010D;/\xc4\x8c/g;   # C caron


# Hex notation of the Sámi letters, no initial 0

    $text =~ s/&\#x161;/\xc5\xa1/g;   # s caron
    $text =~ s/&\#x167;/\xc5\xa7/g;   # t stroke
    $text =~ s/&\#x14b;/\xc5\x8b/g;   # eng
    $text =~ s/&\#x111;/\xc4\x91/g;   # d stroke
    $text =~ s/&\#x17e;/\xc5\xbe/g;   # z caron
    $text =~ s/&\#x10d;/\xc4\x8d/g;   # c caron

    $text =~ s/&\#x160;/\xc5\xa0/g;   # S caron
    $text =~ s/&\#x166;/\xc5\xa6/g;   # T stroke
    $text =~ s/&\#x14a;/\xc5\x8a/g;   # ENG
    $text =~ s/&\#x110;/\xc4\x90/g;   # D stroke
    $text =~ s/&\#x17d;/\xc5\xbd/g;   # Z caron
    $text =~ s/&\#x10c;/\xc4\x8c/g;   # C caron

# hex notation of the Sámi letters, capital A-F

    $text =~ s/&\#x14B;/\xc5\x8b/g;   # eng
    $text =~ s/&\#x17E;/\xc5\xbe/g;   # z caron
    $text =~ s/&\#x10D;/\xc4\x8d/g;   # c caron

    $text =~ s/&\#x14A;/\xc5\x8a/g;   # ENG
    $text =~ s/&\#x17D;/\xc5\xbd/g;   # Z caron
    $text =~ s/&\#x10D;/\xc4\x8c/g;   # C caron

    return $text;

}

#
# This converts html entities that belong to WS2 and ISO-197-IR
# to utf-8
#
sub html_entities_to_utf8 {
    my ($text) = @_;

    # Then WS2 ones, decimal notation

    $text =~ s/&\#154;/\xc5\xa1/g;   # s caron
    $text =~ s/&\#188;/\xc5\xa7/g;   # t stroke
    $text =~ s/&\#185;/\xc5\x8b/g;   # eng
    $text =~ s/&\#152;/\xc4\x91/g;   # d stroke
    $text =~ s/&\#191;/\xc5\xbe/g;   # z caron
    $text =~ s/&\#132;/\xc4\x8d/g;   # c caron


    $text =~ s/&\#138;/\xc5\xa0/g;   # S caron
    $text =~ s/&\#186;/\xc5\xa6/g;   # T stroke
    $text =~ s/&\#184;/\xc5\x8a/g;   # ENG
    $text =~ s/&\#137;/\xc4\x90/g;   # D stroke
    $text =~ s/&\#190;/\xc5\xbd/g;   # Z caron
    $text =~ s/&\#130;/\xc4\x8c/g;   # C caron

    $text =~ s/&\#248;/c3xb8/g;         # oslash
    $text =~ s/&\#216;/xc3x98/g;        # Oslash
    $text =~ s/&\#197;/xc3x85/g;	# Aring
    $text =~ s/&\#229;/xc3xa5/g;        # a ring
    $text =~ s/&\#228;/xc3xa4/g;	# adiaeresis
    $text =~ s/&\#196;/xc3x84/g;	# Adiaeresis
    $text =~ s/&\#239;/xc3xa6/g;	# aelig
    $text =~ s/&\#198;/xc3x86/g;	# AElig

    # Then ISO-197-IR, I'm a bit confused, but at least if fixes
    # Regnor Jernslettens doc's at www.uit.no/ssweb/dok/
#    $text =~ s/&\#154;/"~"/g;   # s caron
#    $text =~ s/&\#184;/"~"/g;   # t stroke
#    $text =~ s/&\#177;/"~"/g;   # eng
    $text =~ s/&\#240;/\xc4\x91/g;   # d stroke
#    $text =~ s/&\#186;/"~"/g;   # z caron
#    $text =~ s/&\#162;/"~"/g;   # c caron


#    $text =~ s/&\#178;/"~"/g;   # S caron
#    $text =~ s/&\#181;/"~"/g;   # T stroke
#    $text =~ s/&\#175;/"~"/g;   # ENG
#    $text =~ s/&\#163;/"~"/g;   # D stroke
#    $text =~ s/&\#185;/"~"/g;   # Z caron
#    $text =~ s/&\#161;/"~"/g;   # C caron


    return $text;
}


#
# This one converts from utf-8 
# to the format in the sme database
#
sub utf8_to_7bit {
    my ($text) = @_;


    $text =~ s/\xc3\xa1/á/g; # a sharp
    $text =~ s/\xc5\xa1/s1/g;   # s caron
    $text =~ s/\xc5\xa7/t1/g;   # t stroke
    $text =~ s/\xc5\x8b/n1/g;   # eng
    $text =~ s/\xc4\x91/d1/g;   # d stroke
    $text =~ s/\xc5\xbe/z1/g;   # z caron
    $text =~ s/\xc4\x8d/c1/g;   # c caron

    $text =~ s/\xC3\x81/Á/g; # A sharp
    $text =~ s/\xC5\xA0/S1/g; # S caron
    $text =~ s/\xC5\xA6/T1/g; # T stroke
    $text =~ s/\xC5\x8A/N1/g; # ENG
    $text =~ s/\xC4\x90/D1/g; # D stroke
    $text =~ s/\xC5\xBD/Z1/g; # Z caron
    $text =~ s/\xC4\x8C/C1/g; # C caron

    $text =~ s/\302\240/\240/g ;   # xA0
    $text =~ s/\302\241/¡/g ;      # xA1
    $text =~ s/\302\242/¢/g ;      # xA2
    $text =~ s/\302\243/£/g ;      # xA3
    $text =~ s/\302\244/\244/g ;   # xA4
    $text =~ s/\302\245/¥/g ;      # xA5
    $text =~ s/\302\246/\246/g ;   # xA6
    $text =~ s/\302\247/§/g ;      # xA7

    $text =~ s/\302\250/¨/g ;      # xA8
    $text =~ s/\302\251/©/g ;      # xA9
    $text =~ s/\302\252/\252/g ;      # xAA
    $text =~ s/\302\253/\253/g ;      # xAB
    $text =~ s/\302\254/\254/g ;      # xAC
    $text =~ s/\302\255/\255/g ;      # xAD
    $text =~ s/\302\256/\256/g ;      # xAE
    $text =~ s/\302\257/\257/g ;      # xAF

# Column B

    $text =~ s/\302\260/\260/g ;      # xB0
    $text =~ s/\302\261/\261/g ;      # xB1
    $text =~ s/\302\262/\262/g ;      # xB2
    $text =~ s/\302\263/\263/g ;      # xB3
    $text =~ s/\302\264/\264/g ;      # xB4
    $text =~ s/\302\265/\265/g ;      # xB5
    $text =~ s/\302\266/\266/g ;      # xB6
    $text =~ s/\302\267/\267/g ;      # xB7

    $text =~ s/\302\270/\270/g ;      # xB8
    $text =~ s/\302\271/\271/g ;      # xB9
    $text =~ s/\302\272/\272/g ;      # xBA
    $text =~ s/\302\273/\273/g ;      # xBB
    $text =~ s/\302\274/\274/g ;      # xBC
    $text =~ s/\302\275/\275/g ;      # xBD
    $text =~ s/\302\276/\276/g ;      # xBE
    $text =~ s/\302\277/\277/g ;      # xBF

# Column C

    $text =~ s/\303\200/À/g ;
    $text =~ s/\303\201/Á/g ;    
    $text =~ s/\303\202/Â/g ;
    $text =~ s/\303\203/Ã/g ;
    $text =~ s/\303\204/Ä/g ;
    $text =~ s/\303\205/Å/g ;
    $text =~ s/\303\206/Æ/g ;
    $text =~ s/\303\207/C/g ;

    $text =~ s/\303\210/È/g ;
    $text =~ s/\303\211/É/g ;
    $text =~ s/\303\212/Ê/g ;
    $text =~ s/\303\213/Ë/g ;
    $text =~ s/\303\214/Ì/g ;
    $text =~ s/\303\215/Í/g ;
    $text =~ s/\303\216/Î/g ;
    $text =~ s/\303\217/Ï/g ;

    $text =~ s/\303\220/Ð/g ;
    $text =~ s/\303\221/Ñ/g ;
    $text =~ s/\303\222/Ò/g ;
    $text =~ s/\303\223/Ó/g ;
    $text =~ s/\303\224/Ô/g ;
    $text =~ s/\303\225/Õ/g ;
    $text =~ s/\303\226/Ö/g ;
    $text =~ s/\303\227/x/g ;

    $text =~ s/\303\230/Ø/g ;
    $text =~ s/\303\231/Ù/g ;
    $text =~ s/\303\232/Ú/g ;
    $text =~ s/\303\233/Û/g ;
    $text =~ s/\303\234/Ü/g ;
    $text =~ s/\303\235/Ý/g ;
    $text =~ s/\303\236/Þ/g ;
    $text =~ s/\303\237/ß/g ;

# Column E

    $text =~ s/\303\240/à/g ;
    $text =~ s/\303\241/á/g ;
    $text =~ s/\303\242/â/g ;
    $text =~ s/\303\243/ã/g ;
    $text =~ s/\303\244/ä/g ;
    $text =~ s/\303\245/å/g ;
    $text =~ s/\303\246/æ/g ;
    $text =~ s/\303\247/c/g ;

    $text =~ s/\303\250/è/g ;
    $text =~ s/\303\251/é/g ;
    $text =~ s/\303\252/ê/g ;
    $text =~ s/\303\253/ë/g ;
    $text =~ s/\303\254/ì/g ;
    $text =~ s/\303\255/í/g ;
    $text =~ s/\303\256/î/g ;
    $text =~ s/\303\257/ï/g ;

# Column F

    $text =~ s/\303\260/ð/g ;
    $text =~ s/\303\261/ñ/g ;
    $text =~ s/\303\262/ò/g ;
    $text =~ s/\303\263/ó/g ;
    $text =~ s/\303\264/ô/g ;
    $text =~ s/\303\265/õ/g ;
    $text =~ s/\303\266/ö/g ;
    $text =~ s/\303\267/-/g ;

    $text =~ s/\303\270/ø/g ;
    $text =~ s/\303\271/ù/g ;
    $text =~ s/\303\272/ú/g ;
    $text =~ s/\303\273/û/g ;
    $text =~ s/\303\274/ü/g ;
    $text =~ s/\303\275/ý/g ;
    $text =~ s/\303\276/þ/g ;
    $text =~ s/\303\277/ÿ/g ;

    return $text;
}

sub ws2_to_utf8 {
    my ($text) = @_;

    # Then WS2 ones, decimal notation
    $text =~ s/Âš/\xc5\xa1/g;   # s caron
    $text =~ s/Â¼/\xc5\xa7/g;   # t stroke
    $text =~ s/Â¹/\xc5\x8b/g;   # eng
    $text =~ s/Â˜/\xc4\x91/g;   # d stroke
    $text =~ s/Â¿/\xc5\xbe/g;   # z caron
    $text =~ s/Â„/\xc4\x8d/g;   # c caron


    $text =~ s/Âš/\xC5\xA1/g;   # S caron
    $text =~ s/Â¼/\xC5\xA7/g;   # T stroke
    $text =~ s/Â¸/\xC5\x8B/g;   # ENG
    $text =~ s/Â‰/\xC4\x91/g;   # D stroke
    $text =~ s/Â¾/\xC5\xBE/g;   # Z caron
    $text =~ s/Â‚/\xC4\x8D/g;   # C caron

    return $text;
}


sub latin9_to_utf8 {
  my ($text) = @_;

  #  ISO-197-IR
  $text =~ s/\xB3/\xc5\xa1/g;   # s caron
  $text =~ s/\xB8/\xc5\xa7/g;   # t stroke
  $text =~ s/\xB1/\xc5\x8b/g;   # eng
  $text =~ s/\xA4/\xc4\x91/g;   # d stroke
  $text =~ s/\xBA/\xc5\xbe/g;   # z caron
  $text =~ s/\xA2/\xc4\x8d/g;   # c caron


  $text =~ s/\xB2/\xC5\x81/g;   # S caron
  $text =~ s/\xB5/\xC5\xA6/g;   # T stroke
  $text =~ s/\xAF/\xC5\x8a/g;   # ENG
  $text =~ s/\xA3/\xC4\x90/g;   # D stroke
  $text =~ s/\xB9/\xC5\xBd/g;   # Z caron
  $text =~ s/\xA1/\xC4\x8c/g;   # C caron

  return $text;

}

#
# This removes garbage, and does the last conversions before 
# the result is representable for tokenize and lookup
# Most of this garbage is punctuation marks, and thus kept.
# This section should be removed in a stable version of the script.


sub remove_garbage {
    my ($text) = @_;
#    $text =~ s/<[^>]*>//g;
#    $text =~ s/&nbsp\;/ /g;
#    $text =~ s/&copy\;//g;
#    $text =~ s/&aacute\;/\xe1/g;
#    $text =~ s/&eth\;/\xc4\x91/g;
#    $text =~ s/-\n//g;
#    $text =~ s/\n/ /g;
#    $text =~ s/-/\n/g;
#    $text =~ s/\)//g;
#    $text =~ s/\(//g;
#    $text =~ s/\///g;
#    $text =~ s/\?//g;
#    $text =~ s/%//g;
#    $text =~ s///g;
#    $text =~ s/\.\.//g;
#    $text =~ s/\d//g;
#    $text =~ s/\[//g;
#    $text =~ s/\]//g;
    $text =~ s/&lt/</g;
    $text =~ s/&gt/>/g;
#    $text =~ s/\'//g;
#    $text =~ s/\`//g;
#    $text =~ s/\;//g;
#    $text =~ s/&\#//g;
#    $text =~ s/://g;
#    $text =~ s/\;//g;
#    $text =~ s/\.//g;
#    $text =~ s/\,//g;
    $text =~ s/\xa0//g;
#    $text =~ s/^\s*(.*?)\s*$/$1/g;
    return $text;
}

sub map_words {
    my ($text) = @_;
    my $word;
    my $newword;
    my @words = split ' ', $text;

 return (join(" ", @words));
#    return lc(join(" ", @words));
#    foreach $word (@words) {
#	$word =~ s/^\s*(.*?)\s*$/$1/;
#	($newword = $word) =~ s/^\s+|\s+$//g;
#	print lc("$newword\n");
#    }
}
