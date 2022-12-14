#! /bin/bash

# sent-disamb.sh
# This is a shell script for analysing sentences with the vislcg3 parser.
# It gives the analysis, and optionally the number of the disambiguator rules.

# usage:
# <script_name> (-t) -l=<lang_code> <sentence_to_analyze>
# to output the number of disambiguator rules, too, use the parameter '-t'
# parametized for language (sme as default)
# input sentence either coming from the pipe or at the end in quotation marks
# parametrized for processing step: -s=pos, -s=dis, -s=dep, -s=syn

LOOKUP=`which lookup`
HLOOKUP='/opt/local/bin/hfst-optimized-lookup'

# -l=sme|sma|fao|etc. => default=sme
fl=$(echo "$@" | grep '\-l\=')

# -s=pos|dis|dep => default=pos
fs=$(echo "$@" | grep '\-s\=')

ft=$(echo "$@" | grep '\-t')

fh=$(echo "$@" | grep '\-h')



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
if [[ "$l" == bla ]] || [[ "$l" == ciw ]] || [[ "$l" == cor ]] || [[ "$l" == crk ]] || [[ "$l" == est ]] || [[ "$l" == fao ]] || [[ "$l" == fin ]] || [[ "$l" == fkv ]] || [[ "$l" == hdn ]] || [[ "$l" == ipk ]] || [[ "$l" == izh ]] || [[ "$l" == kal ]] || [[ "$l" == kca ]] || [[ "$l" == kpv ]] || [[ "$l" == liv ]] || [[ "$l" == mdf ]] || [[ "$l" == mhr ]] || [[ "$l" == mrj ]] || [[ "$l" == myv ]] || [[ "$l" == ndl ]] || [[ "$l" == nio ]] || [[ "$l" == nob ]] || [[ "$l" == olo ]] || [[ "$l" == ron ]] || [[ "$l" == sjd ]] || [[ "$l" == sje ]] || [[ "$l" == sma ]] || [[ "$l" == smj ]] || [[ "$l" == smn ]] || [[ "$l" == sms ]] || [[ "$l" == som ]] || [[ "$l" == tat ]] || [[ "$l" == tlh ]] || [[ "$l" == tuv ]] || [[ "$l" == udm ]] || [[ "$l" == vep ]] || [[ "$l" == vro ]] || [[ "$l" == yrk ]] || [[ "$l" == zul ]] 
 then
	lg="langs"
elif [[ "$l" == "sme" ]] 
then
    lg="gt"
else
    lg="st"
fi

#abbr
# if sme then gt/sme/bin/abbr.txt
# if newinfra then $GTHOME/$lg/$l/tools/preprocess/abbr.txt
# if st then st/$l/bin/abbr.txt
# if no abbr in these places then abbr=""


if  [  -f $GTHOME/gt/sme/bin/abbr.txt ]
then
    abbr="--abbr=$GTHOME/gt/sme/bin/abbr.txt"        # <--- special case for sme
elif [  -f $GTHOME/$lg/$l/tools/preprocess/abbr.txt ]
then
    abbr="--abbr=$GTHOME/$lg/$l/tools/preprocess/abbr.txt"  # <--- ny infra
elif [  -f $GTHOME/$lg/$l/bin/abbr.txt ]
then
    abbr="--abbr=$GTHOME/$lg/$l/bin/abbr.txt"  # <--- left-overs i gamal infra (st)
else
    abbr=""
fi


# old, delete:
# abbr
#if  [  -f $GTHOME/$lg/$l/bin/abbr.txt ]
#then
#    abbr="--abbr=$GTHOME/$lg/$l/bin/abbr.txt"
#else
#    abbr=""
#fi

# New infra or not
if [[ "$l" == est ]] || [[ "$l" == fao ]] || [[ "$l" == fin ]] || [[ "$l" == fkv ]] || [[ "$l" == hdn ]] || [[ "$l" == ipk ]] || [[ "$l" == izh ]] || [[ "$l" == kal ]] || [[ "$l" == kca ]] || [[ "$l" == kpv ]] || [[ "$l" == liv ]] || [[ "$l" == mdf ]] || [[ "$l" == mhr ]] || [[ "$l" == mrj ]] || [[ "$l" == myv ]] || [[ "$l" == ndl ]] || [[ "$l" == nio ]] || [[ "$l" == nob ]] || [[ "$l" == olo ]] || [[ "$l" == sjd ]] || [[ "$l" == sje ]] || [[ "$l" == sma ]] || [[ "$l" == smj ]] || [[ "$l" == smn ]] || [[ "$l" == sms ]] || [[ "$l" == som ]] || [[ "$l" == tat ]] || [[ "$l" == tlh ]] || [[ "$l" == tuv ]] || [[ "$l" == udm ]] || [[ "$l" == vep ]] || [[ "$l" == vro ]] || [[ "$l" == yrk ]] || [[ "$l" == zul ]] 
then 
	MORPH="$LOOKUP $GTHOME/$lg/$l/src/analyser-gt-desc.xfst"
else
	MORPH="$LOOKUP -q -flags mbTT -utf8 $GTHOME/$lg/$l/bin/$l.fst"
