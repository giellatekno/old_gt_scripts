# init.sh
#
# to use the Giellatekno tools, please run the script
#
#  gt/script/gtsetup.sh
#
# That script will set up a number of environmental variables,
# and make sure this file is read as part of the login process.

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

# Add predefined lookup aliases for all languages:
. $GTHOME/gt/script/init.d/lookup-init.sh

# Alias for svn update
alias svnup="svn up $GTHOME $GTBIG $GTFREE $GTPRIV"

# Standardised aliases for Giellatekno work:
alias victorio='ssh victorio.uit.no'
alias vic='ssh victorio.uit.no'
alias g5='ssh divvun.no'
alias xs='ssh divvun.no'

# forrest run port 8 og 9
alias fo="forrest     -Dforrest.jvmargs=\"-Dfile.encoding=utf-8 -Djava.awt.headless=true\""
alias f8="forrest run -Dforrest.jvmargs=\"-Dfile.encoding=utf-8 -Djava.awt.headless=true\""
alias f9="forrest run -Dforrest.jvmargs=\"-Dfile.encoding=utf-8 -Djava.awt.headless=true -Djetty.port=8889\""
alias f7="forrest run -Dforrest.jvmargs=\"-Dfile.encoding=utf-8 -Djava.awt.headless=true -Djetty.port=8887\""

alias  saxonXQ="java -Xmx2048m net.sf.saxon.Query"
alias saxonXSL="java -Xmx2048m net.sf.saxon.Transform"
alias xquery="saxonXQ"
alias xslt2="saxonXSL"
alias xsl2="saxonXSL"

# Unicode/UTF-8 aware rev:
alias rev="perl -nle 'print scalar reverse \$_'"

# utility command
alias path='echo -e ${PATH//:/\\n}'

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

# setup the path to private bins if $GTPRIV is defined:
if [ -n "$GTPRIV" ]; then
  prepend_path PATH $GTPRIV/polderland/bin
fi
export PATH

osMajorVer=`uname -r | cut -d. -f1`
osMinorVer=`uname -r | cut -d. -f2`

# add Saxon to the classpath with a default location of ~/lib/, and a default name
# saxon9.jar
if [ -z "$CLASSPATH" ]; then
  CLASSPATH=~/lib/saxon9.jar
else
  prepend_path CLASSPATH ~/lib/saxon9.jar
fi
export CLASSPATH

# Perl setup:
export PERL_UNICODE=""
if [ -z "$PERL5LIB" ]; then
  PERL5LIB=$GTHOME/gt/script
else
  prepend_path PERL5LIB $GTHOME/gt/script
fi
export PERL5LIB

# If MacPorts is installed, make sure it is also available in the environment.
# This is especially important on the XServe.
if [ -d /opt/local/bin ]; then
	export PATH=/opt/local/bin:/opt/local/sbin:${PATH}
	export MANPATH=/opt/local/share/man:${MANPATH}
	export INFOPATH=/opt/local/share/info:${INFOPATH}
fi

# This environment variable will by default exclude the .svn subdirs from being
# searched when grepping files, which is almost always what you want.
# It requires at least GNU grep 2.5.3. Default on Snow Leopard is 2.5.0, via
# MacPorts GNU grep 2.7.0 or newer is available
#export GREP_OPTIONS="--exclude-dir=\.svn"
