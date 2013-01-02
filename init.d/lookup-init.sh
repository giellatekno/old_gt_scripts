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

# sme
alias        dsme='$LOOKUP $GTHOME/gt/sme/bin/isme.fst'
alias    dsmeNorm='$LOOKUP $GTHOME/gt/sme/bin/isme-norm.fst'
alias   dsmeOahpa='$LOOKUP $GTHOME/gt/sme/bin/oahpa-isme-norm.fst'
alias      dsmeGG='$LOOKUP $GTHOME/gt/sme/bin/isme-GG.restr.fst'
alias      dsmeKJ='$LOOKUP $GTHOME/gt/sme/bin/isme-KJ.restr.fst'
alias        usme='$LOOKUP $GTHOME/gt/sme/bin/sme.fst'
alias    usmeNorm='$LOOKUP $GTHOME/gt/sme/bin/sme-norm.fst'

alias       drsme='$LOOKUP $GTHOME/gt/sme/bin/isme-GG.restr.fst'

# These to be rebuilt in new infra:
# alias  dsmaRestrN='$LOOKUP $GTHOME/gt/sma/bin/isma-NO.restr.fst'
# alias dsmaRestrS='$LOOKUP $GTHOME/gt/sma/bin/isma-SO.restr.fst'


# Languages in newinfra

alias dfao='$LOOKUP $GTHOME/langs/fao/src/generator-gt-desc.xfst'
alias dfin='$LOOKUP $GTHOME/langs/fin/src/generator-gt-desc.xfst'
alias dfkv='$LOOKUP $GTHOME/langs/fkv/src/generator-gt-desc.xfst'
alias dizh='$LOOKUP $GTHOME/langs/izh/src/generator-gt-desc.xfst'
alias dkal='$LOOKUP $GTHOME/langs/kal/src/generator-gt-desc.xfst'
alias dkca='$LOOKUP $GTHOME/langs/kca/src/generator-gt-desc.xfst'
alias dkom='$LOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.xfst'
alias dkpv='$LOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.xfst'
alias dliv='$LOOKUP $GTHOME/langs/liv/src/generator-gt-desc.xfst'
alias dmdf='$LOOKUP $GTHOME/langs/mdf/src/generator-gt-desc.xfst'
alias dmhr='$LOOKUP $GTHOME/langs/mhr/src/generator-gt-desc.xfst'
alias dmrj='$LOOKUP $GTHOME/langs/mrj/src/generator-gt-desc.xfst'
alias dmyv='$LOOKUP $GTHOME/langs/myv/src/generator-gt-desc.xfst'
alias dolo='$LOOKUP $GTHOME/langs/olo/src/generator-gt-desc.xfst'
alias dsjd='$LOOKUP $GTHOME/langs/sjd/src/generator-gt-desc.xfst'
alias dsje='$LOOKUP $GTHOME/langs/sje/src/generator-gt-desc.xfst'
alias dsma='$LOOKUP $GTHOME/langs/sma/src/generator-gt-desc.xfst'
alias dsmj='$LOOKUP $GTHOME/langs/smj/src/generator-gt-desc.xfst'
alias dsmn='$LOOKUP $GTHOME/langs/smn/src/generator-gt-desc.xfst'
alias dsms='$LOOKUP $GTHOME/langs/sms/src/generator-gt-desc.xfst'
alias dudm='$LOOKUP $GTHOME/langs/udm/src/generator-gt-desc.xfst'
alias dvep='$LOOKUP $GTHOME/langs/vep/src/generator-gt-desc.xfst'
alias dvro='$LOOKUP $GTHOME/langs/vro/src/generator-gt-desc.xfst'
alias dyrk='$LOOKUP $GTHOME/langs/yrk/src/generator-gt-desc.xfst'

