#! /bin/bash

# loop-sent-depend.sh
# This is a shell script for analysing (at the moment, only) Northern Sámi sentences with the vislcg3 parser.
# It gives the analysis, and optionally the number of the disambiguation rules.

#usage:
# <script_name> (-t)
# to output the number of disambiguation rules, too, use the parameter '-t'

# You need to make GT_HOME point to your gt/ directory, normally one of the two following:
# export GT_HOME=/Users/<your_user_name> 
# export GT_HOME=/Users/<your_user_name>/Documents

# todo: parametize for language!
# possible todo: this can be merged with loop-sent-disamb.sh they are almost the same

ft=$(echo "$@" | grep '\-t')

if [ ! -z "$ft" ]
then
    t="-t"
else
    t=""
fi

while [ 1 ]                                 # as long as there is input
do                                          # run the following loop
echo "Atte cealkaga: "                      # (message to user)
read sentence                               # next line calls the usual command which is the script sent-disamb.sh
./sent-disamb.sh "${sentence}" | \
vislcg3 -g $GTHOME/gt/sme/src/sme-dep.rle $t
done                      
exit 0

