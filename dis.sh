#!/bin/bash

#****************************************************************
#			dis.sh
#			written by Saara Huhmarniemi
#			Oct 9, 2006
#
#           run vislcg
#
# $Id $
#****************************************************************

# compile m4 grammar file
# call vislcg

vislcg="vislcg --grammar $HOME/gt/sme/bin/sme-dis.rle --minimal"

cd $HOME/gt/ && make dis TARGET=sme
exec $vislcg<&0

