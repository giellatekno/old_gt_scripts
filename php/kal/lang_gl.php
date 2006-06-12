<?php
/***************************************************************************
 *                            lang_gl.php [Kalaallisut]
 *                              -------------------
 *     begin                : Tue Sep 13 2005
 *     copyright            : (C) 2005 Oqaasileriffik
 *
 *
 ****************************************************************************/

//
//
//iso-8859-1
//
$lang['ENCODING'] = 'utf-8';
$lang['DIRECTION'] = 'ltr';
$lang['LEFT'] = 'left';
$lang['RIGHT'] = 'right';
$lang['DATE_FORMAT'] =  "d M Y"; // This should be changed to the default date format for your language, php date() format

//
// Common, these terms are used
// extensively on several pages
//
$lang['Help'] = 'Ilitsersuut';
$lang['Home'] = 'Saqqaanut';
$lang['Print'] = 'Anillatsiguk';
//
//

$lang['Site_terms'] = 'Site Terms'; // Legal notice and terms of usage
$lang['Site_terms_text'] = ' ';
$lang['Privacy_policy'] = 'Privacy Policy';
$lang['Privacy_policy_text'] = ' ';

//
$lang['Forum'] = 'Forum';
$lang['Category'] = 'Category';
$lang['Topic'] = 'Topic';
$lang['Topics'] = 'Topics';
$lang['Replies'] = 'Replies';
$lang['Views'] = 'Views';
$lang['Post'] = 'Post';
$lang['Posts'] = 'Posts';
$lang['Posted'] = 'Posted';
$lang['Username'] = 'Username';
$lang['Password'] = 'Password';
$lang['Poster'] = 'Poster';
$lang['Author'] = 'Author';
$lang['Message'] = 'Message';

$lang['Go'] = 'Go';
$lang['Jump_to'] = 'Jump to';
$lang['Submit'] = 'Submit';
$lang['Reset'] = 'Reset';
$lang['Cancel'] = 'Cancel';
$lang['Preview'] = 'Preview';
$lang['Confirm'] = 'Confirm';
$lang['Spellcheck'] = 'Spellcheck';
$lang['Yes'] = 'Yes';
$lang['No'] = 'No';
$lang['Enabled'] = 'Enabled';
$lang['Disabled'] = 'Disabled';
$lang['Error'] = 'Error';

$lang['Next'] = 'Next';
$lang['Previous'] = 'Previous';
$lang['Goto_page'] = 'Goto page';

$lang['Admin_panel'] = 'Go to Administration Panel';

$lang['Board_disable'] = 'Sorry, but this board is currently unavailable.  Please try again later.';

$lang['Select'] = 'Select';
$lang['Delete'] = 'Delete';
$lang['Move'] = 'Move';
$lang['Lock'] = 'Lock';
$lang['Unlock'] = 'Unlock';

// Global Header strings
//

//
// Login
//
$lang['Enter_password'] = 'Please enter your username and password to log in.';
$lang['Login'] = 'Log in';
$lang['Logout'] = 'Log out';
$lang['Forgotten_password'] = 'I forgot my password';
$lang['Log_me_in'] = 'Log me on automatically each visit';
$lang['Error_login'] = 'You have specified an incorrect or inactive username, or an invalid password.';

//
// Main Search Variables
//

$lang['Search_greenlandic'] = "Greenlandic";
$lang['Search_synonym'] = "Synonym";
$lang['Search_danish'] = "Danish";
$lang['Search_latin'] = "Latin";
$lang['Search_register'] = "Register";
$lang['Search_reference'] = "Reference";

$lang['Search_query'] = 'Search Query';
$lang['Search_options'] = 'Search Options';
$lang['Search_wildcard'] = "Wildcard search";
$lang['Search_exact'] = "Exact match";
$lang['Search_for_any'] = 'Search for any terms or use query as entered'; // no
$lang['Search_for_all'] = 'Search for all terms'; // no
$lang['Search_keywords'] = 'Search for Keywords'; //no
$lang['Search_keywords_explain'] = 'You can use <u>AND</u> to define words which must be in the results, <u>OR</u> to define words which may be in the result and <u>NOT</u> to define words which should not be in the result. Use * as a wildcard for partial matches'; // no

