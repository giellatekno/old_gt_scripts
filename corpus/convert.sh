#!/bin/sh -l

#
# This script is specific for the conversion that is done
# on stallo
#

qsub convert2xml --debug /home/boerre/svnrepos/freecorpus/orig/sma
qsub convert2xml --debug /home/boerre/svnrepos/freecorpus/orig/sme
qsub convert2xml --debug /home/boerre/svnrepos/freecorpus/orig/smj

qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sma
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/admin
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/bible
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/facta
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/ficti
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/laws
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/Assu/1995
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/Assu/1996
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/Assu/1997
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/Assu/1998
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/Assu/1999
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/Avvir_xml-filer/Avvir_2008_xml-filer
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/Avvir_xml-filer/Avvir_2009_xml-filer
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/Avvir_xml-filer/Avvir_2010_xml-filer
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/MinAigi
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/MinAigi/1997
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/MinAigi/1998
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/MinAigi/1999
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/MinAigi/2000
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/MinAigi/2001
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/MinAigi/2003
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/MinAigi/2004
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/MinAigi/2005
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/MinAigi/2006
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/MinAigi/2007
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/MinAigi/2008
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/avvir.no
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/sme/news/minaigi.no
qsub convert2xml --debug /home/boerre/svnrepos/boundcorpus/orig/smj
