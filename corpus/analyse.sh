#!/bin/sh -l

#
# This script is specific for the analysis that is done stallo
#

#PBS -lwalltime=5:00:00
#PBS -lnodes=1
#PBS -q express
#PBS -A uit-sami-001

source $HOME/.bash_profile
module load autoconf/2.69
module load automake/1.13.1
cd $GTHOME

cd $GTHOME/gtcore
make

for lang in sma sme smj
do
	cd $GTHOME/langs/$lang
	make

	for corpus in $GTFREE $GTBOUND
	do
		cd $corpus
		convert2xml orig/$lang
		time analyse_corpus $lang converted/$lang
		xsls=`find orig/$lang -name \*.xsl|wc -l`
		cxmls=`find converted/$lang -name \*.xml|wc -l`
		axmls=`find analysed/$lang -name \*.xml|wc -l`
		echo "$lang xsls $xsls cxml $cxmls axml $axmls $corpus"
	done
done

DATE=`date +%Y-%m-%d`

for xmltype in converted analysed
do
	DIRECTORY=/Users/hoavda/Public/corp/freecorpus/$xmltype/$DATE
	ssh boerre@divvun.no "if [ -d \"$DIRECTORY\" ]; then echo \"$DIRECTORY exists\"; else mkdir $DIRECTORY;fi"
	rsync -az $GTFREE/$xmltype/ boerre@divvun.no:$DIRECTORY

	DIRECTORY=/Users/hoavda/Public/corp/boundcorpus/$xmltype/$DATE
	ssh boerre@divvun.no "if [ -d \"$DIRECTORY\" ]; then echo \"$DIRECTORY exists\"; else mkdir $DIRECTORY;fi"
	rsync -az $GTBOUND/$xmltype/ boerre@divvun.no:$DIRECTORY
done

