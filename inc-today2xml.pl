#!/usr/bin/perl -w

# -----------------------------------------------------------------------------
#
# perl-info
# version     : Version $Id$
# author      : Børre Gaup <borre.gaup@uit.no>
# license     : GPL
# description : 'emerge --info' for perl
#
# -----------------------------------------------------------------------------
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# -----------------------------------------------------------------------------

use utf8;
use strict;
use XML::Twig;


&process_commandline;
&add_changes_to_xmlfile;

sub process_commandline {

    if ($#ARGV != 1) {
        print "usage: inc-today2xml.pl <mainlangfile> <translatedlangfile>\n";
        exit;
    }

    # check if the files have the same number of lines, else die
    my $command = "wc -l ";

    my @length_file1 = split(/ /, `$command  $ARGV[0]`);
    my @length_file2 = split(/ /, `$command  $ARGV[1]`);

    if ( $length_file1[0] ne $length_file2[0] ) {
        print "Error: files don't have equally many lines.\n";
        print "Fix that, and then try this script again\n";
        exit;
    }
}

# Make an xml file from the to input files

sub add_changes_to_xmlfile {
    open (MAIN_LANG_FILE, $ARGV[0]) or die "Can't open $ARGV[0]";
    open (TRANSLATION_LANG_FILE, $ARGV[1]) or die "Can't open $ARGV[1]";


    my $xmldoc = XML::Twig->new( pretty_print => 'indented' );

    $xmldoc->parsefile('smenob.xml');

    my $root = $xmldoc->root;

    my $line1 = "";
    my $line2 = "";

    # Process all the lines in both files
    # Since both files have the same amount of lines, check only
    # if the first file has any more lines
    while ($line1 = <MAIN_LANG_FILE>) {
        # Make an entry, place at the end of the file
        my $e = new XML::Twig::Elt('e');
        $e->paste('last_child', $root);

        # The mainlangfile has only one word and one pos per line
        chomp($line1);
        my @parts = split(/\t/, $line1);

        # Make a lemma group
        my $lg = new XML::Twig::Elt('lg');
        $lg->paste('last_child', $e);

        # Make a lemma, set text and attribute
        my $l = new XML::Twig::Elt('l', $parts[0]);
        $l->set_att(pos => $parts[1]);
        $l->paste('last_child', $lg);

        # Make an empty lemma comment
        my $lc = new XML::Twig::Elt('lc');
        $lc->paste('last_child', $lg);

        # The translatedlangfile can have many translation groups
        # separated by |
        $line2 = <TRANSLATION_LANG_FILE>;
        chomp($line2);
        my @meaningsgroups = split('\|', $line2);

        # Go through each meaningsgroup and add them to the entry
        foreach my $meaningsgroup (@meaningsgroups) {
            my $mg = new XML::Twig::Elt('mg');
            $mg->paste('last_child', $e);

            my $tg = new XML::Twig::Elt('tg');
            $tg->paste('last_child', $mg);

            @parts = split(/\t/, $meaningsgroup);

            my $translation = "";
            my $translationcomment = "";

            # The meaning is the first part of the subpart
            # The meaning can consist of a translation and a comment, split by (
            my @meaningparts = split(/\(/, $parts[0]);
            $translation = $meaningparts[0];
            if (@meaningparts > 1) {
                $translationcomment = $meaningparts[1];
            }

            my $pos = "";
            if ( @parts > 1 ) {
                $pos = $parts[1];
            }

            my $t = new XML::Twig::Elt('t', $translation);
            $t->set_att(pos => $pos);
            $t->paste('last_child', $tg);

            my $xg = new XML::Twig::Elt('xg');
            $xg->paste('last_child', $tg);

            my $x = new XML::Twig::Elt('x', $translationcomment);
            $x->paste('last_child', $xg);
        }
    }

    # Take a backup of the current smenob.xml, and print the twig to smenob.xml
    `mv smenob.xml smenob.xml.backup`;
    open (TEMPORARY_XML_FILE, ">smenob.xml");

    $xmldoc->print( \*TEMPORARY_XML_FILE);
    close TEMPORARY_XML_FILE;
    close MAIN_LANG_FILE;
    close TRANSLATION_LANG_FILE;
}
