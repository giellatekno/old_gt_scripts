# init.sh
#
# to use the Giellatekno tools, put the following in your .profile:
#
#  export GTHOME=/Users/sjur/langtech/main 
# . $GTHOME/gt/script/init.sh
#

#
# Giellatekno - a set of tools for analysing and processing a number
#               of human languages, expecially but not restricted to
#               the Sámi languages. The Giellatekno toolset also includes
#               support for buildling end-user tools such as proofing
#               tools and electronic dictionaries.
# The setup and init scripts (ie this file) are based on similar scripts
#               from the Fink project (http://www.finkproject.org/).
# Copyright (c) 2001 Christoph Pfisterer
# Copyright (c) 2001-2004 The Fink Team
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

# define append_path and prepend_path to add directory paths, e.g. PATH, MANPATH.
# add to end of path
append_path()
{
  if ! eval test -z "\"\${$1##*:$2:*}\"" -o -z "\"\${$1%%*:$2}\"" -o -z "\"\${$1##$2:*}\"" -o -z "\"\${$1##$2}\"" ; then
    eval "$1=\$$1:$2"
  fi
}

# add to front of path
prepend_path()
{
  if ! eval test -z "\"\${$1##*:$2:*}\"" -o -z "\"\${$1%%*:$2}\"" -o -z "\"\${$1##$2:*}\"" -o -z "\"\${$1##$2}\"" ; then
    eval "$1=$2:\$$1"
  fi
}

# setup the Giellatekno path. We assume that the Giellatekno directory exists.
if [ -z "$PATH" ]; then
  PATH=$GTHOME/gt/script:/bin:/sbin:/usr/bin:/usr/sbin
else
  prepend_path PATH $GTHOME/gt/script
fi
export PATH

osMajorVer=`uname -r | cut -d. -f1`
osMinorVer=`uname -r | cut -d. -f2`

if [ -r /sw/share/java/classpath ]; then
  if [ -z "$CLASSPATH" ]; then
    CLASSPATH=`cat /sw/share/java/classpath`:.
  else
    add2classpath=`cat /sw/share/java/classpath`
    prepend_path CLASSPATH $add2classpath
  fi
  export CLASSPATH
fi

if [ -z "$PERL5LIB" ]; then
  PERL5LIB=/sw/lib/perl5:/sw/lib/perl5/darwin
else
  prepend_path PERL5LIB /sw/lib/perl5:/sw/lib/perl5/darwin
fi
export PERL5LIB

# eof
