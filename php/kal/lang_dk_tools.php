<?php
/***************************************************************************
 *                            lang_dk_tools.php [Danish]
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

// Word analyzer

//Velkommen til Oqaasileriffiks ordautomat. Med analysatoren kan du få at vide, hvordan et givet 
//ord er sat sammen, og med generatoren kan du danne ord i de former, du beder den danne.

//Vil du have de grammatiske betegnelser på <tag1>dansk <tag2>grønlandsk <tag3>lingvistisk tradition 
//Hvilket ord vil du have analyseret? <word>
//<analyse>

$lang['ANALYSE_title'] = "Ordanalysator";
$lang['ANALYSE_salutation'] = "

Velkommen til Oqaasileriffiks analysator. Den kan analysere alle grønlandske endelser og langt de fleste stammer.

";
$lang['ANALYSE_tags'] = "Vil du have det grammatiske metasprog på <d-kal>dansk <g-kal>grønlandsk <kal>lingvistisk tradition";
$lang['ANALYSE_words'] = "Hvilket ord vil du gerne analysere?";
$lang['ANALYSE_submit'] = "Analyser";
$lang['ANALYSE_no_word'] = "Du glemte at skrive et ord!";

//
// GENERATE
//

$lang['GENERATE_title'] = "Ordgenerator";
$lang['GENERATE_salutation'] = "Velkommen til Oqaasileriffiks ordgenerator. Med den kan du danne en næsten hvilken som helst ordform, hvis du fortæller systemet hvad det er, du ønsker.
Men pas på. Den er kun en maskine og kan ikke tænke selv, så hvis du fx beder den give dig ordet \"brinti\" med endelsen \"min\", ja så vil den uden videre give dig den teoretisk korrekte ordform \"brintiga\", selv om det ikke er et muligt grønlandsk ord. 
<br> Husk,<br> 

<li>at grønlandske navneord altid skal have tal og kasus<br>
<li>at intransitive udsagsnord altid skal have modus og grundledsperson<br>
<li>at transitive udsagnsord altid skal have modus, grundledsperson og genstandsledperson";

// STEP 1

$lang['GENERATE_label_step1'] = "Hvad er det for et ord, du vil danne";
$lang['GENERATE_word_class'] = "et navneord:et udsagnsord:en partikel";
$lang['GENERATE_continue'] = "fortsæt";

// STEP 2

// A NOUN

$lang['GENERATE_label_noun'] = "Hvilket navneord vil du gerne have analyseret?";
$lang['GENERATE_label_noun_case'] = "2. Hvilken kasus skal du bruge?";
$lang['GENERATE_noun_case'] = "Absolut:Relativ:Terminalis (mut):Ablativ (mit):Lokalis (mi):Aequalis (tut):Instrumentalis (mik):Vialis (kut)";
$lang['GENERATE_label_noun_form'] = "3. Hvilket tal har du brug for til dit navneord?";
$lang['GENERATE_noun_form'] = "ental:flertal";
$lang['GENERATE_label_noun_genitive'] = "4. Hvem - om nogen - ejer navneordet (possessor)?";
$lang['GENERATE_noun_genitive'] = "min/mine (+1Sg):din/dine (+2Sg):hans/hendes (+3Sg):sin/sine (+4Sg):vores (+1Pl):Jeres (+2Pl):deres (+3Pl):deres (+4Pl)";
$lang['GENERATE_label_noun_clitic'] = "5. Kommer der - om nogen - en tilhængspartikel efter navneordet?";
$lang['GENERATE_noun_clitic'] = "lu (+LU):lugooq (+LUGOOQ):lumi (+LUMI):li (+LI):lissaaq (+LISSAAQ):ligooq (+LIGOOQ):luunniit (+LUUNNIIT):luunniimmi (+LUUNNIIMMI):una (+UNA):gooq (+GOOQ):gooruna (+GOORUNA):aasiinngooq (+AASIINNGOOQ):aasiit (+AASIIT):mi (+MI):miaasiinngooq (+MIAASIINNGOOQ):miaasiit (+MIAASIIT):migooq (+MIGOOQ):ttaaq (+TTAAQ)";

// END A NOUN

// A VERB

$lang['GENERATE_label_verb'] = "1. Skriv en eller anden form af dit udsagnsord (så finder automaten den korrekte stamme at gå videre fra)";
$lang['GENERATE_label_verb_affix'] = "2.Har du brug for et tilhæng? Her er et lille udvalg";
$lang['GENERATE_verb_affix'] = "-niarpoq (+NIAR):-tariaqarpoq (+TARIAQAR):-Tarpoq (+TAR):-nngilaq (+NNGIT):-Taqaaq (+TAQE):-ssaaq (+SSA)";
$lang['GENERATE_label_verb_mood'] = "3. Hvilken måde, vil du vide noget om?";
$lang['GENERATE_verb_mood'] = "fremsættemåde (+Ind):spørgemåde (+Int):bydemåde (+Imp):ønskemåde (+Opt):fortids afhængemåde (+Cau):fremtids afhængemåde (+Con):navnemåde (+Par):positiv ledsagemåde (+Inf):negativ ledsagemåde (+InfNeg):gentagemåde (+Ite)";
$lang['GENERATE_label_verb_person'] = "4. Hvem skal være grundled?";
$lang['GENERATE_verb_person'] = "jeg (+1Sg):du (+2Sg):han/hun/den/det (+3Sg):fjerde person (+4Sg):vi (+1Pl):I (+2Pl):de (+3Pl):fjerde person (+4Pl)";
$lang['GENERATE_label_verb_objective'] = "5. Hvem er genstandsleddet, hvis udsagnsordet er transitivt";
$lang['GENERATE_verb_objective'] = "mig (+1Sg):dig (+2Sg):ham/hende/den/det (+3Sg):fjerde person (+4Sg):os (+1Pl):jer (+2Pl):dem (+3Pl):fjerde person (+4Pl)";
$lang['GENERATE_label_verb_clitic'] = "6. Skal der komme tilhængspartikler efter udsagnsordet?";
$lang['GENERATE_verb_clitic'] = "lu (+LU):lugooq (+LUGOOQ):lumi (+LUMI):li (+LI):lissaaq (+LISSAAQ):ligooq (+LIGOOQ):luunniit (+LUUNNIIT):luunniimmi (+LUUNNIIMMI):una (+UNA):gooq (+GOOQ):gooruna (+GOORUNA):aasiinngooq (+AASIINNGOOQ):aasiit (+AASIIT):mi (+MI):miaasiinngooq (+MIAASIINNGOOQ):miaasiit (+MIAASIIT):migooq (+MIGOOQ):ttaaq (+TTAAQ)";


// END A VERB


// A PARTICLE

$lang['GENERATE_label_particle'] = "1. Hvilken partikel drejer det sig om?";
$lang['GENERATE_label_particle_clitic'] = "2. Skal der sættes tilhængspartikler efter?";
$lang['GENERATE_particle_clitic'] = "lu (+LU):lugooq (+LUGOOQ):lumi (+LUMI):li (+LI):lissaaq (+LISSAAQ):ligooq (+LIGOOQ):luunniit (+LUUNNIIT):luunniimmi (+LUUNNIIMMI):una (+UNA):gooq (+GOOQ):gooruna (+GOORUNA):aasiinngooq (+AASIINNGOOQ):aasiit (+AASIIT):mi (+MI):miaasiinngooq (+MIAASIINNGOOQ):miaasiit (+MIAASIIT):migooq (+MIGOOQ):ttaaq (+TTAAQ)";

// END A PARTICLE

$lang['GENERATE_submit'] = "Generer";
$lang['GENERATE_no_word'] = "Du glemte at skrive et ord!";

//
// PARADIGM
//

$lang['PARADIGM_title'] = "Paradigmegenerator";
$lang['PARADIGM_salutation'] = "Velkommen til Oqaasileriffiks paradigmegenerator.
<p> ";
$lang['PARADIGM_tags'] = "Vil du have det grammatiske metasprog på <d-kal>dansk <g-kal>grønlandsk <kal>lingvistisk tradition";
$lang['PARADIGM_words'] = "Over hvilket ord vil du have bygget et paradigme?";
$lang['PARADIGM_label_word_class'] = "<br>Er det";
$lang['PARADIGM_word_class'] = "et navneord:et intransitivt udsagnsord:et transitivt udsagnsord:et stedord";
$lang['PARADIGM_submit'] = "Byg paradigmet";
$lang['PARADIGM_no_word'] = "Du glemte at skrive noget!";

//
// TOOL SELECTION
//

$lang['TOOLS_selection'] = "Nu vil jeg gerne <selection> <go>";
$lang['TOOLS_analyse'] = "analysere";
$lang['TOOLS_generate'] = "generere";
$lang['TOOLS_paradigm'] = "genere et paradigme";
$lang['TOOLS_submit'] = "næste";

// end
// ##############################################
// Language technology
// ##############################################
//

//
// That's all Folks!
// -------------------------------------------------

?>

