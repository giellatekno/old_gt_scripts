# A number of useful aliases to run lookup sessions on the langauges we support.

# xerox aliases

HOSTNAME=`hostname`

if [ $HOSTNAME == 'victorio.uit.no' ]
then export LOOKUP='/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup -flags  mbTT -utf8'
#then export LOOKUP='/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup -q -flags  mbTT -utf8'
else export LOOKUP='lookup -flags mbTT'
#else export LOOKUP='lookup -q -flags mbTT'
fi

export HLOOKUP='hfst-lookup -q'

# Sámi languages:
alias   dsjd='$LOOKUP $GTHOME/gt/sjd/bin/isjd.fst'
alias   dsje='$LOOKUP $GTHOME/gt/sje/bin/isje.fst'
alias   dsme='$LOOKUP $GTHOME/gt/sme/bin/isme.fst'
alias   dsmeNorm='$LOOKUP $GTHOME/gt/sme/bin/isme-norm.fst'
alias   dsmeOahpa='$LOOKUP $GTHOME/gt/sme/bin/oahpa-isme-norm.fst'
alias   dsmeGG='$LOOKUP $GTHOME/gt/sme/bin/isme-GG.restr.fst'
alias   dsmeKJ='$LOOKUP $GTHOME/gt/sme/bin/isme-KJ.restr.fst'
alias   dsmn='$LOOKUP $GTHOME/gt/smn/bin/ismn.fst'
alias   dsms='$LOOKUP $GTHOME/gt/sms/bin/isms.fst'
alias   usjd='$LOOKUP $GTHOME/gt/sjd/bin/sjd.fst'
alias   usje='$LOOKUP $GTHOME/gt/sje/bin/sje.fst'
alias   usme='$LOOKUP $GTHOME/gt/sme/bin/sme.fst'
alias   usmeNorm='$LOOKUP $GTHOME/gt/sme/bin/sme-norm.fst'
alias   usmn='$LOOKUP $GTHOME/gt/smn/bin/smn.fst'
alias   usms='$LOOKUP $GTHOME/gt/sms/bin/sms.fst'

alias         dsma='$LOOKUP $GTHOME/langs/sma/src/generator-gt-desc.xfst'
alias     dsmaNorm='$LOOKUP $GTHOME/langs/sma/src/generator-gt-norm.xfst'
alias   dsmaRestrS='$LOOKUP $GTHOME/gt/sma/bin/isma-SO.restr.fst'
#alias  dsmaRestrN='$LOOKUP $GTHOME/gt/sma/bin/isma-NO.restr.fst'
alias         dsmj='$LOOKUP $GTHOME/langs/smj/src/generator-gt-desc.xfst'
alias     dsmjNorm='$LOOKUP $GTHOME/langs/smj/src/generator-gt-norm.xfst'

alias       usma='$LOOKUP $GTHOME/langs/sma/src/analyser-gt-desc.xfst'
alias   usmaNorm='$LOOKUP $GTHOME/langs/sma/src/analyser-gt-norm.xfst'
alias       usmj='$LOOKUP $GTHOME/langs/smj/src/analyser-gt-desc.xfst'
alias   usmjNorm='$LOOKUP $GTHOME/langs/smj/src/analyser-gt-norm.xfst'

alias   дсйд='$LOOKUP $GTHOME/gt/sjd/bin/isjd.fst'
alias   усйд='$LOOKUP $GTHOME/gt/sjd/bin/sjd.fst'

alias   drsme='$LOOKUP $GTHOME/gt/sme/bin/isme-GG.restr.fst'

# Other languages:
alias   damh='$LOOKUP $GTHOME/st/amh/bin/iamh.fst'
alias   dbxr='$LOOKUP $GTHOME/st/bxr/bin/ibxr.fst'
alias   dces='$LOOKUP $GTHOME/st/ces/bin/ices.fst'
alias   dciw='$LOOKUP $GTHOME/st/ciw/bin/iciw.fst'
alias   dcor='$LOOKUP $GTHOME/st/cor/bin/icor.fst'
alias   ddeu='$LOOKUP $GTHOME/st/deu/bin/ideu.fst'
alias   deng='$LOOKUP $GTHOME/st/eng/bin/ieng.fst'
alias   deus='$LOOKUP $GTHOME/st/eus/bin/ieus.fst'
alias   diku='$LOOKUP $GTHOME/st/iku/bin/iiku.fst'
alias   dipk='$LOOKUP $GTHOME/st/ipk/bin/iipk.fst'
alias   dnno='$LOOKUP $GTHOME/st/nno/bin/inno.fst'
alias   dnob='$LOOKUP $GTHOME/st/nob/bin/inob.fst'
alias   dnon='$LOOKUP $GTHOME/st/non/bin/inon.fst'
alias   drus='$LOOKUP $GTHOME/st/rus/bin/irus.fst'

