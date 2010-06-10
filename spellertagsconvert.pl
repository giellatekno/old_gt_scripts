#!/usr/bin/perl -w

use strict;
use utf8;


while (<>) {
	s/\+SgCmp/\+CmpN\/Sg/g;
	s/\+SgNomCmp/\+CmpN\/SgN/g;
	s/\+SgGenCmp/\+CmpN\/SgG/g;
	s/\+PlGenCmp/\+CmpN\/PlG/g;

	s/\+First/\+CmpN\/First/g;
	s/\+Last/\+CmpN\/Last/g;
	s/\+None/\+CmpN\/None/g;
	s/\+CmpOnly/\+CmpN\/Only/g;
	s/\+SgLeft/\+CmpN\/SgLeft/g;
	s/\+SgNomLeft/\+CmpN\/SgNomLeft/g;
	s/\+SgGenLeft/\+CmpN\/SgGenLeft/g;
	s/\+PlGenLeft/\+CmpN\/PlGenLeft/g;
	s/\+AllCmp/\+CmpN\/All/g;
	s/\+DefCmp/\+CmpN\/Def/g;
	s/\+DefSgGenCmp/\+CmpN\/DefSgGen/g;
	s/\+DefPlGenCmp/\+CmpN\/DefPlGen/g;

	print;
}