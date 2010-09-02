#!/bin/sh

# $1 = -a 
# $2 = anchor file
# $3 = first input file
# $4 = second input file

# sentence alignment tool
# source code in $GTHOME/tools/alignment-tools
java -Xms512m -Xmx1024m -jar /usr/local/share/tca2/alignment.jar $1 $2 $3 $4
