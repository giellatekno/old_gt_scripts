#! /bin/bash

# sent-disamb.sh
# This is a shell script for analysing sentences with the vislcg3 parser.
# It gives the analysis, and optionally the number of the disambiguation rules.

# usage:
# <script_name> (-t) -l <lang_code> <sentence_to_analyze>
# to output the number of disambiguation rules, too, use the parameter '-t'
# parametized for language (sme as default)
# input sentence either coming from the pipe or at the end in quotation marks
# parametrized for processing step: -s pos, -s dis, -s syn, -s dep

LOOKUP=`which lookup`
HLOOKUP='/opt/local/bin/hfst-optimized-lookup'

# -l sme|sma|fao|etc. => default: sme
l='sme'
# -s pos|dis|dep => default: pos
s='pos'
# -t => default: no trace
t=''

# lang group => default: gt (because of default: sme)
lg='gt'

#abbr file => default: sme-path (because of default: sme)
abbr='$GTHOME/gt/sme/bin/abbr.txt'

#long_lang_list
long_lang_list=(bla ciw cor crk est fao fin fkv
                hdn ipk izh kal kca kpv liv mdf
                mhr mrj myv ndl nio nob olo ron
                sjd sje sma smj smn sms som tat
                tlh tuv udm vep vro yrk zul)

echo "_pre l  ${l}"
echo "_pre s  ${s}"
echo "_pre t  ${t}"
echo "_pre lg  ${lg}"
echo "_pre abbr  ${abbr}"


usage() { echo "Usage: $0 [-l <sme|sma|...>][-s <pos|dis|syn|dep>][-t][-h]" 1>&2; exit 1; }

while getopts ":l:s:h:t" o; do
    case "${o}" in
        l)
            l=${OPTARG}
            ;;
        s)
            s=${OPTARG}
            ;;
        t)
            t='--trace'
            ;;
        h)
	    usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# language parameter test and abbr file assignment
if [[ "${long_lang_list[*]}" =~ (^|[^[:alpha:]])$l([^[:alpha:]]|$) ]]; then
    echo "lang $l is in list $long_lang_list"
    lg='langs'
    if [  -f $GTHOME/$lg/$l/tools/preprocess/abbr.txt ]; then
       abbr="--abbr=$GTHOME/$lg/$l/tools/preprocess/abbr.txt"  # <--- new infra
       echo "abbr $abbr"
    else
       abbr=''
       echo "Warning: no abbr file found \n $GTHOME/$lg/$l/tools/preprocess/abbr.txt \n ...... preprocessing without it!" 1>&2;
    fi 
elif [[ "$l" == "sme" ]]; then
    lg='gt'
    if [  -f $GTHOME/$lg/$l/bin/abbr.txt ]; then
       abbr="--abbr=$GTHOME/$lg/$l/bin/abbr.txt"  # <--- sme exception
       echo "abbr $abbr"
    else
       echo "Error: no abbr file found \n $GTHOME/$lg/$l/bin/abbr.txt \n ...... please generate it!" 1>&2; exit 1; 
    fi 
else
    lg='st'
    if [  -f $GTHOME/$lg/$l/bin/abbr.txt ]; then
       abbr="--abbr=$GTHOME/$lg/$l/bin/abbr.txt"  # <--- leftovers in the old infra (st)
       echo "abbr $abbr"
    else
       abbr=''
       echo "Warning: no abbr file found \n $GTHOME/$lg/$l/bin/abbr.txt \n ...... preprocessing without it!" 1>&2; 
    fi
fi

echo "post_ l  ${l}"
echo "post_ s  ${s}"
echo "post_ t  ${t}"
echo "post_ lg  ${lg}"
echo "post_ abbr  ${abbr}"






# Notes for further development:
# ==============================

# At the moment, there is a family of scripts for analysis, in addition to this one:
# cealkka (sentence), sme-dis.sh (sentence, with rule nr), sme-multi.sh (sentence w/o disamb)
#                     smj-dis.sh (sentence, with rule nr), smj-multi.sh (sentence w/o disamb)
# With more lgs and more options this will develop into a wildernis.

# What we want:
# One script, with parametrised options along several paths:
# What language, 
# What kind of input (plain text, xml text, evt. other text formats as well)
# What kind of output (disambiguated text with and without rule numbers, non-disambiguated text with and without syntactic tags
# What kind of morphological transducers (standard (tolerant) or normative (restricted))

# dis.sh (script for disambiguating sentences or text)
# If given as
# dis.sh filename
# the script expects a text
# If given as 
# dis.sh 
# (i.e., without file name), the script expects a sentence, and answers:
# "Write a sentence and press ENTER. Terminate by pressing ctrl-C."

# options:
# -l <lang> what disambiguator to call for (sme as default?)
# -n        gives the rule number (no rule numbers is default)
# -m        gives the non-disambiguated output (only section 1 in the .rle file)
# -norm     uses normative transducers for the morphological analysis,
#           ie will not recognise any non-conformant spellings
# -i <type> gives text type:
#           xml  (default, calls for ccat with the same <lang> as given above)
#           txt  (takes plain text as input, is basically the script we have now)
#           doc  (if we bother doing this, it would call for ... | antiword -db | ccat | ...)
#           odt  (openoffice documents could probably get the same treatment
#           html (importing relevant code from convert2xml.pl)
#           pdf  (importing relevant code from convert2xml.pl)
# -o <type> visl (default is the standard vislcg output format)
#           xml  (gives xml-tagget output)
