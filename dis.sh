#!/bin/bash

#****************************************************************
#			dis.sh
#			written by Saara Huhmarniemi
#			Oct 9, 2006
#
#           run vislcg
#
# $Id$
#****************************************************************

# compile m4 grammar file
# call vislcg
# Usage: as vislcg.
# dis.sh --grammar=... --minimal < file.txt
# .. | lookup2cg | dis.sh --grammar=... --minimal

mei=$@

a=$(echo "$@" | grep '.*-D.*')
#echo $a
if [ ! -z "$a" ]
then 
	m4flags=$(echo $@ | perl -pe "s/.*?(-D.*)\..*/\1/")
fi

#echo "M4FLAGS"
#echo $m4flags
#echo $@

vislcg="vislcg $@"
pwd=$(pwd)

#echo "VISLCG"
#echo $vislcg

cd $GTHOME/gt/ && make dis GTLANG=sme M4FLAGS="$m4flags"
cd $pwd && exec $vislcg<&0