alias ufao='$LOOKUP $GTHOME/langs/fao/src/analyser-gt-desc.xfst'
alias ufin='$LOOKUP $GTHOME/langs/fin/src/analyser-gt-desc.xfst'
alias ufkv='$LOOKUP $GTHOME/langs/fkv/src/analyser-gt-desc.xfst'
alias uizh='$LOOKUP $GTHOME/langs/izh/src/analyser-gt-desc.xfst'
alias ukal='$LOOKUP $GTHOME/langs/kal/src/analyser-gt-desc.xfst'
alias ukca='$LOOKUP $GTHOME/langs/kca/src/analyser-gt-desc.xfst'
alias ukom='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.xfst'
alias ukpv='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.xfst'
alias uliv='$LOOKUP $GTHOME/langs/liv/src/analyser-gt-desc.xfst'
alias umdf='$LOOKUP $GTHOME/langs/mdf/src/analyser-gt-desc.xfst'
alias umhr='$LOOKUP $GTHOME/langs/mhr/src/analyser-gt-desc.xfst'
alias umrj='$LOOKUP $GTHOME/langs/mrj/src/analyser-gt-desc.xfst'
alias umyv='$LOOKUP $GTHOME/langs/myv/src/analyser-gt-desc.xfst'
alias uolo='$LOOKUP $GTHOME/langs/olo/src/analyser-gt-desc.xfst'
alias usjd='$LOOKUP $GTHOME/langs/sjd/src/analyser-gt-desc.xfst'
alias usje='$LOOKUP $GTHOME/langs/sje/src/analyser-gt-desc.xfst'
alias usma='$LOOKUP $GTHOME/langs/sma/src/analyser-gt-desc.xfst'
alias usmj='$LOOKUP $GTHOME/langs/smj/src/analyser-gt-desc.xfst'
alias usmn='$LOOKUP $GTHOME/langs/smn/src/analyser-gt-desc.xfst'
alias usms='$LOOKUP $GTHOME/langs/sms/src/analyser-gt-desc.xfst'
alias uudm='$LOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.xfst'
alias uvep='$LOOKUP $GTHOME/langs/vep/src/analyser-gt-desc.xfst'
alias uvro='$LOOKUP $GTHOME/langs/vro/src/analyser-gt-desc.xfst'
alias uyrk='$LOOKUP $GTHOME/langs/yrk/src/analyser-gt-desc.xfst'

# Languages in newinfra, lazy cyrillic aliases:

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


# Languages in newinfra, Normative variants:

alias dfaoNorm='$LOOKUP $GTHOME/langs/fao/src/generator-gt-norm.xfst'
alias dfinNorm='$LOOKUP $GTHOME/langs/fin/src/generator-gt-norm.xfst'
alias dizhNorm='$LOOKUP $GTHOME/langs/izh/src/generator-gt-norm.xfst'
alias dkalNorm='$LOOKUP $GTHOME/langs/kal/src/generator-gt-norm.xfst'
alias dkcaNorm='$LOOKUP $GTHOME/langs/kca/src/generator-gt-norm.xfst'
alias dkomNorm='$LOOKUP $GTHOME/langs/kpv/src/generator-gt-norm.xfst'
alias dkpvNorm='$LOOKUP $GTHOME/langs/kpv/src/generator-gt-norm.xfst'
alias dmdfNorm='$LOOKUP $GTHOME/langs/mdf/src/generator-gt-norm.xfst'
alias dmhrNorm='$LOOKUP $GTHOME/langs/mhr/src/generator-gt-norm.xfst'
alias dmrjNorm='$LOOKUP $GTHOME/langs/mrj/src/generator-gt-norm.xfst'
alias dmyvNorm='$LOOKUP $GTHOME/langs/myv/src/generator-gt-norm.xfst'
alias doloNorm='$LOOKUP $GTHOME/langs/olo/src/generator-gt-norm.xfst'
alias dsmaNorm='$LOOKUP $GTHOME/langs/sma/src/generator-gt-norm.xfst'
alias dsmjNorm='$LOOKUP $GTHOME/langs/smj/src/generator-gt-norm.xfst'
alias dudmNorm='$LOOKUP $GTHOME/langs/udm/src/generator-gt-norm.xfst'
alias dvepNorm='$LOOKUP $GTHOME/langs/vep/src/generator-gt-norm.xfst'
alias dvroNorm='$LOOKUP $GTHOME/langs/vro/src/generator-gt-norm.xfst'
alias dyrkNorm='$LOOKUP $GTHOME/langs/yrk/src/generator-gt-norm.xfst'

