<?php
/***************************************************************************
 *                            conf.php
 *                              -------------------
 *     begin                : Tue Sep 13 2005
 *     copyright            : (C) 2005 Oqaasileriffik
 *     email                : tero.avellan@aumanet.fi
 *
 *
 ****************************************************************************/

$id = $_GET['id'];

//
// Global language variables
//

$lang = array();

if ($_GET['lang'] == "") {
$language = "gl";
include ($path_to_conf . 'lang/lang_gl.php');
include ($path_to_conf . 'lang/lang_gl_tools.php');
}
else {
$language = $_GET['lang'];
include ($path_to_conf . 'lang/lang_' . $_GET['lang'] . '.php');
include ($path_to_conf . 'lang/lang_' . $_GET['lang'] . '_tools.php');
}

// For new language selection we need to remove
// few query_string variables

$old_lang = $global['PATH_TO_SELF'] . "?" . $_SERVER['QUERY_STRING'];
$new_lang = preg_replace('/lang=gl&/', '', $old_lang);
$new_lang = preg_replace('/lang=dk&/', '', $new_lang);
$new_lang = preg_replace('/lang=eng&/', '', $new_lang);
$new_lang = preg_replace('/&lang=gl/', '', $new_lang);
$new_lang = preg_replace('/&lang=dk/', '', $new_lang);
$new_lang = preg_replace('/&lang=eng/', '', $new_lang);
$new_lang = $new_lang;

//
// Global path variables
//

$global = array();

$global['PATH_TO_CONF'] = 'Inc/';
$global['PATH_TO_LOCALWWW'] = '/home/per/public_html';
$global['PATH_TO_LOCALLEX'] = '/kal';
$global['PATH_TO_CGI-BIN'] = "http://localhost/cgi-bin";
$global['PATH_TO_IMAGES'] = 'Images/';
$global['PATH_TO_CSS'] = "Inc/stylesheet.css";
$global['PATH_TO_LOOKUP'] = $global['PATH_TO_LOCALWWW']."/Inc/kal-lookup.php";
$global['PATH_TO_ANALYSE'] = $global['PATH_TO_LOCALWWW']."/Inc/tag/kal-analyse.php";
$global['PATH_TO_TAGS'] = $global['PATH_TO_LOCALWWW']."/Inc/tag/kal-tags.php";
$global['PATH_TO_PARADIGM'] = $global['PATH_TO_LOCALWWW']."/Inc/kal-paradigm.php";
$global['PATH_TO_SELF'] = $_SERVER['PHP_SELF'];
$global['PATH_TO_HELP'] = 'http://www.oqaasileriffik.gl/eng/help.html';
$global['PATH_TO_HOME'] = 'http://www.oqaasileriffik.gl/'.$language.'/';
//$global['PATH_TO_HELP'] = 'help.php?lang='.$language;
//$global['PATH_TO_HOME'] = 'index.php?lang='.$language;
$global['PATH_TO_PRINT'] = 'print.php';

$global['SITE_NAME'] = "Oqaasileriffik";
$global['DTD'] = "-//W3C//DTD HTML 4.01 Transitional//EN";
$global['BASET_TARGET'] = "_top";

//
// Language tools variables
//

// Xerox FST version:
// fst -UT8 if professional, otherwise xfst

$global['XEROX_VERSION'] = "fst -UTF8";
$global['XEROX_CHARSET'] = "-utf8"; 

// Directory where all the Xerox binaries are:

$global['PATH_TO_XEROX'] = "/opt/xerox/bin" ;

// Directory where all the compiled fst's are:

$global['PATH_TO_FST_BIN'] = $global['PATH_TO_LOCALLEX']."/bin";

// Directory for the source files (which compile into fst's):

$global['PATH_TO_FST_SRC'] = $global['PATH_TO_LOCALLEX']."/src";

// Directory for the rulefiles (which compile into paradigm's):

$global['PATH_TO_FST_RULES'] = $global['PATH_TO_LOCALLEX']."/rules";

// The temp directory:

$global['PATH_TO_TMP'] = $global['PATH_TO_LOCALLEX']."/tmp";

// Directory where all the perl scripts are:
// $global['PATH_TO_SCRIPTS'] = "";
// Path to Paradigm generator makefile:
// $global['PATH_TO_MAKE'] = ""; 

// Directory for the compiled paradigm files:

$global['PATH_TO_PARADIGM_FILES'] = $global['PATH_TO_LOCALLEX']."/para";

// Directory for the tag files:

$global['PATH_TO_TAG_FILES'] = $global['PATH_TO_LOCALWWW']."/Inc/tag";

//
// That's all Folks!
// -------------------------------------------------

?>

