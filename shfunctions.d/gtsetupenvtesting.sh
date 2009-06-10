# -*-Shell-script-*-
# Common GT scripts to test and set the basic environment requirements
# $Id:jmx-settings.sh 7231 2008-01-14 22:33:35Z wolfgang_m $

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

#Pseudocode:
# ls GTPARENT
# for each dir except GTHOME, ls inside it
# if ls returns tts, then yes, else no
    BIG_EXISTS=NO
    GTBIG=$GTPARENT/big
}

do_priv_exists () {
# Check whether there exists a directory parallell to GTHOME that seems to
# contain a working copy of the private repository.
    PRIV_EXISTS=NO
    GTPRIV=$GTPARENT/private

    gtparentsdirs=`ls $GTPARENT | grep '/' `
    Result="This should be a list of dirs: $gtparentsdirs"
    display_result
    for dir in $gtparentsdirs ; do
        echo $dir
        if `ls $GTPARENT/$dir | grep polderland` ; then
            PRIV_EXISTS=YES
            GTPRIV=$GTPARENT/$dir
            exit
        fi
    done
}
