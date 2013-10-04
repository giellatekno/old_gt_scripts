#!/bin/ksh
#$Id: svn_wrapper 7144 2011-05-20 12:10:41Z bannima $
##############################################################################
#
# Wrapper for Subversion client that sets up an 'svn' keyring and launches
# gnome-keyring-daemon as and when required
#
# Author: Mark R. Bannister <mark@proseconsulting.co.uk>
# Date: 5th April 2011
#
# Run with --gkd-help for options accepted by this wrapper script
#
# Run with --gkd-info to report if the keyring daemon is currently running
#
# Run with --gkd-logout in your shell logout script to ensure that the
# gnome-keyring-daemon user process is killed if you have no remaining
# login sessions on the host
#
# Run with --gkd-kill manually if, for some reason, you would like to kill
# the running gnome-keyring-daemon
#
# Set SVN_WRAPPER_DEBUG=1 for debug information
#
##############################################################################
CALL=$(basename $0)
OS_PLATFORM=$(uname -s)
HOST=$(uname -n)
KRTOOL=keyring_tool
GKD=gnome-keyring-daemon
SVN=svn
[ -z "$HOME" ] && HOME=~
SVN_DIR=$HOME/.subversion
SVN_CONFIG=$SVN_DIR/config
SVN_SERVERS=$SVN_DIR/servers
SVN_AUTH=$SVN_DIR/auth
GKD_STATE=$SVN_DIR/$CALL.$HOST
GKD_LOG=$SVN_DIR/$CALL.$HOST.log
TMPFILE=/tmp/tmp.$CALL.$$

trap 'rm -f $TMPFILE; exit' INT HUP TERM

AWK=/bin/gawk
[ -x /bin/nawk ] && AWK=/bin/nawk

SVN_WRAPPER_DEBUG=${SVN_WRAPPER_DEBUG:=0}

#
# The GNU xargs utility is better than the Solaris one,
# so use gxargs if at all possible on Solaris, otherwise
# svn will not be able to grab stdin when it needs to
#
XARGS=xargs
if [ $OS_PLATFORM = SunOS ]; then
    if [ -x /opt/csw/bin/gxargs ]; then
	XARGS=/opt/csw/bin/gxargs
	GNU_XARGS=1	# This is GNU xargs or compatible
    else
	GNU_XARGS=0	# This is not GNU xargs
    fi
else
    GNU_XARGS=1		# This is GNU xargs or compatible
fi

#
# Name of default keyring will contain the OS platform
# to work around incompatibilities between the GNOME keyring
# on Solaris and Linux, so we'll have one keyring per platform
#
GKD_KEYRING=svn_$(echo $OS_PLATFORM | tr '[A-Z]' '[a-z]')

##############################################################################
# Load_gkd_state()
#
# Load state variables for gnome-keyring-daemon into environment
##############################################################################
function Load_gkd_state
{
    export GNOME_KEYRING_PID=
    if [ -f $GKD_STATE ]; then
	[ $SVN_WRAPPER_DEBUG -eq 1 ] &&
	    echo $CALL: debug: sourcing $GKD_STATE >&2

	set -a
	. $GKD_STATE
	set +a
    fi
}

##############################################################################
# Is_gkd_running()
#
# Tests if gnome-keyring-daemon is already running for this user
# Returns 0 if the daemon is running, 1 otherwise
##############################################################################
function Is_gkd_running
{
    typeset psname

    if [ $OS_PLATFORM = SunOS ]; then
	psname=$(ls -l /proc/$GNOME_KEYRING_PID/path/a.out 2> /dev/null |
			    $AWK '{print $NF}')
    else
	psname=$(ls -l /proc/$GNOME_KEYRING_PID/exe 2> /dev/null |
			    $AWK '{print $NF}')
    fi

    [ "$psname" != $GKD ] && return 1
    return 0
}

