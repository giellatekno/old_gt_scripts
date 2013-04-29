#!/bin/bash

cat $@ | cut -d"	" -f2 | cut -d" " -f2 | perl -p -i -e 's/.\n/ /g' 