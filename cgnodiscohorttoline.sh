#!/bin/bash

cat $1 | cut -d"\t" -f2 | | cut -d" " -f2 | perl -p -i -e 's/.\n/ /g' 