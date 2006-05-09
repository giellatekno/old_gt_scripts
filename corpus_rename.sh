#!/bin/bash

#****************************************************************
#			corpus_rename.sh
#			written by Saara Huhmarniemi
#			May 2, 2006
#
#           Fix the malformed filenames in corpus directory
#           Script is originally designed for MinAigi files.
#
# $Id $
#****************************************************************

# Fix directory names
# - replace spaces with underscores
# - replace dot with underscore

# Fix the filenames in corpus directory:
# - replace spaces with underscores
# - remove space in the end of the file name
# - replace other "difficult" characters with underscore (implemented: dot)
# - add correct extensions (.doc, .pdf, .txt, .html) if missing

corpdir=/usr/local/share/corp
#corpdir=/home/saara/samipdf

# Add different subdirectories here, separated by newline.
subdirs="orig/sme/news/MinAigi"

filetypes="application/msword
application/pdf
text/html
text/plain"


# Original documents and xsl-files
rename ()
{
	for dir in "$@"
	do
	  echo "fixing $corpdir/$dir"

	  # change directories first
	  find $corpdir/$dir -type d | while read I; do NEWNAME=$(echo $I | sed -e "s/•/_/g" -e "s/ /_/g"); if [ "$I" != "$NEWNAME" ]; then mv "$I" "$NEWNAME"; fi; done;

	  find $corpdir/$dir -type f | while read I; do NEWNAME=$(echo "$I" | sed -e "s/•/_/g" -e "s/[ ]*$//" -e "s/ /_/g"); if [ "$I" != "$NEWNAME" ] && [ -f "$I" ]; then mv "$I" "$NEWNAME"; fi; if [ -f "$I " ]; then mv "$I " "$NEWNAME"; fi; done;
	  files=$(find $corpdir/$dir -type f)

	  for file in $files
	  do
		filetype=$(file -ib "$file" | sed -e "s/;.*//")
		found=0

		for type in $filetypes
		do
		  if [ "$type" = "$filetype" ]
		  then
			  found=1
		  fi
		done
		if [ ! $found ]
		then
			echo "$file: File type was not recognized. stop"
			return
		fi
		extension=$(echo "$file" | sed -e "s/.*\.//")

		if [ "$extension" = "$file" ]
			then
			case "$filetype" in
					"text/plain" ) file2=$file.txt;;
                     "text/html" ) file2=$file.html;;
					 "application/msword") file2=$file.doc;;
					 "application/pdf") file2=$file.pdf;;
					 *) file2=$file;;
			 esac
			 if [ "$file" != "$file2" ]
				 then
				 mv "$file" "$file2"
			 fi
	  	 fi
	   done
	done
}

rename $subdirs

exit 0
