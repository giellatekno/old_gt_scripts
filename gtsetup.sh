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

# The following environmental variables are defined:
#
# export GTHOME=~/langtech/main   # always
# export  GTBIG=~/langtech/big    # if the biggies repository is checked out
# export GTPRIV=~/langtech/priv   # if the private repository is checked out
# 


# Where am I:
case "$0" in
	/*)
		SCRIPTPATH=$(dirname "$0")
		;;
	*)
        PWD=`pwd`
		SCRIPTPATH=$(dirname "$PWD/$0")
		;;
esac

# source common functions and settings
source "${SCRIPTPATH}"/shfunctions.d/gtsetupenvtesting.sh
source "${SCRIPTPATH}"/shfunctions.d/gtsetupcommondialogs.sh
source "${SCRIPTPATH}"/shfunctions.d/gtsetupmain.sh
source "${SCRIPTPATH}"/shfunctions.d/gtsetupbiggies.sh
source "${SCRIPTPATH}"/shfunctions.d/gtsetuppriv.sh


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

# Set GTHOME based on the location of this setup script.
# Does also check for the existence of big and private working copies.
set_gthome

# Check whether the environment is already in place:
if grep GTHOME $TMPFILE >/dev/null 2>&1 ; then
    main_setup_done=YES
fi
if grep GTBIG $TMPFILE >/dev/null 2>&1 ; then
    big_setup_done=YES
fi
if grep GTPRIV $TMPFILE >/dev/null 2>&1 ; then
    priv_setup_done=YES
fi

# Look whether $GTHOME was in the ENV.
# TODO: Test for other sensible things, too. 
if ( [ "$main_setup_done" == "YES" ] &&
     [ "$big_setup_done"  == "YES" ] &&
     [ "$priv_setup_done" == "YES" ]   ) ; then
    # Yes: everything is already set up
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
        big_command_csh
        priv_command_csh
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
        big_command_sh
        priv_command_sh
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
		if [ "$main_setup_done" == "YES" ]; then
            if [ "$big_setup_done" == "YES" ]; then
                # Set up priv only, the rest is ok:
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
            else
                # Set up big and priv:
                echo "test"
            fi
        else
            # set up all three:
    		display_choose_do
    		display_choose_big_do
        fi
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
