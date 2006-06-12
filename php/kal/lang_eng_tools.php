<?php
/***************************************************************************
 *                            lang_eng_tools.php [English]
 *                              -------------------
 *     begin                : Mon Dec 19 2005
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

// Word analyzer

//Welcome to Oqaasileriffik's word-automat. The analyzer will help you analyse actual words
//and it will make the words you want if you feed it with the proper bits of information.

//Would you like your tags to be in <tag1>Danish <tag2>Greenlandic <tag3>Linguistic 
//What word do you want to analyse? <word>
//<analyse>

$lang['ANALYSE_title'] = "Word analyzer";
$lang['ANALYSE_salutation'] = "Welcome to Oqaasileriffik's word analyzer. It will help you analyse words into stems and endings.";
$lang['ANALYSE_tags'] = "Would you like your tags to be in <d-kal>Danish <g-kal>Greenlandic <kal>Linguistic";
$lang['ANALYSE_words'] = "What word do you want to analyse?";
$lang['ANALYSE_submit'] = "Analyse";
$lang['ANALYSE_no_word'] = "No Words Received!";

//
// GENERATE
//

$lang['GENERATE_title'] = "Word generator";
$lang['GENERATE_salutation'] = "Welcome to Oqaasileriffik's word generator. It will make the words you want if you feed it with the proper bits of information.
<br> Remember that <br>
<li>number and case are mandatory with nouns
<li>mode and subject person are mandatory with intransive verbs
<li>mode, subject person, and object person are mandatory with transitive verbs";

// STEP 1

$lang['GENERATE_label_step1'] = "Do you want to build";
$lang['GENERATE_word_class'] = "a noun:a verb:a particle";
$lang['GENERATE_continue'] = "Continue";

// STEP 2

// A NOUN

$lang['GENERATE_label_noun'] = "What is the noun in question?";
$lang['GENERATE_label_noun_case'] = "2. Which case do you need?";
$lang['GENERATE_noun_case'] = "Absolutive (+Abs):Relative (+Rel):mut-case (+Trm):mit-case (+Abl):mi-case (+Lok):tut-case (+Aeq):mik-case (+Ins):kut-case (+Via)";
$lang['GENERATE_label_noun_form'] = "3. Do you need your noun in";
$lang['GENERATE_noun_form'] = "singular (+Sg):the plural (+Pl)";
$lang['GENERATE_label_noun_genitive'] = "4. If your noun is somebody's, then who's";
$lang['GENERATE_noun_genitive'] = "my (+1Sg):your (+2Sg):his/her (+3Sg):fourth singular (+4Sg):our (+1Pl):your (+2Pl):their (+3Pl):fourth plural (+4Pl)";
$lang['GENERATE_label_noun_clitic'] = "5. Should a clitic follow your noun?";
$lang['GENERATE_noun_clitic'] = "lu (+LU):lugooq (+LUGOOQ):lumi (+LUMI):li (+LI):lissaaq (+LISSAAQ):ligooq (+LIGOOQ):luunniit (+LUUNNIIT):luunniimmi (+LUUNNIIMMI):una (+UNA):gooq (+GOOQ):gooruna (+GOORUNA):aasiinngooq (+AASIINNGOOQ):aasiit (+AASIIT):mi (+MI):miaasiinngooq (+MIAASIINNGOOQ):miaasiit (+MIAASIIT):migooq (+MIGOOQ):ttaaq (+TTAAQ)";

// END A NOUN

// A VERB

$lang['GENERATE_label_verb'] = "1. What a wordform of the verb in question. (The automaton will itself isolate the base form necessary for the next steps)";
$lang['GENERATE_label_verb_affix'] = "2. Would you like to add an affix?";
$lang['GENERATE_verb_affix'] = "-niarpoq (+NIAR):-tariaqarpoq (+TARIAQAR):-Tarpoq (+TAR):-nngilaq (+NNGIT):-Taqaaq (+TAQE):-ssaaq (+SSA)";
$lang['GENERATE_label_verb_mood'] = "3. Which mode do you need";
$lang['GENERATE_verb_mood'] = "indicative (+Ind):interrogative (+Int):imperative (+Imp):optative (+Opt):causative (+Cau):conditional (+Con):particip (+Par):infinitive (+Inf):negated infinitive (+InfNeg):iterative (+Ite)";
$lang['GENERATE_label_verb_person'] = "4. Who is the subject?";
$lang['GENERATE_verb_person'] = "I (+1Sg):you (+2Sg):he/she (+3Sg):fourth singular (+4Sg):we (+1Pl):you (+2Pl):they (+3Pl):fourth plural (+4Pl)";
$lang['GENERATE_label_verb_objective'] = "5. In case of a transitive verb the object is";
$lang['GENERATE_verb_objective'] = "me (+1Sg):you (+2Sg):him/her (+3Sg):fourth singular (+4Sg):us (+1Pl):you (+2Pl):them (+3Pl):fourth plural (+4Pl)";
$lang['GENERATE_label_verb_clitic'] = "6. Should a clitic follow your verb?";
$lang['GENERATE_verb_clitic'] = "lu (+LU):lugooq (+LUGOOQ):lumi (+LUMI):li (+LI):lissaaq (+LISSAAQ):ligooq (+LIGOOQ):luunniit (+LUUNNIIT):luunniimmi (+LUUNNIIMMI):una (+UNA):gooq (+GOOQ):gooruna (+GOORUNA):aasiinngooq (+AASIINNGOOQ):aasiit (+AASIIT):mi (+MI):miaasiinngooq (+MIAASIINNGOOQ):miaasiit (+MIAASIIT):migooq (+MIGOOQ):ttaaq (+TTAAQ)";

// END A VERB

// A PARTICLE

$lang['GENERATE_label_particle'] = "1. What is the particle in question?";
$lang['GENERATE_label_particle_clitic'] = "2. Should a clitic follow your particle?";
$lang['GENERATE_particle_clitic'] = "lu (+LU):lugooq (+LUGOOQ):lumi (+LUMI):li (+LI):lissaaq (+LISSAAQ):ligooq (+LIGOOQ):luunniit (+LUUNNIIT):luunniimmi (+LUUNNIIMMI):una (+UNA):gooq (+GOOQ):gooruna (+GOORUNA):aasiinngooq (+AASIINNGOOQ):aasiit (+AASIIT):mi (+MI):miaasiinngooq (+MIAASIINNGOOQ):miaasiit (+MIAASIIT):migooq (+MIGOOQ):ttaaq (+TTAAQ)";

// END A PARTICLE

$lang['GENERATE_submit'] = "Generate";
$lang['GENERATE_no_word'] = "No Words Received!";

//
// PARADIGM
//

$lang['PARADIGM_title'] = "Paradigm generator";
$lang['PARADIGM_salutation'] = "Welcome to Oqaasileriffik's paradigm generator!";
$lang['PARADIGM_tags'] = "Would you like your tags to be in <d-kal>Danish <g-kal>Greenlandic <kal>Linguistic";
$lang['PARADIGM_words'] = "What word do you want to use?";
$lang['PARADIGM_label_word_class'] = "<br>Is it";
$lang['PARADIGM_word_class'] = "a noun:an intransitive verb:a transitive verb:a pronoun";
$lang['PARADIGM_submit'] = "Create the paradigm";
$lang['PARADIGM_no_word'] = "No words received!";

//
// TOOL SELECTION
//

$lang['TOOLS_selection'] = "I would like to <selection> a new word. <go>";
$lang['TOOLS_analyse'] = "analyse";
$lang['TOOLS_generate'] = "generate";
$lang['TOOLS_paradigm'] = "generate a paradigm";
$lang['TOOLS_submit'] = "Go";

// end
// ##############################################
// Language technology
// ##############################################
//

//
// That's all Folks!
// -------------------------------------------------

?>

