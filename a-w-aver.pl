#!/usr/bin/perl -w

# Script thet estimates analyses per word

$words = 0 ;
$count = 0 ;
$total = 0 ;

while (<STDIN>) {
    if (/^\s*$/) {
	$words += 1 ;
	$total += $count ;
	$count = 0 ;
    } else {
	$count++ ;
    }
}

print "Average solutions / word: ", $total/$words, "\n" ;