$lang['Search_submit'] = 'Search';
$lang['Search_submit_New_search'] = 'New search';

$lang['Display_results'] = 'Display results as';
$lang['All_available'] = 'All available';

$lang['Found_search_match'] = 'Search found %d match'; // eg. Search found 1 match
$lang['Found_search_matches'] = 'Search found %d matches'; // eg. Search found 24 matches
$lang['Found_search_match_info'] = 'Results'. $view_hits . 'of about' . $total_hits;
$lang['No_search_match'] = 'Your search did not match any word.';
$lang['No_search_match_tips'] = 'Suggestions:
<ul>
<li>Make sure all words are spelled correctly.
<li>Try different words.
</ul>';

$lang['Close_window'] = 'Close Window';


//
// Katersat
//

// Main Variables

$lang['KATERSAT_title'] = "Language database";

$lang['KATERSAT_btn_info'] = "Get info";
$lang['KATERSAT_btn_shv'] = "Medical Terminology";
$lang['KATERSAT_btn_go'] = "Go here";

// Gram

$lang['KATERSAT_gram_title'] = "Grammatical information:";
$lang['KATERSAT_gram_about'] = "Press here to obtain grammatical information including information about Kleinschmidt's orthography";
$lang['KATERSAT_gram_class'] = "Class of words";
$lang['KATERSAT_gram_old'] = "Old orthography";
$lang['KATERSAT_gram_stem'] = "Stem";
$lang['KATERSAT_gram_morph'] = "Morphemes";
$lang['KATERSAT_gram_misc'] = "Miscellaneous";
$lang['KATERSAT_gram_use'] = "Field of use";

// Usus

$lang['KATERSAT_usus_title'] = "Definitions:";
$lang['KATERSAT_usus_about'] = "Press here to obtain definitions and information on";
$lang['KATERSAT_usus_def_dk'] = "Definition in Danish";
$lang['KATERSAT_usus_def_gl'] = "Definition in Greenlandic";
$lang['KATERSAT_usus_examples'] = "Examples";

// Lang

$lang['KATERSAT_lang_title'] = "Other Languages:";
$lang['KATERSAT_lang_about'] = "Press here to get equivalents in other languages than Danish/Greenlandic";
$lang['KATERSAT_lang_english'] = "In English";
$lang['KATERSAT_lang_swedish'] = "In Swedish";
$lang['KATERSAT_lang_others'] = "Others";

// Etc

$lang['KATERSAT_etc_title'] = "Miscellaneous:";
$lang['KATERSAT_etc_about'] = "Press here to get e.g. information on authorisation and other formal regulations of the word in question";
$lang['KATERSAT_etc_misc'] = "Miscellaneous";
$lang['KATERSAT_etc_reference'] = "Reference";
$lang['KATERSAT_etc_compilator'] = "Compilator";
$lang['KATERSAT_etc_date'] = "Date";

//
// SHV
//

$lang['SHV_title'] = "Database for medical terminology";
$lang['SHV_about'] = "Information on authorisation and other formal regulations of the word in question.";
$lang['SHV_label1'] = $lang['Search_greenlandic'];
$lang['SHV_label2'] = $lang['Search_synonym'];
$lang['SHV_label3'] = $lang['Search_danish'];
$lang['SHV_label4'] = $lang['Search_latin'];
$lang['SHV_label5'] = $lang['Search_register'];
$lang['SHV_label6'] = $lang['Search_reference'];

//
// Aqqinik
//

$lang['AQQINIK_title'] = "Database for sanctioned Greenlandic personal names";

