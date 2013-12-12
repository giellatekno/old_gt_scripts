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
cd $GTHOME/gt
make GTLANG=sme
make GTLANG=sme abbr
cd $GTHOME/langs/sma
./autogen.sh
./configure
make
cd $GTFREE
svn up
make clean
make_corpus.py orig
cd $GTBOUND
svn up
make clean
make_corpus.py orig

for lang in sma sme
do
	ccatter.py $HOME/ccats/ $lang $GTFREE/converted/$lang $GTBOUND/converted/$lang
	time analyse_corpus.py --lang $lang --analysisdir $HOME/analysed $GTFREE/converted/$lang $GTBOUND/converted/$lang 2> $HOME/$lang.log
done

find $GTFREE/converted/ -type f \! -name \*.xml | xargs rm
find $GTBOUND/converted/ -type f \! -name \*.xml | xargs rm

ssh boerre@divvun.no "rm -rf /Users/hoavda/Public/corp/boundcorpus/converted"
ssh boerre@divvun.no "rm -rf /Users/hoavda/Public/corp/freecorpus/converted"

rsync -az $GTFREE/converted boerre@divvun.no:/Users/hoavda/Public/corp/freecorpus/.
rsync -az $GTBOUND/converted boerre@divvun.no:/Users/hoavda/Public/corp/boundcorpus/.
rsync -az $HOME/ccats boerre@divvun.no:/Users/hoavda/Public/corp/.
rsync -az $HOME/analysed/* boerre@divvun.no:/Users/hoavda/Public/corp/analysed/.

