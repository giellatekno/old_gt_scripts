for file in $(find $GTFREE/prestable/tmx -name '*.tmx' -type f)
do
    xsltproc $GTHOME/tools/CorpusTools/corpustools/xslt/tmx2html.xsl $file > $file.html
done
