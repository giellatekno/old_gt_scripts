# A number of useful aliases to run lookup sessions on the langauges we support.

# xerox aliases

# Sámi languages:
alias   dsjd='lookup -flags mbTT $GTHOME/gt/sjd/bin/isjd.fst'
alias   dsje='lookup -flags mbTT $GTHOME/gt/sje/bin/isje.fst'
alias   dsma='lookup -flags mbTT $GTHOME/gt/sma/bin/isma.fst'
alias   dsme='lookup -flags mbTT $GTHOME/gt/sme/bin/isme.fst'
alias   dsmj='lookup -flags mbTT $GTHOME/gt/smj/bin/ismj.fst'
alias   dsmn='lookup -flags mbTT $GTHOME/gt/smn/bin/ismn.fst'
alias   dsms='lookup -flags mbTT $GTHOME/gt/sms/bin/isms.fst'
alias   usjd='lookup -flags mbTT $GTHOME/gt/sjd/bin/sjd.fst'
alias   usje='lookup -flags mbTT $GTHOME/gt/sje/bin/sje.fst'
alias   usma='lookup -flags mbTT $GTHOME/gt/sma/bin/sma.fst'
alias   usme='lookup -flags mbTT $GTHOME/gt/sme/bin/sme.fst'
alias   usmj='lookup -flags mbTT $GTHOME/gt/smj/bin/smj.fst'
alias   usmn='lookup -flags mbTT $GTHOME/gt/smn/bin/smn.fst'
alias   usms='lookup -flags mbTT $GTHOME/gt/sms/bin/sms.fst'

# Other languages:
alias   damh='lookup -flags mbTT $GTHOME/st/amh/bin/iamh.fst'
alias   dces='lookup -flags mbTT $GTHOME/st/ces/bin/ices.fst'
alias   dcor='lookup -flags mbTT $GTHOME/st/cor/bin/icor.fst'
alias   ddeu='lookup -flags mbTT $GTHOME/st/deu/bin/ideu.fst'
alias   deng='lookup -flags mbTT $GTHOME/st/eng/bin/ieng.fst'
alias   dfao='lookup -flags mbTT $GTHOME/st/fao/bin/ifao.fst'
alias   diku='lookup -flags mbTT $GTHOME/st/iku/bin/iiku.fst'
alias   dipk='lookup -flags mbTT $GTHOME/st/ipk/bin/iipk.fst'
alias   dkal='lookup -flags mbTT $GTHOME/st/kal/bin/ikal.fst'
alias   dnno='lookup -flags mbTT $GTHOME/st/nno/bin/inno.fst'
alias   dnob='lookup -flags mbTT $GTHOME/st/nob/bin/inob.fst'
alias   dnon='lookup -flags mbTT $GTHOME/st/non/bin/inon.fst'
alias   uamh='lookup -flags mbTT $GTHOME/st/amh/bin/amh.fst'
alias   uces='lookup -flags mbTT $GTHOME/st/ces/bin/ces.fst'
alias   ucor='lookup -flags mbTT $GTHOME/st/cor/bin/cor.fst'
alias   udeu='lookup -flags mbTT $GTHOME/st/deu/bin/deu.fst'
alias   ueng='lookup -flags mbTT $GTHOME/st/eng/bin/eng.fst'
alias   ufao='lookup -flags mbTT $GTHOME/st/fao/bin/fao.fst'
alias   uiku='lookup -flags mbTT $GTHOME/st/iku/bin/iku.fst'
alias   uipk='lookup -flags mbTT $GTHOME/st/ipk/bin/ipk.fst'
alias   ukal='lookup -flags mbTT $GTHOME/st/kal/bin/kal.fst'
alias   unno='lookup -flags mbTT $GTHOME/st/nno/bin/nno.fst'
alias   unob='lookup -flags mbTT $GTHOME/st/nob/bin/nob.fst'
alias   unon='lookup -flags mbTT $GTHOME/st/non/bin/non.fst'

