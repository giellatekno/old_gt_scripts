<?php
/***************************************************************************
 *                            kal-paradigm.php
 *                              -------------------
 *     begin                : Sun Jan 8 2006
 *     copyright            : (C) 2006 Oqaasileriffik
 *     email                : tero.avellan@aumanet.fi
 *     version              : 1.0
 *
 *
 ****************************************************************************/

include ('Inc/conf.php');

$word = $_GET['word']; // INPUT WORD
$tags = $_GET['fst']; // TAG SELECTION
$temp = $global['PATH_TO_TMP'];
$filename = "tempfile";
if (@file($temp.'/'.$filename.'-print')) { 
$html = implode('', @file($temp.'/'.$filename.'-print'));

?>

<!DOCTYPE HTML PUBLIC "<?echo $global['DTD'] ?>">
<html>
<head>
<title><?echo $global['SITE_NAME'] ?> - Paradigm generator</title>
<meta http-equiv="Content-Type" content="text/html;charset=<?echo $lang['ENCODING'] ?>">
<LINK rel="stylesheet" type="text/css" href="<?echo $global['PATH_TO_CSS'] ?>">

</head>
<body bgcolor="#FFFFFF" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" text="#000000" link="#660000" alink="#ffcc99" vlink="#660000">

<?php

// Printing variables:
$cnt = 0;
$line_cnt = 0;
$split = 40;
if ($tags == "l") { $width = "300"; }
else { $width = "100%"; }

?>

<div align="center">
<br><br><br>
<table width="700" border="0" cellpadding="3" cellspacing="0">
<tr><td valign="top">
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
//round($line_cnt)
		if ($line_num == ($split+1) | $line_num == (($split*3)+1) | $line_num == (($split*5)+1) | $line_num == (($split*7)+1)) {
		if ($tags == "l") {
			echo "</table>\n\n";
			echo "</td><td valign=\"top\">\n\n";
			echo "<table width=\"".$width."\" border=\"0\" cellpadding=\"3\" cellspacing=\"0\">";
			}
		else {
			echo "</table>\n\n";
			echo "</td></tr>";
			echo "<tr><td valign=\"top\" colspan=\"2\"><hr></td></tr>";		
			echo "<tr><td align=\"right\" colspan=\"2\"><font class='copy'>&copy;".$global['SITE_NAME'].".</font></td></tr>";
			echo "<tr><td valign=\"top\" colspan=\"2\"><br><br><br><br><br><br></td></tr>";
			echo "<tr><td valign=\"top\">\n\n";
			echo "<table width=\"".$width."\" border=\"0\" cellpadding=\"3\" cellspacing=\"0\">";
			}
		}
		else if ($line_num == (($split*2)+1) | $line_num == (($split*4)+1) | $line_num == (($split*6)+1) | $line_num == (($split*8)+1)) {
		echo "</table>\n\n";
		echo "</td></tr>";
		echo "<tr><td valign=\"top\" colspan=\"2\"><hr></td></tr>";		
		echo "<tr><td align=\"right\" colspan=\"2\"><font class='copy'>&copy;".$global['SITE_NAME'].".</font></td></tr>";
		echo "<tr><td valign=\"top\" colspan=\"2\"><br><br><br><br><br><br></td></tr>";
		echo "<tr><td valign=\"top\">\n\n";
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
	}
}

?>

</table>
</td></tr>
<tr><td valign="top" colspan="2"><hr></td></tr>
<tr><td align="right" colspan="2"><font class='copy'>&copy; <?echo $global['SITE_NAME'] ?></font></td></tr>
</table>
</td></tr>
</table>

<?php

// HOUSEKEEPING
// ============

	exec("rm -f $temp/$filename-print");

}
else {

//DO NOTHING!

}

//
// That's all Folks!
// -------------------------------------------------
 
?>

</div>
</body>
</html>
