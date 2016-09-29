#!/bin/bash -l

#
# This script is specific for the analysis that is done on stallo
#

# Read environment variables that are needed
source $HOME/.bash_profile

DATE=$(date +%Y-%m-%d)

declare -A CORPUSES
CORPUSES=(
    [$GTFREE]=/Users/hoavda/Public/corp/freecorpus/analysed/$DATE
    [$GTBOUND]=/Users/hoavda/Public/corp/boundcorpus/analysed/$DATE
)

for CORPUS in "${!CORPUSES[@]}"
do
    for lang in sma sme smj fkv smn sms
    do
        # count how many files are potentially convertible
        xsls=$(find $CORPUS/orig/$lang -name \*.xsl|wc -l)

        # count how many files that really got converted
        cxmls=$(find $CORPUS/converted/$lang -name \*.xml|wc -l)

        # count how many files that really got analysed
        axmls=$(find $CORPUS/analysed/$lang -name \*.xml|wc -l)

        # print the facts
        echo "$lang xsls $xsls cxml $cxmls axml $axmls $CORPUS"
    done

    DIRECTORY=${CORPUSES[$CORPUS]}
    # The directory on divvun.no that files should be synced to
    # Make sure the directory exists in divvun.no
    ssh boerre@divvun.no "if [ -d \"$DIRECTORY\" ]; then echo \"$DIRECTORY exists\"; else mkdir $DIRECTORY;fi"
    # sync the file to freecorpus
    rsync -qaz $CORPUS/analysed/ boerre@divvun.no:$DIRECTORY
    # remove analysed files. If the analysis job is not run during the night,
    # this assures we won't get stale data synced to divvun.no
    rm -rf $CORPUS/analysed

done