# Other FU languages:
alias   dfin='lookup -flags mbTT $GTHOME/kt/fin/bin/ifin.fst'
alias   dkom='lookup -flags mbTT $GTHOME/kt/kom/bin/ikom.fst'
alias   ufin='lookup -flags mbTT $GTHOME/kt/fin/bin/fin.fst'
alias   ukom='lookup -flags mbTT $GTHOME/kt/kom/bin/kom.fst'

# Bilingual transducers:
alias fitswe='lookup -flags mbTT $GTHOME/kvensk/fitswe/bin/fitswe.fst'
alias fkvnob='lookup -flags mbTT $GTHOME/kvensk/bin/fkvnob.fst'
alias kaldan='lookup -flags mbTT $GTHOME/words/dicts/kaldan/bin/kaldan.fst'
alias kaldic='lookup -flags mbTT $GTHOME/words/dicts/kaldan/bin/kaldic.fst'
alias kaleng='lookup -flags mbTT $GTHOME/words/dicts/kaleng/bin/kaleng.fst'
alias nobfkv='lookup -flags mbTT $GTHOME/kvensk/bin/nobfkv.fst'
alias nobsme='lookup -flags mbTT $GTHOME/words/dicts/smenob/bin/ismenob.fst'
alias smenob='lookup -flags mbTT $GTHOME/words/dicts/smenob/bin/smenob.fst'
alias smesmj='lookup -flags mbTT $GTHOME/words/dicts/smesmj/bin/smesmj.fst'
alias smjsme='lookup -flags mbTT $GTHOME/words/dicts/smesmj/bin/smjsme.fst'
alias swefit='lookup -flags mbTT $GTHOME/kvensk/swefit/bin/swefit.fst'

# Other transducers
alias ogeo='lookup -flags mbTT ~/GTHOME/words/dicts/smi/geo/bin/geo.fst'





# .hfst.ol aliases

# Sámi languages:
alias   hdsjd='hfst-optimize-lookup $GTHOME/gt/sjd/bin/isjd.hfst.ol'
alias   hdsje='hfst-optimize-lookup $GTHOME/gt/sje/bin/isje.hfst.ol'
alias   hdsma='hfst-optimize-lookup $GTHOME/gt/sma/bin/isma.hfst.ol'
alias   hdsme='hfst-optimize-lookup $GTHOME/gt/sme/bin/isme.hfst.ol'
alias   hdsmj='hfst-optimize-lookup $GTHOME/gt/smj/bin/ismj.hfst.ol'
alias   hdsmn='hfst-optimize-lookup $GTHOME/gt/smn/bin/ismn.hfst.ol'
alias   hdsms='hfst-optimize-lookup $GTHOME/gt/sms/bin/isms.hfst.ol'
alias   husjd='hfst-optimize-lookup $GTHOME/gt/sjd/bin/sjd.hfst.ol'
alias   husje='hfst-optimize-lookup $GTHOME/gt/sje/bin/sje.hfst.ol'
alias   husma='hfst-optimize-lookup $GTHOME/gt/sma/bin/sma.hfst.ol'
alias   husme='hfst-optimize-lookup $GTHOME/gt/sme/bin/sme.hfst.ol'
alias   husmj='hfst-optimize-lookup $GTHOME/gt/smj/bin/smj.hfst.ol'
alias   husmn='hfst-optimize-lookup $GTHOME/gt/smn/bin/smn.hfst.ol'
alias   husms='hfst-optimize-lookup $GTHOME/gt/sms/bin/sms.hfst.ol'

