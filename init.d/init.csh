# init.csh
#
# to use the Giellatekno tools, put the following in your .cshrc:
#
#	setenv GTHOME $GTHOME
#	source \$GTHOME/gt/script/init.d/init.csh
#

#
# Giellatekno - a set of tools for analysing and processing a number
#               of human languages, expecially but not restricted to
#               the Sámi languages. The Giellatekno toolset also includes
#               support for buildling end-user tools such as proofing
#               tools and electronic dictionaries.
# The setup and init scripts (ao this file) are based on similar scripts
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
alias append_path 'if ( $\!:1 !~ \!:2\:* && $\!:1 !~ *\:\!:2\:* && $\!:1 !~ *\:\!:2 && $\!:1 !~ \!:2 ) setenv \!:1 ${\!:1}\:\!:2'
# add to front of path
alias prepend_path 'if ( $\!:1 !~ \!:2\:* && $\!:1 !~ *\:\!:2\:* && $\!:1 !~ *\:\!:2 && $\!:1 !~ \!:2 ) setenv \!:1 \!:2\:${\!:1}; if ( $\!:1 !~ \!:2\:* ) setenv \!:1 \!:2`echo \:${\!:1} | /usr/bin/sed -e s%^\!:2\:%% -e s%:\!:2\:%:%g -e s%:\!:2\$%%`'

# setup the Giellatekno path. We assume that the Giellatekno directory exists.
if ( $?PATH ) then
    prepend_path PATH $GTHOME/gt/script
else
    setenv PATH $GTHOME/gt/script:/bin:/sbin:/usr/bin:/usr/sbin
endif

set osMajorVersion = `uname -r | cut -d. -f1`
set osMinorVersion = `uname -r | cut -d. -f2`

if ( -r /sw/share/java/classpath ) then
  if ( $?CLASSPATH ) then
    set add2classpath = `cat /sw/share/java/classpath`
    prepend_path CLASSPATH $add2classpath
  else
    setenv CLASSPATH `cat /sw/share/java/classpath`:.
  endif
endif

if ( $?PERL5LIB ) then
  prepend_path PERL5LIB /sw/lib/perl5:/sw/lib/perl5/darwin
else
  setenv PERL5LIB /sw/lib/perl5:/sw/lib/perl5/darwin
endif

# Add X11 paths (but only if the directories are readable)
if ( -r /usr/X11R6/bin ) then
    append_path PATH /usr/X11R6/bin
endif
if ( -r /usr/X11R6/man ) then
    append_path MANPATH /usr/X11R6/man
endif

# eof
