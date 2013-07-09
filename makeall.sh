#!/bin/sh

echo ""
echo " This script will compile in our new infrastructure"
echo ""


echo ""
echo "===>     All the newinfra languages      <==="
pushd $GTHOME/langs

echo " -------------------------------------------------------------------------------------- ciw, Ojibwe "
cd   ciw && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- crk, Plains Cree "
cd ../crk && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- cor, Cornish "
cd ../cor && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- est, Estonian "
cd ../est && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- fao, Faroese "
cd ../fao && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- fin, Finnish "
cd ../fin && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- fkv, Kven "
cd ../fkv && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- ipk, Iñupiaq "
cd ../ipk && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- izh, Izhorian "
cd ../izh && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- kal, Greenlandic "
echo " "
echo " No, sorry, we skip Greenlandic. It takes to long time to compile."
echo " In order to compile Greenlandic, do this:"
echo " cd $GTHOME/langs/kal/"
echo " ./autogen.sh && ./configure && make "
echo " "
#cd ../kal && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- kca, Khanty "
cd ../kca && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- kpv, Komi Zyryan "
cd ../kpv && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- liv, Livonian "
cd ../liv && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- mdf, Moksha "
cd ../mdf && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- mhr, Meadow Mari "
cd ../mhr && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- mrj, Hill Mari "
cd ../mrj && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- myv, Erzya "
cd ../myv && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- ndl, Ndolo "
cd ../ndl && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- nio, Nganasan "
cd ../nio && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- nob, Norwegian Bokmål "
cd ../nob && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- olo, Olonetsian "
cd ../olo && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- ron, Rumanian "
cd ../ron && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- sjd, Kildin Saami "
cd ../sjd && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- sje, Pite Saami "
cd ../sje && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- sma, South Saami "
cd ../sma && pwd && nice ./autogen.sh && nice ./configure --enable-oahpa --with-hfst&& nice make   # adjectives.lexc
#cd ../sma && pwd && nice ./autogen.sh && nice ./configure --enable-oahpa --with-hfst&& nice make  # adjectives-oahpa.lexc
echo " -------------------------------------------------------------------------------------- smj, Lule Saami "
cd ../smj && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- smn, Inari Saami "
cd ../smn && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- sms, Skolt Saami "
cd ../sms && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- som, Somali "
cd ../som && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- tlh, Klingon "
cd ../tlh && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- tuv, Turkana "
cd ../tuv && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- udm, Udmurt "
cd ../udm && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- vep, Veps "
cd ../vep && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- vro, Võro "
cd ../vro && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- yrk, Tundra Nenets "
cd ../yrk && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 
echo " -------------------------------------------------------------------------------------- zul, Zulu "
cd ../zul && pwd && nice ./autogen.sh && nice ./configure --with-hfst&& nice make 


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
echo "===>                    <===" 
echo "===>   Other languages  <===" 
echo "===>                    <===" 
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
