#!/bin/sh

echo ""
echo " This script will compile in our new infrastructure"
echo ""


echo ""
echo "===>     All the newinfra languages      <==="
pushd $GTHOME/newinfra/langs

cd   fao && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../fin && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../izh && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
#cd ../kal && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../kca && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../kpv && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../liv && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../mdf && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../mhr && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../mrj && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../myv && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../ndl && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../nio && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../olo && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../sma && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../smj && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../tlh && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../tuv && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../vep && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../yrk && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"
cd ../zul && pwd && nice ./autogen.sh && nice ./configure && nice make && echo "--- >>> <<< ---"


# File to run all our compilation
# processes in xerox.
echo ""
echo " This script will compile all our analysers and lexica with xerox"
echo ""
pushd $GTHOME/gt
echo "===>                    <===" 
echo "===>   Sámi languages   <===" 
echo "===>                    <===" 
echo ""
echo "===>     North Sámi      <==="
nice time make GTLANG=sme all
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
echo "===>   Other languages  <===" 
echo "===>                    <===" 
echo ""
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
nice time make
nice time make -f make-smadict
echo ""
echo "===>   North Sámi - Norwegian   <===" 
cd $GTHOME/words/dicts/smenob
nice time make
nice time make -f make-smedict
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
# fitswe is not in the public domain.
#echo ""
#echo "===>   Meänkieli - Swedish   <===" 
#cd $GTHOME/words/dicts/fitswe/
#nice time make 
#echo ""
#echo "===>   Swedish - Meänkieli   <===" 
#cd $GTHOME/words/dicts/swefit
#nice time make



popd
echo "===>                  <==="
echo "===>                  <==="
echo "===>                  <==="
echo "===> Done, at last  . <==="
echo "===>                  <==="
