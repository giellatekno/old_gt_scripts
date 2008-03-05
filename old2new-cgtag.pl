#!/usr/bin/perl -w
#
# old2new-cgtag.pl
# Script to convert old cg tagset to new cg tagset.
# usage:
# cat sme/src/sme-dis.rle | perl script/old2new-cgtag.pl | uniq > sme/dev/test.rle
# cat sme/corp/bigkorpusVISL.txt | grep -v '#' | preprocess  --abbr=sme/bin/abbr.txt | lo | lookup2cg | vislcg3 -g sme/dev/test.rle | l

# cat sme/corp/
#
# $Id


# strict variable definitions
use strict;

# usage of utf8 in the perl-code
use utf8;

# These definitions ensure that the script works 
# also in environments, where PERL_UNICODE is not set.
binmode( STDIN, ':utf8' );
binmode( STDOUT, ':utf8' );
binmode( STDERR, ':utf8' );
use open 'utf8';

while (<>) {

s/\@<GQ/\@<Q/g;   	    
s/\@ADV-ADV>/\@ADV>/g;       # adv modifying adv
s/\@ADV-ADV</\@ADV</g;       # adv modifying adv
s/\@ADV-A>/\@A>/g;         # adv modifying adj
#s/\@ADVL/\@ADVL/g;           
s/\@AN>/\@N>/g;           
#s/\@APP/\@APP/g;           # check this one.
s/\@ActioN>/\@N>/g;   
s/\@CC-NP/\@CNP/g; 	      
s/\@CC-VP/\@CVP/g; 	      
s/\@CC/\@CC/g;			  
s/\@CMPND/\@N>/g;            # one word A-_ja_B?
s/\@CS-NP/\@CNP/g;       
s/\@CS-VP/\@CVP/g;   # trying to get embedding to work
s/\@CS/\@CS/g;           
s/\@DN>/\@N>/g;           
s/\@GA>/\@A>/g;      
s/\@GN>/\@N>/g;           
s/\@GP</\@P</g;      
s/\@GP>/\@P>/g;   	       
s/\@GQ</\@Q</g;      
#s/\@HNOUN/\@HNOUN/g;         
s/\@INTERJ/\@INTERJ/g;   
s/\@NNum>/\@Num>/g;
s/\@NPron</\@Pron</g;
s/\@NQ</\@Q</g;
s/\@NumN</\@N</g;
s/\@NUM-PRON/\@Pron</g;
#s/\@OBJ/\@OBJ/g;
#s/\@OPRED/\@OPRED/g; 	    
#s/\@PCLE/\@PCLE/g;
#s/\@PCLE-COMPL/\@PCLE-COMPL/g;
s/\@PROP>/\@N>/g;               # check this one.
s/\@PrcN>/\@N>/g;
s/\@PronN</\@N</g;	    
s/\@PronN>/\@N>/g;	    
s/\@QN>/\@N>/g;                 # ok, I think.
s/\@QN</\@N</g;	    
#s/\@SPRED/\@SPRED/g; 	    
s/\@SUBJ-QH/\@SUBJ/g;
#s/\@SUBJ/\@SUBJ/g;
s/\@TITLE/\@N>/g;               # a bit like APP?
s/\@VOC/\@APP/g;
#s/\@X/\@X/g;
#s/\@\+FAUXV/\@\+FAUXV/g;
#s/\@\-FAUXV/\@\-FAUXV/g;
#s/\@\+FMAINV/\@\+FMAINV/g;       
#s/\@\-FMAINV/\@\-FMAINV/g;       
s/\@-FSUBJ/\@-FSUBJ/g;          # non-finite subj

print ;
}
