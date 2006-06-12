<? if ($id == "katersat") { ?>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td valign="top">
<br>
<table width="100%" border="0" cellpadding="10" cellspacing="0">
<tr><td valign="top" width="180">

<form action="$program" method="post">
<input type="hidden" name="lang" value="$lang">
<input type="hidden" name="type" value="list">
<table width="100%" border="1" cellspacing="0" cellpadding="5">
<tr><td><font class='default'><b><? echo $lang['Search_greenlandic'] ?>:</b></font></td></tr>
<tr><td><input size="23" type="text" name="oqaaseq"></td></tr>
<tr><td><font class='default'><b><? echo $lang['Search_danish'] ?>:</b></font></td></tr>
<tr><td><input size="23" type="text" name="dansk"></td></tr>
<tr><td align="right"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td align="left"><font class='default'><input type=radio name="method" value="0" checked>&nbsp;<? echo $lang['Search_wildcard'] ?><br><input type=radio name="method" value="1">&nbsp;<? echo $lang['Search_exact'] ?><p>&nbsp;<select name="hits"><option value="5">5<option value="10">10<option value="15">15<option value="20">20<option value="25" selected>25<option value="30">30<option value="40">40<option value="50">50<option value="60">60<option value="70">70<option value="80">80<option value="90">90<option value="100">100</select></font></td></tr></table><br><input type="submit" value="<? echo $lang['Search_submit'] ?>"><br><input type="reset" value="<? echo $lang['Clear_form'] ?>"></td></tr>
</table>
</form>

</td></tr>
</table>

</td></tr>
</table>

<? 
}
elseif ($id == "xfst") { 
?>

dsflsdklfksdšfsdlfklkšl

<?
}
else { 
include ($lang_path . 'lang/lang_' . $language . '_menu.php'); ?>

<br>
<table border="0" cellpadding="3" cellspacing="0">

<tr><td valign="middle"><img src="Images/help.gif" alt=""></td><td valign="middle"><font class='lanmenu'><a href="<?echo $global['PATH_TO_HELP']?>" target="top"><?echo $lang['Help']?></a></font></td></tr>

<tr><td valign="middle"><img src="Images/home.gif" alt=""></td><td valign="middle"><font class='lanmenu'><a href="<?echo $global['PATH_TO_HOME']?>" target="_top"><?echo $lang['Home']?></a></font></td></tr>

</table>

<? 

 } 

?>

