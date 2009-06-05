#!/bin/sh 
#
# Shell script for preparing the user's shell startup scripts for Giellatekno

# Giellatekno - a set of tools for analysing and processing a number
#               of human languages, expecially but not restricted to
#               the Sámi languages. The Giellatekno toolset also includes
#               support for buildling end-user tools such as proofing
#               tools and electronic dictionaries.
# The setup and init scripts (ao this file) are based on similar scripts
#               from the Fink project (http://www.finkproject.org/).
# This file is based on the file /sw/bin/pathsetup.sh in the Fink distro.
# Copyright (c) 2003-2005 Martin Costabel
# Copyright (c) 2003-2007 The Fink Package Manager Team
# Copyright (c) 2009 The Divvun and Giellatekno teams
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#


# This version is tested for csh type user login shells and for bash, 
# for other sh type shells it does nothing.

# export GTHOME=~/langtech/main
# export GTPRIV=~/langtech/priv
# export GTBIG=~/langtech/big
# 


# Function declarations:

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
    /usr/bin/login -f $USER >$TMPFILE <<"EOF"
    /bin/echo -n LOGINSHELL= 
    /usr/bin/printenv SHELL
    /usr/bin/printenv PATH
    /usr/bin/printenv
    /bin/bash --norc --noprofile <<EOF2
#   For bash, we need a second opinion. 
#   We do the test for bash inside bash.
    if test $(/bin/echo $SHELL | /usr/bin/grep bash); then
	bash --login <<EOF3
        /usr/bin/printenv PATH
        /usr/bin/printenv
	exit
EOF3
    fi
    exit
EOF2
    exit
EOF
}

msg_title () {
    echo ---------------------------------------
    echo Setting up your Giellatekno environment
    echo ---------------------------------------
}

msg_create () {
    echo I will create a file named $RC in your
    echo home directory, containing the lines:
    echo
    case $ONCONSOLE in
        YES)
    echo \\\"$SOURCECMD\\\"
    ;;
        NO)
    echo "   \"$SOURCECMD\""
    ;;
    esac
}

msg_append () {
    echo I will append the lines:
    echo
    case $ONCONSOLE in 
	YES)
    echo \\\"$SOURCECMD\\\"
    ;;
	NO)
    echo "   \"$SOURCECMD\""
    ;;
    esac
    echo
    echo to the file $RC in your home directory.
}		       

msg_choose () {
    echo If you do not want me to do this, 
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

src_command_csh () {
    SOURCECMD="\
setenv GTHOME $GTHOME \n\
\n\
test -r $GTHOME/gt/script/init.d/init.csh && \
source $GTHOME/gt/script/init.d/init.csh\n"
}

src_command_sh () {
    SOURCECMD="\
export GTHOME=$GTHOME \n\
\n\
test -r $GTHOME/gt/script/init.d/init.sh && . $GTHOME/gt/script/init.d/init.sh\n"
}

link_biggies () {
    echo "Test!"
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
    read -t 20 answer
    answer=`echo $answer | sed 's/^[nN].*$/n/'`
    if [ ! -z "$answer" -a "x$answer" != "xn" ]; then
       answer="YES"
    fi
    ;;
    esac
}

display_choose () {
    case $ONCONSOLE in
        YES)
# display choice popup
   osascript <<-EOF
   tell application "Finder"
      activate
      set dd to display dialog "`msg_title`\nYour login shell: $LOGINSHELL\n\n`$MSG` \n\n`msg_choose`\n" buttons {"No, thanks", "YES"} default button 2 giving up after 30
      set UserResponse to button returned of dd
   end tell
EOF
   ;;
	NO)
# display choice dialog
    msg_title; echo "Your login shell: $LOGINSHELL"; echo ""
    $MSG; echo ""
    msg_choose
    /bin/echo -n " [Y/n] "
    read -t 20 answer
    answer=`echo $answer | sed 's/^[yY].*$/y/'`
    if [ ! -z "$answer" -a "x$answer" != "xy" ]; then
       answer="No, thanks"
    fi
    ;;
    esac
}

display_result () {
# display final result
    case $ONCONSOLE in
        YES)
   osascript <<-EOF
   tell application "Finder"
      activate
      set dd to display dialog "`msg_title`\n$Result\n" buttons {"OK"} default button 1 with icon caution giving up after 20
      set UserResponse to button returned of dd
   end tell
EOF
   ;;
	NO)
   printf "$Result" 
   ;;
    esac
}

display_choose_big_do (){
# propose to check out big, append line to startup script, and verify if it worked
    case $ONCONSOLE in
        YES)
	    answer=`display_choose_big`
	    ;;
		NO)
	    display_choose_big
	    ;;
    esac
    if [ "$answer" == "YES" ]; then
