#!/bin/sh
# Written by Børre Gaup <boerre.gaup@pc.nu>, 2002-08-08.
# This automates the conversion of pdf files to the xfst format in the sme 
# database.
# Usage: go to the gt/script directory. Enter ./pdfto7bit.sh at the commandline
# This will convert all the pdf files in the CORP directory to the format that 
# the sme database expects
# The translated files will be stored in the subdirectory modified, and should 
# be inspedted and manually moved from there to the parent directory corp.


FROMCORP=../sme/corp/original
TOCORP=../sme/corp/modified

for i in $FROMCORP/sams*.pdf
do
	echo "Konverting $i..."
	pdftotext -raw -enc UTF-8 $i - \   # invoces the utility pdftotext
	| tr -s ' ' \       # conflates repeted spaces
	| ./del.pl \        # invoces del.pl, deleting sm hyphens(?)   
	| ./utf8.pl \       # invoces utf8.pl, translating sami letters
	> $TOCORP/`basename $i .pdf`.txt
	echo "done"
done

