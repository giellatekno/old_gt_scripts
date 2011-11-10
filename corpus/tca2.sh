#!/bin/sh

# $1 = anchor file
# $2 = first input file
# $3 = second input file

# sentence alignment tool
# source code in $GTHOME/tools/alignment-tools
java -Xms512m -Xmx1024m -jar $GTHOME/tools/alignment-tools/tca2/dist/lib/alignment.jar -cli -anchor=$1 -in1=$2 -in2=$3
