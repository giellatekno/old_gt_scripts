#!/bin/bash

#****************************************************************
#			corpus_fix_meta.sh
#			written by Saara Huhmarniemi
#			Apr 7, 2006
#
#           Change the metainformation of a directory.
#
# $Id$
#****************************************************************

# Update the metainformation of a whole corpus subdirectory.
# Remember to test your change first!
# Give the subdirectory in variable $dir
# Give the xsl-script in variable xslfix

corpdir=/usr/local/share/corp
dir=orig/sme/laws

xslfix=/home/saara/gt/script/change_xsl.xsl

files=`find $corpdir/$dir -type f ! -name "*.xsl*"`

for file in $files
do
  tmpfile="$file.tmp"
  xslfile="$file.xsl"
  xslvfile="$file.xsl,v"
  if [ -f $xslvfile ]; then
	  if ! co -l -f -q "$xslfile"; then
		  rcs -u "$xslfile"
		  co -l -f -q "$xslfile"
	  fi
	  if [ -s $xslfile ]; then
		  xsltproc --novalid "$xslfix" "$xslfile" > "$tmpfile";
		  if [ -s $tmpfile ]; then
			  mv -f "$tmpfile" "$xslfile"
		  fi
		  ci -m"fixed license info by corpus_fix_meta.sh" -q "$xslfile" "$xslvfile"
	  fi
  else
	  if [ -s $xslfile ]; then
		  xsltproc --novalid "$xslfix" "$xslfile" > "$tmpfile";
		  if [ -s $tmpfile ]; then
			  mv -f "$tmpfile" "$xslfile"
		  fi
		  ci -t"fixed license info by corpus_fix_meta.sh" -q -i "$xslfile" "$xslvfile"
	  fi
  fi
done