alias ufaoNorm='$LOOKUP $GTHOME/langs/fao/src/analyser-gt-norm.xfst'
alias ufinNorm='$LOOKUP $GTHOME/langs/fin/src/analyser-gt-norm.xfst'
alias uizhNorm='$LOOKUP $GTHOME/langs/izh/src/analyser-gt-norm.xfst'
alias ukalNorm='$LOOKUP $GTHOME/langs/kal/src/analyser-gt-norm.xfst'
alias ukcaNorm='$LOOKUP $GTHOME/langs/kca/src/analyser-gt-norm.xfst'
alias ukomNorm='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.xfst'
alias ukpvNorm='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.xfst'
alias umdfNorm='$LOOKUP $GTHOME/langs/mdf/src/analyser-gt-norm.xfst'
alias umhrNorm='$LOOKUP $GTHOME/langs/mhr/src/analyser-gt-norm.xfst'
alias umrjNorm='$LOOKUP $GTHOME/langs/mrj/src/analyser-gt-norm.xfst'
alias umyvNorm='$LOOKUP $GTHOME/langs/myv/src/analyser-gt-norm.xfst'
alias uoloNorm='$LOOKUP $GTHOME/langs/olo/src/analyser-gt-norm.xfst'
alias usmaNorm='$LOOKUP $GTHOME/langs/sma/src/analyser-gt-norm.xfst'
alias usmjNorm='$LOOKUP $GTHOME/langs/smj/src/analyser-gt-norm.xfst'
alias uudmNorm='$LOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.xfst'
alias uvepNorm='$LOOKUP $GTHOME/langs/vep/src/analyser-gt-norm.xfst'
alias uvroNorm='$LOOKUP $GTHOME/langs/vro/src/analyser-gt-norm.xfst'
alias uyrkNorm='$LOOKUP $GTHOME/langs/yrk/src/analyser-gt-norm.xfst'

# Languages in newinfra, lazy cyrillic aliases:

alias дкомНорм='$LOOKUP $GTHOME/langs/kpv/src/generator-gt-norm.xfst'
alias дмчрНорм='$LOOKUP $GTHOME/langs/mhr/src/generator-gt-norm.xfst'
alias дмывНорм='$LOOKUP $GTHOME/langs/myv/src/generator-gt-norm.xfst'
alias дудмНорм='$LOOKUP $GTHOME/langs/udm/src/generator-gt-norm.xfst'
alias дыркНорм='$LOOKUP $GTHOME/langs/udm/src/generator-gt-norm.xfst'

alias укомНорм='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.xfst'
alias глщьНорм='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.xfst'
alias умчрНорм='$LOOKUP $GTHOME/langs/mhr/src/analyser-gt-norm.xfst'
alias умывНорм='$LOOKUP $GTHOME/langs/myv/src/analyser-gt-norm.xfst'
alias уудмНорм='$LOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.xfst'
alias уыркНорм='$LOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.xfst'


# Other languages in the old infra:

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


alias   дбхр='$LOOKUP $GTHOME/st/bxr/bin/ibxr.fst'
alias   убхр='$LOOKUP $GTHOME/st/bxr/bin/bxr.fst'

# Other FU languages:
alias dhun='$LOOKUP $GTHOME/kt/hun/bin/ihun.fst'
alias uhun='$LOOKUP $GTHOME/kt/hun/bin/hun.fst'






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


# HFST aliases

# sme
alias hdsme='$HLOOKUP $GTHOME/gt/sme/bin/isme.hfstol'
alias husme='$HLOOKUP $GTHOME/gt/sme/bin/sme.hfstol'



alias hdsmaNorm='$HLOOKUP $GTHOME/langs/sma/src/generator-gt-norm.hfst'
alias hdsmjNorm='$HLOOKUP $GTHOME/langs/smj/src/generator-gt-norm.hfst'

alias husmaNorm='$HLOOKUP $GTHOME/langs/sma/src/analyser-gt-norm.hfst'
alias husmjNorm='$HLOOKUP $GTHOME/langs/smj/src/analyser-gt-norm.hfst'


