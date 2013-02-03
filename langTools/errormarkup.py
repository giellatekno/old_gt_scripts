# -*- coding: utf-8 -*-

import re
import unittest
from lxml import etree
import doctest
import lxml.doctestcompare as doctestcompare

class TestErrorMarkup(unittest.TestCase):
    def setUp(self):
        self.em = ErrorMarkup()

    def assertXmlEqual(self, got, want):
        """Check if two stringified xml snippets are equal
        """
        checker = doctestcompare.LXMLOutputChecker()
        if not checker.check_output(want, got, 0):
            message = checker.output_difference(doctest.Example("", want), got, 0).encode('utf-8')
            raise AssertionError(message)

        pass

    def testErrorort1(self):
        input = '<p>jne.$(adv,typo|jna.)</p>'
        want = '<p><errorort correct="jna." errtype="typo" pos="adv">jne.</errorort></p>'

        #got = etree.tostring(self.em.addErrorMarkup(input), encoding = 'utf8')
        #self.assertXmlEqual(got, want)

    def testErrorort2(self):
        input = '<p>daesn\'$daesnie</p>'
        want = '<p><errorort correct="daesnie">daesn\'</errorort></p>'

    def testErrorCorrect1(self):
        input = '<p>1]§Ij</p>'
        want = '<p><error correct="Ij">1]</error></p>'

    def testErrorCorrect2(self):
        input = '<p>væ]keles§(væjkeles)</p>'
        want = '<p><error correct="væjkeles">væ]keles</error></p>'

    def testErrorCorrect3(self):
        input = '<p>smávi-§smávit-</p>'
        want = '<p><error correct="smávit-">smávi-</error></p>'

    def testErrorCorrect4(self):
        input = '<p>CD:t§CD:at</p>'
        want = '<p><error correct="CD:at">CD:t</error></p>'

    def testErrorCorrect5(self):
        input = '<p>DNB-feaskáris§(DnB-feaskáris)</p>'
        want = '<p><error correct="DnB-feaskáris">DNB-feaskáris</error></p>'

    def testErrorCorrect6(self):
        input = '<p>boade§boađe</p>'
        want = '<p><error correct="boađe">boade</error></p>'

    def testErrorCorrect7(self):
        input = '<p>2005’as§2005:s</p>'
        want = '<p><error correct="2005:s">2005’as</error></p>'

    def testErrorCorrect8(self):
        input = '<p>NSRii§NSR:ii</p>'
        want = '<p><error correct="NSR:ii">NSRii</error></p>',

    def testErrorCorrect9(self):
        input = '<p>Nordkjosbotn\'ii§Nordkjosbotnii</p>'
        want = '<p><error correct="Nordkjosbotnii">Nordkjosbotn\'ii</error></p>'

    def testErrorort3(self):
        input = '<p>nourra$(a,meta|nuorra)</p>'
        want = '<p><errorort correct="nuorra" errtype="meta" pos="a">nourra</errorort></p>'

    def testErrorMorphsyn1(self):
        input = '<p>(Nieiddat leat nuorra)£(a,spred,nompl,nomsg,agr|Nieiddat leat nuorat)</p>'
        want = '<p><errormorphsyn cat="nompl" const="spred" correct="Nieiddat leat nuorat" errtype="agr" orig="nomsg" pos="a">Nieiddat leat nuorra</errormorphsyn></p>'

    def testErrorSyn1(self):
        input = '<p>(riŋgen nieidda lusa)¥(x,pph|riŋgen niidii)</p>'
        want = '<p><errorsyn correct="riŋgen niidii" errtype="pph" pos="x">riŋgen nieidda lusa</errorsyn></p>'

    def testErrorSyn2(self):
        input = '<p>ovtta¥(num,redun| )</p>'
        want = '<p><errorsyn correct=" " errtype="redun" pos="num">ovtta</errorsyn></p>'

    def testErrorLex1(self):
        input = '<p>dábálaš€(adv,adj,der|dábálaččat)</p>'
        want = '<p><errorlex correct="dábálaččat" errtype="der" origpos="adj" pos="adv">dábálaš</errorlex></p>'

    def testErrorOrtreal1(self):
        input = '<p>ráhččamušaid¢(noun,mix|rahčamušaid)</p>'
        want = '<p><errorortreal pos="noun" errtype="mix" correct="rahčamušaid">ráhččamušaid</errorortreal></p>'

    def testErrorOrtreal2(self):
        input = '<p>gitta Nordkjosbotn\'ii$Nordkjosbotnii (mii lea ge nordkjosbotn$Nordkjosbotn sámegillii? Muhtin, veahket mu!) gos</p>'
        want = '<p>gitta <errorort correct="Nordkjosbotnii">Nordkjosbotn\'ii</errorort> (mii lea ge <errorort correct="Nordkjosbotn">nordkjosbotn</errorort> sámegillii? Muhtin, veahket mu!) gos</p>'

    def testErrorMorphsyn2(self):
        input = '<p>Čáppa muohtaskulptuvrraid ráhkadeapmi VSM olggobealde lei maiddái ovttasbargu gaskal (skuvla ohppiid)£(noun,attr,gensg,nomsg,case|skuvlla ohppiid) ja VSM.</p>'
        want = '<p>Čáppa muohtaskulptuvrraid ráhkadeapmi VSM olggobealde lei maiddái ovttasbargu gaskal <errormorphsyn cat="gensg" const="attr" correct="skuvlla ohppiid" errtype="case" orig="nomsg" pos="noun">skuvla ohppiid</errormorphsyn> ja VSM.</p>'

    def testErrorort4(self):
        input = '<p>- ruksesruonáčalmmehisvuohta lea sullii 8%:as$(acr,suf|8%:s)</p>'
        want = '<p>- ruksesruonáčalmmehisvuohta lea sullii <errorort correct="8%:s" errtype="suf" pos="acr">8%:as</errorort></p>'

    def testErrorOrtreal3(self):
        input = '<p>( nissonin¢(noun,suf|nissoniin) dušše (0.6 %:s)£(0.6 %) )</p>'
        want = '<p>( <errorortreal correct="nissoniin" errtype="suf" pos="noun">nissonin</errorortreal> dušše <errormorphsyn correct="0.6 %">0.6 %:s</errormorphsyn> )</p>'

    def testErrorort5(self):
        input = '<p>(haploida) ja njiŋŋalas$(noun,á|njiŋŋálas) ságahuvvon$(verb,a|sagahuvvon) manneseallas (diploida)</p>'
        want = '<p>(haploida) ja <errorort correct="njiŋŋálas" errtype="á" pos="noun">njiŋŋalas</errorort> <errorort correct="sagahuvvon" errtype="a" pos="verb">ságahuvvon</errorort> manneseallas (diploida)</p>'

    def testErrorort6(self):
        input = '<p>(gii oahpaha) giinu$(x,notcmp|gii nu) manai intiánalávlagat$(loan,conc|indiánalávlagat) (guovža-klána)$(noun,cmp|guovžaklána) olbmuid</p>'
        want = '<p>(gii oahpaha) <errorort correct="gii nu" errtype="notcmp" pos="x">giinu</errorort> manai <errorort correct="indiánalávlagat" errtype="conc" pos="loan">intiánalávlagat</errorort> <errorort correct="guovžaklána" errtype="cmp" pos="noun">guovža-klána</errorort> olbmuid</p>'

    def testErrorort7(self):
        input = '<p>I 1864 ga han ut boka <span type="quote" xml:lang="swe">"Fornuftigt Madstel"</span>. Asbjørsen$(prop,typo|Asbjørnsen) døde 5. januar 1885, nesten 73 år gammel.</p>'
        want = '<p>I 1864 ga han ut boka <span type="quote" xml:lang="swe">"Fornuftigt Madstel"</span>. <errorort correct="Asbjørnsen" errtype="typo" pos="prop">Asbjørsen</errorort> døde 5. januar 1885, nesten 73 år gammel.</p>'

    #Nested markup
    def testNestedMarkup1(self):
        input = '<p>(šaddai$(verb,conc|šattai) ollu áššit)£(verb,fin,pl3prs,sg3prs,tense|šadde ollu áššit)</p>'
        want = '<p><errormorphsyn cat="pl3prs" const="fin" correct="šadde ollu áššit" errtype="tense" orig="sg3prs" pos="verb"><errorort correct="šattai" errtype="conc" pos="verb">šaddai</errorort> ollu áššit</errormorphsyn></p>'

    def testNestedMarkup2(self):
        input = '<p>(guokte ganddat§(n,á|gánddat))£(n,nump,gensg,nompl,case|guokte gándda)</p>'
        want = '<p><errormorphsyn cat="gensg" const="nump" correct="guokte gándda" errtype="case" orig="nompl" pos="n">guokte <error correct="gánddat">ganddat</error></errormorphsyn></p>'

    def testNestedMarkup3(self):
        input = '<p>(Nieiddat leat nourra$(adj,meta|nuorra))£(adj,spred,nompl,nomsg,agr|Nieiddat leat nuorat)</p>'
        want = '<p><errormorphsyn cat="nompl" const="spred" correct="Nieiddat leat nuorat" errtype="agr" orig="nomsg" pos="adj">Nieiddat leat <errorort correct="nuorra" errtype="meta" pos="adj">nourra</errorort></errormorphsyn></p>'

    def testNestedMarkup4(self):
        input = '<p>(leat (okta máná)£(n,spred,nomsg,gensg,case|okta mánná))£(v,v,sg3prs,pl3prs,agr|lea okta mánná)</p>'
        want = '<p><errormorphsyn cat="sg3prs" const="v" correct="lea okta mánná" errtype="agr" orig="pl3prs" pos="v">leat <errormorphsyn cat="nomsg" const="spred" correct="okta mánná" errtype="case" orig="gensg" pos="n">okta máná</errormorphsyn></errormorphsyn></p>'

    def testNestedMarkup5(self):
        input = '<p>heaitit dáhkaluddame$(verb,a|dahkaluddame) ahte sis máhkaš¢(adv,á|mahkáš) livččii makkarge$(adv,á|makkárge) politihkka, muhto rahpasit baicca muitalivčče (makkar$(interr,á|makkár) soga)€(man soga) sii ovddasttit$(verb,conc|ovddastit).</p>'
        want = '<p>heaitit <errorort correct="dahkaluddame" errtype="a" pos="verb">dáhkaluddame</errorort> ahte sis <errorortreal correct="mahkáš" errtype="á" pos="adv">máhkaš</errorortreal> livččii <errorort correct="makkárge" errtype="á" pos="adv">makkarge</errorort> politihkka, muhto rahpasit baicca muitalivčče <errorlex correct="man soga"><errorort correct="makkár" errtype="á" pos="interr">makkar</errorort> soga</errorlex> sii <errorort correct="ovddastit" errtype="conc" pos="verb">ovddasttit</errorort>.</p>'

    def testNestedMarkup6(self):
        input = '<p>(Bearpmahat$(noun,svow|Bearpmehat) earuha€(verb,v,w|sirre))£(verb,fin,pl3prs,sg3prs,agr|Bearpmehat sirrejit) uskki ja loaiddu.</p>'
        want = '<p><errormorphsyn cat="pl3prs" const="fin" correct="Bearpmehat sirrejit" errtype="agr" orig="sg3prs" pos="verb"><errorort correct="Bearpmehat" errtype="svow" pos="noun">Bearpmahat</errorort> <errorlex correct="sirre" errtype="w" origpos="v" pos="verb">earuha</errorlex></errormorphsyn> uskki ja loaiddu.</p>'

    def testNestedMarkup7(self):
        input = '<p>Mirja ja Line leaba (gulahallan olbmožat)¢(noun,cmp|gulahallanolbmožat)€gulahallanolbmot</p>'
        want = '<p>Mirja ja Line leaba <errorlex correct="gulahallanolbmot"><errorortreal correct="gulahallanolbmožat" errtype="cmp" pos="noun">gulahallan olbmožat</errorortreal></errorlex></p>'

    def testNestedMarkup8(self):
        input = '<p>(Ovddit geasis)£(noun,advl,gensg,locsg,case|Ovddit geasi) ((čoaggen$(verb,mono|čoggen) ollu jokŋat)£(noun,obj,genpl,nompl,case|čoggen ollu joŋaid) ja sarridat)£(noun,obj,genpl,nompl,case|čoggen ollu joŋaid ja sarridiid)</p>'
        want = '<p><errormorphsyn cat="gensg" const="advl" correct="Ovddit geasi" errtype="case" orig="locsg" pos="noun">Ovddit geasis</errormorphsyn> <errormorphsyn cat="genpl" const="obj" correct="čoggen ollu joŋaid ja sarridiid" errtype="case" orig="nompl" pos="noun"><errormorphsyn cat="genpl" const="obj" correct="čoggen ollu joŋaid" errtype="case" orig="nompl" pos="noun"><errorort correct="čoggen" errtype="mono" pos="verb">čoaggen</errorort> ollu jokŋat</errormorphsyn> ja sarridat</errormorphsyn></p>'

    def testNestedMarkup9(self):
        input = '<p>Bruk ((epoxi)$(noun,cons|epoksy) lim)¢(noun,mix|epoksylim) med god kvalitet.</p>'
        want = '<p>Bruk  <errorortreal correct="epoksylim" errtype="mix" pos="noun"><errorort correct="epoksy" errtype="cons" pos="noun">epoxi</errorort> lim</errorortreal> med god kvalitet.</p>'

    def testSetCommonAttributes1(self):
        input = etree.fromstring('<errorort>jne.</errorort>')
        want = '<errorort pos="adv">jne.</errorort>'

        self.em.setCommonAttributes(input, {'pos': "adv"})

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetCommonAttributes2(self):
        input = etree.fromstring('<errorort>jne.</errorort>')
        want = '<errorort errtype="typo">jne.</errorort>'

        self.em.setCommonAttributes(input, {'errtype': "typo"})

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetCommonAttributes3(self):
        input = etree.fromstring('<errorort>jne.</errorort>')
        want = '<errorort teacher="yes">jne.</errorort>'

        self.em.setCommonAttributes(input, {'teacher': "yes"})

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetOrthographicalAttributes1(self):
        input = etree.fromstring('<errorort>jne.</errorort>')
        want = '<errorort teacher="yes">jne.</errorort>'

        self.em.setOrthographicalAttributes(input, "yes")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetOrthographicalAttributes2(self):
        input = etree.fromstring('<errorort>jne.</errorort>')
        want = '<errorort pos="adj" teacher="yes">jne.</errorort>'

        self.em.setOrthographicalAttributes(input, "adj,yes")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetOrthographicalAttributes3(self):
        input = etree.fromstring('<errorort>jne.</errorort>')
        want = '<errorort pos="adj" errtype="blabla" teacher="yes">jne.</errorort>'

        self.em.setOrthographicalAttributes(input, "adj,blabla,yes")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetOrthographicalAttributes4(self):
        input = etree.fromstring('<errorort>jne.</errorort>')
        want = '<errorort pos="blabla">jne.</errorort>'

        self.em.setOrthographicalAttributes(input, "blabla")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetOrthographicalAttributes5(self):
        input = etree.fromstring('<errorort>jne.</errorort>')
        want = '<errorort pos="adj" errtype="blabla">jne.</errorort>'

        self.em.setOrthographicalAttributes(input, "adj,blabla")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetLexicalAttributes1(self):
        input = etree.fromstring('<errorlex>dábálaš</errorlex>')
        want = '<errorlex pos="adv">dábálaš</errorlex>'

        self.em.setLexicalAttributes(input, "adv")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetLexicalAttributes2(self):
        input = etree.fromstring('<errorlex>dábálaš</errorlex>')
        want = '<errorlex teacher="yes">dábálaš</errorlex>'

        self.em.setLexicalAttributes(input, "yes")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetLexicalAttributes3(self):
        input = etree.fromstring('<errorlex>dábálaš</errorlex>')
        want = '<errorlex pos="adv" origpos="adj">dábálaš</errorlex>'

        self.em.setLexicalAttributes(input, "adv,adj")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetLexicalAttributes4(self):
        input = etree.fromstring('<errorlex>dábálaš</errorlex>')
        want = '<errorlex pos="adv" teacher="yes">dábálaš</errorlex>'

        self.em.setLexicalAttributes(input, "adv,yes")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetLexicalAttributes5(self):
        input = etree.fromstring('<errorlex>dábálaš</errorlex>')
        want = '<errorlex errtype="der" pos="adv" origpos="adj">dábálaš</errorlex>'

        self.em.setLexicalAttributes(input, "adv,adj,der")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetLexicalAttributes6(self):
        input = etree.fromstring('<errorlex>dábálaš</errorlex>')
        want = '<errorlex teacher="yes" pos="adv" origpos="adj">dábálaš</errorlex>'

        self.em.setLexicalAttributes(input, "adv,adj,yes")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetLexicalAttributes7(self):
        input = etree.fromstring('<errorlex>dábálaš</errorlex>')
        want = '<errorlex errtype="der" pos="adv" origpos="adj" teacher="yes">dábálaš</errorlex>'

        self.em.setLexicalAttributes(input, "adv,adj,der,yes")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetMorphosyntacticAttributes1(self):
        input = etree.fromstring('<errormorphsyn>Nieiddat leat nuorra</errormorphsyn>')
        want = '<errormorphsyn cat="nompl" const="spred" errtype="agr" orig="nomsg" pos="a" teacher="yes">Nieiddat leat nuorra</errormorphsyn>'

        self.em.setMorphosyntacticAttributes(input, "a,spred,nompl,nomsg,agr,yes")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetMorphosyntacticAttributes2(self):
        input = etree.fromstring('<errormorphsyn>Nieiddat leat nuorra</errormorphsyn>')
        want = '<errormorphsyn cat="nompl" const="spred" errtype="agr" orig="nomsg" pos="a">Nieiddat leat nuorra</errormorphsyn>'

        self.em.setMorphosyntacticAttributes(input, "a,spred,nompl,nomsg,agr")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetMorphosyntacticAttributes3(self):
        input = etree.fromstring('<errormorphsyn>Nieiddat leat nuorra</errormorphsyn>')
        want = '<errormorphsyn cat="nompl" const="spred" teacher="yes" orig="nomsg" pos="a">Nieiddat leat nuorra</errormorphsyn>'

        self.em.setMorphosyntacticAttributes(input, "a,spred,nompl,nomsg,yes")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetMorphosyntacticAttributes4(self):
        input = etree.fromstring('<errormorphsyn>Nieiddat leat nuorra</errormorphsyn>')
        want = '<errormorphsyn cat="nompl" const="spred" orig="nomsg" pos="a">Nieiddat leat nuorra</errormorphsyn>'

        self.em.setMorphosyntacticAttributes(input, "a,spred,nompl,nomsg")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetMorphosyntacticAttributes5(self):
        input = etree.fromstring('<errormorphsyn>Nieiddat leat nuorra</errormorphsyn>')
        want = '<errormorphsyn cat="nompl" const="spred" teacher="no" pos="a">Nieiddat leat nuorra</errormorphsyn>'

        self.em.setMorphosyntacticAttributes(input, "a,spred,nompl,no")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetMorphosyntacticAttributes6(self):
        input = etree.fromstring('<errormorphsyn>Nieiddat leat nuorra</errormorphsyn>')
        want = '<errormorphsyn cat="nompl" const="spred" pos="a">Nieiddat leat nuorra</errormorphsyn>'

        self.em.setMorphosyntacticAttributes(input, "a,spred,nompl")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetMorphosyntacticAttributes7(self):
        input = etree.fromstring('<errormorphsyn>Nieiddat leat nuorra</errormorphsyn>')
        want = '<errormorphsyn teacher="no" const="spred" pos="a">Nieiddat leat nuorra</errormorphsyn>'

        self.em.setMorphosyntacticAttributes(input, "a,spred,no")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetMorphosyntacticAttributes8(self):
        input = etree.fromstring('<errormorphsyn>Nieiddat leat nuorra</errormorphsyn>')
        want = '<errormorphsyn const="spred" pos="a">Nieiddat leat nuorra</errormorphsyn>'

        self.em.setMorphosyntacticAttributes(input, "a,spred")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetMorphosyntacticAttributes9(self):
        input = etree.fromstring('<errormorphsyn>Nieiddat leat nuorra</errormorphsyn>')
        want = '<errormorphsyn teacher="no" pos="a">Nieiddat leat nuorra</errormorphsyn>'

        self.em.setMorphosyntacticAttributes(input, "a,no")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetMorphosyntacticAttributes10(self):
        input = etree.fromstring('<errormorphsyn>Nieiddat leat nuorra</errormorphsyn>')
        want = '<errormorphsyn pos="a">Nieiddat leat nuorra</errormorphsyn>'

        self.em.setMorphosyntacticAttributes(input, "a")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetMorphosyntacticAttributes11(self):
        input = etree.fromstring('<errormorphsyn>Nieiddat leat nuorra</errormorphsyn>')
        want = '<errormorphsyn teacher="yes">Nieiddat leat nuorra</errormorphsyn>'

        self.em.setMorphosyntacticAttributes(input, "yes")

        self.assertXmlEqual(etree.tostring(input), want)