##############################################################################
# Do_gkd_start()
#
# Starts the GNOME Keyring Daemon
# Only do this if Is_gkd_running() returns 1
##############################################################################
function Do_gkd_start
{
    [ $SVN_WRAPPER_DEBUG -eq 1 ] && echo $CALL: debug: starting $GKD >&2
    nohup $GKD > $GKD_STATE 2> $GKD_LOG
    set -a
    . $GKD_STATE
    set +a
}

##############################################################################
# Do_gkd_info()
#
# Display info about running gnome-keyring-daemon
##############################################################################
function Do_gkd_info
{
    #
    # Load environment variables
    #
    Load_gkd_state

    if Is_gkd_running; then
	echo $CALL: $GKD is running, pid $GNOME_KEYRING_PID >&2
	return 0
    else
	echo $CALL: $GKD is not running >&2
	return 1
    fi
}

##############################################################################
# Do_gkd_kill()
#
# Kill the gnome-keyring-daemon
#
# If arg is 0, kills the daemon regardless
#	 if 1, the user is logging out, only kill the daemon if the user
#		will have no further active login sessions
##############################################################################
function Do_gkd_kill
{
    typeset -i logout=$1

    if [ $SVN_WRAPPER_DEBUG -eq 1 ]; then
	case $logout in
	    0) echo $CALL: debug: --gkd-kill >&2;;
	    1) echo $CALL: debug: --gkd-logout >&2;;
	esac
    fi

    #
    # Load environment variables
    #
    Load_gkd_state

    #
    # Exit immediately if the daemon is not running
    #
    Is_gkd_running || return 0

    #
    # Exit immediately if this user has other open terminals
    # (when --gkd-logout, but ignore this test if --gkd-kill)
    #
    if [ $logout -eq 1 ]; then
	[ -z "$USER" ] && USER=$(id | $AWK -F'[()]' '{print $2}')
	[ $(w -h $USER | wc -l) -gt 1 ] && return 0
    else
	SVN_WRAPPER_DEBUG=1
    fi

    [ $SVN_WRAPPER_DEBUG -eq 1 ] &&
	echo $CALL: debug: kill $GKD pid $GNOME_KEYRING_PID >&2

    kill $GNOME_KEYRING_PID
    rm -f $GKD_STATE $GKD_LOG
    return 0
}

