#!/bin/sh -l

#
# This script is specific for the analysis that is done on stallo
#

#PBS -lwalltime=7:00:00
#PBS -lnodes=1
#PBS -q express
#PBS -A uit-sami-001

# Read environment variables that are needed
. "$HOME/.bash_profile"

# Load modules that are needed by make in the lang directories
module load autoconf/2.69
module load automake/1.13.1

# Make sure giella-core is the latest, greatest
cd "$GTHOME/giella-core"
./autogen.sh
./configure
make -j

# Make sure giella-shared is the latest, greatest
cd "$GTHOME/giella-shared"
./autogen.sh
./configure
make -j

for lang in sma sme smj fkv smn sms
do
    cd "$GTHOME/langs/$lang"
    # make sure no files unknown to svn are hanging around
    svn st|grep '^?'|cut -f8 -d" "|xargs rm -rf
    # to make *really* sure the latest, greatest fsts are built
    make clean
    # build fst needed for analysis
    time make -j
    if [ $lang != "sms" ]
    then
        cd "$GTHOME/langs/$lang/tools/preprocess"
        rm abbr.txt
        time make -j abbr
    fi


    for corpus in $GTFREE $GTBOUND
    do
        cd "$corpus"
        time analyse_corpus $lang converted/$lang
        echo "finished analysing $corpus:$lang"
    done
done
