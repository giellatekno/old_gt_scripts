
for file in $(find . -name "*.xml")
    do
        echo "Replacing on : $file"
        sed 's/<strong>\([^<]*\)<\/strong><\/a>/\1<\/a>/' $file > $file.tmp1
        mv -f $file.tmp1 $file
        echo "Replacement done on : $file"
        rm -f $file.tmp1
done
