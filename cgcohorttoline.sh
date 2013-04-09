#!/bin/bash

cat $@ | sed 's/$/#/g' | perl -p -i -e 's/"</\n"</g' | perl -p -i -e 's/#\n/ /g'
