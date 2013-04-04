#!/bin/bash

cat $1 | sed 's/$/#/g' | perl -p -i -e 's/"</\n"</g' | perl -p -i -e 's/#\n/ /g'
