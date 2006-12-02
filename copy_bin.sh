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

tmpdir=/usr/tmp
script_dir=$tmpdir/gt/script
bindir=$tmpdir/gt/bin
srcdir=$tmpdir/gt/src

host=$(hostname)

# If we are in G5
if [ "$host" == "hum-tf4-ans142.hum.uit.no" ]
then 
	perl_libdir=/Library/Perl/5.8.6
else
	perl_libdir=/usr/lib/perl5/5.8.5
fi

common_bin=/usr/local/bin

own_modules="samiChar
langTools"
#other_modules="XML::Twig"

binaries="ccat"

scripts="preprocess lookup2cg text_cat cgi-export"

##### start copying

# First check out the lateset version from cvs.
echo "Check out gt from cvs"
cvs -d /usr/local/cvs/repository checkout -d $tmpdir/gt gt

# make and copy ccat
echo "Making and copying ccat.."
echo "cd $script_dir/samiXMLParser && make"
cd $script_dir/samiXMLParser && make
echo "cp $script_dir/samiXMLParser/ccat $common_bin"
cp $script_dir/samiXMLParser/ccat $common_bin

# copy scripts
echo "Copying scripts.."
for s in $scripts
do 
  echo "cp $script_dir/$s $common_bin"
  cp $script_dir/$s $common_bin
done

# copy perl modules
echo "Copying Perl modules.."
for mod in $own_modules
do
  echo "cp -r $script_dir/$mod $perl_libdir"
  cp -r $script_dir/$mod $perl_libdir
done

