#!/bin/sh


# File to run all our complation
# processes. Pick and uncomment at will.
echo ""
echo " This script will compile all our analysers and lexica "
echo ""
pushd
cd $GTHOME/gt
echo "===>                    <===" 
echo "===>   Sámi languages   <===" 
echo "===>                    <===" 
echo ""
echo "===>     South Sámi      <==="
nice time make TARGET=sma
echo ""
echo "===>     North Sámi      <==="
nice time make TARGET=sme
echo ""
echo "===>     Lule Sámi       <==="
nice time make TARGET=smj
echo ""
echo "===>     Inari Sámi      <==="
nice time make TARGET=smn
echo ""
echo "===>     Skolt Sámi      <==="
nice time make TARGET=sms
echo ""
echo "===>     Kildin Sámi     <==="
nice time make TARGET=sjd
echo ""
echo "===>      Pite Sámi      <==="
nice time make TARGET=sje
echo "===>                    <===" 
echo "===>   Other languages  <===" 
echo "===>                    <===" 
cd $GTHOME/st/fao/src
echo ""
echo "===>       Faroese       <===" 
nice time make
cd $GTHOME/st/kal/src
echo ""
echo "===>     Greenlandic     <===" 
nice time make TARGET=sloppy
cd $GTHOME/st/nob/src
echo ""
echo "===>      Bokmål      <===" 
nice time make
echo ""
echo "===>    Nynorsk       <===" 
cd $GTHOME/st/nno/src
nice time make
echo ""
echo "===>    Old Norse     <===" 
cd $GTHOME/st/non/src
nice time make
cd $GTHOME/st/ces/src
echo ""
echo "===>    Czech     <===" 
nice time make
cd $GTHOME/st/deu/src
echo ""
echo "===>    German    <===" 
nice time make
cd $GTHOME/st/amh/src
echo ""
echo "===>    Amharic   <===" 
nice time make
cd $GTHOME/st/eng/src
echo ""
echo "===>    English      <===" 
nice time make
cd $GTHOME/st/cor/src
echo ""
echo "===>    Cornish   <===" 
nice time make
cd $GTHOME/st/ipk/src
echo ""
echo "===>     Iñupiaq     <===" 
nice time make
cd $GTHOME/st/iku/src
echo ""
echo "===>     Inuktitut     <===" 
nice time make
echo "===>                    <===" 
echo "===>  Bilingual transd. <===" 
echo "===>                    <===" 
cd $GTHOME/words/dicts/smesmj/src
echo ""
echo "===>     Dictionaries   <===" 
nice time make
cd $GTHOME/words/dicts/smenob
echo ""
echo "===>   North Sámi - Norwegian   <===" 
nice time make
cd $GTHOME/words/dicts/kaleng/src/
echo ""
echo "===>   Greenlandic - English   <===" 
nice time make
cd $GTHOME/words/dicts/kaldan/
echo ""
echo "===>   Greenlandic - Danish   <===" 
nice time make

cd $GTHOME/words/dicts/smi/geo/src/
echo ""
echo "===>   Geographic fst   <===" 
nice time make
cd $GTHOME/kvensk/fkvnob/
echo ""
echo "===>   Kven - Norwegian   <===" 
nice time make
cd $GTHOME/kvensk/nobfkv/
echo ""
echo "===>   Norwegian - Kven   <===" 
nice time make
cd $GTHOME/kvensk/fitswe/
echo ""
echo "===>   Meänkieli - Swedish   <===" 
nice time make 
cd $GTHOME/kvensk/swefit
echo ""
echo "===>   Swedish - Meänkieli   <===" 
nice time make
echo "===>                    <===" 
echo "===> Other FU languages <===" 
echo "===>                    <===" 
cd $GTHOME/kt/fin/src
echo "===>               <==="
echo "===>     Finnish   <===" 
echo "===>               <==="
nice time make
#cd $GTHOME/kt/kom/src
# For some reason, the Makefile timing does not work here. Have a look.
#echo "===>              <==="
#echo "===>     Komi     <===" 
#echo "===>              <==="
#nice time make
popd
echo "===>                  <==="
echo "===>                  <==="
echo "===>                  <==="
echo "===> Done, at last  . <==="
echo "===>                  <==="
