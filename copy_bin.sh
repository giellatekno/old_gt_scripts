#!/bin/bash

#****************************************************************
#			copy_bin.sh
#			written by Saara Huhmarniemi
#			Oct 30, 2006
#
#           Copy the scripts and binaries that are needed in
#           corpus- and other linguistic work to the common bin.
#
# $Id$
#****************************************************************

host=$(hostname)
# Set variables according to the current host.
if [ "$host" == "victorio.uit.no" ]
then
    tmpdir=/usr/tmp
else
	group=staff
	tmpdir=/tmp
fi
script_dir=$tmpdir/gt/script
bindir=$tmpdir/gt/bin
srcdir=$tmpdir/gt/src
tooldir=$GT_HOME/tools/lang-guesser

common_bin=/usr/local/bin

own_modules="samiChar
langTools"
#other_modules="XML::Twig"

binaries="ccat"

scripts="preprocess lookup2cg $tooldir/text_cat.pl cgi-export"

# If we are in G5
if [ "$host" == "victorio.uit.no" ]
then 
	perl_libdir=/usr/lib/perl5/5.8.8
	echo "Check out gt from cvs"
	cvs -d /usr/local/cvs/repository checkout -d $tmpdir/gt gt
else
	perl_libdir=/Library/Perl/5.8.6
	perl_libdir2=/sw/lib/perl5/5.8.6
	cd $tmpdir && cvs -d :ext:victorio.uit.no:/usr/local/cvs/repository checkout gt
fi


##### start copying

echo "*** Copying requires sudo rights ***"

# make and copy ccat
echo "Making and copying ccat.."
echo "cd $script_dir/samiXMLParser && make"
cd $script_dir/samiXMLParser && make
echo "cp $script_dir/samiXMLParser/ccat $common_bin"
sudo cp $script_dir/samiXMLParser/ccat $common_bin

# copy scripts
echo "Copying scripts.."
for s in $scripts
do 
  echo "cp $script_dir/$s $common_bin"
  sudo cp $script_dir/$s $common_bin
done

# copy perl modules
echo "Copying Perl modules.."
for mod in $own_modules
do
  echo "cp -r $script_dir/$mod $perl_libdir"
  sudo cp -r $script_dir/$mod $perl_libdir
  if [ "$host" == "victorio.uit.no" ]
	  then 
	  echo
  else
	  echo "cp -r $script_dir/$mod $perl_libdir2"
	  sudo cp -r $script_dir/$mod $perl_libdir2
  fi
done