#		if svn co xxx && link_biggies ; then
		if [ "" == "" ] ; then
		    Result="\n The Biggies part of the Giellatekno resources \
have been checked out in $GTPARENT/big.\n\
\n\
I also added symbolic links within each language dir to corpus \
resources for testing purposes.\n\nNOT YET TRUE - DUMMY TEXT!!!"
		else
		    Result="\n
Hmm. I tried my best, but it still does not work.
The code I put into $RC has no effect.\n
Please check your $LOGINSHELL startup scripts.
Perhaps some other file like\n
	    ~/.login\n
is resetting the PATH after $RC is executed.
		   \n"
		fi		    
    else
		Result="OK, as you wish.\nYou are on your own. Good luck\n" 
    fi
    display_result
}

display_choose_do (){
# propose choice, append line to startup script, and verify if it worked
    case $ONCONSOLE in
        YES)
    answer=`display_choose`
    ;;
	NO)
    display_choose
    ;;
    esac
    if [ "$answer" != "No, thanks" ]; then
	echo "" >> $HOME/$RC
	echo "$SOURCECMD" >> $HOME/$RC
	chown $USER $HOME/$RC
	do_login_test
	if grep GTHOME $TMPFILE >/dev/null 2>&1 ; then
	    Result="\n Your Giellatekno setup should be fine now.\n\n"
	else
	    Result="\n
Hmm. I tried my best, but it still does not work.
The code I put into $RC has no effect.\n
Please check your $LOGINSHELL startup scripts.
Perhaps some other file like\n
	    ~/.login\n
is resetting the PATH after $RC is executed.
		   \n"
	fi		    
    else
	Result="OK, as you wish.\nYou are on your own. Good luck\n" 
    fi
    display_result
}

msg_already_setup (){
    echo Your environment seems to be correctly
    echo set up for Giellatekno already.
}

display_already_setup (){
    case $ONCONSOLE in
        YES)
    osascript <<-EOF
    tell application "Finder"
	activate
	set dd to display dialog "`msg_title`\n\n`msg_already_setup`" buttons {"OK"} default button 1 giving up after 20 
    set UserResponse to button returned of dd
    end tell
EOF
    ;;
	NO)
    msg_title; echo""; msg_already_setup
    ;;
    esac
}
# End of function declarations

### Main program:

# A temporary file for communicating with a login shell 
# mktemp is in different places on mac and linux
if [ -x /usr/bin/mktemp ] || [ -x /bin/mktemp ] ; then
    TMPFILE=`mktemp /tmp/resu.XXXXXX`
fi

# Are we logged in at the console?
do_isconsole

# Run a login shell to see whether the Giellatekno paths are already set up.
do_login_test

# Where am I? In the scripts/ catalog within what is becoming GTHOME:
set_gthome

# Look whether /sw/sbin was in the PATH. 
# TODO: Test for other sensible things, too. 
if grep GTHOME $TMPFILE >/dev/null 2>&1 ; then
    # Yes: already set up
    display_already_setup
else
    # No: we need to do something
    eval `grep LOGINSHELL $TMPFILE`
    if [ -z $LOGINSHELL ]; then
		Result="\nYour startup scripts contain an error.\nI am giving up. Bye.\n"
		display_result
		exit
    fi
    LOGINSHELL=`basename $LOGINSHELL`
    case $LOGINSHELL in
    *csh)
	    # For csh and tcsh
        src_command_csh
        if [ -f $HOME/.tcshrc ]; then
		    RC=.tcshrc
		elif [ -f $HOME/.cshrc ]; then
		    RC=.cshrc
		else
		    RC=new
		fi
	 	case $RC in
		new)
		    RC=.cshrc
		    MSG=msg_create
		    ;;
		*)
		    MSG=msg_append
		    ;;
		esac
		display_choose_do
		display_choose_big_do
	    ;;
    bash)
	    # Only bash here; other sh type shells are not supported
        src_command_sh
        if [ -f $HOME/.bash_profile ]; then
		    RC=.bash_profile
		elif [ -f $HOME/.bash_login ]; then
		    RC=.bash_login
        elif [ -f $HOME/.profile ]; then
		    RC=.profile
        elif [ -f $HOME/.bashrc ]; then
		    RC=.bashrc
		else
		    RC=new
		fi
		case $RC in
		  new)
		    RC=.profile
		    MSG=msg_create
		  ;;
		  *)
		    MSG=msg_append
		  ;;
		esac
		display_choose_do
		display_choose_big_do
	    ;;
    *)
    # Any shell except *csh and bash
	Result="\n
Since you have changed your login shell to $LOGINSHELL,
I am confident that you know what you are doing.\n
So now add lines equivalent to
		
	GTHOME=$GTHOME
	export GTHOME
	source \$GTHOME/gt/script/init.d/init.sh

to one of your $LOGINSHELL startup scripts
and you will be set up for using the Giellatekno tools.
	    
    Have a nice day.
	    \n"
	display_result
    ;;
    esac	    
fi

rm -f $TMPFILE

# End of program.
