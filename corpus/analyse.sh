#!/bin/sh -l

#
# This script is specific for the analysis that is done on stallo
#

#PBS -lwalltime=7:00:00
#PBS -lnodes=1
#PBS -q express
#PBS -A uit-sami-001

# Read environment variables that are needed
source $HOME/.bash_profile

# Load modules that are needed by make in the lang directories
module load autoconf/2.69
module load automake/1.13.1

# Make sure gtcore is the latest, greatest
cd $GTHOME/gtcore
make

for lang in sma sme smj
do
    # build fst needed for analysis
    cd $GTHOME/langs/$lang
    make

    for corpus in $GTFREE $GTBOUND
    do
        cd $corpus
        # remove old analysed files, making sure
        # old analysed files are not included, only new ones
        rm -rf analysed/$lang

        # analyse the converted files
        time analyse_corpus $lang converted/$lang

        echo "finished analysing $corpus:$lang"
    done
done

