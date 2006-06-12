<?php 

/***************************************************************************
 *                            tools.php
 *                              -------------------
 *     begin                : Tue Dec 20 2005
 *     copyright            : (C) 2005- Oqaasileriffik
 *     email                : tero.avellan@aumanet.fi
 *
 *
 ****************************************************************************/

include ('Inc/conf.php');

?>

<!DOCTYPE HTML PUBLIC "<?echo $global['DTD'] ?>">
<html>
<head>
<title><?echo $global['SITE_NAME'] ?></title>
<meta http-equiv="Content-Type" content="text/html;charset=<?echo $lang['ENCODING'] ?>">
<LINK rel="stylesheet" type="text/css" href="<?echo $global['PATH_TO_CSS'] ?>">
<base target="<?echo $global['BASE_TARGET'] ?>">
</head>
<body bgcolor="#efe7c6" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" text="#000000" link="#660000" alink="#ffcc99" vlink="#660000">
<div align="center">
<table border="0" width="750" cellpadding="0" cellspacing="5">
<tr><td align="right">

<!-- LANGUAGE START //-->

<table border="0" cellpadding="3" cellspacing="0">
<tr><td width="5">&nbsp;</td><td valign="middle">
<font class='lanmenu'><a href="<? echo($new_lang . '&lang=gl') ?>" target="_top"><? if ($language == "gl") { ?><b><? } ?>Kalaallisut<? if ($language == "gl") { ?></b><? } ?></a>&nbsp;/&nbsp;<a href="<? echo($new_lang . '&lang=dk') ?>" target="_top"><? if ($language == "dk") { ?><b><? } ?>Dansk<? if ($language == "dk") { ?></b><? } ?></a>&nbsp;/&nbsp;<a href="<? echo($new_lang . '&lang=eng') ?>" target="_top"><? if ($language == "eng") { ?><b><? } ?>English<? if ($language == "eng") { ?></b><? } ?></a></font>
</td></tr>
</table>

<!-- LANGUAGE END //-->

</td></tr>
<tr><td valign="top">
<table border="0" width="100%" cellpadding="0" cellspacing="0"><tr><td><img src="Images/header.gif" width="100%" alt=""></td></tr></table>
</td></tr>
<tr><td align="left" valign="top">
<table border="0" width="100%" cellpadding="0" cellspacing="0">
<tr><td valign="top" bgcolor="#CECECE">

<table border="0" width="100%" cellpadding="0" cellspacing="1">
<tr align="left"><td bgcolor="#FFFFFF">

<table width="100%" border="0" cellpadding="0" cellspacing="15">
<tr><td valign="top">

<table border="0" cellpadding="3" cellspacing="0">
<tr><td valign="middle"><img src="Images/help.gif" alt=""></td><td valign="middle"><font class='lanmenu'><a href="<?echo $global['PATH_TO_HELP']?>" target="top"><?echo $lang['Help']?></a></font></td><td>&nbsp;|&nbsp;</td><td valign="middle"><img src="Images/home.gif" alt=""></td><td valign="middle"><font class='lanmenu'><a href="<?echo $global['PATH_TO_HOME']?>" target="_top"><?echo $lang['Home']?></a></font></td>

<? if ($_GET['pid'] == "paradigm" & $_GET['text'] == true) { ?>

<td>&nbsp;|&nbsp;</td><td valign="middle"><img src="Images/print.gif" alt=""></td><td valign="middle"><font class='lanmenu'><a href="<?echo $global['PATH_TO_PRINT']?>?word=<?echo $_GET['text'] ?>&fst=<?echo $_GET['fst']?>" target="top"><?echo $lang['Print']?></a></font></td>
<? } ?>

</tr>
</table>
</td></tr>
<tr><td valign="top">
<table width="100%" border="0" cellpadding="10" cellspacing="0">
<tr><td valign="top">

<?php 

/***************************************************************************
 * TOOLS START
 ****************************************************************************/

?>

<font class='default'>

<? 

//
// HEADERS START
//

if ($_GET['pid'] == "analyse") { 

?>

<h3><?echo $lang['ANALYSE_title'] ?></h3>
<p>
<?

// HEADER FOR ANALYSE

if ($_GET['cmd'] != 'go') { 
	echo $lang['ANALYSE_salutation']; 
}

?>

<?
}

// HEADER FOR GENERATE