alias   uamh='$LOOKUP $GTHOME/st/amh/bin/amh.fst'
alias   ubxr='$LOOKUP $GTHOME/st/bxr/bin/bxr.fst'
alias   uces='$LOOKUP $GTHOME/st/ces/bin/ces.fst'
alias   uciw='$LOOKUP $GTHOME/st/ciw/bin/ciw.fst'
alias   ucor='$LOOKUP $GTHOME/st/cor/bin/cor.fst'
alias   udeu='$LOOKUP $GTHOME/st/deu/bin/deu.fst'
alias   ueng='$LOOKUP $GTHOME/st/eng/bin/eng.fst'
alias   ueus='$LOOKUP $GTHOME/st/eus/bin/eus.fst'
alias   uiku='$LOOKUP $GTHOME/st/iku/bin/iku.fst'
alias   uipk='$LOOKUP $GTHOME/st/ipk/bin/ipk.fst'
alias   unno='$LOOKUP $GTHOME/st/nno/bin/nno.fst'
alias   unob='$LOOKUP $GTHOME/st/nob/bin/nob.fst'
alias   unon='$LOOKUP $GTHOME/st/non/bin/non.fst'
alias   urus='$LOOKUP $GTHOME/st/rus/bin/rus.fst'

alias   dfao='$LOOKUP $GTHOME/langs/fao/src/generator-gt-desc.xfst'
alias   dkal='$LOOKUP $GTHOME/langs/kal/src/generator-gt-desc.xfst'

alias   ufao='$LOOKUP $GTHOME/langs/fao/src/analyser-gt-desc.xfst'
alias   ukal='$LOOKUP $GTHOME/langs/kal/src/analyser-gt-desc.xfst'

alias   дбхр='$LOOKUP $GTHOME/st/bxr/bin/ibxr.fst'
alias   убхр='$LOOKUP $GTHOME/st/bxr/bin/bxr.fst'

# Other FU languages:
alias dhun='$LOOKUP $GTHOME/kt/hun/bin/ihun.fst'
alias uhun='$LOOKUP $GTHOME/kt/hun/bin/hun.fst'

alias dfin='$LOOKUP $GTHOME/langs/fin/src/generator-gt-desc.xfst'
alias dizh='$LOOKUP $GTHOME/langs/izh/src/generator-gt-desc.xfst'
alias dkca='$LOOKUP $GTHOME/langs/kca/src/generator-gt-desc.xfst'
alias dkom='$LOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.xfst'
alias dkpv='$LOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.xfst'
alias dmdf='$LOOKUP $GTHOME/langs/mdf/src/generator-gt-desc.xfst'
alias dmhr='$LOOKUP $GTHOME/langs/mhr/src/generator-gt-desc.xfst'
alias dmrj='$LOOKUP $GTHOME/langs/mrj/src/generator-gt-desc.xfst'
alias dmyv='$LOOKUP $GTHOME/langs/myv/src/generator-gt-desc.xfst'
alias dolo='$LOOKUP $GTHOME/langs/olo/src/generator-gt-desc.xfst'
alias dudm='$LOOKUP $GTHOME/langs/udm/src/generator-gt-desc.xfst'
alias dvep='$LOOKUP $GTHOME/langs/vep/src/generator-gt-desc.xfst'
alias dyrk='$LOOKUP $GTHOME/langs/yrk/src/generator-gt-desc.xfst'
alias dvro='$LOOKUP $GTHOME/kt/vro/bin/ivro.fst'

