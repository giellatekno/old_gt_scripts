#!/usr/bin/perl -w
# This script takes a html document as input. It then takes all entities
# at least the s�i ones and converts them to utf8 letters.
# After that we can take away all the garbage that's in html files,
# and finally convert it to 7bit…

use strict;


# use HTML::TreeBuilder;
# my $tree = HTML::TreeBuilder->new->parse_file($ARGV[0]);


# use HTML::FormatText;

# my $formatter = "";
# $formatter = HTML::FormatText->new(leftmargin => 0, rightmargin => 50);




my $result = html_entities_to_utf8(`striphtml.py $ARGV[0]`);
#$result = ws2_to_7bit($result);
#$result = latin9_to_7bit($result);
$result = remove_garbage($result);
$result = utf8_to_7bit($result);

print $result;

sub html_entities_to_utf8 {
    my ($text) = @_;

    # First unicode ones

    # This takes care of decimal notation
    $text =~ s/&\#225;/á/g; # a sharp
    $text =~ s/&\#353;/š/g;   # s caron
    $text =~ s/&\#359;/ŧ/g;   # t stroke
    $text =~ s/&\#331;/ŋ/g;   # eng
    $text =~ s/&\#273;/đ/g;   # d stroke
    $text =~ s/&\#382;/ž/g;   # z caron
    $text =~ s/&\#269;/č/g;   # c caron

    $text =~ s/&\#193;/á/g; # A sharp
    $text =~ s/&\#352;/š/g;   # S caron
    $text =~ s/&\#358;/ŧ/g;   # T stroke
    $text =~ s/&\#330;/ŋ/g;   # ENG
    $text =~ s/&\#272;/đ/g;   # D stroke
    $text =~ s/&\#381;/ž/g;   # Z caron
    $text =~ s/&\#268;/č/g;   # C caron

    # This takes care of hexadecimal notation
    $text =~ s/&\#x00e1;/á/g; # a sharp
    $text =~ s/&\#x0161;/š/g;   # s caron
    $text =~ s/&\#x0167;/ŧ/g;   # t stroke
    $text =~ s/&\#x014b;/ŋ/g;   # eng
    $text =~ s/&\#x0111;/đ/g;   # d stroke
    $text =~ s/&\#x017e;/ž/g;   # z caron
    $text =~ s/&\#x010d;/č/g;   # c caron

    $text =~ s/&\#x0193;/á/g; # A sharp
    $text =~ s/&\#x0160;/š/g;   # S caron
    $text =~ s/&\#x0166;/ŧ/g;   # T stroke
    $text =~ s/&\#x014a;/ŋ/g;   # ENG
    $text =~ s/&\#x0110;/đ/g;   # D stroke
    $text =~ s/&\#x017d;/ž/g;   # Z caron
    $text =~ s/&\#x010c;/č/g;   # C caron

    # Then WS2 ones, decimal notation
    $text =~ s/&\#154;/š/g;   # s caron
    $text =~ s/&\#188;/ŧ/g;   # t stroke
    $text =~ s/&\#185;/ŋ/g;   # eng
    $text =~ s/&\#152;/đ/g;   # d stroke
    $text =~ s/&\#191;/ž/g;   # z caron
    $text =~ s/&\#132;/č/g;   # c caron


    $text =~ s/&\#138;/š/g;   # S caron
    $text =~ s/&\#186;/ŧ/g;   # T stroke
    $text =~ s/&\#184;/ŋ/g;   # ENG
    $text =~ s/&\#137;/đ/g;   # D stroke
    $text =~ s/&\#190;/ž/g;   # Z caron
    $text =~ s/&\#130;/č/g;   # C caron

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
    $text =~ s/&\#240;/đ/g;   # d stroke
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

sub utf8_to_7bit {
    my ($text) = @_;


    $text =~ s/\á/\341/g; # a sharp
    $text =~ s/š/s1/g;   # s caron
    $text =~ s/ŧ/t1/g;   # t stroke
    $text =~ s/ŋ/n1/g;   # eng
    $text =~ s/đ/d1/g;   # d stroke
    $text =~ s/ž/z1/g;   # z caron
    $text =~ s/č/c1/g;   # c caron
    $text =~ s/Á/\341/g; # A sharp
    $text =~ s/Š/s1/g; # S caron
    $text =~ s/Ŧ/t1/g; # T stroke
    $text =~ s/Ŋ/n1/g; # ENG
    $text =~ s/Đ/d1/g; # D stroke
    $text =~ s/Ž/z1/g; # Z caron
    $text =~ s/Č/c1/g; # C caron


    return $text;
}


# sub ws2_to_7bit {
#     my ($text) = @_;
# 
#     # Then WS2 ones, decimal notation
#     $text =~ s/\x9A/"~"/g;   # s caron
#     $text =~ s/\xBC/"~"/g;   # t stroke
#     $text =~ s/\xB9/"~"/g;   # eng
#     $text =~ s/\x98/"~"/g;   # d stroke
#     $text =~ s/\xBF/"~"/g;   # z caron
#     $text =~ s/\x84/"~"/g;   # c caron
# 
# 
#     $text =~ s/\x8A/"~"/g;   # S caron
#     $text =~ s/\xBA/"~"/g;   # T stroke
#     $text =~ s/\xB8/"~"/g;   # ENG
#     $text =~ s/\x89/"~"/g;   # D stroke
#     $text =~ s/\xBE/"~"/g;   # Z caron
#     $text =~ s/\x82/"~"/g;   # C caron
# 
#     return $text;
# }
# 
# sub latin9_to_7bit {
#     my ($text) = @_;
# 
#     # ISO-197-IR
#     $text =~ s/\xB3/"~"/g;   # s caron
#     $text =~ s/\xB8/"~"/g;   # t stroke
#     $text =~ s/\xB1/"~"/g;   # eng
#     $text =~ s/\xA4/"~"/g;   # d stroke
#     $text =~ s/\xBA/"~"/g;   # z caron
#     $text =~ s/\xA2/"~"/g;   # c caron
# 
# 
#     $text =~ s/\xB2/"~"/g;   # S caron
#     $text =~ s/\xB5/"~"/g;   # T stroke
#     $text =~ s/\xAF/"~"/g;   # ENG
#     $text =~ s/\xA3/"~"/g;   # D stroke
#     $text =~ s/\xB9/"~"/g;   # Z caron
#     $text =~ s/\xA1/"~"/g;   # C caron
# 
#     return $text;
# }


sub remove_garbage {
    my ($text) = @_;

    $text =~ s/&nbsp\;//g;
    $text =~ s/&copy\;//g;
    $text =~ s/&aacute\;/\xe1/g;
    $text =~ s/&eth\;/ETHHHH/g;
    $text =~ s/-\n//g;
    $text =~ s/ /\n/g;
    $text =~ s/-/\n/g;
    $text =~ s/\)//g;
    $text =~ s/\(//g;
    $text =~ s/\///g;
    $text =~ s/\?//g;
    $text =~ s/%//g;
    $text =~ s///g;
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
    #$text =~ s///g;



    return $text;
}
