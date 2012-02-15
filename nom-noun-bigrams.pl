#!/usr/bin/env perl
use warnings;
use strict;
use warnings;
use Getopt::Long;

use utf8;

# nom-noun-bigrams
# Perl-script for extracting pairs of nominative noun candidates.
# Outputs such pairs. No disambiguation is assumed, only the presence
# of a nominative tag in one of the analyses of the first word, and a
# noun (and adjective?) tag in one of the analyses of the second word.
#
# Input: word pairs morphologically analysed
#
# Kurssain leat ámmát bagadallit.
# Kurssain        kursa+N+Sg+Com
# Kurssain        kursa+N+Pl+Loc
# 
# leat    leat+V+IV+Ind+Prs+Sg2
# leat    leat+V+IV+Ind+Prs+Pl3
# leat    leat+V+IV+Ind+Prs+Pl1
# leat    leat+V+IV+Ind+Prs+ConNeg
# leat    leat+V+IV+Inf
# 
# ámmát 2  ámmát+N+Sg+Nom
# 
# bagadallit      bagadit+V+TV+Der/alla+V+Imprt+Pl2
# bagadallit      bagadit+V+TV+Der/alla+V+Actor+N+Pl+Nom
# bagadallit      bagadallat+V+TV+Imprt+Pl2
# bagadallit      bagadallat+V+TV+Actor+N+Pl+Nom
# bagadallit      bagadalli+Hum+N+Actor+Pl+Nom
# 
# .       .+CLB
# Ná mii oažžut sámi ja álgoálbmot perspektiivva buot oahpahusas.
# Ná      ná+Adv
# 
# mii     mii+Pron+Rel+Sg+Nom
# mii     mii+Pron+Interr+Sg+Nom
# mii     mun+Pron+Pers+Pl1+Nom
# 
# oažžut  oažžut+V+TV+Inf
# oažžut  oažžut+V+TV+Imprt+Pl2
# oažžut  oažžut+V+TV+Imprt+Pl1
# oažžut  oažžut+V+TV+Ind+Prs+Pl1
# oažžut  oažžut+V+TV+Actor+N+Pl+Nom
# 
# sámi    sápmi+N+Sg+Gen
# sámi    sápmi+N+Sg+Acc
# 
# ja      ja+CC
# 
# álgoálbmot      álgu+N+SgNomCmp+Cmp#álbmot+Hum+Group+N+Sg+Nom
# álgoálbmot      álgu+N+SgNomCmp+Cmp#álbmut+V+TV+Actor+N+Sg+Nom+PxSg2
# álgoálbmot      álgu+N+SgNomCmp+Cmp#álbmut+V+TV+Actor+N+Sg+Gen+PxSg2
# álgoálbmot      álgu+N+SgNomCmp+Cmp#álbmut+V+TV+Actor+N+Sg+Acc+PxSg2
# álgoálbmot      álgo#álbmot+Hum+Group+N+Sg+Nom
# 
# perspektiivva   perspektiiva+N+Sg+Gen
# perspektiivva   perspektiiva+N+Sg+Acc
# 
# buot    buot+Adv
# buot    buot+Pron+Indef
# 
# oahpahusas      oahpahus+N+Sg+Gen+PxSg3
# oahpahusas      oahpahus+N+Sg+Acc+PxSg3
# oahpahusas      oahpahus+N+Sg+Loc
# 
# .       .+CLB

# Illudan dakkár eará studeanta hommáide.

# Illudan illudit+V+IV+PrfPrc
# Illudan illudit+V+IV+Ind+Prs+Sg1
# Illudan illudit+V+IV+Der/eapmi+N+Sg+Gen
# Illudan illudit+V+IV+Actio+Acc
# Illudan illudit+V+IV+Actio+Gen
# Illudan illudit+V+IV+Actio+Nom
# 
# dakkár  dakkár+Pron+Dem+Attr
# dakkár  dakkár+Pron+Dem+Sg+Nom
# 
# eará    eará+Pron+Indef+Attr
# eará    eará+Pron+Indef+Sg+Nom
# eará    eará+Pron+Indef+Sg+Acc
# eará    eará+Pron+Indef+Sg+Gen
# 
# studeanta       studeanta+Hum+N+Sg+Nom
# 
# hommáide        hommá+N+Pl+Ill
# hommáide        hommát+V+IV+Ind+Prt+Du2
# 
# .       .+CLB


#
# Output: words pairs matching the following:
# Word1: the tag +Nom is found
# Word2: one of the tags +N or +A is found

$/ = "";
my $nomWord = "";
my $prevNomWord = "";

# Read while not eol
while(<>) {

    $prevNomWord = $nomWord;
    $nomWord = "";

    my $input = $_;
    my @lines = split(/\n/, $input);

    foreach my $line (@lines)  {

        my ($word, $analysis) = split(/\t/, $line);

        if ( ($analysis =~ /\+N\+Sg\+Nom/ || $analysis =~ /\+N\+Actor\+Sg\+Nom/) &&
        	$analysis !~ /\+Prop\+/ &&
        	$analysis !~ /\+ACR\+/  &&
        	$analysis !~ /\+ABBR\+/ 
        	) {
            $nomWord = $word;
        }
        
        if (
        	($analysis =~ /\+A\+/ || $analysis =~ /\+N\+/) && 
        	 $prevNomWord ne ""      &&
        	 $analysis !~ /\+Prop\+/ &&
        	 $analysis !~ /\+ACR\+/  &&
        	 $analysis !~ /\+ABBR\+/
        	) {
            print "$prevNomWord $word\n";
            $prevNomWord = "";
        }
    }
}
