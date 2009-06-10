# -*-Shell-script-*-
# GT setup functions to set up the private repository.
# $Id$

priv_command_csh () {
    PRIVCMD="\
setenv GTPRIV $GTPRIV"
}

priv_command_sh () {
    PRIVCMD="\
export GTPRIV=$GTPRIV"
}

msg_confirm_priv () {
    echo It seems you already have checked out the private
    echo repository at:
    echo
    echo "$GTPRIV"
    echo
    echo Do you want me to set this path as the value of
    echo the environmental variable \$GTPRIV?
    echo
    case $ONCONSOLE in
        YES)
    echo You can answer \\\"No\\\" here  
    echo and do it later manually.
    ;;
	NO)
    echo "You can answer \"No\" here and do it later manually."
    ;;
    esac
    echo
    /bin/echo -n Continue\?
}

display_confirm_priv () {
    case $ONCONSOLE in
        YES)
# display choice popup
   osascript <<-EOF
   tell application "Finder"
      activate
      set dd to display dialog "`msg_title`\n\n`msg_confirm_priv`\n" buttons {"YES", "No, thanks"} default button 1 giving up after 30
      set UserResponse to button returned of dd
   end tell
EOF
   ;;
	NO)
# display choice dialog
    msg_title; echo ""; echo ""
    msg_confirm_priv
    /bin/echo -n " [Y/n] "
    read answer
    answer=`echo $answer | sed 's/^[yY].*$/y/'`
    if [ ! -z "$answer" -a "x$answer" != "xy" ]; then
       answer="NO"
    fi
    ;;
    esac
}

msg_choose_priv () {
    echo Please provide your username and password
    echo to check out the private repository
    case $ONCONSOLE in
        YES)
    echo in the following two dialogs.
    echo you can answer \\\"No\\\" here  
    echo and do it later manually.
    ;;
	NO)
    echo "you can answer \"No\" here and do it later manually."
    ;;
    esac
    echo
    /bin/echo -n Continue\?
}

display_choose_priv () {
    case $ONCONSOLE in
        YES)
# display choice popup
   osascript <<-EOF
   tell application "Finder"
      activate
      set dd to display dialog "`msg_title`\n\n`msg_choose_priv`\n" buttons {"OK", "No, thanks"} default button 2 giving up after 30
      set UserResponse to button returned of dd
   end tell
EOF
   ;;
	NO)
# display choice dialog
    msg_title; echo ""; echo ""
    msg_choose_priv
    /bin/echo -n " [N/y] "
    read answer
    answer=`echo $answer | sed 's/^[nN].*$/n/'`
    if [ ! -z "$answer" -a "x$answer" != "xn" ]; then
       answer="YES"
    fi
    ;;
    esac
}

display_choose_priv_do () {
# propose to check out priv:
    case $ONCONSOLE in
        YES)
	    answer=`display_choose_priv`
	    ;;
		NO)
	    display_choose_priv
	    ;;
	esac
	if [ "$answer" == "YES" ]; then
	svnco=`cd "$GTPARENT" && svn co https://victorio.uit.no/private/trunk priv`
		if [ svnco == 0 ] ; then
		    Result="\n The private part of the Giellatekno resources \
have been checked out in $GTPARENT/big.\n\"
		else
		    Result="\n
Something went wrong when checking out the biggies
repository. Please try to run this command manually:\n
\n
cd $GTPARENT && svn co https://victorio.uit.no/private/trunk priv\n"
		fi		    
    else
		Result="OK, as you wish.\nYou are on your own. Good luck.\n
\n
If you want to do it manually later, try this command:
\n
cd $GTPARENT && svn co https://victorio.uit.no/private/trunk priv\n
\n
\nYou will be asked for username and password." 
    fi
    display_result
}

display_setup_priv () {
    case $ONCONSOLE in
        YES)
        answer=`display_main_big_setup`
        ;;
        NO)
        display_main_big_setup
        ;;
    esac
    if [ "$answer" == "Continue" ]; then
       setup_priv
    fi
}

setup_priv () {
    if [ "$PRIV_EXISTS" == "YES" ]; then
        confirm_priv_do
    else
        display_choose_priv_do
    fi
}

confirm_priv_do () {
# propose to add existing priv dir as GTPRIV:
    case $ONCONSOLE in
        YES)
	    answer=`display_confirm_priv`
	    ;;
		NO)
	    display_confirm_priv
	    ;;
	esac
	if [ "$answer" == "YES" ]; then
		echo "$PRIVCMD" >> $HOME/$RC
		. $HOME/$RC
    	do_login_test
    	if grep GTPRIV $TMPFILE >/dev/null 2>&1 ; then
    	    Result="\n Your Giellatekno setup should be fine now.\n\n"
		else
		    Result="\n
Something went wrong when setting up \$GTPRIV.

Please add text equivalent to the
following to your $RC file:\n
		
export GTPRIV=$GTPRIV
"

		fi		    
    else
		Result="OK, as you wish.\nYou are on your own. Good luck\n" 
    fi
    display_result
}
