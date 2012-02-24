#!/bin/bash

for file in `find $GTFREE/prestable/converted/sme -name \*.xml`
do
    typosfile=`echo $file | sed -e 's/.xml$/.typos/'`
    ccat -a -l sme $file | hunspell -l --check-url | sed -e 's_[0-9]\{1,2\}/[0-9][0-9]__' -e 's_[0-9]\{4\}:s__' -e 's/[A-ZÁŠŦŊĐŽČa-zášŧŋđžč]\.//' -e 's/^[A-ZÁŠŦŊĐŽČa-zášŧŋđžč\/]$//' -e 's/\/_+//' -e '/^$/ d' > $typosfile
    echo -n .
done