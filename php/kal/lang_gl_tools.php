<?php
/***************************************************************************
 *                            lang_gl_tools.php [Greenlandic]
 *                              -------------------
 *     begin                : Tue Dec 20 2005
 *     copyright            : (C) 2005 Oqaasileriffik
 *
 *
 ****************************************************************************/

// 
// ##############################################
// Language technology
// ##############################################
// begin

//
// Selection possibilities are separated by colon (:).
// Some labels includes symbolic tags replacing real html-tags i.e. <kal>
// Don't remove but you can change position!
//

//
// ANALYSE
//

$lang['ANALYSE_title'] = "Misissuissut";
$lang['ANALYSE_salutation'] = "



";
$lang['ANALYSE_tags'] = "Oqaasilerinermi taaguutit suut? <d-kal>qallunaatut <g-kal>kalaallisut <kal>oqaasilerisutut";
$lang['ANALYSE_words'] = "Oqaaseq suna misissorniarpiuk?";
$lang['ANALYSE_submit'] = "Misissoruk";
$lang['ANALYSE_no_word'] = "Oqaaseq allanngitsoorpat!";

//
// GENERATE
//

$lang['GENERATE_title'] = "Oqaasileriffiup oqaasinngortitsissutiliaanut tikilluarit.";
$lang['GENERATE_salutation'] = "

Oqaasinngortitsissut una atorlugu oqaasinnngortitsillutit katiterisinnaavutit.
<p>
Aallaqqaammut toqqakkit nagguik suna naanerillu suut atorlugit oqaasinngortitsiniarnerlutit. Taava periarfissaqarputit uiguutit ilaat (amerlanngitsut) aamma uiguutit annerit atornissaannut. 
<p>
Unali eqqaamajuk: Oqaasinngortitsissut tassaavoq maskiina eqqarsarsinnaanngitsoq taamalu toqqartukkannik naliliisinnaanngitsoq. Taamaammat oqaaserpassuit atunngitsut ilanngullugit sanasarpai. Assersuutigalugu oqaaseq 'brinti' apeqqutigisinnaavat ILLIT piginnittutut toqqarlugu. Taava eqqarsarani oqaaseq 'brintiga' oqaasinngortissavaa uffa oqaaseq taanna atunngitsuusoq.

";

// STEP 1

$lang['GENERATE_label_step1'] = "Oqaaseq qanoq ittoq pilersinniarpiuk";
$lang['GENERATE_word_class'] = "Taggit:Oqaluut:Oqaaseeraq";
$lang['GENERATE_continue'] = "Ingerlaqqigit";

// STEP 2

// A NOUN

$lang['GENERATE_label_noun'] = "1. Taggit suna?";
$lang['GENERATE_label_noun_case'] = "2. Kasusi sorleq atussava?";
$lang['GENERATE_noun_case'] = "taasiinnarniut (+Abs):allamoorut (+Rel):piffilerut (+Trm):aallarfilerut (+Abl):sumiiffilerut (+Lok):assilerut (+Aeq):atortulerut (+Ins):aqqutilerut (+Via)";
$lang['GENERATE_label_noun_form'] = "3. Taggisiliat ataasersiutaassava qasseersiutaassavaluunniit?";
$lang['GENERATE_noun_form'] = "ataasersiut (+Sg):qasseersiut (+Pl)";
$lang['GENERATE_label_noun_genitive'] = "4. Taggisiliat piginnittorsiuteqassava?";
$lang['GENERATE_noun_genitive'] = "uanga (+1Sg):illit (+2Sg):uuma (+3Sg):nammineq (+4Sg):uagut (+1Pl):ilissi (+2Pl):ukua (+3Pl):namminneq (+4Pl)";
$lang['GENERATE_label_noun_clitic'] = "5. Taggisip kingorna annermik uiguuteqassava?";
$lang['GENERATE_noun_clitic'] = "lu (+LU):lugooq (+LUGOOQ):lumi (+LUMI):li (+LI):lissaaq (+LISSAAQ):ligooq (+LIGOOQ):luunniit (+LUUNNIIT):luunniimmi (+LUUNNIIMMI):una (+UNA):gooq (+GOOQ):gooruna (+GOORUNA):aasiinngooq (+AASIINNGOOQ):aasiit (+AASIIT):mi (+MI):miaasiinngooq (+MIAASIINNGOOQ):miaasiit (+MIAASIIT):migooq (+MIGOOQ):ttaaq (+TTAAQ)";

// END A NOUN

// A VERB

