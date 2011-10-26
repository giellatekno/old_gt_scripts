# A number of useful aliases to run lookup sessions on the langauges we support.

# xerox aliases

HOSTNAME=`hostname`

if [ $HOSTNAME == 'victorio.uit.no' ]
then export LOOKUP='/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup -q -flags  mbTT -utf8'
else export LOOKUP='lookup -q -flags mbTT'
fi

export HLOOKUP='hfst-lookup -q'

# Sámi languages:
alias   dsjd='$LOOKUP $GTHOME/gt/sjd/bin/isjd.fst'
alias   dsje='$LOOKUP $GTHOME/gt/sje/bin/isje.fst'
alias   dsma='$LOOKUP $GTHOME/gt/sma/bin/isma.fst'
alias   dsmaNorm='$LOOKUP $GTHOME/gt/sma/bin/isma-norm.fst'
alias   dsmaRestrS='$LOOKUP $GTHOME/gt/sma/bin/isma-SO.restr.fst'
#alias   dsmaRestrN='$LOOKUP $GTHOME/gt/sma/bin/isma-NO.restr.fst'
alias   dsme='$LOOKUP $GTHOME/gt/sme/bin/isme.fst'
alias   dsmeNorm='$LOOKUP $GTHOME/gt/sme/bin/isme-norm.fst'
alias   dsmj='$LOOKUP $GTHOME/gt/smj/bin/ismj.fst'
alias   dsmjNorm='$LOOKUP $GTHOME/gt/smj/bin/ismj-norm.fst'
alias   dsmn='$LOOKUP $GTHOME/gt/smn/bin/ismn.fst'
alias   dsms='$LOOKUP $GTHOME/gt/sms/bin/isms.fst'
alias   usjd='$LOOKUP $GTHOME/gt/sjd/bin/sjd.fst'
alias   usje='$LOOKUP $GTHOME/gt/sje/bin/sje.fst'
alias   usma='$LOOKUP $GTHOME/gt/sma/bin/sma.fst'
alias   usmaNorm='$LOOKUP $GTHOME/gt/sma/bin/sma-norm.fst'
alias   usme='$LOOKUP $GTHOME/gt/sme/bin/sme.fst'
alias   usmeNorm='$LOOKUP $GTHOME/gt/sme/bin/sme-norm.fst'
alias   usmj='$LOOKUP $GTHOME/gt/smj/bin/smj.fst'
alias   usmjNorm='$LOOKUP $GTHOME/gt/smj/bin/smj-norm.fst'
alias   usmn='$LOOKUP $GTHOME/gt/smn/bin/smn.fst'
alias   usms='$LOOKUP $GTHOME/gt/sms/bin/sms.fst'

alias   дсйд='$LOOKUP $GTHOME/gt/sjd/bin/isjd.fst'
alias   усйд='$LOOKUP $GTHOME/gt/sjd/bin/sjd.fst'

alias   drsme='$LOOKUP $GTHOME/gt/sme/bin/isme-GG.restr.fst'

# Other languages:
alias   damh='$LOOKUP $GTHOME/st/amh/bin/iamh.fst'
alias   dces='$LOOKUP $GTHOME/st/ces/bin/ices.fst'
alias   dcor='$LOOKUP $GTHOME/st/cor/bin/icor.fst'
alias   ddeu='$LOOKUP $GTHOME/st/deu/bin/ideu.fst'
alias   deng='$LOOKUP $GTHOME/st/eng/bin/ieng.fst'
alias   deus='$LOOKUP $GTHOME/st/eus/bin/ieus.fst'
alias   dfao='$LOOKUP $GTHOME/st/fao/bin/ifao.fst'
alias   diku='$LOOKUP $GTHOME/st/iku/bin/iiku.fst'
alias   dipk='$LOOKUP $GTHOME/st/ipk/bin/iipk.fst'
alias   dkal='$LOOKUP $GTHOME/st/kal/bin/ikal.fst'
alias   dnno='$LOOKUP $GTHOME/st/nno/bin/inno.fst'
alias   dnob='$LOOKUP $GTHOME/st/nob/bin/inob.fst'
alias   dnon='$LOOKUP $GTHOME/st/non/bin/inon.fst'
alias   drus='$LOOKUP $GTHOME/st/rus/bin/irus.fst'
alias   uamh='$LOOKUP $GTHOME/st/amh/bin/amh.fst'
alias   uces='$LOOKUP $GTHOME/st/ces/bin/ces.fst'
alias   ucor='$LOOKUP $GTHOME/st/cor/bin/cor.fst'
alias   udeu='$LOOKUP $GTHOME/st/deu/bin/deu.fst'
alias   ueng='$LOOKUP $GTHOME/st/eng/bin/eng.fst'
alias   ueus='$LOOKUP $GTHOME/st/eus/bin/eus.fst'
alias   ufao='$LOOKUP $GTHOME/st/fao/bin/fao.fst'
alias   uiku='$LOOKUP $GTHOME/st/iku/bin/iku.fst'
alias   uipk='$LOOKUP $GTHOME/st/ipk/bin/ipk.fst'
alias   ukal='$LOOKUP $GTHOME/st/kal/bin/kal.fst'
alias   unno='$LOOKUP $GTHOME/st/nno/bin/nno.fst'
alias   unob='$LOOKUP $GTHOME/st/nob/bin/nob.fst'
alias   unon='$LOOKUP $GTHOME/st/non/bin/non.fst'
alias   urus='$LOOKUP $GTHOME/st/rus/bin/rus.fst'
alias   dbxr='$LOOKUP $GTHOME/st/bxr/bin/ibxr.fst'
alias   ubxr='$LOOKUP $GTHOME/st/bxr/bin/bxr.fst'

