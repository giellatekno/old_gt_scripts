#!/bin/sh
# Written by Børre Gaup <boerre.gaup@pc.nu>, 2002-08-08.
# This automates the conversion of pdf files to the xfst format in the sme 
# database.
# Usage: go to the gt/script directory. Enter ./pdfto7bit.sh at the commandline
# This will convert all the pdf files in the CORP directory to the format that 
# the sme database expects

FROMCORP=../sme/corp/original
TOCORP=../sme/corp/modified

for i in $FROMCORP/sams*.pdf
do
	echo "Konverting $i..."
	pdftotext -raw -enc UTF-8 $i - \
	| tr -s ' ' \
	| ./del.pl \
	| ./utf8.pl \
	> $TOCORP/`basename $i .pdf`.txt
	echo "done"
done

