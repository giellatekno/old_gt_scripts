for file in $(find $GTFREE/prestable/tmx -name '*.tmx' -type f)
do
    xsltproc $GTHOME/gt/script/corpus/tmx2html.xsl $file > $file.html
done