alias   дбхр='$LOOKUP $GTHOME/st/bxr/bin/ibxr.fst'
alias   убхр='$LOOKUP $GTHOME/st/bxr/bin/bxr.fst'

# Other FU languages:
alias   dkom='$LOOKUP $GTHOME/kt/kom/bin/ikom.fst'
alias   dmhr='$LOOKUP $GTHOME/kt/mhr/bin/imhr.fst'
alias   umhr='$LOOKUP $GTHOME/kt/mhr/bin/mhr.fst'
alias   dudm='$LOOKUP $GTHOME/kt/udm/bin/iudm.fst'
alias   uudm='$LOOKUP $GTHOME/kt/udm/bin/udm.fst'
alias   dhun='$LOOKUP $GTHOME/kt/hun/bin/ihun.fst'
alias   uhun='$LOOKUP $GTHOME/kt/hun/bin/hun.fst'
alias   ukom='$LOOKUP $GTHOME/kt/kom/bin/kom.fst'
alias   дком='$LOOKUP $GTHOME/kt/kom/bin/ikom.fst'
alias   дmhr='$LOOKUP $GTHOME/kt/mhr/bin/imhr.fst'
alias   дudm='$LOOKUP $GTHOME/kt/udm/bin/iudm.fst'
alias   уком='$LOOKUP $GTHOME/kt/kom/bin/kom.fst'
alias   умчр='$LOOKUP $GTHOME/kt/mhr/bin/mhr.fst'
alias   уудм='$LOOKUP $GTHOME/kt/udm/bin/udm.fst'
alias   ufin='$HLOOKUP $GTHOME/kt/fin/omorfi/src/morphology.cg.hfstol'
alias   dfin='$HLOOKUP $GTHOME/kt/fin/omorfi/src/morphology.generate.cg.hfstol'
alias   ufins='$HLOOKUP $GTHOME/kt/fin/omorfi/src/morphology.cg.hfst'
alias   dfins='$HLOOKUP $GTHOME/kt/fin/omorfi/src/morphology.generate.cg.hfst'
alias   xufin='$LOOKUP $GTHOME/kt/fin/bin/fin.fst'
alias   xdfin='$LOOKUP $GTHOME/kt/fin/bin/ifin.fst'


# Bilingual transducers:
alias fitswe='$LOOKUP $GTHOME/kvensk/fitswe/bin/fitswe.fst'
alias fkvnob='$LOOKUP $GTHOME/kvensk/bin/fkvnob.fst'
alias kaldan='$LOOKUP -flags mbTT -utf8 $GTHOME/words/dicts/kaldan/bin/kaldan.fst'
alias kaldic='$LOOKUP $GTHOME/words/dicts/kaldan/bin/kaldic.fst'
alias kaleng='$LOOKUP $GTHOME/words/dicts/kaleng/bin/kaleng.fst'
alias nobfkv='$LOOKUP $GTHOME/kvensk/bin/nobfkv.fst'
alias nobsme='$LOOKUP $GTHOME/words/dicts/smenob/bin/ismenob.fst'
alias smenob='$LOOKUP $GTHOME/words/dicts/smenob/bin/smenob.fst'
alias smesmj='$LOOKUP $GTHOME/words/dicts/smesmj/bin/smesmj.fst'
alias smjsme='$LOOKUP $GTHOME/words/dicts/smesmj/bin/smjsme.fst'
alias swefit='$LOOKUP $GTHOME/kvensk/swefit/bin/swefit.fst'

# Other transducers
alias ogeo='$LOOKUP $GTHOME/words/dicts/smi/geo/bin/geo.fst'


# .hfst.ol aliases

# Sámi languages:
alias   hdsjd='$HLOOKUP $GTHOME/gt/sjd/bin/isjd.hfst.ol'
alias   hdsje='$HLOOKUP $GTHOME/gt/sje/bin/isje.hfst.ol'
alias   hdsma='$HLOOKUP $GTHOME/gt/sma/bin/isma.hfst.ol'
alias   hdsme='$HLOOKUP $GTHOME/gt/sme/bin/isme.hfst.ol'
alias   hdsmj='$HLOOKUP $GTHOME/gt/smj/bin/ismj.hfst.ol'
alias   hdsmn='$HLOOKUP $GTHOME/gt/smn/bin/ismn.hfst.ol'
alias   hdsms='$HLOOKUP $GTHOME/gt/sms/bin/isms.hfst.ol'
alias   husjd='$HLOOKUP $GTHOME/gt/sjd/bin/sjd.hfst.ol'
alias   husje='$HLOOKUP $GTHOME/gt/sje/bin/sje.hfst.ol'
alias   husma='$HLOOKUP $GTHOME/gt/sma/bin/sma.hfst.ol'
alias   husme='$HLOOKUP $GTHOME/gt/sme/bin/sme.hfst.ol'
alias   husmj='$HLOOKUP $GTHOME/gt/smj/bin/smj.hfst.ol'
alias   husmn='$HLOOKUP $GTHOME/gt/smn/bin/smn.hfst.ol'
alias   husms='$HLOOKUP $GTHOME/gt/sms/bin/sms.hfst.ol'

