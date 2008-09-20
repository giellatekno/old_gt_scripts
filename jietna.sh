

cat $1 | preprocess | \
lookup -flags mbTT -utf8 $HOME/gtsvn/gt/sme/bin/sme-num.fst | \
cut -f2 | tr ' ' '\n' | \
lookup -flags mbTT -utf8 $HOME/gtsvn/gt/sme/bin/hyphrules-sme.fst | \
cut -f2 | \
lookup -flags mbTT -utf8 $HOME/gtsvn/gt/sme/bin/phon-sme.fst | \
cut -f2 | tr '\n' ' ' | tr -s ' '
