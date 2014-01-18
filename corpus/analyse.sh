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
svn up

for lang in sma sme smj
do
	cd $GTHOME/langs/$lang
	./autogen.sh
	./configure
	make

	for corpus in $GTFREE $GTBOUND
	do
		cd $corpus
		svn up orig/$lang
		make_corpus.py orig/$lang
		time analyse_corpus $lang converted/$lang
	done
done

#for lang in sma sme smj
#do
#	#ccatter.py $HOME/ccats/ $lang $GTFREE/converted/$lang $GTBOUND/converted/$lang
#done


# rsync -az $HOME/ccats boerre@divvun.no:/Users/hoavda/Public/corp/.
for xmltype in converted analysed
do
	ssh boerre@divvun.no "rm -rf /Users/hoavda/Public/corp/freecorpus/$xmltype"
	rsync -az $GTFREE/$xmltype boerre@divvun.no:/Users/hoavda/Public/corp/freecorpus/.

	ssh boerre@divvun.no "rm -rf /Users/hoavda/Public/corp/boundcorpus/$xmltype"
	rsync -az $GTBOUND/$xmltype boerre@divvun.no:/Users/hoavda/Public/corp/boundcorpus/.
done

