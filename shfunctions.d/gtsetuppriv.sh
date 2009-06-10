# -*-Shell-script-*-
# GT setup functions to set up the private repository.
# $Id:jmx-settings.sh 7231 2008-01-14 22:33:35Z wolfgang_m $

msg_choose_priv () {
    echo The Giellatekno code base also contain some
    echo rather private files that are not required
    echo in most cases. They are helpful when doing
    echo proofing tools testing, and speech technology
    echo development.
    echo
    echo Do you want me to check out this optional
    echo code block for you? It is about 500 Mb downloaded data,
    echo and will occupy roughly 1 Gb on your disk.
    echo The default is to NOT check out this part.
    case $ONCONSOLE in
        YES)
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

priv_command_csh () {
    PRIVCMD="\
setenv GTPRIV $GTPRIV"
}

priv_command_sh () {
    PRIVCMD="\
export GTPRIV=$GTPRIV"
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

display_choose_priv () {
    case $ONCONSOLE in
        YES)
# display choice popup
   osascript <<-EOF
   tell application "Finder"
      activate
      set dd to display dialog "`msg_title`\n\n`msg_choose_priv`\n" buttons {"YES", "No, thanks"} default button 2 giving up after 30
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
	svnco=`cd "$GTPARENT" && svn co https://victorio.uit.no/biggies/trunk big`
	link_biggies
		if [ svnco == 0 ] ; then
		    Result="\n The Biggies part of the Giellatekno resources \
have been checked out in $GTPARENT/big.\n\
\n\
I also added symbolic links within each language dir to corpus \
resources for testing purposes."
		else
		    Result="\n
Something went wrong when checking out the biggies
repository. Please try to run this command manually:\n
\n
cd "$GTPARENT" && svn co https://victorio.uit.no/biggies/trunk big\n
\n"
		fi		    
    else
		Result="OK, as you wish.\nYou are on your own. Good luck.\n" 
    fi
    display_result
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
