#!/usr/bin/perl -w

# Perl script to change from eXist 1.1 to eXist 1.2
while (<>) {
    if ( m/xi\:include/ ) {
        s/xml\#xpointer/xml\" xpointer=\"xpointer/g ;
    }
    print ;
}
