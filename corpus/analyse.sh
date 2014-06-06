#!/bin/sh -l

#
# This script is specific for the analysis that is done on stallo
#

#PBS -lwalltime=9:00:00
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
    if [ "$lang" == "sme" ]
    then
        cd $GTHOME/gt
        make GTLANG=sme
        make GTLANG=sme abbr
    else
        cd $GTHOME/langs/$lang
        make
    fi

    for corpus in $GTFREE $GTBOUND
    do
        cd $corpus
        # remove old analysed files, making sure
        # old analysed files are not included, only new ones
        rm -rf converted/$lang analysed/$lang

        # convert original files to xml
        time convert2xml --debug orig/$lang

        # analyse the newly converted files
        time analyse_corpus $lang converted/$lang

        # count how many files are potentially convertible
        xsls=`find orig/$lang -name \*.xsl|wc -l`

        # count how many files that really got converted
        cxmls=`find converted/$lang -name \*.xml|wc -l`

        # count how many files that really got analysed
        axmls=`find analysed/$lang -name \*.xml|wc -l`

        # print the facts
        echo "$lang xsls $xsls cxml $cxmls axml $axmls $corpus"
    done
done

DATE=`date +%Y-%m-%d`

for xmltype in converted analysed
do
    # The directory on divvun.no that files should be synced to
    DIRECTORY=/Users/hoavda/Public/corp/freecorpus/$xmltype/$DATE
    # Make sure the directory exists in divvun.no
    ssh boerre@divvun.no "if [ -d \"$DIRECTORY\" ]; then echo \"$DIRECTORY exists\"; else mkdir $DIRECTORY;fi"
    # sync the file to freecorpus
    rsync -az $GTFREE/$xmltype/ boerre@divvun.no:$DIRECTORY

    # The directory on divvun.no that files should be synced to
    DIRECTORY=/Users/hoavda/Public/corp/boundcorpus/$xmltype/$DATE
    # Make sure the directory exists in divvun.no
    ssh boerre@divvun.no "if [ -d \"$DIRECTORY\" ]; then echo \"$DIRECTORY exists\"; else mkdir $DIRECTORY;fi"
    # sync the file to boundcorpus
    rsync -az $GTBOUND/$xmltype/ boerre@divvun.no:$DIRECTORY
done
