

#!/bin/sh

# File to run all our compilation
# processes in hfst.
echo ""
echo " This script will compile all our analysers and lexica with hfst"
echo ""
pushd $GTHOME/gt

cd $GTHOME/kt/fin/src
nice time make
echo "===>                          <===" 
echo "===>                          <==="
echo "===>     Finnish with omorfi  <===" 
echo "===>                          <==="
cd $GTHOME/kt/fin/omorfi
nice time make && make install





echo ""
echo ""
echo "===>   Now, let us try the hfst compiler     <==="
echo "===> Just ignore this if you don't have hfst <==="
echo ""
echo ""

echo ""
echo "===>       North Sámi       <===" 
echo ""
cd $GTHOME/gt/
nice time make GTLANG=sme hfst

echo ""
echo "===>       Lule Sámi       <===" 
echo ""
cd $GTHOME/gt/
nice time make GTLANG=smj hfst

echo ""
echo "===>       South Sámi       <===" 
echo ""
cd $GTHOME/gt/
nice time make GTLANG=sma hfst

echo ""
echo "===>       Faroese       <===" 
cd $GTHOME/st/fao/src
nice time make -f Makefile.hfst
echo ""
echo ""
echo "===>       Kurdish       <===" 
cd $GTHOME/st/kmr/src
nice time make -f Makefile.hfst
echo ""
echo ""
echo "===>       Tagalog       <===" 
cd $GTHOME/st/tgl/src
nice time make -f Makefile.hfst
echo ""
echo ""
echo "===>       Kven       <===" 
cd $GTHOME/kt/fkv/src
nice time make -f Makefile.hfst
echo ""



popd
echo "===>                  <==="
echo "===>                  <==="
echo "===>                  <==="
echo "===> Done, at last  . <==="
echo "===>                  <==="
