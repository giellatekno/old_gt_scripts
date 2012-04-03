#!/usr/bin/env bash
# memusg -- Measure memory usage of processes
# Usage: memusg COMMAND [ARGS]...
#
# Author: Jaeho Shin <netj@sparcs.org>
# Created: 2010-08-16
#
# Source: https://gist.github.com/526585
#
# Heavily modified to be usable in a scripted and make-d environment
# To use this script to measure the memory consumption of a process
# as part of a makefile, do as follows:
#
# target:
#	process1 &
#	scripted-memusg.sh $(notdir process1) 2> maxmemusage.txt
#
# That is, make sure the process you want to measure is running in the
# background before starting the memory monitoring script.

set -um

# check input
[ $# -gt 0 ] || { sed -n '2,/^#$/ s/^# //p' <"$0"; exit 1; }

# TODO support more options: peak, footprint, sampling rate, etc.

pgid=`ps -c | grep $1 | cut -f1 -d" "`

# detect operating system and prepare measurement
case `uname` in
    Darwin|*BSD) sizes() { /bin/ps -o rss= $1; } ;;
    Linux) sizes() { /bin/ps -o rss= -$1; } ;;
    *) echo "`uname`: unsupported operating system" >&2; exit 2 ;;
esac

# monitor the memory usage in the background.
peak=0
while sizes=`sizes $pgid`
do
    set -- $sizes
    sample=$((${@/#/+}))
    let peak="sample > peak ? sample : peak"
    sleep 0.1
done
echo "memusg: peak=$peak kb" >&2
