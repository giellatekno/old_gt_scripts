#!/bin/bash
#
# Based on:
# http://www.drunkenfist.com/304/2009/02/11/code-i-like-batch-subversion-rename-replace-underscore-with-hyphen-bash-script/
# and:
# http://www.ibm.com/developerworks/linux/library/l-sed2.html
#
# Used to batch rename files under version control.
# Adapt the find pattern and regular expression substitution to match your needs:
for i in `find *-20*.xml`; do
     svn mv $i `echo $i | sed 's/^\(.*\)-.*-.*-\(20.*\)\(.xml\)$/\2-\1\3/g'`;
done