//
// Feedback
//
$lang['FEEDBACK_title'] = "Feed-back";
$lang['FEEDBACK_about'] = "Didn't you find what you were lookig for? Do you have comments to the information you found? Do you have other comments?";
$lang['FEEDBACK_name'] = "Name";
$lang['Email'] = 'E-mail';
$lang['FEEDBACK_telephone'] = "Telephone";
$lang['FEEDBACK_comments'] = "Comments";
$lang['FEEDBACK_info'] = "If you include your e-mail address or a telephone number we shall return some feed-back to your comments as soon as possible.";
$lang['Send'] = "Ujarlerfik";
$lang['Clear'] = "Imaaruk";

//
// Time Settings
//

$lang['Time'] = 'Time';
$lang['Hours'] = 'Hours';

$lang['1_Day'] = '1 Day';
$lang['7_Days'] = '7 Days';
$lang['2_Weeks'] = '2 Weeks';
$lang['1_Month'] = '1 Month';
$lang['3_Months'] = '3 Months';
$lang['6_Months'] = '6 Months';
$lang['1_Year'] = '1 Year';

$lang['All_times'] = 'All times are %s'; // eg. All times are GMT - 12 Hours (times from next block)

$lang['-12'] = 'GMT - 12 Hours';
$lang['-11'] = 'GMT - 11 Hours';
$lang['-10'] = 'GMT - 10 Hours';
$lang['-9'] = 'GMT - 9 Hours';
$lang['-8'] = 'GMT - 8 Hours';
$lang['-7'] = 'GMT - 7 Hours';
$lang['-6'] = 'GMT - 6 Hours';
$lang['-5'] = 'GMT - 5 Hours';
$lang['-4'] = 'GMT - 4 Hours';
$lang['-3.5'] = 'GMT - 3.5 Hours';
$lang['-3'] = 'GMT - 3 Hours';
$lang['-2'] = 'GMT - 2 Hours';
$lang['-1'] = 'GMT - 1 Hours';
$lang['0'] = 'GMT';
$lang['1'] = 'GMT + 1 Hour';
$lang['2'] = 'GMT + 2 Hours';
$lang['3'] = 'GMT + 3 Hours';
$lang['3.5'] = 'GMT + 3.5 Hours';
$lang['4'] = 'GMT + 4 Hours';
$lang['4.5'] = 'GMT + 4.5 Hours';
$lang['5'] = 'GMT + 5 Hours';
$lang['5.5'] = 'GMT + 5.5 Hours';
$lang['6'] = 'GMT + 6 Hours';
$lang['6.5'] = 'GMT + 6.5 Hours';
$lang['7'] = 'GMT + 7 Hours';
$lang['8'] = 'GMT + 8 Hours';
$lang['9'] = 'GMT + 9 Hours';
$lang['9.5'] = 'GMT + 9.5 Hours';
$lang['10'] = 'GMT + 10 Hours';
$lang['11'] = 'GMT + 11 Hours';
$lang['12'] = 'GMT + 12 Hours';
$lang['13'] = 'GMT + 13 Hours';

