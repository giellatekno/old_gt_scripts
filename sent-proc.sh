#! /bin/bash

# sent-disamb.sh
# This is a shell script for analysing (at the moment, only) Northern Sámi sentences with the vislcg3 parser.
# It gives the analysis, and optionally the number of the disambiguation rules.

#usage:
# <script_name> (-t) -l=<lang_code> <sentence_to_analyze>
# to output the number of disambiguation rules, too, use the parameter '-t'
# parametized for language (sme as default)
# input sentence either coming from the pipe or at the end in quotation marks
# parametrized for processing step: -s=pos, -s=dis, -s=dep

if [ `hostname` == 'victorio.uit.no' ]
then
    LOOKUP=/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup
    HLOOKUP='/usr/local/bin/hfst-optimized-lookup'
else
    LOOKUP=`which lookup`
    HLOOKUP='/opt/local/bin/hfst-optimized-lookup'
fi

# -l=sme|sma|fao|etc. => default=sme
fl=$(echo "$@" | grep '\-l\=')

# -s=pos|dis|dep => default=pos
fs=$(echo "$@" | grep '\-s\=')

ft=$(echo "$@" | grep '\-t')

# lang
if [ ! -z "$fl" ]
then
    l=$(echo "$@" | perl -pe "s/.*?-l=(...).*/\1/")
else
    l="sme"
fi

# step
if [ ! -z "$fs" ]
then
    s=$(echo "$@" | perl -pe "s/.*?-s=(...).*/\1/")
else
    s="pos"
fi

# trace
if [ ! -z "$ft" ]
then
    t="--trace"
else
    t=""
fi

# lang group
if [[ "$l" == "sme" ]] || [[ "$l" == "sma" ]] || [[ "$l" == "smj" ]]
then
    lg="gt"
elif [[ "$l" == "fin" ]] || [[ "$l" == "kom" ]] || [[ "$l" == "fkv" ]]
then
    lg="kt"
else
    lg="st"
fi

# abbr
if  [  -f $GTHOME/$lg/$l/bin/abbr.txt ]
then
    abbr="--abbr=$GTHOME/$lg/$l/bin/abbr.txt"
else
    abbr=""
fi

# omorfi or not omorfi
if [[ "$l" == fin ]]
then 
	MORPH="$HLOOKUP $GTHOME/kt/fin/bin/share/omorfi/mor-omorfi.cg.hfst.ol"
else
	MORPH="$LOOKUP -flags mbTT -utf8 $GTHOME/$lg/$l/bin/$l.fst"
fi

last_fl=$(echo "${@:${#@}}" | perl -ne 'if (/-l=.../) {print;}')
last_fs=$(echo "${@:${#@}}" | perl -ne 'if (/-s=.../) {print;}')
last_ft=$(echo "${@:${#@}}" | perl -ne 'if (/-t/) {print;}')

# if no params or last param is a flag then take input from the left (cat, echo, etc.)
# else take the last param from the right
if [[ $# -eq 0 ]]
then
#tput cup 0 0
    sentence=$(cat -)
else
    if [[ ! -z "$last_fl" ]] || [[ ! -z "$last_fs" ]] || [[  ! -z "$last_ft" ]] 
    then
	sentence=$(cat -)
    else
	sentence=${@:${#@}}
    fi
fi

pos_cmd="echo $sentence | preprocess $abbr | $MORPH | $GTHOME/gt/script/lookup2cg"
dis_cmd=$pos_cmd" | vislcg3 -g $GTHOME/$lg/$l/src/$l-dis.rle $t"
dep_cmd=$dis_cmd" | vislcg3 -g $GTHOME/gt/sme/src/sme-dep.rle $t"

# processing step
case $s in
    pos) 
	echo "... pos tagging ..."
	echo $(echo $pos_cmd) | sh
	;;
    dis)
	echo "... disambiguating ..."
	echo $(echo $dis_cmd) | sh
	;;
    dep)
	echo "... dependency parsing ..."
	echo $(echo $dep_cmd) | sh
	;;
esac