elseif ($_GET['pid'] == "generate") {
?>

<h3><?echo $lang['GENERATE_title'] ?></h3>
<p>
<?

if ($_GET['cmd'] != 'go') { 
	echo $lang['GENERATE_salutation']; 
}

?>

<? }

// HEADER FOR PARADIGM

elseif ($_GET['pid'] == "paradigm") { 
?>

<h3><?echo $lang['PARADIGM_title'] ?></h3>
<p>
<?

if ($_GET['cmd'] != 'go') { 
	echo $lang['PARADIGM_salutation']; 
}

?>

<? } 

else { 

}

//
// HEADERS END
//

?>

<?

//
// IF WE ARE GOING TO ANALYSE OR GENERATE AND
// TEXT IS SELECTED. WE NEED COMMAND GO.
//

if ($_GET['cmd'] == 'go') {

	if ($_GET['pid'] == "paradigm") { 
 		// Processing tool for paradigm generator
		include $global['PATH_TO_PARADIGM'];
	}
	else {
		// Processing tool for analyzer and generator
		include $global['PATH_TO_LOOKUP'];
	}
}
else {

//
// TOOL BODY PAGES START
//

//
// ANALYSE
//

if ($_GET['pid'] == "analyse") { ?>
<hr>
<form action="<?echo $global['PATH_TO_SELF'] ?>" method="get" target="_top">
<input type="hidden" name="pid" value="analyse">
<input type="hidden" name="lang" value="<?echo $language?>">
<input type="hidden" name="cmd" value="go">

<?

$tags = preg_replace('/\<d-kal\>/', '<input type="radio" name="fst" value="d">', $lang['ANALYSE_tags']);
$tags = preg_replace('/\<g-kal\>/', '<input type="radio" name="fst" value="g">', $tags);
$tags = preg_replace('/\<kal\>/', '<input type="radio" name="fst" value="l" checked>', $tags);

echo $tags;

?>

<p>
<?echo $lang['ANALYSE_words'] ?>&nbsp;<input name="text" size="50" type="text">
<p>
<input type="submit" value="<?echo $lang['ANALYSE_submit'] ?>"></form>

<? 
}

//
// GENERATE
//

elseif ($_GET['pid'] == "generate") { 

echo "<hr>";

// STEP 1

if ($_GET['word_class'] == '') { 

$wclass = preg_split('/\:/', $lang['GENERATE_word_class']);

?>

<form action="<?echo $global['PATH_TO_SELF'] ?>" method="get" target="_top">

<input type="hidden" name="pid" value="generate">
<input type="hidden" name="lang" value="<?echo $language?>">
<?echo $lang['GENERATE_label_step1'] ?>&nbsp;<select name="word_class">
<option value="noun"><?echo $wclass[0] ?></option>
<option value="verb"><?echo $wclass[1] ?></option>
<option value="particle"><?echo $wclass[2] ?></option>
</select>
<input type="submit" value="<?echo $lang['GENERATE_continue'] ?>"></form>

<? 
} 

// STEP 2

else {
?>

<form action="<?echo $global['PATH_TO_SELF'] ?>" method="get" target="_top">
<input type="hidden" name="pid" value="generate">
<input type="hidden" name="lang" value="<?echo $language?>">
<input type="hidden" name="cmd" value="go">
<input type="hidden" name="word_class" value="<? echo $_GET['word_class'] ?>">

<? 

// A NOUN

if ($_GET['word_class'] == "noun") { 

$noun_case = preg_split('/\:/', $lang['GENERATE_noun_case']);
$noun_form = preg_split('/\:/', $lang['GENERATE_noun_form']);
$noun_genitive = preg_split('/\:/', $lang['GENERATE_noun_genitive']);
$noun_clitic = preg_split('/\:/', $lang['GENERATE_noun_clitic']);

?>
<?echo $lang['GENERATE_label_noun'] ?>&nbsp;<input name="text" size="50" type="text">
<p>
<?echo $lang['GENERATE_label_noun_case'] ?>&nbsp; 
<select name="case">
<option value="+Abs"><?echo $noun_case[0] ?></option> 
<option value="+Rel"><?echo $noun_case[1] ?></option>
<option value="+Trm"><?echo $noun_case[2] ?></option>
<option value="+Abl"><?echo $noun_case[3] ?></option>
<option value="+Lok"><?echo $noun_case[4] ?></option>
<option value="+Aeq"><?echo $noun_case[5] ?></option>
<option value="+Ins"><?echo $noun_case[6] ?></option>
<option value="+Via"><?echo $noun_case[7] ?></option>
<option value="" selected></option>
</select>
<p>
<?echo $lang['GENERATE_label_noun_form'] ?>&nbsp;
<select name="form">
<option value="+Sg"><?echo $noun_form[0] ?></option>
<option value="+Pl"><?echo $noun_form[1] ?></option>
<option value="" selected></option>
</select>
<p>
<?echo $lang['GENERATE_label_noun_genitive'] ?>&nbsp;
<select name="genitive">
<option value="+1Sg"><?echo $noun_genitive[0] ?></option>
<option value="+2Sg"><?echo $noun_genitive[1] ?></option>
<option value="+3Sg"><?echo $noun_genitive[2] ?></option>
<option value="+4Sg"><?echo $noun_genitive[3] ?></option>
<option value="+1Pl"><?echo $noun_genitive[4] ?></option>
<option value="+2Pl"><?echo $noun_genitive[5] ?></option>
<option value="+3Pl"><?echo $noun_genitive[6] ?></option>
<option value="+4Pl"><?echo $noun_genitive[7] ?></option>
<option value="" selected></option>
</select>
<p>
<?echo $lang['GENERATE_label_noun_clitic'] ?>&nbsp;
<select name="clitic">
<option value="+LU"><?echo $noun_clitic[0] ?></option>
<option value="+LUGOOQ"><?echo $noun_clitic[1] ?></option>
<option value="+LUMI"><?echo $noun_clitic[2] ?></option>
<option value="+LI"><?echo $noun_clitic[3] ?></option>
<option value="+LISSAAQ"><?echo $noun_clitic[4] ?></option>
<option value="+LIGOOQ"><?echo $noun_clitic[5] ?></option>
<option value="+LUUNNIIT"><?echo $noun_clitic[6] ?></option>
<option value="+LUUNNIIMMI"><?echo $noun_clitic[7] ?></option>
<option value="+UNA"><?echo $noun_clitic[8] ?></option>
<option value="+GOOQ"><?echo $noun_clitic[9] ?></option>
<option value="+GOORUNA"><?echo $noun_clitic[10] ?></option>
<option value="+AASIINNGOOQ"><?echo $noun_clitic[11] ?></option>
<option value="+AASIIT"><?echo $noun_clitic[12] ?></option>
<option value="+MI"><?echo $noun_clitic[13] ?></option>
<<option value="+MIAASIINNGOOQ"><?echo $noun_clitic[14] ?></option>
<option value="+MIAASIIT"><?echo $noun_clitic[15] ?></option>
<option value="+MIGOOQ"><?echo $noun_clitic[16] ?></option>
<option value="+TTAAQ"><?echo $noun_clitic[17] ?></option>
<option value="" selected></option>
</select>
<p>
<? 
}

// A VERB

elseif ($_GET['word_class'] == "verb") { 

$verb_affix = preg_split('/\:/', $lang['GENERATE_verb_affix']);
$verb_mood = preg_split('/\:/', $lang['GENERATE_verb_mood']);
$verb_person = preg_split('/\:/', $lang['GENERATE_verb_person']);
$verb_objective = preg_split('/\:/', $lang['GENERATE_verb_objective']);
$verb_clitic = preg_split('/\:/', $lang['GENERATE_verb_clitic']);

?>
<?echo $lang['GENERATE_label_verb'] ?>&nbsp;
<input name="text" size="50" type="text">
<p>
<?echo $lang['GENERATE_label_verb_affix'] ?>&nbsp;
<select name="affix">
<option value="+NIAR"><?echo $verb_affix[0] ?></option>
<option value="+TARIAQAR"><?echo $verb_affix[1] ?></option>
<option value="+TAR"><?echo $verb_affix[2] ?></option>
<option value="+NNGIT"><?echo $verb_affix[3] ?></option>
<option value="+TAQE"><?echo $verb_affix[4] ?></option>
<option value="+SSA"><?echo $verb_affix[5] ?></option>
<option value="" selected></option>
</select>
<p>
<?echo $lang['GENERATE_label_verb_mood'] ?>&nbsp;
<select name="mood"> 
<option value="+Ind"><?echo $verb_mood[0] ?></option>
<option value="+Int"><?echo $verb_mood[1] ?></option>
<option value="+Imp"><?echo $verb_mood[2] ?></option>
<option value="+Opt"><?echo $verb_mood[3] ?></option>
<option value="+Cau"><?echo $verb_mood[4] ?></option>
<option value="+Con"><?echo $verb_mood[5] ?></option>
<option value="+Par"><?echo $verb_mood[6] ?></option>
<option value="+Inf"><?echo $verb_mood[7] ?></option>
<option value="+InfNeg"><?echo $verb_mood[8] ?></option>
<option value="+Ite"><?echo $verb_mood[9] ?></option>
<option value="" selected></option>
</select>
<p>
<?echo $lang['GENERATE_label_verb_person'] ?>&nbsp;
<select name="person">
<option value="+1Sg"><?echo $verb_person[0] ?></option>
<option value="+2Sg"><?echo $verb_person[1] ?></option>
<option value="+3Sg"><?echo $verb_person[2] ?></option>
<option value="+4Sg"><?echo $verb_person[3] ?></option>
<option value="+1Pl"><?echo $verb_person[4] ?></option>
<option value="+2Pl"><?echo $verb_person[5] ?></option>
<option value="+3Pl"><?echo $verb_person[6] ?></option>
<option value="+4Pl"><?echo $verb_person[7] ?></option>
<option value="" selected></option>
</select>
<p>
<?echo $lang['GENERATE_label_verb_objective'] ?>&nbsp;
<select name="objective"> 
<option value="+1Sg"><?echo $verb_objective[0] ?></option>
<option value="+2Sg"><?echo $verb_objective[1] ?></option>
<option value="+3Sg"><?echo $verb_objective[2] ?></option>
<option value="+4Sg"><?echo $verb_objective[3] ?></option>
<option value="+1Pl"><?echo $verb_objective[4] ?></option>
<option value="+2Pl"><?echo $verb_objective[5] ?></option>
<option value="+3Pl"><?echo $verb_objective[6] ?></option>
<option value="+4Pl"><?echo $verb_objective[7] ?></option>
<option value="" selected></option>
</select>
<p>
<?echo $lang['GENERATE_label_verb_clitic'] ?>&nbsp;
<select name="clitic">
<option value="+LU"><?echo $verb_clitic[0] ?></option>
<option value="+LUGOOQ"><?echo $verb_clitic[1] ?></option>
<option value="+LUMI"><?echo $verb_clitic[2] ?></option>
<option value="+LI"><?echo $verb_clitic[3] ?></option>
<option value="+LISSAAQ"><?echo $verb_clitic[4] ?></option>
<option value="+LIGOOQ"><?echo $verb_clitic[5] ?></option>
<option value="+LUUNNIIT"><?echo $verb_clitic[6] ?></option>
<option value="+LUUNNIIMMI"><?echo $verb_clitic[7] ?></option>
<option value="+UNA"><?echo $verb_clitic[8] ?></option>
<option value="+GOOQ"><?echo $verb_clitic[9] ?></option>
<option value="+GOORUNA"><?echo $verb_clitic[10] ?></option>
<option value="+AASIINNGOOQ"><?echo $verb_clitic[11] ?></option>
<option value="+AASIIT"><?echo $verb_clitic[12] ?></option>
<option value="+MI"><?echo $verb_clitic[13] ?></option>
<<option value="+MIAASIINNGOOQ"><?echo $verb_clitic[14] ?></option>
<option value="+MIAASIIT"><?echo $verb_clitic[15] ?></option>
<option value="+MIGOOQ"><?echo $verb_clitic[16] ?></option>
<option value="+TTAAQ"><?echo $verb_clitic[17] ?></option>
<option value="" selected></option>
</select>

<? 
}

// A PARTICLE

elseif ($_GET['word_class'] == "particle") { 

$particle_clitic = preg_split('/\:/', $lang['GENERATE_particle_clitic']);

?>
<?echo $lang['GENERATE_label_particle'] ?>&nbsp;<input name="text" size="50" type="text">
<p>
<?echo $lang['GENERATE_label_particle_clitic'] ?>&nbsp;
<select name="clitic">
<option value="+LU"><?echo $particle_clitic[0] ?></option>
<option value="+LUGOOQ"><?echo $particle_clitic[1] ?></option>
<option value="+LUMI"><?echo $particle_clitic[2] ?></option>
<option value="+LI"><?echo $particle_clitic[3] ?></option>
<option value="+LISSAAQ"><?echo $particle_clitic[4] ?></option>
<option value="+LIGOOQ"><?echo $particle_clitic[5] ?></option>
<option value="+LUUNNIIT"><?echo $particle_clitic[6] ?></option>
<option value="+LUUNNIIMMI"><?echo $particle_clitic[7] ?></option>
<option value="+UNA"><?echo $particle_clitic[8] ?></option>
<option value="+GOOQ"><?echo $particle_clitic[9] ?></option>
<option value="+GOORUNA"><?echo $particle_clitic[10] ?></option>
<option value="+AASIINNGOOQ"><?echo $particle_clitic[11] ?></option>
<option value="+AASIIT"><?echo $particle_clitic[12] ?></option>
<option value="+MI"><?echo $particle_clitic[13] ?></option>
<<option value="+MIAASIINNGOOQ"><?echo $particle_clitic[14] ?></option>
<option value="+MIAASIIT"><?echo $particle_clitic[15] ?></option>
<option value="+MIGOOQ"><?echo $particle_clitic[16] ?></option>
<option value="+TTAAQ"><?echo $particle_clitic[17] ?></option>
<option value="" selected></option>
</select>
<? } ?>

<p>
<input type="submit" value="<?echo $lang['GENERATE_submit'] ?>"></form>

<? } ?>

<? 
}

//
// PARADIGM
//

elseif ($_GET['pid'] == "paradigm") { 

$wclass = preg_split('/\:/', $lang['PARADIGM_word_class']);

?>

<hr>
<form action="<?echo $global['PATH_TO_SELF'] ?>" method="get" target="_top">
<input type="hidden" name="pid" value="paradigm">
<input type="hidden" name="lang" value="<?echo $language?>">
<input type="hidden" name="cmd" value="go">

<?

$tags = preg_replace('/\<d-kal\>/', '<input type="radio" name="fst" value="d">', $lang['PARADIGM_tags']);
$tags = preg_replace('/\<g-kal\>/', '<input type="radio" name="fst" value="g">', $tags);
$tags = preg_replace('/\<kal\>/', '<input type="radio" name="fst" value="l" checked>', $tags);

echo $tags;

?>

<p>
<?echo $lang['PARADIGM_words'] ?>&nbsp;<input name="text" size="50" type="text">

<br>

<?echo $lang['PARADIGM_label_word_class'] ?>&nbsp;<select name="word_class">
<option value="inoun"><?echo $wclass[0] ?></option>
<option value="iverb"><?echo $wclass[1] ?></option>
<option value="tverb"><?echo $wclass[2] ?></option>
<option value="pronoun"><?echo $wclass[3] ?></option>
</select>
<p>
<input type="submit" value="<?echo $lang['PARADIGM_submit'] ?>"></form>

<? } 

//
// TOOL BODY PAGES END
//

?>

<? } ?>

