#!/bin/bash -l

#
# This script is specific for the analysis that is done on stallo
#

# Read environment variables that are needed
source $HOME/.bash_profile

DATE=`date +%Y-%m-%d`

declare -A CORPUSES
CORPUSES=(
    [$GTFREE]=/Users/hoavda/Public/corp/freecorpus/analysed/$DATE
    [$GTBOUND]=/Users/hoavda/Public/corp/boundcorpus/analysed/$DATE
)

for CORPUS in "${!CORPUSES[@]}"
do
    for lang in sma sme smj
    do
        # count how many files are potentially convertible
        xsls=`find orig/$lang -name \*.xsl|wc -l`

        # count how many files that really got converted
        cxmls=`find converted/$lang -name \*.xml|wc -l`

        # count how many files that really got analysed
        axmls=`find analysed/$lang -name \*.xml|wc -l`

        # print the facts
        echo "$lang xsls $xsls cxml $cxmls axml $axmls $corpus"
    done

    DIRECTORY=${CORPUSES[$CORPUS]}
    # The directory on divvun.no that files should be synced to
    # Make sure the directory exists in divvun.no
    ssh boerre@divvun.no "if [ -d \"$DIRECTORY\" ]; then echo \"$DIRECTORY exists\"; else mkdir $DIRECTORY;fi"
    # sync the file to freecorpus
    rsync -qaz $CORPUS/analysed/ boerre@divvun.no:$DIRECTORY
done
