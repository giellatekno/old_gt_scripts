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

args=$@

vislcg="vislcg $@"
pwd=$(pwd)

cd $HOME/gt/ && make dis TARGET=sme
cd $pwd && exec $vislcg<&0