alias ufin='$LOOKUP $GTHOME/langs/fin/src/analyser-gt-desc.xfst'
alias uizh='$LOOKUP $GTHOME/langs/izh/src/analyser-gt-desc.xfst'
alias ukca='$LOOKUP $GTHOME/langs/kca/src/analyser-gt-desc.xfst'
alias ukom='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.xfst'
alias ukpv='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.xfst'
alias umdf='$LOOKUP $GTHOME/langs/mdf/src/analyser-gt-desc.xfst'
alias umhr='$LOOKUP $GTHOME/langs/mhr/src/analyser-gt-desc.xfst'
alias umrj='$LOOKUP $GTHOME/langs/mrj/src/analyser-gt-desc.xfst'
alias umyv='$LOOKUP $GTHOME/langs/myv/src/analyser-gt-desc.xfst'
alias uolo='$LOOKUP $GTHOME/langs/olo/src/analyser-gt-desc.xfst'
alias uudm='$LOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.xfst'
alias uvep='$LOOKUP $GTHOME/langs/vep/src/analyser-gt-desc.xfst'
alias uyrk='$LOOKUP $GTHOME/langs/yrk/src/analyser-gt-desc.xfst'
alias uvro='$LOOKUP $GTHOME/kt/vro/bin/vro.fst'

alias уком='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.xfst'
alias глщь='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.xfst'
alias умчр='$LOOKUP $GTHOME/langs/mhr/src/analyser-gt-desc.xfst'
alias умыв='$LOOKUP $GTHOME/langs/myv/src/analyser-gt-desc.xfst'
alias уудм='$LOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.xfst'
alias уырк='$LOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.xfst'

alias дком='$LOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.xfst'
alias дмчр='$LOOKUP $GTHOME/langs/mhr/src/generator-gt-desc.xfst'
alias дмыв='$LOOKUP $GTHOME/langs/myv/src/generator-gt-desc.xfst'
alias дудм='$LOOKUP $GTHOME/langs/udm/src/generator-gt-desc.xfst'
alias дырк='$LOOKUP $GTHOME/langs/udm/src/generator-gt-desc.xfst'



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
alias   hdsjd='$HLOOKUP $GTHOME/gt/sjd/bin/isjd.hfstol'
alias   hdsje='$HLOOKUP $GTHOME/gt/sje/bin/isje.hfstol'
alias   hdsma='$HLOOKUP $GTHOME/langs/sma/src/generator.gt.hfst'
alias   hdsme='$HLOOKUP $GTHOME/gt/sme/bin/isme.hfstol'
alias   hdsmj='$HLOOKUP $GTHOME/langs/smj/src/generator.gt.hfst'
alias   hdsmn='$HLOOKUP $GTHOME/gt/smn/bin/ismn.hfstol'
alias   hdsms='$HLOOKUP $GTHOME/gt/sms/bin/isms.hfstol'
alias   husjd='$HLOOKUP $GTHOME/gt/sjd/bin/sjd.hfstol'
alias   husje='$HLOOKUP $GTHOME/gt/sje/bin/sje.hfstol'
alias   husma='$HLOOKUP $GTHOME/langs/sma/src/analyser.gt.hfst'
alias   husme='$HLOOKUP $GTHOME/gt/sme/bin/sme.hfstol'
alias   husmj='$HLOOKUP $GTHOME/langs/smj/src/analyser.gt.hfst'
alias   husmn='$HLOOKUP $GTHOME/gt/smn/bin/smn.hfstol'
alias   husms='$HLOOKUP $GTHOME/gt/sms/bin/sms.hfstol'

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
alias hdfin='$HLOOKUP $GTHOME/kt/fin/bin/ifin.hfst.ol'
alias hdkom='$HLOOKUP $GTHOME/kt/kom/bin/ikom.hfst.ol'
alias hdmdf='$HLOOKUP $GTHOME/kt/mdf/bin/imdf.hfstol'
alias hdmrj='$HLOOKUP $GTHOME/kt/mrj/bin/imrj.hfstol'
alias hdolo='$HLOOKUP $GTHOME/kt/olo/bin/iolo.hfstol'
alias hdvep='$HLOOKUP $GTHOME/kt/vep/bin/ivep.hfstol'
alias hdvro='$HLOOKUP $GTHOME/kt/vro/bin/ivro.hfstol'
alias hufin='$HLOOKUP $GTHOME/kt/fin/bin/fin.hfst.ol'
alias hukom='$HLOOKUP $GTHOME/kt/kom/bin/kom.hfst.ol'
alias humdf='$HLOOKUP $GTHOME/kt/mdf/bin/mdf.fstol'
alias humrj='$HLOOKUP $GTHOME/kt/mrj/bin/mrj.fstol'
alias huolo='$HLOOKUP $GTHOME/kt/olo/bin/olo.fstol'
alias huvep='$HLOOKUP $GTHOME/kt/vep/bin/vep.fstol'
alias huvro='$HLOOKUP $GTHOME/kt/vro/bin/vro.fstol'

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
