<?php
/***************************************************************************
 *                            kal-paradigm.php
 *                              -------------------
 *     begin                : Sun Jan 8 2006
 *     copyright            : (C) 2006 Oqaasileriffik
 *     email                : tero.avellan@aumanet.fi
 *     version              : 1.0
 *     modified             : Fri Feb 10 2006
 *
 *
 ****************************************************************************/

// PHP program written by Tero Avellan, Oqaasileriffik, for Greenlandic

//
// Version history
//
// 1.0 Added print feature 6 february 2006

//
// conf.php
// kal-paradigm.php
// kal-analyse.php
// kal-tags.php
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

if ($_GET['text'] == true & ( $_GET['pid'] == "paradigm")) {

//
// IF PARADIGM --> SET WORD CLASS AND SET CODE FILE
//

// IF NOUNS
if ($_GET['word_class'] == "inoun") {
	$word_class = 'N';
	$codes = "noun-codes.txt";
}
// IF INTRANSITIVE VERBS
elseif ($_GET['word_class'] == "iverb") {
	$word_class = 'V';
	$codes = "intrans-codes.txt";
}
// IF TRANSITIVE VERBS
elseif ($_GET['word_class'] == "tverb") {
	$word_class = 'V';
	$codes = "trans-codes.txt";
}
// IF PRONOUNS
elseif ($_GET['word_class'] == "pronoun") {
	$word_class = 'Pron';
	$codes = "pron-codes.txt";
}
// ELSE DO NOTHING!
else {
	// particle
	$word_class = 'P';
	$codes = "pron-codes.txt";
}

?>

<?

//
// How to create string from form:
//

$text = $_GET['text']; // INPUT WORD
$tags = $_GET['fst']; // TAG SELECTION

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
// And here is where the actual generating gets done:
//

//**************************************************************
//**************************************************************

// VARIABLE DEFINITIONS
// ====================

// Where all the Xerox binaries are:
$xfstdir = $global['PATH_TO_XEROX'];

// Where all the Xerox binaries are:
$xfst = $global['XEROX_VERSION'];

// Where all the perl scripts are:
// $bindir = $global['PATH_TO_SCRIPTS'];

// Directory where all the compiled fst's are:
$fstdir = $global['PATH_TO_FST_BIN'] ;

// Directory for the source files (which compile into fst's):
$srcdir = $global['PATH_TO_FST_SRC'];

// The temp directory:
$temp = $global['PATH_TO_TMP'];

// Input files with inflectional tags:
$fstrules = $global['PATH_TO_FST_RULES'] ;

// Directory where all the compiled paradigms' are:
$paradigmdir = $global['PATH_TO_PARADIGM_FILES'] ;

// This variable is holding the filename of the save file:
$savefile = $fstdir."/kal.save";

// FORM SPECIFIC SECTIONS
// =====================

// WORD IN PUBLIC FORM 
$fst = $fstdir . "/kal.fst"; // Linguistic tags
include($global['PATH_TO_ANALYSE']);
$word = $an_word;

// WORD IN BASEFORM
//$wordline = preg_split('/\s/', $allwords);
//$word = $wordline[0];

// Set baseform
$baseform = $word;
$filename = "tempfile";

echo "<hr>";

// POS SPECIFIC SECTIONS
// =====================

//
// Create paradigm generation input file:
//

/*
 * Purpose:
 *
 * To create a file for testing paradigm generation by combining a tag list
 * and a word (supposedly the base form).
 *
 *	ARG1:	input file with inflectional tags
 *	ARG2:	the base form of the word we want to inflect
 *
 * Output file:
 *
 * Baseform+tags for all tags given in the tag file
 * This can directly be given to xfst for word form generation
 */

$mergefile = file($fstrules.'/'.$codes);
$fm = fopen($temp.'/'.$filename.'-para.ptest', "w", 0);
foreach ($mergefile as $mergeline) {
	//$mergefile = chop($mergeline);
	fputs($fm, $baseform.$mergeline);
}
fclose($fm);

//
// Paradigm generation:
//

	$script = "load ".$savefile."\n"."apply down < ".$temp."/$filename-para.ptest \n quit \n";
	$fp = fopen($temp.'/'.$filename.'-gtest-script', "w", 0);
	fputs($fp, $script);
	fclose($fp);
	exec("$xfstdir/$xfst < $temp/$filename-gtest-script > $paradigmdir/$filename.paradigm");

// HOUSEKEEPING
// ============

	exec("rm -f $temp/$filename-para.ptest");
	exec("rm -f $temp/$filename-gtest-script");

//**************************************************************
//**************************************************************

//FILE START
if (@file($paradigmdir.'/'.$filename.'.paradigm')) {

// Get a file into string:
$html = implode('', file($paradigmdir.'/'.$filename.'.paradigm'));

// Make a temporary printfile:
$pr = fopen($temp.'/'.$filename.'-print', "w", 0);
fputs($pr, $html);
fclose($pr);

// Printing variables:
$cnt = 0;
$line_cnt = 0;
$split = 40;
if ($tags == "l") { $width = "300"; }
else { $width = "100%"; }

?>

<table width="100%" border="0" cellpadding="3" cellspacing="0">
<tr><td valign="top">
<table width="<?echo $width; ?>" border="0" cellpadding="3" cellspacing="0">

<?php

// Loop through our array, show HTML source as HTML source; and line numbers too.

$lines = preg_split('/\n\n/', $html);
foreach ($lines as $line_num => $line) {
	$line_cnt = $line_cnt+1;
}
foreach ($lines as $line_num => $line) {
	if ($line_num == 0) {
	}
	else {
		if ($line_num == ($split+1) | $line_num == (($split*3)+1) | $line_num == (($split*5)+1) | $line_num == (($split*7)+1)) {
		if ($tags == "l") {
			echo "</table>\n\n";
			echo "</td><td valign=\"top\">\n\n";
			echo "<table width=\"".$width."\" border=\"0\" cellpadding=\"3\" cellspacing=\"0\">";
			}
		else {
			echo "</table>\n\n";
			echo "</td></tr><tr><td valign=\"top\" colspan=\"2\"><hr></td></tr><tr><td valign=\"top\">\n\n";
			echo "<table width=\"".$width."\" border=\"0\" cellpadding=\"3\" cellspacing=\"0\">";
			}
		}
		else if ($line_num == (($split*2)+1) | $line_num == (($split*4)+1) | $line_num == (($split*6)+1) | $line_num == (($split*8)+1)) {
		echo "</table>\n\n";
		echo "</td></tr><tr><td valign=\"top\" colspan=\"2\"><hr></td></tr><tr><td valign=\"top\">\n\n";
		echo "<table width=\"".$width."\" border=\"0\" cellpadding=\"3\" cellspacing=\"0\">";
		}
		else {
		}
		echo "<tr>";
		$columns = preg_split('/\n/', $line);
		echo "<td><font class='line'>".$line_num.".</font></td>";

		echo "<td><font class='db'>";
		$base_tag_form = $columns[0];
		include($global['PATH_TO_TAGS']);
		echo "</font></td>";

		echo "<td align=\"right\"><font class='db'><b>";
		$lastline = preg_split('/\s/', $columns[1]);
		if ($lastline[0] == "Closing") { }
		else { echo $columns[1]; }
		echo "</b></font></td>";
		echo "</tr>";
	}
}

?>

</table>
</td></tr>
</table>

<?php

} //FILE END

//
// IF WE DON'T HAVE A WORD
//

}
else {
	echo "<hr>".$lang['PARADIGM_no_word'];
}

//
// That's all Folks!
// -------------------------------------------------
 
?>


-----------------------------1539548166661214351620291420
Content-Disposition: form-data; name="Compose.Attach.Add.x"

50