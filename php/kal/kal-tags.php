<?php
/***************************************************************************
 *                            kal-tags.php
 *                              -------------------
 *     begin                : Fri Feb 10 2006
 *     copyright            : (C) 2006 Oqaasileriffik
 *     email                : tero.avellan@aumanet.fi
 *     version              : 1.0
 *     modified             : Fri Feb 10 2006
 *
 *
 ****************************************************************************/

//
// Required:
// tag-da.regex
// tag-kal.regex
//

// TAG SELECTION
// =============

$tagdir = $global['PATH_TO_TAG_FILES']; // TAG DIRECTORY

if ($_GET['fst'] == "l") {
	echo $base_tag_form;
}
else {

if (@file($tagdir.'/tag-kal.regex') & @file($tagdir.'/tag-da.regex')) {

	if ($_GET['fst'] == "g") {
		// Get a file into string:
		$tagfile = implode('', file($tagdir.'/tag-kal.regex'));
	}
	else if ($_GET['fst'] == "d") {
		// Get a file into string:
		$tagfile = implode('', file($tagdir.'/tag-da.regex'));
	}

	// Removing the unsecure characters from the input file.
	$tagfile = preg_replace('/[;<>\*\+\-\%\|`&\$!#\(\)\[\]:\'\"]/',' ',$tagfile);
	// Split the input file to lines
	$taglines = preg_split('/\n/', $tagfile);

	// Split the column to tags
	$tagcolumns = preg_split('/\+/', $base_tag_form);
	
	// Print base form
	echo "<b>".$tagcolumns[0]."</b>";

	// Loop for each line
	foreach ($tagcolumns as $tag_pos => $tagcolumn) {

		// Loop for tag file
		foreach ($taglines as $tagline_num => $tagline) {
		$tag = preg_split('/,/', $tagline);
		$tag[1] = preg_replace('/\s/','',$tag[1]);
		if ($tagcolumn == $tag[1] ) { echo ",".$tag[0]; }
		}
	}
}
else { echo $base_tag_form; }

}

// END OF TAG SELECTION
// ====================

//
// That's all Folks!
// -------------------------------------------------
 
?>

