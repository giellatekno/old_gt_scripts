# -*-Shell-script-*-
# GT setup functions to set up the big repository.
# $Id$

msg_choose_big () {
    echo The Giellatekno code base also contain some rather big 
    echo files that are not required in most cases. They are helpful
    echo when doing proofing tools testing, and speech technology
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

big_command_csh () {
    BIGCMD="\
setenv GTBIG $GTBIG"
}

big_command_sh () {
    BIGCMD="\
export GTBIG=$GTBIG"
}

display_choose_big () {
    case $ONCONSOLE in
        YES)
# display choice popup
   osascript <<-EOF
   tell application "Finder"
      activate
      set dd to display dialog "`msg_title`\n\n`msg_choose_big`\n" buttons {"YES", "No, thanks"} default button 2 giving up after 30
      set UserResponse to button returned of dd
   end tell
EOF
   ;;
	NO)
# display choice dialog
    msg_title; echo ""; echo ""
    msg_choose_big
    /bin/echo -n " [N/y] "
    read answer
    answer=`echo $answer | sed 's/^[nN].*$/n/'`
    if [ ! -z "$answer" -a "x$answer" != "xn" ]; then
       answer="YES"
    fi
    ;;
    esac
}

link_biggies () {
	ln -s $GTBIG/gt/sme/corp $GTHOME/gt/sme/
}

display_choose_big_do () {
# propose to check out big:
    case $ONCONSOLE in
        YES)
	    answer=`display_choose_big`
	    ;;
		NO)
	    display_choose_big
	    ;;
	esac
    if [ "$answer" == "YES" ]; then
#		svnco=`cd "$GTPARENT" && svn co https://victorio.uit.no/biggies/trunk big`
		link_biggies
		echo "" >> $HOME/$RC
		echo "$BIGCMD" >> $HOME/$RC
		if [ svnco == 0 ] ; then
		    Result="\n The Biggies part of the Giellatekno resources \
have been checked out in $GTPARENT/big.\n\
\n\
I also added symbolic links within some language dirs to corpus \
resources for testing purposes. Check out gt/LANG/zcorp/."
		else
		    Result="\n
Something went wrong when checking out the biggies
repository. Please try to run this command manually:\n
\n
cd "$GTPARENT" && svn co https://victorio.uit.no/biggies/trunk big\n
\n"
		fi		    
    else
		Result="OK, as you wish.\nYou are on your own. Good luck\n" 
    fi
    display_result
}

