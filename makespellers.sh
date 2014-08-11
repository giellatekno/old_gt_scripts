#!/bin/sh

echo ""
echo " This script will compile in our new infrastructure"
echo ""


echo ""
echo "===>     All the newinfra languages      <==="
pushd $GTHOME/langs

echo " -------------------------------------------------------------------------------------- est, Estonian "
cd $GTHOME/langs/est && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- fao, Faroese "
cd $GTHOME/langs/fao && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- fin, Finnish "
cd $GTHOME/langs/fin && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install 
echo " -------------------------------------------------------------------------------------- kca, Khanty "
cd $GTHOME/langs/kca && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- kpv, Komi Zyryan "
cd $GTHOME/langs/kpv && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- mdf, Moksha "
cd $GTHOME/langs/mdf && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- mhr, Meadow Mari "
cd $GTHOME/langs/mhr && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- mrj, Hill Mari "
cd $GTHOME/langs/mrj && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- myv, Erzya "
cd $GTHOME/langs/myv && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- nio, Nganasan "
cd $GTHOME/langs/nio && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- nob, Norwegian Bokmål "
cd $GTHOME/langs/nob && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- olo, Olonetsian "
cd $GTHOME/langs/olo && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- ron, Rumanian "
cd $GTHOME/langs/ron && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- rus, Russian "
cd $GTHOME/langs/rus && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- sjd, Kildin Saami "
cd $GTHOME/langs/sjd && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- sje, Pite Saami "
cd $GTHOME/langs/sje && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- sma, South Saami "
cd $GTHOME/langs/sma && pwd && nice ./autogen.sh -l && nice ./configure --enable-oahpa --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install    # adjectives.lexc
#cd $GTHOME/langs/sma && pwd && nice ./autogen.sh -l && nice ./configure --enable-oahpa --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install   # adjectives-oahpa.lexc
echo " -------------------------------------------------------------------------------------- smj, Lule Saami "
cd $GTHOME/langs/smj && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  

echo " -------------------------------------------------------------------------------------- sms, Skolt Saami "
cd $GTHOME/langs/sms && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- som, Somali "
cd $GTHOME/langs/som && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- udm, Udmurt "
cd $GTHOME/langs/udm && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- vep, Veps "
cd $GTHOME/langs/vep && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- vro, Võro "
cd $GTHOME/langs/vro && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
echo " -------------------------------------------------------------------------------------- yrk, Tundra Nenets "
cd $GTHOME/langs/yrk && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  
#echo " -------------------------------------------------------------------------------------- zul, Zulu "
#cd $GTHOME/langs/$GTHOME/langs/startup-langs/zul && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --enable-spellers && nice time make  HFST_LEXC_FLAGS=-F && sudo make install  



popd
echo "===>                  <==="
echo "===>                  <==="
echo "===>                  <==="
echo "===> Done, at last  . <==="
echo "===>                  <==="
