<?php
/***************************************************************************
 *                            kal-lookup.php
 *                              -------------------
 *     begin                : Wed Dec 21 2005
 *     copyright            : (C) 2005 Oqaasileriffik
 *     email                : tero.avellan@aumanet.fi
 *     version              : 2.1
 *     modified             : Tue Jan 10 2006
 *
 *
 ****************************************************************************/

// Original Perl version written by Ken Beesley, Xerox, for Aymara.
// Reviewed and modified 12 april 2002, Trond Trosterud
//
// PHP program written by Tero Avellan, Oqaasileriffik, for Greenlandic
// Reviewed and modified 26 september 2005, Tero Avellan

//
// Version history
//
// 1.0 PHP-version with Perl
// 1.1 Pure PHP-version without Perl using traditional dictionary base-form
// 1.2 User can select tag format for the analyzer
// Jump to version 2.0
// 2.0 Changed to accept word in "normal" form, not in base-form
// 2.1 Changed all PATH variables to point conf.php

//
// conf.php
// kal-lookup.php
// kal-analyse.php
// lang_dk.php
// lang_eng.php
// lang_gl.php
// lang_dk_tools.php
// lang_eng_tools.php
// lang_gl_tools.php
// tools.php
//

//
// IF WE HAVE A WORD
//

if ($_GET['text'] == true & ( $_GET['pid'] == "analyse" | $_GET['pid'] == "generate")) {

//
// IF GENERATE --> SET WORD CLASS
//

if ($_GET['word_class'] == "noun") {
	$word_class = 'N';
}
elseif ($_GET['word_class'] == "verb") {
	$word_class = 'V';
}
else {
	// particle
	$word_class = 'P';
}

?>

<?

//
// Program variables
//

$xfstdir = $global['PATH_TO_XEROX'] ;
$fstdir = $global['PATH_TO_FST_BIN'] ;
$fstchar = $global['XEROX_CHARSET'] ;

//
// Files for analyzer
//

/*
if ($_GET['fst'] == "g") {
$fst = $fstdir . "/g-kal.fst"; // Greenlandic tags
}
elseif ($_GET['fst'] == "d") {
$fst = $fstdir . "/d-kal.fst"; // Danish tags
}
else {
$fst = $fstdir . "/kal.fst"; // Linguistic tags
}
*/

$fst = $fstdir . "/kal.fst"; // Linguistic tags

// File for generator
$ifst = $fstdir . "/ikal.fst";

//
// How to create string from form:
//

$text = $_GET['text'];

//
// Character encoding:
//
// Special characters in the text (e.g. literal ampersands, plus signs and equal signs 
// typed by the user) must be encoded for transmission, to prevent confusion with
// the delimiters used by CGI); here is the magic formula to undo the CGI encodings

// $text =~ s/%(..)/pack("c",hex($1))/ge ; // need to be fixed for PHP. 

// Change the plus signs back to the original spaces typed by the user
// Well, no, here we want the pluses 

$text = preg_replace('/\+/',' ',$text); // IF ANALYSE. ELSE DON'T DO IT. COMPUTER ANALYSE ALWAYS.
$text = preg_replace('/\s\s+/',' ', $text); // strips excess whitespace from a string

// Removing the unsecure characters from the input.
$text = preg_replace('/[;<>\*\|`&\$!#\(\)\[\]\{\}:\'\"]/',' ',$text);

$text = preg_replace('/\?/',' ?',$text); // make space before question marks (?)
$text = preg_replace('/\./',' .',$text); // make space before dot (.)
$text = preg_replace('/\,/',' ,',$text); // make space before (,)

// split the text into words crudely on spaces
$words = preg_split('/\s+/', $text) ;

// if we reach here, then the user did indeed one or more words;
// join the words back into a single string

// each remaining word now separated by spaces
$allwords = implode(" ", $words) ;

//
// And here is where the actual lookup/lookdown gets done:
// 
// 1.  echo the string $allwords via a pipe to tr, which replaces spaces with newlines
// 2.  pipe the now tokenized text (one word per line) to the lookup application
//         (which has some flags set, and which accesses kal.fst or ikal.fst)
// 3.  The output of lookup is assigned as the value of $result

if ($_GET['pid'] == "analyse") {

// IF ANALYSE --> Lookup
exec("echo $allwords | tr \" \" \"\n\" | $xfstdir/lookup -flags L\" => \"LTT -d $fst $fstchar", $output);

}
elseif ($_GET['pid'] == "generate") {


// WORD IN PUBLIC FORM 
// ===================
include($global['PATH_TO_ANALYSE']);

// WORD IN BASEFORM
// ================
//$an_word = $allwords;

// FORM OF GENERATOR
// =================

if ($_GET['word_class'] == "noun") {
	$allwords = $an_word.'+N'.$_GET['case'].$_GET['form'].$_GET['genitive'].$_GET['clitic']; 
}
elseif ($_GET['word_class'] == "verb") {
	$allwords = $an_word.$_GET['affix'].'+V'.$_GET['mood'].$_GET['person'].$_GET['objective'].$_GET['clitic'];
}
elseif ($_GET['word_class'] == "particle") {
	$allwords = $an_word.$_GET['clitic'];
}
else {
	$allwords = $an_word;
}

// AND FINALY WE GENERATE IT
// IF GENERATE --> Lookdown 

exec("echo $allwords | tr \" \" \"\n\" | $xfstdir/lookup -flags mbL\" => \"LTT -d $ifst $fstchar", $output);

}

$result = implode("\n",$output);

// Now we need to parse the $result string to output the information as HTML
// This information will be directed automatically back to the user's browser for display
//
// first split the $result into solutiongroups (one solutiongroup for each input word)
// given the way that 'lookup' formats its results, solutiongroups are separated by
// two newline characters

$solutiongroups = preg_split('/\n\n/', $result);

// the following is basically a loop over the original input words, now 
// associated with their solutions

foreach ($solutiongroups as $solutiongroup) {

echo  "\n<HR>\n" ;
$cnt = 0;

// each $solutiongroup contains the analysis
// or analyses for a single input word.  Multiple
// analyses are separated by a newline

$lexicalstrings = preg_split('/\n/', $solutiongroup);

// each lexicalstring looks like
// input=>root [CAT]

// now loop through the analyses for a single input word

foreach ($lexicalstrings as $lexicalstring) {

if ($lexicalstring == true) {
$solution = preg_replace('/\=\>/','=>',$lexicalstring);
$tag_solution = preg_split('/\s\=\>\s/', $solution);

echo ++$cnt.". ";
if ($_GET['fst'] == 'g' || $_GET['fst'] == 'd') {
echo $tag_solution[0]." => ";
$base_tag_form = $tag_solution[1];
include($global['PATH_TO_TAGS']);
}
else { echo $solution; }
echo "<br>";

}

}

}

}

//
// IF WE DON'T HAVE A WORD
//

else {
	if ($_GET['pid'] == "analyse") {
		echo "<hr>".$lang['ANALYSE_no_word'];
	}
	elseif ($_GET['pid'] == "generate") {
		echo "<hr>".$lang['GENERATE_no_word'];
	}
	else {
		echo "<hr>Huonoa tuuria!";
	}
}

//
// That's all Folks!
// -------------------------------------------------
 
?>

