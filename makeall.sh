#!/bin/sh

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
echo "===>   Other languages  <===" 
echo "===>                    <===" 
echo ""
echo "===>       Faroese       <===" 
cd $GTHOME/st/fao/src
nice time make -f Makefile.orig
echo ""
echo "===>     Greenlandic     <===" 
echo
echo Greenlandic takes 1,5 hour to compile. 
echo It is therefore removed from the makeall list.
echo If you want to compile it, do this:
echo
echo cd \$GTHOME/st/kal/src
echo nice time make GTLANG=sloppy
# cd $GTHOME/st/kal/src
# nice time make GTLANG=sloppy
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
echo "===>                    <===" 
echo "===> Other FU languages <===" 
echo "===>                    <===" 
echo "===>               <==="
echo "===>     Finnish   <===" 
echo "===>               <==="


cd $GTHOME/kt/kom/src
 For some reason, the Makefile timing does not work here. Have a look.
echo "===>              <==="
echo "===>     Komi     <===" 
echo "===>              <==="
echo "===> lexfiles...  <==="
nice time make lexfiles
echo "===>              <==="
echo "===> ... and fst  <==="
nice time make

cd $GTHOME/kt/myv/src
echo "===>              <==="
echo "===>    Erzya     <===" 
echo "===>              <==="
echo "===> lexfiles...  <==="
nice time make lexfiles
echo "===>              <==="
echo "===> ... and fst  <==="
nice time make

cd $GTHOME/kt/mdf/src
echo "===>              <==="
echo "===>    Moksha    <===" 
echo "===>              <==="
echo "===> lexfiles...  <==="
nice time make lexfiles
echo "===>              <==="
echo "===> ... and fst  <==="
nice time make


!cd $GTHOME/kt/vep/src
!echo "===>              <==="
!echo "===>    Veps      <===" 
!echo "===>              <==="
!echo "===> lexfiles...  <==="
!nice time make lexfiles
!echo "===>              <==="
!echo "===> ... and fst  <==="
!nice time make


cd $GTHOME/kt/vro/src
echo "===>              <==="
echo "===>    Võro      <===" 
echo "===>              <==="
echo "===> lexfiles...  <==="
nice time make lexfiles
echo "===>              <==="
echo "===> ... and fst  <==="
nice time make


cd $GTHOME/kt/mrj/src
echo "===>              <==="
echo "===>   Hill Mari  <===" 
echo "===>              <==="
echo "===> lexfiles...  <==="
nice time make lexfiles
echo "===>              <==="
echo "===> ... and fst  <==="
nice time make

popd
echo "===>                  <==="
echo "===>                  <==="
echo "===>                  <==="
echo "===> Done, at last  . <==="
echo "===>                  <==="
