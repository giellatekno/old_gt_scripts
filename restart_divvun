#!/bin/bash

# search for either java.lang.OutOfMemoryError or BUILD FAILED
egrep 'java\.lang\.OutOfMemoryError|BUILD FAILED|Address already in use|Bad Cookie received'  $GTHOME/xtdoc/sd/divvun.log
#test -e .
if [ "$?" == "0" ]; then
	# Find the pid of the processes belonging to forrest started by user sd
	processes=(`ps aux | grep sd | grep java | grep -v grep | sed -e 's/^hoavda  *//'|cut -f1 -d" "`)
	# Try to quit them nicely
	i=0
	last_process=${#processes[*]}
	while [ $i -lt $last_process ]; do
		kill ${processes[$i]}
		echo "$i: ${processes[$i]}"
		let i++
	done
	# Wait a while, to let them finish cleanly
	sleep 30
	# Reset the array counter, then really kill the processes
	i=0
	while [ $i -lt $last_process ]; do
		kill -9 ${processes[$i]}
		echo "$i: ${processes[$i]}"
		let i++
	done
	sleep 10
	cd $GTHOME/xtdoc/sd
	# Give the current logfile a unique name, to be able to see what went wrong...
	mv divvun.log divvun.log-`date +%Y-%m-%d:%H%M`
	# Clean up old files
	$HOME/forrest/bin/forrest clean
	# Restart forrest
	$HOME/forrest/bin/forrest run -Dforrest.jvmargs=\"-Djava.awt.headless='true' -Dfile.encoding=utf-8\" > $GTHOME/xtdoc/sd/divvun.log 2>&1 &
fi

