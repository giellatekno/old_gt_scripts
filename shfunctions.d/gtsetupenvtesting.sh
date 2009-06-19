# -*-Shell-script-*-
# Common GT scripts to test and set the basic environment requirements
# $Id$

set_gthome () {
# GTHOME is loc. of script + ../../
# set_gthome is robust wrt to spaces in dirnames, and also from
# where the script is called (ie it can be called from anywhere).

# First we need to find the full pathname from the root
# to the script file:
	dirname=$(dirname "$0")
	pwd=$(pwd)
#	if dirname = '.' then $pwd contains the full path:
	if [ "$dirname" == "." ]; then
		tmp=$pwd
#	else if pwd = '/' then $dirname contains the full path:
	elif [ "$pwd" == "/" ]; then
		tmp=$dirname
#	else concatenate $pwd and $dirname with a / in between:
	else
		tmp="$pwd/$dirname"
	fi
# Now tmp contains the full path to the setup script, and we
# remove the last 2 dirs to get GTHOME:
	tmp2="${tmp%/*}"
	GTHOME="${tmp2%/*}"
	GTPARENT="${GTHOME%/*}"
	echo
	echo "*** Please be patient, this first step might take a few seconds... ***"
	echo
    do_big_exists
    do_priv_exists
}

do_isconsole () {
# Test whether we can use Finder popup windows
    ONCONSOLE=NO
    /bin/ps x -U $USER | grep Finder | grep -v grep >/dev/null && ONCONSOLE=YES
    [ "x$SCRIPT_NAME" = "xpostflight" ] && ONCONSOLE=YES 
}

do_login_test () {
# Start a login session to see whether the PATH is already set up for
# the Giellatekno tools.
# PATH and SHELL are written into TMPFILE.
# We have to use basic shell speak here, because we don't know
# which shell will come up.
    /bin/echo -n LOGINSHELL= >$TMPFILE
    /usr/bin/printenv SHELL >>$TMPFILE
    /usr/bin/printenv PATH >>$TMPFILE
    /usr/bin/printenv >>$TMPFILE
}

do_big_exists () {
# Check whether there exists a directory parallell to GTHOME that seems to
# contain the biggies.
# "tts" is used as the test case - it only exists at the immediate
# level below the working copy root in the biggies repository.
# -maxdepth -mindepth is used because of a bug with -depth n on victorio
    BIGDIR=`find $GTPARENT -maxdepth 2 -mindepth 2 -name tts 2> /dev/null`
    # if nothing is found, it can be because the trunk dir was checked out
    # as well - thus checking one level further down:
    if [ "$BIGDIR" == "" ] ; then
        BIGDIR=`find $GTPARENT -maxdepth 3 -mindepth 3 -name tts 2> /dev/null`
    fi
    if [ "$BIGDIR" != "" ] ;
    then
        BIG_EXISTS=YES
        GTBIG=${BIGDIR%/*}
    else
        BIG_EXISTS=NO
        GTBIG=$GTPARENT/big
    fi
}

do_priv_exists () {
# Check whether there exists a directory parallell to GTHOME that seems to
# contain a working copy of the private repository.
# "polderland" is used as the test case - it only exists at the immediate
# level below the working copy root in the private repository.
    PRIVDIR=`find $GTPARENT -maxdepth 2 -mindepth 2 -name polderland 2> /dev/null`
    if [ "$PRIVDIR" == "" ] ; then
        PRIVDIR=`find $GTPARENT -maxdepth 3 -mindepth 3 -name polderland 2> /dev/null`
    fi
    if [ "$PRIVDIR" != "" ] ;
    then
        PRIV_EXISTS=YES
        GTPRIV=${PRIVDIR%/*}
    else
        PRIV_EXISTS=NO
        GTPRIV=$GTPARENT/priv
    fi
}

make_RC_backup () {
    cp -f $HOME/$RC $HOME/$RC.$BACKUPSUFF
    grep -v 'gt/script/init.d/init\..*sh' $HOME/$RC > $HOME/$RC.$NEWSUFF
}

msg_undo () {
    echo
    echo No changes were made. The $RC.$BACKUPSUFF
    echo and $RC.$NEWSUFF files have been
    echo deleted. Your $RC file is untouched.
    echo
    echo Please rerun the script later, or modify
    echo your $RC file manually.
    echo
}

display_undo (){
    case $ONCONSOLE in
        YES)
    osascript <<-EOF
    tell application "Finder"
	activate
	set dd to display dialog "`msg_title`\n\n`msg_undo`" buttons {"OK"} default button 1 giving up after 20 
    set UserResponse to button returned of dd
    end tell
EOF
    ;;
	NO)
    msg_title; echo""; msg_undo
    ;;
    esac
}

undo_setup () {
    rm -f $HOME/$RC.$BACKUPSUFF
    rm -f $HOME/$RC.$NEWSUFF
    display_undo
}