fi

if  [[ "$l" == est ]] || [[ "$l" == fao ]] || [[ "$l" == fin ]] || [[ "$l" == fkv ]] || [[ "$l" == hdn ]] || [[ "$l" == ipk ]] || [[ "$l" == izh ]] || [[ "$l" == kal ]] || [[ "$l" == kca ]] || [[ "$l" == kpv ]] || [[ "$l" == liv ]] || [[ "$l" == mdf ]] || [[ "$l" == mhr ]] || [[ "$l" == mrj ]] || [[ "$l" == myv ]] || [[ "$l" == ndl ]] || [[ "$l" == nio ]] || [[ "$l" == nob ]] || [[ "$l" == olo ]] || [[ "$l" == sjd ]] || [[ "$l" == sje ]] || [[ "$l" == sma ]] || [[ "$l" == smj ]] || [[ "$l" == smn ]] || [[ "$l" == sms ]] || [[ "$l" == som ]] || [[ "$l" == tat ]] || [[ "$l" == tlh ]] || [[ "$l" == tuv ]] || [[ "$l" == udm ]] || [[ "$l" == vep ]] || [[ "$l" == vro ]] || [[ "$l" == yrk ]] || [[ "$l" == zul ]]  
then 
	DIS="$GTHOME/$lg/$l/src/syntax/disambiguator.cg3"
else
	DIS="$GTHOME/$lg/$l/src/$l-dis.rle"
fi


print_help() {
    echo "USAGE: 1. sent-proc.sh [-t] [-l=LANG] [-s=PROCESSING_STEP] \"INPUT_TEXT\""
    echo "                       or"
    echo "       2. cat FILE or echo \"INPUT_TEXT\" | sent-proc.sh [-t] [-l=LANG] [-s=PROCESSING_STEP] "
    echo "-l language code: sme North Saami (default), sma South Saami, etc."
    echo "-s processing step: pos part-of-speech tagging without disambiguator which is (default)"
    echo "   processing step: dis part-of-speech tagging with disambiguator with vislcg3"
    echo "   processing step: syn assigning syntactic functions via vislcg3"
    echo "   processing step: dep dependency parsing with vislcg3"
    echo "-t print traces of the disambiguator or parsing step"
    echo "-h print this text"
    exit
} 

last_fl=$(echo "${@:${#@}}" | perl -ne 'if (/-l=.../) {print;}')
last_fs=$(echo "${@:${#@}}" | perl -ne 'if (/-s=.../) {print;}')
last_ft=$(echo "${@:${#@}}" | perl -ne 'if (/-t/) {print;}')
last_fh=$(echo "${@:${#@}}" | perl -ne 'if (/-h/) {print;}')

# if no params or last param is a flag then take input from the left (cat, echo, etc.)
# else take the last param from the right
if [[ ! -z "$last_fh" ]]
then
    print_help
elif [[ $# -eq 0 ]]
then
#tput cup 0 0
    sentence=$(cat -)
    if [[ -z "$sentence" ]]
    then
	print_help
    fi
else
    if [[ ! -z "$last_fl" ]] || [[ ! -z "$last_fs" ]] || [[  ! -z "$last_ft" ]] 
    then
	sentence=$(cat -)
    else
	sentence=${@:${#@}}
	if [[ -z "$sentence" ]]
	then
	    print_help
	fi
    fi
fi




sdPATH='gtdshared/smi/src/syntax'



if [[ $l == fao ]]

then

pos_cmd="echo $sentence | preprocess $abbr | $MORPH | $GTHOME/gt/script/lookup2cg"
dis_cmd=$pos_cmd" | vislcg3 -g $GTHOME/$lg/$l/src/syntax/disambiguator.cg3 $t"
syn_cmd=$dis_cmd" | vislcg3 -g $GTHOME/$lg/$l/src/syntax/functions.cg3 $t"  #$GTHOME/gt/sme/src/smi-syn.rle
dep_cmd=$syn_cmd" | vislcg3 -g $GTCORE/$sdPATH/dependency.cg3 $t" #$GTHOME/gt/smi/src/smi-dep.rle

else

pos_cmd="echo $sentence | preprocess $abbr | $MORPH | $GTHOME/gt/script/lookup2cg"
dis_cmd=$pos_cmd" | vislcg3 -g $DIS $t"
syn_cmd=$dis_cmd" | vislcg3 -g $GTCORE/$sdPATH/functions.cg3 $t"  #$GTHOME/gt/sme/src/smi-syn.rle
dep_cmd=$syn_cmd" | vislcg3 -g $GTCORE/$sdPATH/dependency.cg3 $t" #$GTHOME/gt/smi/src/smi-dep.rle

fi


# processing step
case $s in
    pos) 
	echo "... pos tagging ..."
	echo $(echo $pos_cmd) | sh
	;;
    dis)
	echo "... pos disambiguating ..."
	echo $(echo $dis_cmd) | sh
	;;
    syn)
	echo "... syntax analysis ..."
	echo $(echo $syn_cmd) | sh
	;;
    dep)
	echo "... inserting dependency relations ..."
	echo $(echo $dep_cmd) | sh
	;;
esac

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
