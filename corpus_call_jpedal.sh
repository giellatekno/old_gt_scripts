#!/bin/sh

libDir=/home/saara/src/jpedal/additional_jars
jpedalDir=/home/saara/src/jpedal

mei=$@

a=$(echo "$@" | perl -pe "if (/\-D/) { s/(.*?)\-D/-D/; } else {s/.*//; }")

if [ -n "$1" -a -n "$2" ]
then
	file=$(echo $1 | sed -re "s/.*\///")
	basename=$(echo $1 | sed -re "s/.*\/(.*)\.pdf/\1/")
	echo java $a -Ddir=$2/$basename -Dxml -cp $libDir/bcprov-jdk14-119.jar:$libDir/jai_core.jar:$libDir/jai_codec.jar:$jpedalDir/os_jpedal.jar org/jpedal/examples/text/ExtractTextInRectangle $1
	java $a -Ddir=$2/$basename -Dxml -cp $libDir/bcprov-jdk14-119.jar:$libDir/jai_core.jar:$libDir/jai_codec.jar:$jpedalDir/os_jpedal.jar org/jpedal/examples/text/ExtractTextInRectangle $1 > /dev/null
fi 
