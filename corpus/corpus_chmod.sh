#!/bin/bash

#****************************************************************
#			corpus_chmod.sh
#			written by Saara Huhmarniemi
#			Apr 7, 2006
#
#           Fix the permissions of the corpus directories
#
# $Id$
#****************************************************************

# Change file group and permissions for different corpus directories.

host=$(hostname)

# Set variables according to the current host.
if [ "$host" == "victorio.uit.no" ]
then
	corpdir="/usr/local/share/corp"
	corpus_group="corpus"
	free_group="cvs"
else
	corpdir="/Users/hoavda/Public/corp"
	corpus_group="staff"
	free_group="staff"
fi

orig="$corpdir/orig"
bound="$corpdir/bound"
free="$corpdir/free"

# Add different languages here, separated by newline.
langdirs="sme"

# Original documents in orig-hierarchy
# xsl-files that are under version control need not to be modified,
# since they are dependent on the directory settings only.
orig ()
{
	for dir in "$@"
	do
	  echo "fixing $orig/$dir..."

	  echo "fixing original-documents.."

	  find $orig/$dir -type f ! -name "*.xsl*" | while read I; \
		  do chgrp $corpus_group "$I"; \
		  chmod 0640 "$I"; done

	  echo "fixing xsl,v-files.."
	  find $orig/$dir -type f -name "*.xsl,v" | while read I; \
		  do chgrp $corpus_group "$I"; \
		  chmod 0440 "$I"; done

	  echo "fixing directories.."
	  find $orig/$dir -type d | while read I; \
		do chgrp $corpus_group "$I"; \
		chmod 0770 "$I"; done
	done
}

# xml-files in bound
gtbound () 
{
	for dir in "$@"
	do
	  echo "fixing $bound/$dir..."
	  find $bound/$dir -name "*.xml" |while read I; \
		  do chgrp $corpus_group "$I"; \
		  chmod 0660 "$I"; done

	  find $bound/$dir -type d |while read I; \
		  do chgrp $corpus_group "$I"; \
		  chmod 0770 "$I"; done
	 done
}

# Free xml-files in free
gtfree () 
{
	for dir in "$@"
	do
	  echo "fixing $free/$dir..."
	  find $free/$dir -name "*.xml" | while read I; \
		do chgrp $free_group "$I"; \
		chmod 0664 "$I"; done

	  find $free/$dir -type d | while read I; \
		do chgrp $free_group "$I"; \
		chmod 0775 "$I"; done
	done
}

if [ "$host" == "victorio.uit.no"  ]
then
	orig $langdirs
	gtbound $langdirs
	gtfree $langdirs
else
	gtbound $langdirs
fi

exit 0
