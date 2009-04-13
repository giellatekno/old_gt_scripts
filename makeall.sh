#!/bin/sh


# File to run all our complation
# processes. Pick and uncomment at will.
echo ""
echo " This script will compile all our analysers and lexica "
echo ""
cd ~/svnredone/gt
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
cd ~/svnredone/st/fao/src
echo ""
echo "===>      Pite Sámi      <==="
nice time make TARGET=sje
cd ~/svnredone/st/fao/src
echo ""
echo "===>       Faroese       <===" 
nice time make
cd ~/svnredone/st/kal/src
echo ""
echo "===>     Greenlandic     <===" 
nice time make TARGET=sloppy
cd ~/svnredone/st/nob/src
echo ""
echo "===>      Bokmål      <===" 
nice time make
echo ""
echo "===>    Nynorsk       <===" 
cd ~/svnredone/st/nno/src
nice time make
echo ""
echo "===>    Old Norse     <===" 
cd ~/svnredone/st/non/src
nice time make
cd ~/svnredone/st/ces/src
echo ""
echo "===>    Czech     <===" 
nice time make
cd ~/svnredone/st/deu/src
echo ""
echo "===>    German    <===" 
nice time make
cd ~/svnredone/st/amh/src
echo ""
echo "===>    Amharic   <===" 
nice time make
cd ~/svnredone/st/eng/src
echo ""
echo "===>    English      <===" 
nice time make
cd ~/svnredone/st/cor/src
echo ""
echo "===>    Cornish   <===" 
nice time make
cd ~/svnredone/st/ipk/src
echo ""
echo "===>     Iñupiaq     <===" 
nice time make
cd ~/svnredone/words/dicts/smesmj/src
echo ""
echo "===>     Dictionaries   <===" 
nice time make
cd ~/svnredone/words/dicts/smenob
echo ""
echo "===>   North Sámi - Norwegian   <===" 
nice time make
cd ~/svnredone/words/dicts/kaleng/src/
echo ""
echo "===>   Greenlandic - English   <===" 
nice time make
cd ~/svnredone/words/dicts/kaldan/
echo ""
echo "===>   Greenlandic - Danish   <===" 
nice time make

cd ~/svnredone/words/dicts/smi/geo/src/
echo ""
echo "===>   Geographic fst   <===" 
nice time make
cd ~/svnredone/kvensk/fkvnob/
echo ""
echo "===>   Kven - Norwegian   <===" 
nice time make
cd ~/svnredone/kvensk/nobfkv/
echo ""
echo "===>   Norwegian - Kven   <===" 
nice time make
cd ~/svnredone/kvensk/fitswe/
echo ""
echo "===>   Meänkieli - Swedish   <===" 
nice time make 
cd ~/svnredone/kvensk/swefit
echo ""
echo "===>   Swedish - Meänkieli   <===" 
nice time make
cd ~/svnredone/kt/fin/src
echo "===>               <==="
echo "===>     Finnish   <===" 
echo "===>               <==="
nice time make
#cd ~/svnredone/kt/kom/src
# For some reason, the Makefile timing does not work here. Have a look.
#echo "===>              <==="
#echo "===>     Komi     <===" 
#echo "===>              <==="
#nice time make
echo "===>                  <==="
echo "===>                  <==="
echo "===>                  <==="
echo "===> Done, at last  . <==="
echo "===>                  <==="
