#!/usr/bin/perl -w

# Perl script to change from eXist 1.2 to eXist 1.1
while (<>) {
    if ( m/xi\:include/ ) {
        s/\" xpointer=\"/\#/g ;
    }
    print ;
}

