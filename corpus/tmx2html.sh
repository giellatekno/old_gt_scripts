for dir in toktmx tmx
do
    for file in `find $GTFREE/prestable/$dir -name \*.tmx`
    do
        xsltproc $GTHOME/gt/script/corpus/tmx2html.xsl $file > $file.html
    done
done