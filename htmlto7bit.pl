#!/usr/bin/perl -w
# This script takes a html document as input. It then takes all entities
# at least the si ones and converts them to utf8 letters.
# After that we can take away all the garbage that's in html files,
# and finally convert it to 7bit…

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
#print $result;
print map_words($result);



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
	print "hola  ... $first, $last\t$cset \n";
    } else { print "ingen charset\n";
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

    $text =~ s/\xe1/\xc3\xa1/g;       # A sharp
    $text =~ s/\232/\xc5\xa1/g;   # s caron
    $text =~ s/\236/\xc5\xbe/g;   # z caron


    $text =~ s/\xc1/\xC3\xA1/g;       # A sharp
    $text =~ s/\212/\xc5\xa1/g;   # S caron
    $text =~ s/\216/\xc5\xbe/g;   # Z caron

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
sub unicode_ent_to_utf8
{
    my ($text) = @_;
    # First unicode ones

    # This takes care of decimal notation
    $text =~ s/&\#225;/\xc3\xa1/g; # a sharp
    $text =~ s/&\#353;/\xc5\xa1/g;   # s caron
    $text =~ s/&\#359;/\xc5\xa7/g;   # t stroke
    $text =~ s/&\#331;/\xc5\x8b/g;   # eng
    $text =~ s/&\#273;/\xc4\x91/g;   # d stroke
    $text =~ s/&\#382;/\xc5\xbe/g;   # z caron
    $text =~ s/&\#269;/\xc4\x8d/g;   # c caron

    $text =~ s/&\#193;/\xc3\xa1/g; # A sharp
    $text =~ s/&\#352;/\xc5\xa1/g;   # S caron
    $text =~ s/&\#358;/\xc5\xa7/g;   # T stroke
    $text =~ s/&\#330;/\xc5\x8b/g;   # ENG
    $text =~ s/&\#272;/\xc4\x91/g;   # D stroke
    $text =~ s/&\#381;/\xc5\xbe/g;   # Z caron
    $text =~ s/&\#268;/\xc4\x8d/g;   # C caron

    # This takes care of hexadecimal notation
    $text =~ s/&\#x00e1;/\xc3\xa1/g; # a sharp
    $text =~ s/&\#x0161;/\xc5\xa1/g;   # s caron
    $text =~ s/&\#x0167;/\xc5\xa7/g;   # t stroke
    $text =~ s/&\#x014b;/\xc5\x8b/g;   # eng
    $text =~ s/&\#x0111;/\xc4\x91/g;   # d stroke
    $text =~ s/&\#x017e;/\xc5\xbe/g;   # z caron
    $text =~ s/&\#x010d;/\xc4\x8d/g;   # c caron

    $text =~ s/&\#x0193;/\xc3\xa1/g; # A sharp
    $text =~ s/&\#x0160;/\xc5\xa1/g;   # S caron
    $text =~ s/&\#x0166;/\xc5\xa7/g;   # T stroke
    $text =~ s/&\#x014a;/\xc5\x8b/g;   # ENG
    $text =~ s/&\#x0110;/\xc4\x91/g;   # D stroke
    $text =~ s/&\#x017d;/\xc5\xbe/g;   # Z caron
    $text =~ s/&\#x010c;/\xc4\x8d/g;   # C caron

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


    $text =~ s/&\#138;/\xc5\xa1/g;   # S caron
    $text =~ s/&\#186;/\xc5\xa7/g;   # T stroke
    $text =~ s/&\#184;/\xc5\x8b/g;   # ENG
    $text =~ s/&\#137;/\xc4\x91/g;   # D stroke
    $text =~ s/&\#190;/\xc5\xbe/g;   # Z caron
    $text =~ s/&\#130;/\xc4\x8d/g;   # C caron

    $text =~ s/&\#248;/ø/g;   # oslash
    $text =~ s/&\#216;/ø/g;   # Oslash
    $text =~ s/&\#197;/Å/g;	# Aring
    $text =~ s/&\#229;/å/g;   # a ring
    $text =~ s/&\#228;/ä/g;	# adiaeresis
    $text =~ s/&\#196;/Ä/g;	# Adiaeresis

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


    $text =~ s/\xc3\xa1/\341/g; # a sharp
    $text =~ s/\xc5\xa1/s1/g;   # s caron
    $text =~ s/\xc5\xa7/t1/g;   # t stroke
    $text =~ s/\xc5\x8b/n1/g;   # eng
    $text =~ s/\xc4\x91/d1/g;   # d stroke
    $text =~ s/\xc5\xbe/z1/g;   # z caron
    $text =~ s/\xc4\x8d/c1/g;   # c caron
    $text =~ s/\xC3\xA1/\341/g; # A sharp
    $text =~ s/\xC5\xA1/s1/g; # S caron
    $text =~ s/\xC5\xA7/t1/g; # T stroke
    $text =~ s/\xC5\x8B/n1/g; # ENG
    $text =~ s/\xC4\x91/d1/g; # D stroke
    $text =~ s/\xC5\xBE/z1/g; # Z caron
    $text =~ s/\xC4\x8D/c1/g; # C caron


    return $text;
}

sub ws2_to_utf8 {
    my ($text) = @_;

    # Then WS2 ones, decimal notation
    $text =~ s//\xc5\xa1/g;   # s caron
    $text =~ s/¼/\xc5\xa7/g;   # t stroke
    $text =~ s/¹/\xc5\x8b/g;   # eng
    $text =~ s//\xc4\x91/g;   # d stroke
    $text =~ s/¿/\xc5\xbe/g;   # z caron
    $text =~ s//\xc4\x8d/g;   # c caron


    $text =~ s//\xC5\xA1/g;   # S caron
    $text =~ s/¼/\xC5\xA7/g;   # T stroke
    $text =~ s/¸/\xC5\x8B/g;   # ENG
    $text =~ s//\xC4\x91/g;   # D stroke
    $text =~ s/¾/\xC5\xBE/g;   # Z caron
    $text =~ s//\xC4\x8D/g;   # C caron

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


  $text =~ s/\xB2/\xC5\xA1/g;   # S caron
  $text =~ s/\xB5/\xC5\xA7/g;   # T stroke
  $text =~ s/\xAF/\xC5\x8B/g;   # ENG
  $text =~ s/\xA3/\xC4\x91/g;   # D stroke
  $text =~ s/\xB9/\xC5\xBE/g;   # Z caron
  $text =~ s/\xA1/\xC4\x8D/g;   # C caron

  return $text;

}

#
# This removes garbage, and does the last conversions before 
# the result is representable for tokenize and lookup
#
sub remove_garbage {
    my ($text) = @_;
    $text =~ s/<[^>]*>//g;
    $text =~ s/&nbsp\;//g;
    $text =~ s/&copy\;//g;
    $text =~ s/&aacute\;/\xe1/g;
    $text =~ s/&eth\;/\xc4\x91/g;
#    $text =~ s/-\n//g;
#    $text =~ s/\n/ /g;
    $text =~ s/-/\n/g;
    $text =~ s/\)//g;
    $text =~ s/\(//g;
    $text =~ s/\///g;
    $text =~ s/\?//g;
    $text =~ s/%//g;
#   $text =~ s///g;
    $text =~ s/\.\.//g;
    $text =~ s/\d//g;
    $text =~ s/\[//g;
    $text =~ s/\]//g;
    $text =~ s/&lt//g;
    $text =~ s/&gt//g;
    $text =~ s/\'//g;
    $text =~ s/\`//g;
    $text =~ s/\;//g;
    $text =~ s/&\#//g;
    $text =~ s/://g;
    $text =~ s/\;//g;
    $text =~ s/\.//g;
    $text =~ s/\,//g;
    $text =~ s/\xa0//g;
#    $text =~ s/^\s*(.*?)\s*$/$1/g;
    return $text;
}

sub map_words {
    my ($text) = @_;
    my $word;
    my $newword;
    my @words = split ' ', $text;

    return lc(join(" ", @words));
#    foreach $word (@words) {
#	$word =~ s/^\s*(.*?)\s*$/$1/;
#	($newword = $word) =~ s/^\s+|\s+$//g;
#	print lc("$newword\n");
#    }
}
