#!/bin/sh

# File to clean all generated files produced
# during compilation.
echo ""
echo " This script will all generated files from all our langauges. "
echo ""
pushd .
cd $GTHOME/gt
echo "===>                    <===" 
echo "===>   Sámi languages   <===" 
echo "===>                    <===" 
echo ""
echo "===>     South Sámi      <==="
nice time make clean GTLANG=sma
echo ""
echo "===>     North Sámi      <==="
nice time make clean GTLANG=sme
echo ""
echo "===>     Lule Sámi       <==="
nice time make clean GTLANG=smj
echo ""
echo "===>     Inari Sámi      <==="
nice time make clean GTLANG=smn
echo ""
echo "===>     Skolt Sámi      <==="
nice time make clean GTLANG=sms
echo ""
echo "===>     Kildin Sámi     <==="
nice time make clean GTLANG=sjd
echo ""
echo "===>      Pite Sámi      <==="
nice time make clean GTLANG=sje
echo "===>                    <===" 
echo "===>   Other languages  <===" 
echo "===>                    <===" 
echo ""
echo "===>       Faroese       <===" 
cd $GTHOME/st/fao/src
nice time make clean
echo ""
echo "===>     Greenlandic     <===" 
cd $GTHOME/st/kal/src
nice time make clean GTLANG=sloppy
echo ""
echo "===>      Bokmål      <===" 
cd $GTHOME/st/nob/src
nice time make clean
echo ""
echo "===>    Nynorsk       <===" 
cd $GTHOME/st/nno/src
nice time make clean
echo ""
echo "===>    Old Norse     <===" 
cd $GTHOME/st/non/src
nice time make clean
echo ""
echo "===>    Czech     <===" 
cd $GTHOME/st/ces/src
nice time make clean
echo ""
echo "===>    German    <===" 
cd $GTHOME/st/deu/src
nice time make clean
echo ""
echo "===>    Amharic   <===" 
cd $GTHOME/st/amh/src
nice time make clean
echo ""
echo "===>    English      <===" 
cd $GTHOME/st/eng/src
nice time make clean
echo ""
echo "===>    Cornish   <===" 
cd $GTHOME/st/cor/src
nice time make clean
echo ""
echo "===>     Iñupiaq     <===" 
cd $GTHOME/st/ipk/src
nice time make clean
echo ""
echo "===>     Inuktitut     <===" 
cd $GTHOME/st/iku/src
nice time make clean
echo "===>                    <===" 
echo "===>  Bilingual transd. <===" 
echo "===>                    <===" 
echo "===>   North Sámi - Lule Sámi  <===" 
cd $GTHOME/words/dicts/smesmj/src
nice time make clean
echo ""
echo "===>     Dictionaries   <===" 
echo ""
echo "===>   North Sámi - Norwegian   <===" 
cd $GTHOME/words/dicts/smenob
nice time make clean
echo ""
echo "===>   Greenlandic - English   <===" 
cd $GTHOME/words/dicts/kaleng/src/
nice time make clean
echo ""
echo "===>   Greenlandic - Danish   <===" 
cd $GTHOME/words/dicts/kaldan/
nice time make clean

echo ""
echo "===>   Geographic fst   <===" 
cd $GTHOME/words/dicts/smi/geo/src/
nice time make clean
echo ""
echo "===>   Kven - Norwegian   <===" 
cd $GTHOME/kvensk/fkvnob/
nice time make clean
echo ""
echo "===>   Norwegian - Kven   <===" 
cd $GTHOME/kvensk/nobfkv/
nice time make clean
echo ""
echo "===>   Meänkieli - Swedish   <===" 
cd $GTHOME/kvensk/fitswe/
nice time make clean 
echo ""
echo "===>   Swedish - Meänkieli   <===" 
cd $GTHOME/kvensk/swefit
nice time make clean
echo "===>                    <===" 
echo "===> Other FU languages <===" 
echo "===>                    <===" 
echo "===>               <==="
echo "===>     Finnish   <===" 
echo "===>               <==="
cd $GTHOME/kt/fin/src
nice time make clean
#cd $GTHOME/kt/kom/src
# For some reason, the Makefile timing does not work here. Have a look.
#echo "===>              <==="
#echo "===>     Komi     <===" 
#echo "===>              <==="
#nice time make clean
popd
echo "===>                  <==="
echo "===>                  <==="
echo "===>                  <==="
echo "===> Done, at last  . <==="
echo "===>                  <==="
