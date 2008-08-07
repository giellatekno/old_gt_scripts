#!/bin/sh


# File to run all our complation
# processes. Pick and uncomment at will.
echo ""
echo " This script will compile all our analysers and lexica "
echo ""
cd ~/gtsvn/gt
echo "===>                     <==="
echo "===>     South Sámi      <==="
echo "===>                     <==="
nice time make TARGET=sma
echo "===>                     <==="
echo "===>     North Sámi      <==="
echo "===>                     <==="
nice time make TARGET=sme
echo "===>                     <==="
echo "===>     Lule Sámi       <==="
echo "===>                     <==="
nice time make TARGET=smj
echo "===>                     <==="
echo "===>     Inari Sámi      <==="
echo "===>                     <==="
nice time make TARGET=smn
echo "===>                     <==="
echo "===>     Skolt Sámi      <==="
echo "===>                     <==="
nice time make TARGET=sms
echo "===>                     <==="
echo "===>     Kildin Sámi     <==="
echo "===>                     <==="
nice time make TARGET=sjd
cd ~/gtsvn/st/fao/src
echo "===>                     <==="
echo "===>       Faroese       <===" 
echo "===>                     <==="
nice time make
cd ~/gtsvn/st/kal/src
echo "===>                     <==="
echo "===>     Greenlandic     <===" 
echo "===>                     <==="
nice time make TARGET=sloppy
cd ~/gtsvn/st/nob/src
echo "===>     		        <==="
echo "===>      Bokmål      <===" 
echo "===>     		        <==="
nice time make
echo "===>     			    <==="
echo "===>    Nynorsk       <===" 
echo "===>     			    <==="
cd ~/gtsvn/st/nno/src
nice time make
echo "===>     			    <==="
echo "===>    Old Norse     <===" 
echo "===>     			    <==="
cd ~/gtsvn/st/non/src
nice time make
cd ~/gtsvn/st/ces/src
echo "===>              <==="
echo "===>    Czech     <===" 
echo "===>              <==="
nice time make
cd ~/gtsvn/st/deu/src
echo "===>              <==="
echo "===>    German    <===" 
echo "===>              <==="
nice time make
cd ~/gtsvn/st/amh/src
echo "===>              <==="
echo "===>    Amharic   <===" 
echo "===>              <==="
nice time make
cd ~/gtsvn/st/eng/src
echo "===>                 <==="
echo "===>    English      <===" 
echo "===>                 <==="
nice time make
cd ~/gtsvn/st/kor/src
echo "===>              <==="
echo "===>    Cornish   <===" 
echo "===>              <==="
nice time make
cd ~/gtsvn/st/ipk/src
echo "===>                 <==="
echo "===>     Iñupiaq     <===" 
echo "===>                 <==="
nice time make
cd ~/gtsvn/words/dicts/smesmj/src
echo "===>                    <==="
echo "===>     Dictionaries   <===" 
echo "===>                    <==="
nice time make
cd ~/gtsvn/words/dicts/smenob/src
nice time make
cd ~/gtsvn/kvensk/fkvnob/
nice time make
cd ~/gtsvn/kvensk/nobfkv/
nice time make
cd ~/gtsvn/kvensk/fitswe/
nice time make 
cd ~/gtsvn/kvensk/swefit
nice time make
cd ~/gtsvn/kt/fin/src
echo "===>               <==="
echo "===>     Finnish   <===" 
echo "===>               <==="
nice time make
#cd ~/gtsvn/kt/kom/src
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
