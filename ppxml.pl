#!/usr/bin/perl -w

# Code taken from/based on:
#
# http://snippets.dzone.com/posts/show/929
#
# Requires a patch to XML::Twig, available at:
#
# http://rt.cpan.org/Public/Bug/Display.html?id=24954
# (download button at the bottom)

### begin_: file metadata
    ### <region-file_info>
    ### main:
    ###   - name    : XMLPrettyPrint: simple xml pretty print in perl
    ###     desc    : use perl with XML::Twig library to print indented xml
    ###     date    : created="Thu 2005-12-01 11:08:15"
    ###     last    : lastmod="Thu 2005-12-01 11:22:34"
    ###     lang    : perl
    ###     tags    : perl xml indent formatted pretty string cfPrettyPrint
    ### </region-file_info>

### begin_: init perl
    use strict;
    use warnings;
    use XML::Twig;

### begin_: init vars
    my  $sXML  = join "", (<>);
#    print "sXML = \n" . $sXML;

### init params
    my  $sPrettyFormat  = 'cvs';
#    print "sPrettyFormat = \n" . $sPrettyFormat . "\n";

### begin_: process
    my  $twig= new XML::Twig;
    $twig->set_indent(" "x4);
    $twig->parse( $sXML );
    $twig->set_pretty_print( $sPrettyFormat );
    $sXML      = $twig->sprint;

### begin_: output
    print $sXML;
