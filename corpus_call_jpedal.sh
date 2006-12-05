#!/bin/sh

libDir=/home/saara/src/jpedal/additional_jars
jpedalDir=/home/saara/src/jpedal

mei=$@

a=$(echo "$@" | grep '.*-D.*')
if [ ! -z "$a" ]
then 
	twocol="-Dcol"
fi

echo $mei

if [ -n "$1" -a -n "$2" ]
then
	file=$(echo $1 | sed -re "s/.*\///")
	basename=$(echo $1 | sed -re "s/.*\/(.*)\.pdf/\1/")
	java $twocol -Ddir=$2/$basename -Dxml -cp $libDir/bcprov-jdk14-119.jar:$libDir/jai_core.jar:$libDir/jai_codec.jar:$jpedalDir/os_jpedal.jar org/jpedal/examples/text/ExtractTextInRectangle $1
fi 