# Other languages:
alias   hdamh='hfst-optimize-lookup $GTHOME/st/amh/bin/iamh.hfst.ol'
alias   hdces='hfst-optimize-lookup $GTHOME/st/ces/bin/ices.hfst.ol'
alias   hdcor='hfst-optimize-lookup $GTHOME/st/cor/bin/icor.hfst.ol'
alias   hddeu='hfst-optimize-lookup $GTHOME/st/deu/bin/ideu.hfst.ol'
alias   hdeng='hfst-optimize-lookup $GTHOME/st/eng/bin/ieng.hfst.ol'
alias   hdfao='hfst-optimize-lookup $GTHOME/st/fao/bin/ifao.hfst.ol'
alias   hdiku='hfst-optimize-lookup $GTHOME/st/iku/bin/iiku.hfst.ol'
alias   hdipk='hfst-optimize-lookup $GTHOME/st/ipk/bin/iipk.hfst.ol'
alias   hdkal='hfst-optimize-lookup $GTHOME/st/kal/bin/ikal.hfst.ol'
alias   hdnno='hfst-optimize-lookup $GTHOME/st/nno/bin/inno.hfst.ol'
alias   hdnob='hfst-optimize-lookup $GTHOME/st/nob/bin/inob.hfst.ol'
alias   hdnon='hfst-optimize-lookup $GTHOME/st/non/bin/inon.hfst.ol'
alias   huamh='hfst-optimize-lookup $GTHOME/st/amh/bin/amh.hfst.ol'
alias   huces='hfst-optimize-lookup $GTHOME/st/ces/bin/ces.hfst.ol'
alias   hucor='hfst-optimize-lookup $GTHOME/st/cor/bin/cor.hfst.ol'
alias   hudeu='hfst-optimize-lookup $GTHOME/st/deu/bin/deu.hfst.ol'
alias   hueng='hfst-optimize-lookup $GTHOME/st/eng/bin/eng.hfst.ol'
alias   hufao='hfst-optimize-lookup $GTHOME/st/fao/bin/fao.hfst.ol'
alias   huiku='hfst-optimize-lookup $GTHOME/st/iku/bin/iku.hfst.ol'
alias   huipk='hfst-optimize-lookup $GTHOME/st/ipk/bin/ipk.hfst.ol'
alias   hukal='hfst-optimize-lookup $GTHOME/st/kal/bin/kal.hfst.ol'
alias   hunno='hfst-optimize-lookup $GTHOME/st/nno/bin/nno.hfst.ol'
alias   hunob='hfst-optimize-lookup $GTHOME/st/nob/bin/nob.hfst.ol'
alias   hunon='hfst-optimize-lookup $GTHOME/st/non/bin/non.hfst.ol'

# Other FU languages:
alias   hdfin='hfst-optimize-lookup $GTHOME/kt/fin/bin/ifin.hfst.ol'
alias   hdkom='hfst-optimize-lookup $GTHOME/kt/kom/bin/ikom.hfst.ol'
alias   hufin='hfst-optimize-lookup $GTHOME/kt/fin/bin/fin.hfst.ol'
alias   hukom='hfst-optimize-lookup $GTHOME/kt/kom/bin/kom.hfst.ol'

# Bilingual transducers:
alias hfitswe='hfst-optimize-lookup $GTHOME/kvensk/fitswe/bin/fitswe.hfst.ol'
alias hfkvnob='hfst-optimize-lookup $GTHOME/kvensk/bin/fkvnob.hfst.ol'
alias hkaldan='hfst-optimize-lookup $GTHOME/words/dicts/kaldan/bin/kaldan.hfst.ol'
alias hkaldic='hfst-optimize-lookup $GTHOME/words/dicts/kaldan/bin/kaldic.hfst.ol'
alias hkaleng='hfst-optimize-lookup $GTHOME/words/dicts/kaleng/bin/kaleng.hfst.ol'
alias hnobfkv='hfst-optimize-lookup $GTHOME/kvensk/bin/nobfkv.hfst.ol'
alias hnobsme='hfst-optimize-lookup $GTHOME/words/dicts/smenob/bin/ismenob.hfst.ol'
alias hsmenob='hfst-optimize-lookup $GTHOME/words/dicts/smenob/bin/smenob.hfst.ol'
alias hsmesmj='hfst-optimize-lookup $GTHOME/words/dicts/smesmj/bin/smesmj.hfst.ol'
alias hsmjsme='hfst-optimize-lookup $GTHOME/words/dicts/smesmj/bin/smjsme.hfst.ol'
alias hswefit='hfst-optimize-lookup $GTHOME/kvensk/swefit/bin/swefit.hfst.ol'

# Other transducers
alias ogeo='hfst-optimize-lookup ~/GTHOME/words/dicts/smi/geo/bin/geo.hfst.ol'

