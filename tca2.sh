#!/bin/sh

# sentence alignment tool
# source code in $GTHOME/tools/alignment-tools
java -Xms512m -Xmx1024m -jar /usr/local/share/tca2/alignment.jar $1 $2 $3 $4