alias hdfao='$HLOOKUP $GTHOME/langs/fao/src/generator-gt-desc.hfst'
alias hdfin='$HLOOKUP $GTHOME/langs/fin/src/generator-gt-desc.hfst'
alias hdfkv='$HLOOKUP $GTHOME/langs/fkv/src/generator-gt-desc.hfst'
alias hdizh='$HLOOKUP $GTHOME/langs/izh/src/generator-gt-desc.hfst'
alias hdkal='$HLOOKUP $GTHOME/langs/kal/src/generator-gt-desc.hfst'
alias hdkca='$HLOOKUP $GTHOME/langs/kca/src/generator-gt-desc.hfst'
alias hdkom='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.hfst'
alias hdkpv='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.hfst'
alias hdliv='$HLOOKUP $GTHOME/langs/liv/src/generator-gt-desc.hfst'
alias hdmdf='$HLOOKUP $GTHOME/langs/mdf/src/generator-gt-desc.hfst'
alias hdmhr='$HLOOKUP $GTHOME/langs/mhr/src/generator-gt-desc.hfst'
alias hdmrj='$HLOOKUP $GTHOME/langs/mrj/src/generator-gt-desc.hfst'
alias hdmyv='$HLOOKUP $GTHOME/langs/myv/src/generator-gt-desc.hfst'
alias hdolo='$HLOOKUP $GTHOME/langs/olo/src/generator-gt-desc.hfst'
alias hdsjd='$HLOOKUP $GTHOME/langs/sjd/src/generator-gt-desc.hfst'
alias hdsje='$HLOOKUP $GTHOME/langs/sje/src/generator-gt-desc.hfst'
alias hdsma='$HLOOKUP $GTHOME/langs/sma/src/generator-gt-desc.hfst'
alias hdsmj='$HLOOKUP $GTHOME/langs/smj/src/generator-gt-desc.hfst'
alias hdsmn='$HLOOKUP $GTHOME/langs/smn/src/generator-gt-desc.hfst'
alias hdsms='$HLOOKUP $GTHOME/langs/sms/src/generator-gt-desc.hfst'
alias hdudm='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-desc.hfst'
alias hdvep='$HLOOKUP $GTHOME/langs/vep/src/generator-gt-desc.hfst'
alias hdvro='$HLOOKUP $GTHOME/langs/vro/src/generator-gt-desc.hfst'
alias hdyrk='$HLOOKUP $GTHOME/langs/yrk/src/generator-gt-desc.hfst'

alias hufao='$HLOOKUP $GTHOME/langs/fao/src/analyser-gt-desc.hfst'
alias hufin='$HLOOKUP $GTHOME/langs/fin/src/analyser-gt-desc.hfst'
alias hufkv='$HLOOKUP $GTHOME/langs/fkv/src/analyser-gt-desc.hfst'
alias huizh='$HLOOKUP $GTHOME/langs/izh/src/analyser-gt-desc.hfst'
alias hukal='$HLOOKUP $GTHOME/langs/kal/src/analyser-gt-desc.hfst'
alias hukca='$HLOOKUP $GTHOME/langs/kca/src/analyser-gt-desc.hfst'
alias hukom='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.hfst'
alias hukpv='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.hfst'
alias huliv='$HLOOKUP $GTHOME/langs/liv/src/analyser-gt-desc.hfst'
alias humdf='$HLOOKUP $GTHOME/langs/mdf/src/analyser-gt-desc.hfst'
alias humhr='$HLOOKUP $GTHOME/langs/mhr/src/analyser-gt-desc.hfst'
alias humrj='$HLOOKUP $GTHOME/langs/mrj/src/analyser-gt-desc.hfst'
alias humyv='$HLOOKUP $GTHOME/langs/myv/src/analyser-gt-desc.hfst'
alias huolo='$HLOOKUP $GTHOME/langs/olo/src/analyser-gt-desc.hfst'
alias husjd='$HLOOKUP $GTHOME/langs/sjd/src/analyser-gt-desc.hfst'
alias husje='$HLOOKUP $GTHOME/langs/sje/src/analyser-gt-desc.hfst'
alias husma='$HLOOKUP $GTHOME/langs/sma/src/analyser-gt-desc.hfst'
alias husmj='$HLOOKUP $GTHOME/langs/smj/src/analyser-gt-desc.hfst'
alias husmn='$HLOOKUP $GTHOME/langs/smn/src/analyser-gt-desc.hfst'
alias husms='$HLOOKUP $GTHOME/langs/sms/src/analyser-gt-desc.hfst'
alias huudm='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.hfst'
alias huvep='$HLOOKUP $GTHOME/langs/vep/src/analyser-gt-desc.hfst'
alias huvro='$HLOOKUP $GTHOME/langs/vro/src/analyser-gt-desc.hfst'
alias huyrk='$HLOOKUP $GTHOME/langs/yrk/src/analyser-gt-desc.hfst'