$lang['GENERATE_label_verb'] = "1. Oqaluut sunaassava?";
$lang['GENERATE_label_verb_affix'] = "2. Uiguutilissaviuk?";
$lang['GENERATE_verb_affix'] = "-niarpoq (+NIAR):-tariaqarpoq (+TARIAQAR):-Tarpoq (+TAR):-nngilaq (+NNGIT):-Taqaaq (+TAQE):-ssaaq (+SSA)";
$lang['GENERATE_label_verb_mood'] = "3. Oqaluut immikkoortoq sorleq atussava?";
$lang['GENERATE_verb_mood'] = "Oqaluinnarniut (+Ind):Apersuiniut (+Int):Inatsiniut (+Imp):Kissarniut (+Opt):Pisimasorsiut (+Cau):Pissanersorsiut (+Con):Taggisaasaq (+Par):Aappiuttartoq (+Inf):Aappiuttartoq pinngitsorsiutilik (+InfNeg):Utertaarisoq (+Ite)";
$lang['GENERATE_label_verb_person'] = "4. Susoq kinaassava?";
$lang['GENERATE_verb_person'] = "uanga (+1Sg):illit (+2Sg):una/ uuma (+3Sg):nammineq (+4Sg):uagut (+1Pl):ilissi (+2Pl):ukua (+3Pl):namminneq (+4Pl)";
$lang['GENERATE_label_verb_objective'] = "5. Oqaluut susaqarpat susaq kinaassava?";
$lang['GENERATE_verb_objective'] = "uanga (+1Sg):illit (+2Sg):una (+3Sg):nammineq (+4Sg):uagut (+1Pl):ilissi (+2Pl):uku (+3Pl):namminneq (+4Pl)";
$lang['GENERATE_label_verb_clitic'] = "6. Oqaluut uiguut annertaqassava?";
$lang['GENERATE_verb_clitic'] = "lu (+LU):lugooq (+LUGOOQ):lumi (+LUMI):li (+LI):lissaaq (+LISSAAQ):ligooq (+LIGOOQ):luunniit (+LUUNNIIT):luunniimmi (+LUUNNIIMMI):una (+UNA):gooq (+GOOQ):gooruna (+GOORUNA):aasiinngooq (+AASIINNGOOQ):aasiit (+AASIIT):mi (+MI):miaasiinngooq (+MIAASIINNGOOQ):miaasiit (+MIAASIIT):migooq (+MIGOOQ):ttaaq (+TTAAQ)";

// END A VERB

// A PARTICLE

$lang['GENERATE_label_particle'] = "1. Oqaaseeraq suna pilersikkusuppiuk?";
$lang['GENERATE_label_particle_clitic'] = "2. Oqaaseeqqap kingornagut annernik uiguuteqassava?";
$lang['GENERATE_particle_clitic'] = "lu (+LU):lugooq (+LUGOOQ):lumi (+LUMI):li (+LI):lissaaq (+LISSAAQ):ligooq (+LIGOOQ):luunniit (+LUUNNIIT):luunniimmi (+LUUNNIIMMI):una (+UNA):gooq (+GOOQ):gooruna (+GOORUNA):aasiinngooq (+AASIINNGOOQ):aasiit (+AASIIT):mi (+MI):miaasiinngooq (+MIAASIINNGOOQ):miaasiit (+MIAASIIT):migooq (+MIGOOQ):ttaaq (+TTAAQ)";

// END A PARTICLE

$lang['GENERATE_submit'] = "Oqaasinngortiguk";
$lang['GENERATE_no_word'] = "Oqaaseq allanngitsoorpat!";

//
// PARADIGM
//

$lang['PARADIGM_title'] = "Oqaatsinik allanngorartitsissut";
$lang['PARADIGM_salutation'] = "

Oqaasileriffiup oqaatsinik allanngorartitsissutiliaanut tikilluarit.
<p>
Taanna atorlugu oqaatsip paasisaqarfigerusutavit qanoq naaneqarsinnaanera nalunaarsorsinnaavat kissaatigigukkulu pappialanngorlugu anillatsitsisinnaallutit.";
$lang['PARADIGM_tags'] = "Oqaasilerinermi taaguutit suut? <d-kal>qallunaatut <g-kal>kalaallisut <kal>oqaasilerisutut";
$lang['PARADIGM_words'] = "Oqaaseq sorleq naanilersorusuppiuk?";
$lang['PARADIGM_label_word_class'] = "<p>Oqaaseq";
$lang['PARADIGM_word_class'] = "taggisaava?:oqaluutaava susaatsoq?:oqaluutaava susalik?:taggimmut taartissaava?";
$lang['PARADIGM_submit'] = "Pilersiguk!";
$lang['PARADIGM_no_word'] = "Oqaaseq allanngitsoorpat!";

//
// TOOL SELECTION
//

$lang['TOOLS_selection'] = "Periarneq tulleq? <selection> <go>";
$lang['TOOLS_analyse'] = "Misissuineq";
$lang['TOOLS_generate'] = "Oqaasinngortitsineq";
$lang['TOOLS_paradigm'] = "Allanngorartitaliorneq";
$lang['TOOLS_submit'] = "Ingerlaqqigit";

// end
// ##############################################
// Language technology
// ##############################################
//

//
// That's all Folks!
// -------------------------------------------------

?>

