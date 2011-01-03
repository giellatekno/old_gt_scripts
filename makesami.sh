#!/bin/sh

# File to run all our compilation
# processes.
echo ""
echo " This script will compile all our Sami analysers and lexica "
echo ""
pushd $GTHOME/gt
echo "===>                    <===" 
echo "===>   Sámi languages   <===" 
echo "===>                    <===" 
echo ""
echo "===>     South Sámi      <==="
nice time make GTLANG=sma all
echo ""
echo "===>     North Sámi      <==="
nice time make GTLANG=sme all
echo ""
echo "===>     Lule Sámi       <==="
nice time make GTLANG=smj all
echo ""
echo "===>     Inari Sámi      <==="
nice time make GTLANG=smn all
echo ""
echo "===>     Skolt Sámi      <==="
nice time make GTLANG=sms all
echo ""
echo "===>     Kildin Sámi     <==="
nice time make GTLANG=sjd all
echo ""
echo "===>      Pite Sámi      <==="
nice time make GTLANG=sje all

echo "===>                    <===" 
echo "===>  Bilingual transd. <===" 
echo "===>                    <===" 
echo "===>   North Sámi - Lule Sámi  <===" 
cd $GTHOME/words/dicts/smesmj/src
nice time make

echo ""
echo "===>     Dictionaries   <===" 
echo ""
echo "===>   South Sámi - Norwegian (South Sámi lemmata only) <===" 
cd $GTHOME/words/dicts/smanob
nice time make
nice time make -f make-smadict
echo ""
echo "===>   North Sámi - Norwegian   <===" 
cd $GTHOME/words/dicts/smenob
nice time make
nice time make -f make-smedict
echo ""
echo "===>   Geographic fst   <===" 
cd $GTHOME/words/dicts/smi/geo/src/
nice time make
echo ""
echo "===>   DONE!!!   <===" 
popd