# Normative variants:
alias hdfaoNorm='$HLOOKUP $GTHOME/langs/fao/src/generator-gt-norm.hfst'
alias hdfinNorm='$HLOOKUP $GTHOME/langs/fin/src/generator-gt-norm.hfst'
alias hdizhNorm='$HLOOKUP $GTHOME/langs/izh/src/generator-gt-norm.hfst'
alias hdkalNorm='$HLOOKUP $GTHOME/langs/kal/src/generator-gt-norm.hfst'
alias hdkcaNorm='$HLOOKUP $GTHOME/langs/kca/src/generator-gt-norm.hfst'
alias hdkomNorm='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-norm.hfst'
alias hdkpvNorm='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-norm.hfst'
alias hdmdfNorm='$HLOOKUP $GTHOME/langs/mdf/src/generator-gt-norm.hfst'
alias hdmhrNorm='$HLOOKUP $GTHOME/langs/mhr/src/generator-gt-norm.hfst'
alias hdmrjNorm='$HLOOKUP $GTHOME/langs/mrj/src/generator-gt-norm.hfst'
alias hdmyvNorm='$HLOOKUP $GTHOME/langs/myv/src/generator-gt-norm.hfst'
alias hdoloNorm='$HLOOKUP $GTHOME/langs/olo/src/generator-gt-norm.hfst'
alias hdudmNorm='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-norm.hfst'
alias hdvepNorm='$HLOOKUP $GTHOME/langs/vep/src/generator-gt-norm.hfst'
alias hdvroNorm='$HLOOKUP $GTHOME/langs/vro/src/generator-gt-norm.hfst'
alias hdyrkNorm='$HLOOKUP $GTHOME/langs/yrk/src/generator-gt-norm.hfst'

alias hufaoNorm='$HLOOKUP $GTHOME/langs/fao/src/analyser-gt-norm.hfst'
alias hufinNorm='$HLOOKUP $GTHOME/langs/fin/src/analyser-gt-norm.hfst'
alias huizhNorm='$HLOOKUP $GTHOME/langs/izh/src/analyser-gt-norm.hfst'
alias hukalNorm='$HLOOKUP $GTHOME/langs/kal/src/analyser-gt-norm.hfst'
alias hukcaNorm='$HLOOKUP $GTHOME/langs/kca/src/analyser-gt-norm.hfst'
alias hukomNorm='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.hfst'
alias hukpvNorm='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.hfst'
alias humdfNorm='$HLOOKUP $GTHOME/langs/mdf/src/analyser-gt-norm.hfst'
alias humhrNorm='$HLOOKUP $GTHOME/langs/mhr/src/analyser-gt-norm.hfst'
alias humrjNorm='$HLOOKUP $GTHOME/langs/mrj/src/analyser-gt-norm.hfst'
alias humyvNorm='$HLOOKUP $GTHOME/langs/myv/src/analyser-gt-norm.hfst'
alias huoloNorm='$HLOOKUP $GTHOME/langs/olo/src/analyser-gt-norm.hfst'
alias huudmNorm='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.hfst'
alias huvepNorm='$HLOOKUP $GTHOME/langs/vep/src/analyser-gt-norm.hfst'
alias huvroNorm='$HLOOKUP $GTHOME/langs/vro/src/analyser-gt-norm.hfst'
alias huyrkNorm='$HLOOKUP $GTHOME/langs/yrk/src/analyser-gt-norm.hfst'

# Other languages:
alias   hdamh='$HLOOKUP $GTHOME/st/amh/bin/iamh.hfst.ol'
alias   hdces='$HLOOKUP $GTHOME/st/ces/bin/ices.hfst.ol'
alias   hdcor='$HLOOKUP $GTHOME/st/cor/bin/icor.hfst.ol'
alias   hddeu='$HLOOKUP $GTHOME/st/deu/bin/ideu.hfst.ol'
alias   hdeng='$HLOOKUP $GTHOME/st/eng/bin/ieng.hfst.ol'
alias   hdiku='$HLOOKUP $GTHOME/st/iku/bin/iiku.hfst.ol'
alias   hdipk='$HLOOKUP $GTHOME/st/ipk/bin/iipk.hfst.ol'
alias   hdnno='$HLOOKUP $GTHOME/st/nno/bin/inno.hfst.ol'
alias   hdnob='$HLOOKUP $GTHOME/st/nob/bin/inob.hfst.ol'
alias   hdnon='$HLOOKUP $GTHOME/st/non/bin/inon.hfst.ol'