<? if ($_GET['pid'] == true) { ?>

<hr>

<form action="<?echo $global['PATH_TO_SELF'] ?>" method="get" target="_top"><input type="hidden" name="lang" value="<?echo $language?>">

<?

$tools_selection = "<select name=\"pid\"><option value=\"analyse\">" . $lang['TOOLS_analyse'] . "</option><option value=\"generate\">" . $lang['TOOLS_generate'] . "</option><option value=\"paradigm\">" . $lang['TOOLS_paradigm'] . "</option></select>";
$tools_submit = "<input type=\"submit\" value=\"". $lang['TOOLS_submit']. "\">";

$tools_selection_print = preg_replace('/\<selection\>/', $tools_selection, $lang['TOOLS_selection']);
$tools_selection_print = preg_replace('/\<go\>/', $tools_submit, $tools_selection_print);

echo $tools_selection_print;

?>

</form>

<? } ?>

</font>

<?php 

/***************************************************************************
 * TOOLS END
 ****************************************************************************/

?>

</td></tr>
</table>
</td></tr>
</table>
</td></tr>
<tr><td bgcolor="#FFFFFF" align="left" valign="top"><img src="Images/footer.gif" alt=""></td></tr>
</table>
</td></tr>
</table>
</td></tr>
<tr><td valign="middle" align="right"><img src="Images/pixel2x5.gif" alt=""><font class='copy'>&copy;<?echo $global['SITE_NAME'] ?>.</font></td></tr>
</table>
</div>
</body>
</html>

