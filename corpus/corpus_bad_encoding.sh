#!/bin/bash
#****************************************************************
#			corpus_bad_encoding.sh
#			written by Saara Huhmarniemi
#			Aug 31, 2006
#
#           Locate encoding problems in corpus files
#
# $Id$
#****************************************************************

# Usage: corpus_bad_encoding.sh > file.txt
# The problematic characters are searched from the corpus files.
# The output is a list of files followed by number of lines where 
# some of the charadters listed occured.
# If you notice a new encoding class, please name it 
# and add to the list below.

dir=$1

# List of wrongly encoded characters, classified according 
# to the supposed encoding. Some classes are overlapping.

greek="[αρλονχυτΔΛ]"
samimac="[Ω∏ª∫π]"
winsam="[ðñçóþ]"
iso_ir="[±¢³º]"
levi_winsam="[¹„¿˜]"
viitonen="[¾¿]"
latinkuus="[¹è¿˜¼]"
wrong_utf8="[Ã]"
# html-symbols that harm processing. Such that &lt;
# html="\&.{1,4}\;"

echo "Files with encoding problems:"

for code in "$wrong_utf8" "$greek" "$samimac" "$winsam" "$iso_ir" "$levi_winsam" "$viitonen" "$latinkuus"
do
  files=$(find $dir -type f | while read I; do grep -cH -E "$code" "$I"; done | sed "s/^.*0$//" |sort |uniq )
  echo "$code" "$files"
done