// These are displayed in the timezone select box
$lang['tz']['-12'] = 'GMT - 12 Hours';
$lang['tz']['-11'] = 'GMT - 11 Hours';
$lang['tz']['-10'] = 'GMT - 10 Hours';
$lang['tz']['-9'] = 'GMT - 9 Hours';
$lang['tz']['-8'] = 'GMT - 8 Hours';
$lang['tz']['-7'] = 'GMT - 7 Hours';
$lang['tz']['-6'] = 'GMT - 6 Hours';
$lang['tz']['-5'] = 'GMT - 5 Hours';
$lang['tz']['-4'] = 'GMT - 4 Hours';
$lang['tz']['-3.5'] = 'GMT - 3.5 Hours';
$lang['tz']['-3'] = 'GMT - 3 Hours';
$lang['tz']['-2'] = 'GMT - 2 Hours';
$lang['tz']['-1'] = 'GMT - 1 Hours';
$lang['tz']['0'] = 'GMT';
$lang['tz']['1'] = 'GMT + 1 Hour';
$lang['tz']['2'] = 'GMT + 2 Hours';
$lang['tz']['3'] = 'GMT + 3 Hours';
$lang['tz']['3.5'] = 'GMT + 3.5 Hours';
$lang['tz']['4'] = 'GMT + 4 Hours';
$lang['tz']['4.5'] = 'GMT + 4.5 Hours';
$lang['tz']['5'] = 'GMT + 5 Hours';
$lang['tz']['5.5'] = 'GMT + 5.5 Hours';
$lang['tz']['6'] = 'GMT + 6 Hours';
$lang['tz']['6.5'] = 'GMT + 6.5 Hours';
$lang['tz']['7'] = 'GMT + 7 Hours';
$lang['tz']['8'] = 'GMT + 8 Hours';
$lang['tz']['9'] = 'GMT + 9 Hours';
$lang['tz']['9.5'] = 'GMT + 9.5 Hours';
$lang['tz']['10'] = 'GMT + 10 Hours';
$lang['tz']['11'] = 'GMT + 11 Hours';
$lang['tz']['12'] = 'GMT + 12 Hours';
$lang['tz']['13'] = 'GMT + 13 Hours';

$lang['datetime']['Sunday'] = 'Sunday';
$lang['datetime']['Monday'] = 'Monday';
$lang['datetime']['Tuesday'] = 'Tuesday';
$lang['datetime']['Wednesday'] = 'Wednesday';
$lang['datetime']['Thursday'] = 'Thursday';
$lang['datetime']['Friday'] = 'Friday';
$lang['datetime']['Saturday'] = 'Saturday';
$lang['datetime']['Sun'] = 'Sun';
$lang['datetime']['Mon'] = 'Mon';
$lang['datetime']['Tue'] = 'Tue';
$lang['datetime']['Wed'] = 'Wed';
$lang['datetime']['Thu'] = 'Thu';
$lang['datetime']['Fri'] = 'Fri';
$lang['datetime']['Sat'] = 'Sat';
$lang['datetime']['January'] = 'January';
$lang['datetime']['February'] = 'February';
$lang['datetime']['March'] = 'March';
$lang['datetime']['April'] = 'April';
$lang['datetime']['May'] = 'May';
$lang['datetime']['June'] = 'June';
$lang['datetime']['July'] = 'July';
$lang['datetime']['August'] = 'August';
$lang['datetime']['September'] = 'September';
$lang['datetime']['October'] = 'October';
$lang['datetime']['November'] = 'November';
$lang['datetime']['December'] = 'December';
$lang['datetime']['Jan'] = 'Jan';
$lang['datetime']['Feb'] = 'Feb';
$lang['datetime']['Mar'] = 'Mar';
$lang['datetime']['Apr'] = 'Apr';
$lang['datetime']['May'] = 'May';
$lang['datetime']['Jun'] = 'Jun';
$lang['datetime']['Jul'] = 'Jul';
$lang['datetime']['Aug'] = 'Aug';
$lang['datetime']['Sep'] = 'Sep';
$lang['datetime']['Oct'] = 'Oct';
$lang['datetime']['Nov'] = 'Nov';
$lang['datetime']['Dec'] = 'Dec';

//
// Errors (not related to a
// specific failure on a page)
//
$lang['Information'] = 'Information';
$lang['Critical_Information'] = 'Critical Information';

$lang['General_Error'] = 'General Error';
$lang['Critical_Error'] = 'Critical Error';
$lang['An_error_occured'] = 'An Error Occurred';
$lang['A_critical_error'] = 'A Critical Error Occurred';

$lang['Admin_reauthenticate'] = 'To administer the board you must re-authenticate yourself.';

//
// That's all Folks!
// -------------------------------------------------

?>

