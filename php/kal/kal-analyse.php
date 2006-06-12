<?php
/***************************************************************************
 *                            kal-analyse.php
 *                              -------------------
 *     begin                : Mon Feb 6 2006
 *     copyright            : (C) 2006 Oqaasileriffik
 *     email                : tero.avellan@aumanet.fi
 *     version              : 1.0
 *     modified             : Fri Feb 10 2006
 *
 *
 ****************************************************************************/

//
// conf.php
// kal-lookup.php
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

$fstchar = $global['XEROX_CHARSET'];

exec("echo $allwords | tr \" \" \"\n\" | $xfstdir/lookup -flags L\" => \"LTT -d $fst $fstchar", $a_output);

$a_result = implode("\n",$a_output);
$a_solutiongroups = preg_split('/\n\n/', $a_result);

foreach ($a_solutiongroups as $a_solutiongroup) {

$a_lexicalstrings = preg_split('/\n/', $a_solutiongroup);

foreach ($a_lexicalstrings as $a_lexicalstring) {

if ($a_lexicalstring == true) {
$a_solution = preg_replace('/\=\>/','=>',$a_lexicalstring);

$div_solution = preg_split('/\s\=\>\s/', $a_solution);
$tag_solution = preg_split('/\s\=\>\s/', $a_solution);
$div_solution = preg_split('/\+/',$div_solution[1]);

// START SOLUTION FOR RE-ANALYSE

//$if_solution = preg_split('/\+/', $a_solution); // split solution again

	if ($div_solution[1] == $word_class || $div_solution[2] == $word_class) {
		if ($div_solution[1] == 'QAR') {
			$an_word = $div_solution[0]."+QAR"; 
		}
		else if ($div_solution[1] == 'QANNGIT') {
			$an_word = $div_solution[0]."+QANNGIT"; 
		}
		else {
			$an_word = $div_solution[0];
		}
			$an_word = preg_replace('/\s/',' ', $an_word);
			echo "<i>";
			if ($_GET['fst'] == 'g' || $_GET['fst'] == 'd') {
			echo $tag_solution[0]." => ";
			$base_tag_form = $tag_solution[1];
			include($global['PATH_TO_TAGS']);
			}
			else { echo $a_solution; }
			echo "</i><br>";
	}
	else {
		if ($word_class == 'P') {
		if ($div_solution[1] == 'QAR') {
			$an_word = $div_solution[0]."+QAR"; 
		}
		else if ($div_solution[1] == 'QANNGIT') {
			$an_word = $div_solution[0]."+QANNGIT"; 
		}
		else {
			$an_word = $div_solution[0];
		}
			$an_word = preg_replace('/\s/',' ', $an_word);
			echo "<i>";
			if ($_GET['fst'] == 'g' || $_GET['fst'] == 'd') {
			echo $tag_solution[0]." => ";
			$base_tag_form = $tag_solution[1];
			include($global['PATH_TO_TAGS']);
			}
			else { echo $a_solution; }
			echo "</i><br>";
		}
		else {
			echo "<i>";
			if ($_GET['fst'] == 'g' || $_GET['fst'] == 'd') {
			echo $tag_solution[0]." => ";
			$base_tag_form = $tag_solution[1];
			include($global['PATH_TO_TAGS']);
			}
			else { echo $a_solution; }
			echo "</i><br>";
		}
	}
}

}

}

//
// That's all Folks!
// -------------------------------------------------
 
?>

