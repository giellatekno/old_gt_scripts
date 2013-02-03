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

    def testSetSyntacticAttributes1(self):
        input = etree.fromstring('<errorsyn>riŋgen nieidda lusa</errorsyn>')
        want = '<errorsyn errtype="pph" pos="x" teacher="no">riŋgen nieidda lusa</errorsyn>'

        self.em.setSyntacticAttributes(input, "x,pph,no")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetSyntacticAttributes2(self):
        input = etree.fromstring('<errorsyn>riŋgen nieidda lusa</errorsyn>')
        want = '<errorsyn errtype="pph" pos="x">riŋgen nieidda lusa</errorsyn>'

        self.em.setSyntacticAttributes(input, "x,pph")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetSyntacticAttributes3(self):
        input = etree.fromstring('<errorsyn>riŋgen nieidda lusa</errorsyn>')
        want = '<errorsyn pos="x" teacher="no">riŋgen nieidda lusa</errorsyn>'

        self.em.setSyntacticAttributes(input, "x,no")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetSyntacticAttributes4(self):
        input = etree.fromstring('<errorsyn>riŋgen nieidda lusa</errorsyn>')
        want = '<errorsyn pos="x">riŋgen nieidda lusa</errorsyn>'

        self.em.setSyntacticAttributes(input, "x")

        self.assertXmlEqual(etree.tostring(input), want)

    def testSetSyntacticAttributes5(self):
        input = etree.fromstring('<errorsyn>riŋgen nieidda lusa</errorsyn>')
        want = '<errorsyn teacher="no">riŋgen nieidda lusa</errorsyn>'

        self.em.setSyntacticAttributes(input, "no")

        self.assertXmlEqual(etree.tostring(input), want)

    def testAddExtraAttributes1(self):
        input = etree.fromstring('<errorsyn>riŋgen nieidda lusa</errorsyn>')
        want = '<errorsyn pos="x">riŋgen nieidda lusa</errorsyn>'

        self.em.addExtraAttributes(input, "x")

        self.assertXmlEqual(etree.tostring(input), want)

    def testMakeErrorElement(self):
        want = '<errorsyn correct="riŋgen niidii">riŋgen nieidda lusa</errorsyn>'
        errorElement = self.em.makeErrorElement(u"riŋgen nieidda lusa", u"riŋgen niidii", "errorsyn")
        self.assertXmlEqual(etree.tostring(errorElement), want)

    def testLookForExtendedAttributes1(self):
        correctionString = '1]'
        want = ('1]', False, '')
        got = self.em.lookForExtendedAttributes(correctionString)

        self.assertEqual(got, want)

    def testLookForExtendedAttributes2(self):
        correctionString = 'a,spred,nompl,nomsg,agr|Nieiddat leat nuorat'
        want = ('Nieiddat leat nuorat', True, 'a,spred,nompl,nomsg,agr')
        got = self.em.lookForExtendedAttributes(correctionString)

        self.assertEqual(got, want)

    def testProcessText1(self):
        text = u'jne.$(adv,typo|jna.)'
        want = [u'jne.', u'$(adv,typo|jna.)']

        self.assertEqual(self.em.processText(text), want)

    def testProcessText2(self):
        text = u"daesn'$daesnie"
        want = [u"daesn'", "$daesnie"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText3(self):
        text = u"1]§Ij"
        want = [u"1]", u"§Ij"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText4(self):
        text = u"væ]keles§(væjkeles)"
        want = [u"væ]keles", u"§(væjkeles)"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText5(self):
        text = u"smávi-§smávit-"
        want = [u"smávi-", u"§smávit-"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText6(self):
        text = u"CD:t§CD:at"
        want = [u"CD:t", u"§CD:at"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText7(self):
        text = u"DNB-feaskáris§(DnB-feaskáris)"
        want = [u"DNB-feaskáris", u"§(DnB-feaskáris)"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText8(self):
        text = u"boade§boađe"
        want = [u"boade", u"§boađe"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText9(self):
        text = u"2005’as§2005:s"
        want = [u"2005’as", u"§2005:s"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText10(self):
        text = u"NSRii§NSR:ii"
        want = [u"NSRii", u"§NSR:ii"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText11(self):
        text = u"Nordkjosbotn'ii§Nordkjosbotnii"
        want = [u"Nordkjosbotn'ii", u"§Nordkjosbotnii"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText12(self):
        text = u"nourra$(a,meta|nuorra)"
        want = [u"nourra", u"$(a,meta|nuorra)"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText13(self):
        text = u"(Nieiddat leat nuorra)£(a,spred,nompl,nomsg,agr|Nieiddat leat nuorat)"
        want = [u"(Nieiddat leat nuorra)", u"£(a,spred,nompl,nomsg,agr|Nieiddat leat nuorat)"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText14(self):
        text = u"(riŋgen nieidda lusa)¥(x,pph|riŋgen niidii)"
        want = [u"(riŋgen nieidda lusa)", u"¥(x,pph|riŋgen niidii)"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText15(self):
        text = u"ovtta¥(num,redun| )"
        want = [u"ovtta", u"¥(num,redun| )"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText16(self):
        text = u"dábálaš€(adv,adj,der|dábálaččat)"
        want = [u"dábálaš", u"€(adv,adj,der|dábálaččat)"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText17(self):
        text = u"ráhččamušaid¢(noun,mix|rahčamušaid)"
        want = [u"ráhččamušaid", u"¢(noun,mix|rahčamušaid)"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText18(self):
        text = u"gitta Nordkjosbotn'ii$Nordkjosbotnii (mii lea ge nordkjosbotn$Nordkjosbotn sámegillii? Muhtin, veahket mu!) gos"
        want = [u"gitta Nordkjosbotn'ii", u"$Nordkjosbotnii", u" (mii lea ge nordkjosbotn", u"$Nordkjosbotn", u" sámegillii? Muhtin, veahket mu!) gos"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText19(self):
        text = u"Čáppa muohtaskulptuvrraid ráhkadeapmi VSM olggobealde lei maiddái ovttasbargu gaskal (skuvla ohppiid)£(noun,attr,gensg,nomsg,case|skuvlla ohppiid) ja VSM."
        want = [u"Čáppa muohtaskulptuvrraid ráhkadeapmi VSM olggobealde lei maiddái ovttasbargu gaskal (skuvla ohppiid)", u"£(noun,attr,gensg,nomsg,case|skuvlla ohppiid)", u" ja VSM."]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText20(self):
        text = u"- ruksesruonáčalmmehisvuohta lea sullii 8%:as$(acr,suf|8%:s)"
        want = [u"- ruksesruonáčalmmehisvuohta lea sullii 8%:as", u"$(acr,suf|8%:s)"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText21(self):
        text = u"( nissonin¢(noun,suf|nissoniin) dušše (0.6 %:s)£(0.6 %) )"
        want = [u"( nissonin", u"¢(noun,suf|nissoniin)", u" dušše (0.6 %:s)", u"£(0.6 %)", u" )"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText22(self):
        text = u"(haploida) ja njiŋŋalas$(noun,á|njiŋŋálas) ságahuvvon$(verb,a|sagahuvvon) manneseallas (diploida)"
        want = [u"(haploida) ja njiŋŋalas", u"$(noun,á|njiŋŋálas)", u" ságahuvvon", u"$(verb,a|sagahuvvon)", u" manneseallas (diploida)"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText23(self):
        text = u"(gii oahpaha) giinu$(x,notcmp|gii nu) manai intiánalávlagat$(loan,conc|indiánalávlagat) (guovža-klána)$(noun,cmp|guovžaklána) olbmuid"
        want = [u"(gii oahpaha) giinu", "$(x,notcmp|gii nu)", u" manai intiánalávlagat", u"$(loan,conc|indiánalávlagat)", u" (guovža-klána)", u"$(noun,cmp|guovžaklána)", u" olbmuid"]

        self.assertEqual(self.em.processText(text), want)

    def testProcessText24(self):
        text = u'(šaddai$(verb,conc|šattai) ollu áššit)£(verb,fin,pl3prs,sg3prs,tense|šadde ollu áššit)'
        want = [u'(šaddai', u"$(verb,conc|šattai)", u" ollu áššit)", u'£(verb,fin,pl3prs,sg3prs,tense|šadde ollu áššit)']

        self.assertEqual(self.em.processText(text), want)

    def testProcessText25(self):
        text = u'(guokte ganddat§(n,á|gánddat))£(n,nump,gensg,nompl,case|guokte gándda)'
        want = [u'(guokte ganddat', u'§(n,á|gánddat)', u')', u'£(n,nump,gensg,nompl,case|guokte gándda)']

        self.assertEqual(self.em.processText(text), want)

    def testProcessText26(self):
        text = u'(Nieiddat leat nourra$(adj,meta|nuorra))£(adj,spred,nompl,nomsg,agr|Nieiddat leat nuorat)'
        want = [u'(Nieiddat leat nourra', u'$(adj,meta|nuorra)', u')', u'£(adj,spred,nompl,nomsg,agr|Nieiddat leat nuorat)']

        self.assertEqual(self.em.processText(text), want)

    def testProcessText27(self):
        text = u'(leat (okta máná)£(n,spred,nomsg,gensg,case|okta mánná))£(v,v,sg3prs,pl3prs,agr|lea okta mánná)'
        want = [u'(leat (okta máná)', u'£(n,spred,nomsg,gensg,case|okta mánná)', u')', u'£(v,v,sg3prs,pl3prs,agr|lea okta mánná)']

        self.assertEqual(self.em.processText(text), want)

    def testProcessText28(self):
        text = u'heaitit dáhkaluddame$(verb,a|dahkaluddame) ahte sis máhkaš¢(adv,á|mahkáš) livččii makkarge$(adv,á|makkárge) politihkka, muhto rahpasit baicca muitalivčče (makkar$(interr,á|makkár) soga)€(man soga) sii ovddasttit$(verb,conc|ovddastit).'
        want = [u'heaitit dáhkaluddame', u'$(verb,a|dahkaluddame)', u' ahte sis máhkaš', u'¢(adv,á|mahkáš)', u' livččii makkarge', u'$(adv,á|makkárge)', u' politihkka, muhto rahpasit baicca muitalivčče (makkar', u'$(interr,á|makkár)', u' soga)', u'€(man soga)', u' sii ovddasttit', u'$(verb,conc|ovddastit)', u'.']

        self.assertEqual(self.em.processText(text), want)

    def testProcessText29(self):
        text = u'(Bearpmahat$(noun,svow|Bearpmehat) earuha€(verb,v,w|sirre))£(verb,fin,pl3prs,sg3prs,agr|Bearpmehat sirrejit) uskki ja loaiddu.'
        want = [u'(Bearpmahat', u'$(noun,svow|Bearpmehat)', u' earuha', u'€(verb,v,w|sirre)', u')', u'£(verb,fin,pl3prs,sg3prs,agr|Bearpmehat sirrejit)', u' uskki ja loaiddu.']

        self.assertEqual(self.em.processText(text), want)

    def testProcessText30(self):
        text = u'Mirja ja Line leaba (gulahallan olbmožat)¢(noun,cmp|gulahallanolbmožat)€gulahallanolbmot'
        want = [u'Mirja ja Line leaba (gulahallan olbmožat)', u'¢(noun,cmp|gulahallanolbmožat)', u'€gulahallanolbmot']

        self.assertEqual(self.em.processText(text), want)

    def testProcessText31(self):
        text = u'(Ovddit geasis)£(noun,advl,gensg,locsg,case|Ovddit geasi) ((čoaggen$(verb,mono|čoggen) ollu jokŋat)£(noun,obj,genpl,nompl,case|čoggen ollu joŋaid) ja sarridat)£(noun,obj,genpl,nompl,case|čoggen ollu joŋaid ja sarridiid)'
        want = [u'(Ovddit geasis)', u'£(noun,advl,gensg,locsg,case|Ovddit geasi)', u' ((čoaggen', u'$(verb,mono|čoggen)', u' ollu jokŋat)', u'£(noun,obj,genpl,nompl,case|čoggen ollu joŋaid)', u' ja sarridat)', u'£(noun,obj,genpl,nompl,case|čoggen ollu joŋaid ja sarridiid)']

        self.assertEqual(self.em.processText(text), want)

    def testProcessText32(self):
        text = u'Bruk ((epoxi)$(noun,cons|epoksy) lim)¢(noun,mix|epoksylim) med god kvalitet.'
        want = [u'Bruk ((epoxi)', u'$(noun,cons|epoksy)', u' lim)', u'¢(noun,mix|epoksylim)', u' med god kvalitet.']

        print self.em.processText(text)
        self.assertEqual(self.em.processText(text), want)

    def testIsCorrection1(self):
        text = u'$(noun,cons|epoksy)'
        self.assertTrue(self.em.isCorrection(text))

    def testIsCorrection2(self):
        text = u'Bruk ((epoxi)'
        self.assertTrue(not self.em.isCorrection(text))

    #def testErrorParser1(self):
        #input = 'jne.$(adv,typo|jna.)'
        #want = ['jne.', '$', 'adv,type', 'jna.']

        #self.assertEqual(got, want)

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
            attDict['pos'] = atts[0]
            if atts[1] == 'yes' or atts[1] == 'no':
                attDict['teacher'] = atts[1]
            else:
                attDict['origpos'] = atts[1]
        elif len(atts) == 3:
            attDict['pos'] =atts[0]
            attDict['origpos'] = atts[1]
            if atts[2] == 'yes' or atts[2] == 'no':
                attDict['teacher'] = atts[2]
            else:
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

    def setSyntacticAttributes(self, errorElement, attributeList):
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
                attDict['errtype'] = atts[1]
        else:
            attDict['pos'] = atts[0]
            attDict['errtype'] = atts[1]
            attDict['teacher'] = atts[2]

        self.setCommonAttributes(errorElement, attDict)

    def errorParser(self, text):
        result = self.processText(text)

        elements = []

        if len(result) > 1:

            # This means that we are inside an error markup
            # Start with the two first elements
            # The first contains an error, the second one is a correction

            for x in range(0, len(result)):
                if self.isCorrection(result[x]):
                    (head, error) = self.processHead(result[x-1])
                    if len(elements) == 0:
                        elements.append(head)
                    else:
                        elements[-1].tail = head
                    #element = self.makeErrorElement(error, result[x])
                    #elements.append(element)
                    # make error element
                    # remove the last element in elements, add that
                    # as the error of the element
                    pass

            if self.isCorrection(result[-1]):
                elements[-1].tail = result[-1]

        return elements

    def isCorrection(self, expression):
        p = re.compile(u'(?P<correction>[$€£¥§¢]\([^\)]*\)|[$€£¥§¢]\S+)(?P<tail>.*)',re.UNICODE)

        return p.search(expression)

    def processText(self, text):

        result = []

        p = re.compile(u'(?P<correction>[$€£¥§¢]\([^\)]*\)|[$€£¥§¢]\S+)(?P<tail>.*)',re.UNICODE)


        m = p.search(text)
        while m:
            head = p.sub('', text)
            if head != '':
                result.append(head)
            result.append(m.group('correction'))
            text = m.group('tail')
            m = p.search(text)

        if text != '':
            result.append(text)

        return result

    def processHead(self, text):
        p = re.compile(u'(?P<error>\([^\(]*\)$|\w+$|\w+[-\':\]]\w+$|\w+[-\'\]\.]$|\d+’\w+$|\d+%:\w+$)',re.UNICODE)

        m = p.search(text)
        text = p.sub('', text)

        return (text, m.group('error'))

    def getError(self, error, separator, correction):
        (fixedCorrection, extAtt, attList) = self.lookForExtendedAttributes(correction)

        elementName = self.getElementName(separator)

        errorElement = self.makeErrorElement(error, fixedCorrection, elementName)

        if extAtt:
            self.addExtraAttributes(errorElement, attList)

        return errorElement

    def lookForExtendedAttributes(self, correction):
        print correction
        extAtt = False
        attList = ''
        if '|' in correction:
            extAtt = True
            (attList, correction) = correction.split('|')
        print correction
        return (correction, extAtt, attList)

    def getElementName(self, separator):
        return self.types[separator]

    def makeErrorElement(self, error, fixedCorrection, elementName):
        errorElement = etree.Element(elementName)
        errorElement.text = error
        errorElement.set('correct', fixedCorrection)

        return errorElement

    def addExtraAttributes(self, errorElement, attList):
        if errorElement.tag == 'errorort' or errorElement.tag == 'errorortreal':
            self.setOrthographicalAttributes(errorElement, attList)

        if errorElement.tag == 'errorlex':
            self.setLexicalAttributes(errorElement, attList)

        if errorElement.tag == 'errormorphsyn':
            self.setMorphosyntacticAttributes(errorElement, attList)

        if errorElement.tag == 'errorsyn':
            self.setSyntacticAttributes(errorElement, attList)