class ErrorMarkup:
    def __init__(self):
        self.types = { "$": "errorort", "¢": "errorortreal", "€": "errorlex", "£": "errormorphsyn", "¥": "errorsyn", "§": "error"}
        pass

    def addErrorMarkup(self, paragraph):
        pass

    def setCommonAttributes(self, errorElement, attDict):
        for name, value in attDict.items():
            errorElement.set(name, value)

    def setOrthographicalAttributes(self, errorElement, attributeList):
        attDict = {}
        atts = attributeList.split(',')

        if len(atts) == 1:
            if atts[0] == 'yes' or atts[0] == 'no':
                attDict['teacher'] = atts[0]
            else:
                attDict['pos'] = atts[0]
        elif len(atts) == 2:
            if atts[1] == 'yes' or atts[1] == 'no':
                attDict['pos'] = atts[0]
                attDict['teacher'] = atts[1]
            else:
                attDict['pos'] = atts[0]
                attDict['errtype'] = atts[1]
        else:
            attDict['pos'] = atts[0]
            attDict['errtype'] = atts[1]
            attDict['teacher'] = atts[2]

        self.setCommonAttributes(errorElement, attDict)

    def setLexicalAttributes(self, errorElement, attributeList):
        attDict = {}
        atts = attributeList.split(',')

        if len(atts) == 1:
            if atts[0] == 'yes' or atts[0] == 'no':
                attDict['teacher'] = atts[0]
            else:
                attDict['pos'] = atts[0]
        elif len(atts) == 2:
            if atts[1] == 'yes' or atts[1] == 'no':
                attDict['pos'] = atts[0]
                attDict['teacher'] = atts[1]
            else:
                attDict['pos'] = atts[0]
                attDict['origpos'] = atts[1]
        elif len(atts) == 3:
            attDict['origpos'] = atts[1]
            if atts[2] == 'yes' or atts[2] == 'no':
                attDict['pos'] =atts[0]
                attDict['teacher'] = atts[2]
            else:
                attDict['pos'] =atts[0]
                attDict['errtype'] =atts[2]
        else:
            attDict['pos'] = atts[0]
            attDict['origpos'] = atts[1]
            attDict['errtype'] = atts[2]
            attDict['teacher'] = atts[3]

        self.setCommonAttributes(errorElement, attDict)

    def setMorphosyntacticAttributes(self, errorElement, attributeList):
        attDict = {}
        atts = attributeList.split(',')

        if len(atts) == 1:
            if atts[0] == 'yes' or atts[0] == 'no':
                attDict['teacher'] = atts[0]
            else:
                attDict['pos'] = atts[0]
        elif len(atts) == 2:
            attDict['pos'] = atts[0]
            if atts[1] == 'yes' or atts[1] == 'no':
                attDict['teacher'] = atts[1]
            else:
                attDict['const'] = atts[1]
        elif len(atts) == 3:
            attDict['pos'] = atts[0]
            attDict['const'] = atts[1]
            if atts[2] == 'yes' or atts[2] == 'no':
                attDict['teacher'] = atts[2]
            else:
                attDict['cat'] = atts[2]
        elif len(atts) == 4:
            attDict['pos'] = atts[0]
            attDict['const'] = atts[1]
            attDict['cat'] = atts[2]
            if atts[3] == 'yes' or atts[3] == 'no':
                attDict['teacher'] = atts[3]
            else:
                attDict['orig'] = atts[3]
        elif len(atts) == 5:
            attDict['pos'] = atts[0]
            attDict['const'] = atts[1]
            attDict['cat'] = atts[2]
            attDict['orig'] = atts[3]
            if atts[4] == 'yes' or atts[4] == 'no':
                attDict['teacher'] = atts[4]
            else:
                attDict['errtype'] = atts[4]
        else:
            attDict['pos'] = atts[0]
            attDict['const'] = atts[1]
            attDict['cat'] = atts[2]
            attDict['orig'] = atts[3]
            attDict['errtype'] = atts[4]
            attDict['teacher'] = atts[5]

        self.setCommonAttributes(errorElement, attDict)

