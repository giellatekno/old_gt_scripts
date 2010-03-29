#!/bin/sh

# File to run all our compilation
# processes.
echo ""
echo " This script will compile all our analysers and lexica "
echo ""
pushd .
cd $GTHOME/gt
echo "===>                    <===" 
echo "===>   Sámi languages   <===" 
echo "===>                    <===" 
echo ""
echo "===>     South Sámi      <==="
nice time make TARGET=sma all
echo ""
echo "===>     North Sámi      <==="
nice time make TARGET=sme all
echo ""
echo "===>     Lule Sámi       <==="
nice time make TARGET=smj all
echo ""
echo "===>     Inari Sámi      <==="
nice time make TARGET=smn all
echo ""
echo "===>     Skolt Sámi      <==="
nice time make TARGET=sms all
echo ""
echo "===>     Kildin Sámi     <==="
nice time make TARGET=sjd all
echo ""
echo "===>      Pite Sámi      <==="
nice time make TARGET=sje all
echo "===>                    <===" 
echo "===>   Other languages  <===" 
echo "===>                    <===" 
echo ""
echo "===>       Faroese       <===" 
cd $GTHOME/st/fao/src
nice time make
echo ""
echo "===>     Greenlandic     <===" 
cd $GTHOME/st/kal/src
nice time make TARGET=sloppy
echo ""
echo "===>      Bokmål      <===" 
cd $GTHOME/st/nob/src
nice time make
echo ""
echo "===>    Nynorsk       <===" 
cd $GTHOME/st/nno/src
nice time make
echo ""
echo "===>    Old Norse     <===" 
cd $GTHOME/st/non/src
nice time make
echo ""
echo "===>    Czech     <===" 
cd $GTHOME/st/ces/src
nice time make
echo ""
echo "===>    German    <===" 
cd $GTHOME/st/deu/src
nice time make
echo ""
echo "===>    Guaraní    <===" 
cd $GTHOME/st/grn/src
nice time make
echo ""
echo "===>    Amharic   <===" 
cd $GTHOME/st/amh/src
nice time make
echo ""
echo "===>    English      <===" 
cd $GTHOME/st/eng/src
nice time make
echo ""
echo "===>    Cornish   <===" 
cd $GTHOME/st/cor/src
nice time make
echo ""
echo "===>     Iñupiaq     <===" 
cd $GTHOME/st/ipk/src
nice time make
echo ""
echo "===>     Inuktitut     <===" 
cd $GTHOME/st/iku/src
nice time make
echo ""
echo "===>    Kurdish   <===" 
cd $GTHOME/st/kmr/src
nice time make
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
nice time make -f make-smadict
echo ""
echo "===>   North Sámi - Norwegian   <===" 
cd $GTHOME/words/dicts/smenob
nice time make
echo ""
echo "===>   Greenlandic - English   <===" 
cd $GTHOME/words/dicts/kaleng/src/
nice time make
echo ""
echo "===>   Greenlandic - Danish   <===" 
cd $GTHOME/words/dicts/kaldan/
nice time make

echo ""
echo "===>   Geographic fst   <===" 
cd $GTHOME/words/dicts/smi/geo/src/
nice time make
echo ""
echo "===>   Kven - Norwegian   <===" 
cd $GTHOME/words/dicts/fkvnob/
nice time make
echo ""
echo "===>   Norwegian - Kven   <===" 
cd $GTHOME/words/dicts/nobfkv/
nice time make
echo ""
echo "===>   Meänkieli - Swedish   <===" 
cd $GTHOME/words/dicts/fitswe/
nice time make 
echo ""
echo "===>   Swedish - Meänkieli   <===" 
cd $GTHOME/words/dicts/swefit
nice time make
echo "===>                    <===" 
echo "===> Other FU languages <===" 
echo "===>                    <===" 
echo "===>               <==="
echo "===>     Finnish   <===" 
echo "===>               <==="
cd $GTHOME/kt/fin/src
nice time make
#cd $GTHOME/kt/kom/src
# For some reason, the Makefile timing does not work here. Have a look.
#echo "===>              <==="
#echo "===>     Komi     <===" 
#echo "===>              <==="
#nice time make

echo ""
echo ""
echo "===>   Now, let us try the hfst compiler   <==="
echo "===> Just ignore this if you don't have it <==="
echo ""
echo ""

echo ""
echo "===>       Faroese       <===" 
cd $GTHOME/st/fao/src
nice time make -f Makefile.hfst
echo ""
echo ""
echo "===>       Kurdish       <===" 
cd $GTHOME/st/fao/src
nice time make -f Makefile.hfst
echo ""
echo ""
echo "===>       Tagalog       <===" 
cd $GTHOME/st/fao/src
nice time make -f Makefile.hfst
echo ""
echo ""
echo "===>       Kven       <===" 
cd $GTHOME/st/fao/src
nice time make -f Makefile.hfst
echo ""


popd
echo "===>                  <==="
echo "===>                  <==="
echo "===>                  <==="
echo "===> Done, at last  . <==="
echo "===>                  <==="