##############################################################################
# Do_gkd_clear()
#
# Clear any passwords cached by the Subversion client
##############################################################################
function Do_gkd_clear
{
    if [ $SVN_WRAPPER_DEBUG -eq 1 ]; then
	echo $CALL: debug: --gkd-clear >&2
	echo $CALL: debug: rm -f $SVN_AUTH/svn.simple/* >&2
    fi
    rm -f $SVN_AUTH/svn.simple/*
    return 0
}

##############################################################################
# Do_gkd_help()
#
# Display help message
##############################################################################
function Do_gkd_help
{
    cat << EOF
Syntax: $CALL <svn arguments> ...
        $CALL --gkd-help
        $CALL --gkd-info
        $CALL --gkd-logout
        $CALL --gkd-kill
        $CALL --gkd-clear

Launches Subversion client with GNOME Keyring support.  If a keyring
daemon for this user is not already running, it will be started.
Set-up an alias for svn to call svn_wrapper instead.

Arguments accepted by this wrapper script:
    --gkd-help     display this help page
    --gkd-info     report if keyring daemon is running
    --gkd-logout   call from .bash_logout to kill keyring daemon
    --gkd-kill     manually kill keyring daemon
    --gkd-clear    removes all passwords cached by the Subversion client

Set and export SVN_WRAPPER_DEBUG=1 for debug information.
EOF
    return 0
}

##############################################################################
# START HERE
##############################################################################

case x$1 in
    x--gkd-help)
	Do_gkd_help;
	exit $?;;

    x--gkd-info)
	Do_gkd_info;
	exit $?;;

    x--gkd-kill)
	Do_gkd_kill 0;
	exit $?;;

    x--gkd-logout)
	Do_gkd_kill 1;
	exit $?;;

    x--gkd-clear)
	Do_gkd_clear;
	exit $?;;
esac

if [ $OS_PLATFORM = SunOS ]; then
    #
    # Create .gnome2 in user's home directory if this system
    # is not running GNOME already
    #
    if [ ! -d $HOME/.gnome2 ]; then
	[ $SVN_WRAPPER_DEBUG -eq 1 ] &&
	    echo $CALL: debug: mkdir $HOME/.gnome2 >&2

	mkdir $HOME/.gnome2
    fi
    chmod 700 $HOME/.gnome2
fi

#
# Create SVN_DIR if missing
#
if [ ! -d $SVN_DIR ]; then
    [ $SVN_WRAPPER_DEBUG -eq 1 ] && echo $CALL: debug: mkdir $SVN_DIR >&2
    mkdir -p $SVN_DIR
fi

#
# Load environment variables
#
Load_gkd_state

Is_gkd_running || Do_gkd_start

[ $SVN_WRAPPER_DEBUG -eq 1 ] &&
    echo $CALL: debug: $GKD pid $GNOME_KEYRING_PID >&2

#
# Check that the svn keyring is set-up
#
if [ "$($KRTOOL -g)" != $GKD_KEYRING ]; then
    # Keyring is not default

    if [ $($KRTOOL -t | grep -c "^$GKD_KEYRING\$") -eq 0 ]; then
	# Keyring does not exist
	[ $SVN_WRAPPER_DEBUG -eq 1 ] &&
	    echo "$CALL: debug: creating '$GKD_KEYRING' keyring" >&2

	echo "Creating new '$GKD_KEYRING' keyring" >&2
	$KRTOOL --create=$GKD_KEYRING
    fi

    [ $SVN_WRAPPER_DEBUG -eq 1 ] &&
	echo "$CALL: debug: setting '$GKD_KEYRING' keyring as default" >&2

    $KRTOOL --setdef=$GKD_KEYRING
fi

#
# Warn if Subversion client is not set-up correctly
#
if [ -f $SVN_CONFIG ]; then
    [ $(grep -c '^password-stores *=.*gnome-keyring' $SVN_CONFIG) -eq 0 ] &&
	echo "$CALL: warning: set 'password-stores = gnome-keyring' in $SVN_CONFIG" >&2
fi

if [ -f $SVN_SERVERS ]; then
    [ $(grep -c '^store-passwords *=.*yes' $SVN_SERVERS) -eq 0 ] &&
	echo "$CALL: warning: set 'store-passwords = yes' in $SVN_SERVERS" >&2

    [ $(grep -c '^store-plaintext-passwords *=.*no' $SVN_SERVERS) -eq 0 ] &&
	echo "$CALL: warning: set 'store-plaintext-passwords = no' in $SVN_SERVERS" >&2
fi

#
# Check there are no plaintext passwords in the Subversion auth cache
#
for file in $SVN_AUTH/svn.simple/*; do
    [ ! -f $file ] && continue
    [ $(grep -c ^simple $file) -gt 0 ] &&
	echo $CALL: warning: $file contains a plaintext password, you should delete this file >&2
done

[ $SVN_WRAPPER_DEBUG -eq 1 ] && echo "$CALL: debug: launching $SVN" >&2
if [ $GNU_XARGS -eq 1 ]; then
    i=1
    while [ $i -le $# ]; do
	eval printf \"%s\\0\" \"\$\{$i\}\"
	((i+=1))
    done > $TMPFILE
else
    i=1
    while [ $i -le $# ]; do
	eval echo \$\{$i\}
	((i+=1))
    done | sed -e "s/'/\\\\'/g" -e "s/^/'/" -e "s/$/'/" > $TMPFILE
fi

if [ $GNU_XARGS -eq 1 ]; then
    $XARGS -0a $TMPFILE $SVN
    retval=$?
else
    $XARGS $SVN < $TMPFILE
    retval=$?
fi

rm -f $TMPFILE
exit $retval