alias   huamh='$HLOOKUP $GTHOME/st/amh/bin/amh.hfst.ol'
alias   huces='$HLOOKUP $GTHOME/st/ces/bin/ces.hfst.ol'
alias   hucor='$HLOOKUP $GTHOME/st/cor/bin/cor.hfst.ol'
alias   hudeu='$HLOOKUP $GTHOME/st/deu/bin/deu.hfst.ol'
alias   hueng='$HLOOKUP $GTHOME/st/eng/bin/eng.hfst.ol'
alias   huiku='$HLOOKUP $GTHOME/st/iku/bin/iku.hfst.ol'
alias   huipk='$HLOOKUP $GTHOME/st/ipk/bin/ipk.hfst.ol'
alias   hunno='$HLOOKUP $GTHOME/st/nno/bin/nno.hfst.ol'
alias   hunob='$HLOOKUP $GTHOME/st/nob/bin/nob.hfst.ol'
alias   hunon='$HLOOKUP $GTHOME/st/non/bin/non.hfst.ol'


# Other FU languages:


# Cyrillic aliases:
# 'ч' = key h on the Russian Phonetic keyboard (for Hfst)
alias чуком='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.hfst'
alias чглщь='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.hfst'
alias чумчр='$HLOOKUP $GTHOME/langs/mhr/src/analyser-gt-desc.hfst'
alias чумыв='$HLOOKUP $GTHOME/langs/myv/src/analyser-gt-desc.hfst'
alias чуудм='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.hfst'
alias чуырк='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.hfst'

alias чдком='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.hfst'
alias чдмчр='$HLOOKUP $GTHOME/langs/mhr/src/generator-gt-desc.hfst'
alias чдмыв='$HLOOKUP $GTHOME/langs/myv/src/generator-gt-desc.hfst'
alias чдудм='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-desc.hfst'
alias чдырк='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-desc.hfst'

alias чдкомНорм='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-norm.hfst'
alias чдмчрНорм='$HLOOKUP $GTHOME/langs/mhr/src/generator-gt-norm.hfst'
alias чдмывНорм='$HLOOKUP $GTHOME/langs/myv/src/generator-gt-norm.hfst'
alias чдудмНорм='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-norm.hfst'
alias чдыркНорм='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-norm.hfst'

alias чукомНорм='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.hfst'
alias чглщьНорм='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.hfst'
alias чумчрНорм='$HLOOKUP $GTHOME/langs/mhr/src/analyser-gt-norm.hfst'
alias чумывНорм='$HLOOKUP $GTHOME/langs/myv/src/analyser-gt-norm.hfst'
alias чуудмНорм='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.hfst'
alias чуыркНорм='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.hfst'

# 'х' = cyrillic h (for Hfst)
alias хуком='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.hfst'
alias хглщь='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.hfst'
alias хумчр='$HLOOKUP $GTHOME/langs/mhr/src/analyser-gt-desc.hfst'
alias хумыв='$HLOOKUP $GTHOME/langs/myv/src/analyser-gt-desc.hfst'
alias хуудм='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.hfst'
alias хуырк='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.hfst'

alias хдком='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.hfst'
alias хдмчр='$HLOOKUP $GTHOME/langs/mhr/src/generator-gt-desc.hfst'
alias хдмыв='$HLOOKUP $GTHOME/langs/myv/src/generator-gt-desc.hfst'
alias хдудм='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-desc.hfst'
alias хдырк='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-desc.hfst'

alias хдкомНорм='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-norm.hfst'
alias хдмчрНорм='$HLOOKUP $GTHOME/langs/mhr/src/generator-gt-norm.hfst'
alias хдмывНорм='$HLOOKUP $GTHOME/langs/myv/src/generator-gt-norm.hfst'
alias хдудмНорм='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-norm.hfst'
alias хдыркНорм='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-norm.hfst'

alias хукомНорм='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.hfst'
alias хглщьНорм='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.hfst'
alias хумчрНорм='$HLOOKUP $GTHOME/langs/mhr/src/analyser-gt-norm.hfst'
alias хумывНорм='$HLOOKUP $GTHOME/langs/myv/src/analyser-gt-norm.hfst'
alias хуудмНорм='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.hfst'
alias хуыркНорм='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.hfst'

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