# Other languages:
alias   hdamh='$HLOOKUP $GTHOME/st/amh/bin/iamh.hfst.ol'
alias   hdces='$HLOOKUP $GTHOME/st/ces/bin/ices.hfst.ol'
alias   hdcor='$HLOOKUP $GTHOME/st/cor/bin/icor.hfst.ol'
alias   hddeu='$HLOOKUP $GTHOME/st/deu/bin/ideu.hfst.ol'
alias   hdeng='$HLOOKUP $GTHOME/st/eng/bin/ieng.hfst.ol'
alias   hdfao='$HLOOKUP $GTHOME/st/fao/bin/ifao.hfst.ol'
alias   hdiku='$HLOOKUP $GTHOME/st/iku/bin/iiku.hfst.ol'
alias   hdipk='$HLOOKUP $GTHOME/st/ipk/bin/iipk.hfst.ol'
alias   hdkal='$HLOOKUP $GTHOME/st/kal/bin/ikal.hfst.ol'
alias   hdnno='$HLOOKUP $GTHOME/st/nno/bin/inno.hfst.ol'
alias   hdnob='$HLOOKUP $GTHOME/st/nob/bin/inob.hfst.ol'
alias   hdnon='$HLOOKUP $GTHOME/st/non/bin/inon.hfst.ol'
alias   huamh='$HLOOKUP $GTHOME/st/amh/bin/amh.hfst.ol'
alias   huces='$HLOOKUP $GTHOME/st/ces/bin/ces.hfst.ol'
alias   hucor='$HLOOKUP $GTHOME/st/cor/bin/cor.hfst.ol'
alias   hudeu='$HLOOKUP $GTHOME/st/deu/bin/deu.hfst.ol'
alias   hueng='$HLOOKUP $GTHOME/st/eng/bin/eng.hfst.ol'
alias   hufao='$HLOOKUP $GTHOME/st/fao/bin/fao.hfst.ol'
alias   huiku='$HLOOKUP $GTHOME/st/iku/bin/iku.hfst.ol'
alias   huipk='$HLOOKUP $GTHOME/st/ipk/bin/ipk.hfst.ol'
alias   hukal='$HLOOKUP $GTHOME/st/kal/bin/kal.hfst.ol'
alias   hunno='$HLOOKUP $GTHOME/st/nno/bin/nno.hfst.ol'
alias   hunob='$HLOOKUP $GTHOME/st/nob/bin/nob.hfst.ol'
alias   hunon='$HLOOKUP $GTHOME/st/non/bin/non.hfst.ol'

# Other FU languages:
alias   hdfin='$HLOOKUP $GTHOME/kt/fin/bin/ifin.hfst.ol'
alias   hdkom='$HLOOKUP $GTHOME/kt/kom/bin/ikom.hfst.ol'
alias   hufin='$HLOOKUP $GTHOME/kt/fin/bin/fin.hfst.ol'
alias   hukom='$HLOOKUP $GTHOME/kt/kom/bin/kom.hfst.ol'

# Bilingual transducers:
alias hfitswe='$HLOOKUP $GTHOME/kvensk/fitswe/bin/fitswe.hfst.ol'
alias hfkvnob='$HLOOKUP $GTHOME/kvensk/bin/fkvnob.hfst.ol'
alias hkaldan='$HLOOKUP $GTHOME/words/dicts/kaldan/bin/kaldan.hfst.ol'
alias hkaldic='$HLOOKUP $GTHOME/words/dicts/kaldan/bin/kaldic.hfst.ol'
alias hkaleng='$HLOOKUP $GTHOME/words/dicts/kaleng/bin/kaleng.hfst.ol'
alias hnobfkv='$HLOOKUP $GTHOME/kvensk/bin/nobfkv.hfst.ol'
alias hnobsme='$HLOOKUP $GTHOME/words/dicts/smenob/bin/ismenob.hfst.ol'
alias hsmenob='$HLOOKUP $GTHOME/words/dicts/smenob/bin/smenob.hfst.ol'
alias hsmesmj='$HLOOKUP $GTHOME/words/dicts/smesmj/bin/smesmj.hfst.ol'
alias hsmjsme='$HLOOKUP $GTHOME/words/dicts/smesmj/bin/smjsme.hfst.ol'
alias hswefit='$HLOOKUP $GTHOME/kvensk/swefit/bin/swefit.hfst.ol'

# Other transducers
alias ogeo='$HLOOKUP $GTHOME/words/dicts/smi/geo/bin/geo.hfst.ol'
